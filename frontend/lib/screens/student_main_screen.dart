import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/student_service.dart';
import '../models/student_model.dart';
import '../utils/animations.dart';
import 'student_login_screen.dart';

/// Pantalla principal del estudiante
/// 
/// Muestra:
/// - Nombre del estudiante
/// - Actividad activa (si hay)
/// - Porcentaje acumulado
/// - Mensaje motivacional
/// - Campo de reflexión
/// 
/// NO muestra:
/// - Ranking de otros
/// - Respuestas correctas (hasta revelación)
/// - Clasificación negativa
class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen>
    with TickerProviderStateMixin {
  final _reflectionController = TextEditingController();
  final _scrollController = ScrollController();
  
  // Estado para múltiples actividades
  final Map<String, int?> _selectedAnswers = {}; // activityId -> selectedIndex
  final Map<String, bool> _submittingActivities = {}; // activityId -> isSubmitting
  final Map<String, DateTime> _activityStartTimes = {}; // activityId -> startTime
  
  bool _showReflectionForm = false;
  bool _reflectionSent = false;
  
  // Legacy - mantener compatibilidad
  int? _selectedAnswer;
  bool _isSubmitting = false;
  DateTime? _activityStartTime;
  
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  StreamSubscription? _activitySubscription;
  StreamSubscription? _newActivitySubscription;
  StreamSubscription? _answerResultSubscription;
  StreamSubscription? _answerRevealSubscription;
  
  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    
    // Escuchar cambios de actividad
    final studentService = context.read<StudentService>();
    _activitySubscription = studentService.activityStream.listen((activity) {
      if (activity != null && activity.isActive) {
        setState(() {
          _selectedAnswer = null;
          _activityStartTime = DateTime.now();
        });
      }
    });
    
    // Escuchar nuevas actividades (para notificaciones)
    _newActivitySubscription = studentService.newActivityStream.listen(_onNewActivity);
    
    // Escuchar resultados de respuestas (feedback inmediato)
    _answerResultSubscription = studentService.answerResultStream.listen(_onAnswerResult);
    
    // Escuchar revelación de respuestas
    _answerRevealSubscription = studentService.answerRevealedStream.listen(_onAnswerRevealed);
    
    _progressController.forward();
  }
  
  @override
  void dispose() {
    _reflectionController.dispose();
    _scrollController.dispose();
    _progressController.dispose();
    _activitySubscription?.cancel();
    _newActivitySubscription?.cancel();
    _answerResultSubscription?.cancel();
    _answerRevealSubscription?.cancel();
    super.dispose();
  }
  
  /// Cuando llega una nueva actividad
  void _onNewActivity(StudentActivity activity) {
    // Vibración para notificar
    HapticFeedback.mediumImpact();
    
    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.assignment_turned_in, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📢 ¡Nueva actividad!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    activity.title ?? activity.question,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  /// Cuando se recibe resultado inmediato de la respuesta
  void _onAnswerResult(AnswerResult result) {
    // Vibración de feedback
    if (result.isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    setState(() {});
  }
  
  /// Cuando el docente revela la respuesta correcta
  void _onAnswerRevealed(AnswerRevealEvent event) {
    // Vibración de notificación
    HapticFeedback.mediumImpact();
    
    // Mostrar notificación con resultado
    final wasCorrect = event.wasCorrect;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              wasCorrect == true
                  ? Icons.check_circle
                  : (wasCorrect == false ? Icons.cancel : Icons.info),
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wasCorrect == true
                        ? '🎉 ¡Respuesta correcta!'
                        : (wasCorrect == false
                            ? '❌ Respuesta incorrecta'
                            : '📝 Respuesta revelada'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    wasCorrect == true
                        ? '¡Excelente trabajo!'
                        : (wasCorrect == false
                            ? 'La respuesta correcta era la opción ${_getLetterForIndex(event.correctIndex)}'
                            : 'No enviaste respuesta'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: wasCorrect == true
            ? Colors.green.shade700
            : (wasCorrect == false ? Colors.red.shade700 : Colors.orange.shade700),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    
    setState(() {});
  }
  
  /// Obtiene la letra correspondiente a un índice de opción
  String _getLetterForIndex(int index) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return index < letters.length ? letters[index] : '${index + 1}';
  }
  
  /// Selecciona una respuesta para una actividad específica
  void _selectAnswerForActivity(String activityId, int answerIndex) {
    setState(() {
      _selectedAnswers[activityId] = answerIndex;
      // Registrar tiempo de inicio si no existe
      _activityStartTimes.putIfAbsent(activityId, () => DateTime.now());
    });
  }
  
  /// Envía la respuesta para una actividad específica
  Future<void> _submitAnswerForActivity(String activityId) async {
    final selectedAnswer = _selectedAnswers[activityId];
    if (selectedAnswer == null) return;
    
    final studentService = context.read<StudentService>();
    
    // Calcular tiempo de respuesta
    int? responseTimeMs;
    final startTime = _activityStartTimes[activityId];
    if (startTime != null) {
      responseTimeMs = DateTime.now().difference(startTime).inMilliseconds;
    }
    
    setState(() => _submittingActivities[activityId] = true);
    
    final success = await studentService.submitAnswerForActivity(
      activityId,
      selectedAnswer,
      responseTimeMs: responseTimeMs,
    );
    
    setState(() => _submittingActivities[activityId] = false);
    
    if (success) {
      // Animación de éxito
      _progressController.reset();
      _progressController.forward();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ ¡Respuesta enviada!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Tu respuesta ha sido registrada correctamente',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '❌ Error al enviar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      studentService.errorMessage ?? 'Intenta de nuevo',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
  
  // Legacy method - mantener compatibilidad
  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null) return;
    
    final studentService = context.read<StudentService>();
    
    // Calcular tiempo de respuesta
    int? responseTimeMs;
    if (_activityStartTime != null) {
      responseTimeMs = DateTime.now()
          .difference(_activityStartTime!)
          .inMilliseconds;
    }
    
    setState(() => _isSubmitting = true);
    
    final success = await studentService.submitAnswer(
      _selectedAnswer!,
      responseTimeMs: responseTimeMs,
    );
    
    setState(() => _isSubmitting = false);
    
    if (success) {
      // Animación de éxito
      _progressController.reset();
      _progressController.forward();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ ¡Respuesta enviada!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Tu respuesta ha sido registrada',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text('❌ Error al enviar respuesta'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
  
  Future<void> _submitReflection() async {
    final content = _reflectionController.text.trim();
    if (content.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La reflexión debe tener al menos 10 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final studentService = context.read<StudentService>();
    
    setState(() => _isSubmitting = true);
    
    final success = await studentService.submitReflection(
      'reflexión de clase',
      content,
    );
    
    setState(() => _isSubmitting = false);
    
    if (success) {
      setState(() {
        _reflectionSent = true;
        _showReflectionForm = false;
      });
      _reflectionController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reflexión enviada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void _logout() {
    final studentService = context.read<StudentService>();
    studentService.clearSavedName();
    studentService.disconnect();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StudentLoginScreen()),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentService>(
      builder: (context, studentService, _) {
        final student = studentService.currentStudent;
        final activities = studentService.activeActivities;
        final hasAnyActivity = activities.isNotEmpty;
        final pendingCount = studentService.pendingActivitiesCount;
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  const Color(0xFF1a1a2e),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header con info del estudiante
                  _buildHeader(studentService, student),
                  
                  // Contenido principal
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Tarjeta de progreso
                          _buildProgressCard(student),
                          
                          const SizedBox(height: 24),
                          
                          // Contador de actividades pendientes
                          if (hasAnyActivity)
                            _buildActivitiesHeader(activities.length, pendingCount),
                          
                          const SizedBox(height: 16),
                          
                          // MOSTRAR TODAS LAS ACTIVIDADES ACTIVAS
                          if (hasAnyActivity)
                            ...activities.map((activity) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildActivityCard(
                                activity, 
                                studentService.hasRespondedActivity(activity.id),
                              ),
                            ))
                          else
                            _buildWaitingCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Sección de reflexión
                          _buildReflectionSection(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Footer con conexión
                  _buildConnectionStatus(studentService),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(StudentService service, Student? student) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                student?.name.isNotEmpty == true
                    ? student!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student?.name ?? 'Estudiante',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'ID: ${student?.sessionId ?? '---'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          
          // Botón de salir
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            color: Colors.white54,
            tooltip: 'Salir',
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressCard(Student? student) {
    final theme = Theme.of(context);
    final percentage = student?.accumulatedPercentage ?? 0;
    final message = student?.motivationalMessage ?? '';
    final icon = student?.classificationIcon ?? '📚';
    final medals = student?.medals ?? [];
    
    return FadeInSlide(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.2),
              theme.colorScheme.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            // Porcentaje grande
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 12),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, _) {
                    return Text(
                      '${(percentage * _progressAnimation.value).toStringAsFixed(0)}%',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Barra de progreso
            AnimatedProgressBar(
              progress: percentage / 100,
              height: 12,
              backgroundColor: Colors.white.withOpacity(0.1),
              progressColor: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            
            const SizedBox(height: 16),
            
            // Mensaje motivacional
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            
            // SECCIÓN DE MEDALLAS
            if (medals.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              _buildMedalsDisplay(medals),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Widget que muestra las medallas del estudiante
  Widget _buildMedalsDisplay(List<Medal> medals) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Título
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded, 
              color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Mis Logros',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.amber.shade300,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${medals.length}',
                style: TextStyle(
                  color: Colors.amber.shade300,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Grid de medallas
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: medals.map((medal) => _buildMedalBadge(medal)).toList(),
        ),
      ],
    );
  }
  
  /// Widget de insignia de medalla individual
  Widget _buildMedalBadge(Medal medal) {
    return Tooltip(
      message: '${medal.name}\n${medal.description}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getMedalColors(medal.type),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getMedalColors(medal.type).first.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              medal.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 6),
            Text(
              medal.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Obtiene los colores de gradiente según el tipo de medalla
  List<Color> _getMedalColors(MedalType type) {
    switch (type) {
      case MedalType.gold:
      case MedalType.champion:
      case MedalType.crown:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)];
      case MedalType.silver:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)];
      case MedalType.bronze:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      case MedalType.perfectScore:
        return [Colors.purple.shade400, Colors.purple.shade700];
      case MedalType.speedster:
      case MedalType.earlyBird:
        return [Colors.blue.shade400, Colors.blue.shade700];
      case MedalType.consistent:
      case MedalType.scholar:
        return [Colors.green.shade400, Colors.green.shade700];
      case MedalType.fire:
        return [Colors.orange.shade400, Colors.red.shade600];
      case MedalType.star:
      case MedalType.improver:
        return [Colors.amber.shade400, Colors.amber.shade700];
    }
  }
  
  /// Encabezado con contador de actividades
  Widget _buildActivitiesHeader(int totalCount, int pendingCount) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividades Disponibles',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  pendingCount > 0
                      ? '$pendingCount de $totalCount pendientes'
                      : '¡Todas completadas!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: pendingCount > 0 
                        ? Colors.orange.shade300 
                        : Colors.green.shade300,
                  ),
                ),
              ],
            ),
          ),
          // Badge con contador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pendingCount > 0 
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$totalCount',
              style: TextStyle(
                color: pendingCount > 0 ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityCard(StudentActivity activity, bool hasResponded) {
    final theme = Theme.of(context);
    
    return FadeInSlide(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasResponded
                ? Colors.green.withOpacity(0.5)
                : theme.colorScheme.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de actividad
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasResponded
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasResponded
                            ? Icons.check_circle
                            : Icons.pending,
                        size: 16,
                        color: hasResponded ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasResponded ? 'Respondida' : 'Activa',
                        style: TextStyle(
                          color: hasResponded ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${activity.percentageValue.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Título de la actividad (si existe)
            if (activity.title != null && activity.title!.isNotEmpty) ...[
              Text(
                activity.title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Cita bíblica / Contenido del slide (si existe)
            if (activity.slideContent != null && activity.slideContent!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '"${activity.slideContent!}"',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    // Referencia bíblica (si existe)
                    if (activity.biblicalReference != null && activity.biblicalReference!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        activity.biblicalReference!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Pregunta
            Text(
              activity.question,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Opciones
            if (!hasResponded)
              ...activity.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                final isSelected = _selectedAnswers[activity.id] == index;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ScaleIn(
                    delay: Duration(milliseconds: 100 * index),
                    child: _buildOptionButton(
                      index: index,
                      text: option,
                      isSelected: isSelected,
                      onTap: () {
                        _selectAnswerForActivity(activity.id, index);
                      },
                    ),
                  ),
                );
              })
            else
              // NUEVO: Feedback detallado de la respuesta
              _buildAnswerFeedback(context, activity),
            
            // Botón de enviar
            if (!hasResponded && _selectedAnswers[activity.id] != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AnimatedButton(
                  onPressed: (_submittingActivities[activity.id] == true) 
                      ? null 
                      : () => _submitAnswerForActivity(activity.id),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade600,
                          Colors.green.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: (_submittingActivities[activity.id] == true)
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Enviar respuesta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionButton({
    required int index,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Letra de opción
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    letters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Texto de opción
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Indicador de selección
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Construye el feedback visual de la respuesta enviada
  Widget _buildAnswerFeedback(BuildContext context, StudentActivity activity) {
    final theme = Theme.of(context);
    final studentService = context.read<StudentService>();
    final answerResult = studentService.getAnswerResult(activity.id);
    
    // Si aún no hay resultado (esperando confirmación del servidor)
    if (answerResult == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Procesando respuesta...',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }
    
    // Si la respuesta ya fue revelada por el docente
    if (answerResult.isRevealed) {
      final isCorrect = answerResult.isCorrect;
      final correctIndex = answerResult.correctIndex ?? 0;
      final selectedIndex = answerResult.selectedIndex;
      
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCorrect
                ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)]
                : [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCorrect ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con resultado
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCorrect ? '🎉 ¡Correcto!' : '❌ Incorrecto',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isCorrect 
                            ? '¡Excelente trabajo! +${answerResult.pointsEarned.toStringAsFixed(0)}%'
                            : 'La respuesta correcta era la opción ${_getLetterForIndex(correctIndex)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            
            // Mostrar opciones con indicadores
            ...activity.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isCorrectOption = index == correctIndex;
              final wasSelected = index == selectedIndex;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    // Indicador de correcto/incorrecto
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCorrectOption
                            ? Colors.green.withOpacity(0.3)
                            : (wasSelected ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          isCorrectOption
                              ? Icons.check
                              : (wasSelected ? Icons.close : null),
                          color: isCorrectOption ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Texto de la opción
                    Expanded(
                      child: Text(
                        '${_getLetterForIndex(index)}. $option',
                        style: TextStyle(
                          color: isCorrectOption
                              ? Colors.green
                              : (wasSelected ? Colors.red.shade300 : Colors.white54),
                          fontWeight: isCorrectOption ? FontWeight.bold : FontWeight.normal,
                          decoration: wasSelected && !isCorrectOption
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    // Badge de selección
                    if (wasSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (wasSelected && isCorrectOption)
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tu respuesta',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }
    
    // Si envió respuesta pero aún NO se reveló (estado intermedio)
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ ¡Respuesta enviada!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Seleccionaste opción ${_getLetterForIndex(answerResult.selectedIndex)}. '
                  'Espera a que el docente revele la respuesta correcta.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWaitingCard() {
    final theme = Theme.of(context);
    
    return FadeInSlide(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            PulseAnimation(
              child: Icon(
                Icons.hourglass_empty_rounded,
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Esperando actividad...',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'El docente aún no ha habilitado\nuna actividad para responder.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWaitingForResultsCard() {
    final theme = Theme.of(context);
    
    return FadeInSlide(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            SuccessCelebration(
              celebrate: true,
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              '¡Respuesta enviada!',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Esperando a que el docente\nrevele los resultados.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReflectionSection() {
    final theme = Theme.of(context);
    
    return FadeInSlide(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.edit_note_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Mi reflexión',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!_showReflectionForm && !_reflectionSent)
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showReflectionForm = true);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Escribir'),
                  ),
              ],
            ),
            
            if (_reflectionSent) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Reflexión enviada al docente',
                        style: TextStyle(color: Colors.green.shade300),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _reflectionSent = false;
                          _showReflectionForm = true;
                        });
                      },
                      child: const Text('Escribir otra'),
                    ),
                  ],
                ),
              ),
            ] else if (_showReflectionForm) ...[
              const SizedBox(height: 16),
              
              // Campo de texto
              TextField(
                controller: _reflectionController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '¿Qué aprendiste hoy? ¿Qué te llamó la atención?',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() => _showReflectionForm = false);
                      _reflectionController.clear();
                    },
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitReflection,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: const Text('Enviar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'Comparte tus pensamientos sobre la clase.\nEl docente podrá leer tu reflexión.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildConnectionStatus(StudentService service) {
    final isConnected = service.isConnected;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Conectado' : 'Desconectado',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

