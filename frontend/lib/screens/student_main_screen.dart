import 'package:flutter/material.dart';
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
/// - Campo de reflexi?n
/// 
/// NO muestra:
/// - Ranking de otros
/// - Respuestas correctas (hasta revelaci?n)
/// - Clasificaci?n negativa
class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen>
    with TickerProviderStateMixin {
  final _reflectionController = TextEditingController();
  final _scrollController = ScrollController();
  
  int? _selectedAnswer;
  bool _isSubmitting = false;
  bool _showReflectionForm = false;
  bool _reflectionSent = false;
  DateTime? _activityStartTime;
  
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  StreamSubscription? _activitySubscription;
  
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
    
    _progressController.forward();
  }
  
  @override
  void dispose() {
    _reflectionController.dispose();
    _scrollController.dispose();
    _progressController.dispose();
    _activitySubscription?.cancel();
    super.dispose();
  }
  
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
      // Animaci?n de éxito
      _progressController.reset();
      _progressController.forward();
    }
  }
  
  Future<void> _submitReflection() async {
    final content = _reflectionController.text.trim();
    if (content.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La reflexi?n debe tener al menos 10 caracteres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final studentService = context.read<StudentService>();
    
    setState(() => _isSubmitting = true);
    
    final success = await studentService.submitReflection(
      'Reflexi?n de clase',
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
          content: Text('? Reflexi?n enviada correctamente'),
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
        final activity = studentService.currentActivity;
        final hasResponded = studentService.hasResponded;
        
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
                          
                          // Actividad actual o mensaje de espera
                          if (activity != null && activity.isActive)
                            _buildActivityCard(activity, hasResponded)
                          else if (hasResponded)
                            _buildWaitingForResultsCard()
                          else
                            _buildWaitingCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Secci?n de reflexi?n
                          _buildReflectionSection(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Footer con conexi?n
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
          
          // Bot?n de salir
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
    final icon = student?.classificationIcon ?? '??';
    
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
          ],
        ),
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
                final isSelected = _selectedAnswer == index;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ScaleIn(
                    delay: Duration(milliseconds: 100 * index),
                    child: _buildOptionButton(
                      index: index,
                      text: option,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedAnswer = index);
                      },
                    ),
                  ),
                );
              })
            else
              // Mensaje de respuesta enviada
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '?Respuesta enviada!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Espera a que el docente revele la respuesta correcta.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Bot?n de enviar
            if (!hasResponded && _selectedAnswer != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AnimatedButton(
                  onPressed: _isSubmitting ? null : _submitAnswer,
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
                      child: _isSubmitting
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
              // Letra de opci?n
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
              
              // Texto de opci?n
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
              
              // Indicador de selecci?n
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
              'El docente a?n no ha habilitado\nuna actividad para responder.',
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
              '?Respuesta enviada!',
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
                  'Mi Reflexi?n',
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
                        'Reflexi?n enviada al docente',
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
                  hintText: '?Qué aprendiste hoy? ?Qué te llam? la atenci?n?',
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
                'Comparte tus pensamientos sobre la clase.\nEl docente podr? leer tu reflexi?n.',
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
