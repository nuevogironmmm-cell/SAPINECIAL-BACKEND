import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/student_model.dart';
import '../services/teacher_service.dart';
import '../utils/animations.dart';

/// Panel de estudiantes para el Dashboard del docente
/// 
/// Muestra en tiempo real:
/// - Lista de estudiantes conectados
/// - Estado de cada estudiante (conectado, respondió, no respondió)
/// - Porcentaje acumulado por estudiante
/// - Clasificación con ícono
/// - Conteo general (respondieron / faltan)
class StudentDashboardPanel extends StatefulWidget {
  final ClassDashboardSummary? summary;
  final String? currentActivityId;
  final VoidCallback? onRefresh;
  final VoidCallback? onClose;
  final Function(String studentId)? onStudentTap;
  final bool isEmbedded; // Para cuando está dentro de un modal
  
  const StudentDashboardPanel({
    super.key,
    this.summary,
    this.currentActivityId,
    this.onRefresh,
    this.onClose,
    this.onStudentTap,
    this.isEmbedded = false,
  });

  @override
  State<StudentDashboardPanel> createState() => _StudentDashboardPanelState();
}

class _StudentDashboardPanelState extends State<StudentDashboardPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = widget.summary;
    
    // Contenido principal
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header (solo si no está embebido)
        if (!widget.isEmbedded)
          _buildHeader(theme, summary),
        
        // Estadísticas rápidas
        if (summary != null)
          _buildQuickStats(theme, summary),
        
        // Lista de estudiantes
        Expanded(
          child: summary == null || summary.connectedStudents.isEmpty
              ? _buildEmptyState(theme)
              : _buildStudentList(theme, summary),
        ),
      ],
    );
    
    // Si está embebido, solo devolver el contenido
    if (widget.isEmbedded) {
      return content;
    }
    
    // Si no, envolverlo en el contenedor decorado
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: content,
    );
  }
  
  Widget _buildHeader(ThemeData theme, ClassDashboardSummary? summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.groups_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Estudiantes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${summary?.totalStudents ?? 0}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          if (widget.onRefresh != null)
            IconButton(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              color: Colors.white54,
              tooltip: 'Actualizar',
            ),
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: const Icon(Icons.close),
              iconSize: 20,
              color: Colors.white54,
              tooltip: 'Cerrar panel',
            ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStats(ThemeData theme, ClassDashboardSummary summary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Respondieron
          Expanded(
            child: _buildStatItem(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              label: 'Respondieron',
              value: '${summary.respondedCount}',
            ),
          ),
          
          // Separador
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.1),
          ),
          
          // Faltan
          Expanded(
            child: _buildStatItem(
              icon: Icons.pending,
              iconColor: Colors.orange,
              label: 'Faltan',
              value: '${summary.notRespondedCount}',
            ),
          ),
          
          // Separador
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.1),
          ),
          
          // Porcentaje de respuesta
          Expanded(
            child: _buildStatItem(
              icon: Icons.pie_chart,
              iconColor: theme.colorScheme.primary,
              label: 'Respuesta',
              value: '${summary.responseRate.toStringAsFixed(0)}%',
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Opacity(
                opacity: 0.3 + (_pulseController.value * 0.4),
                child: child,
              );
            },
            child: Icon(
              Icons.person_search_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin estudiantes',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esperando conexiones...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStudentList(ThemeData theme, ClassDashboardSummary summary) {
    // Ordenar: respondieron primero, luego por porcentaje
    final students = List<Student>.from(summary.connectedStudents);
    students.sort((a, b) {
      // Primero por estado (respondidos arriba)
      if (a.status == StudentConnectionStatus.responded && 
          b.status != StudentConnectionStatus.responded) {
        return -1;
      }
      if (b.status == StudentConnectionStatus.responded && 
          a.status != StudentConnectionStatus.responded) {
        return 1;
      }
      // Luego por porcentaje (mayor arriba)
      return b.accumulatedPercentage.compareTo(a.accumulatedPercentage);
    });
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return FadeInSlide(
          delay: Duration(milliseconds: 50 * index),
          duration: const Duration(milliseconds: 300),
          child: _buildStudentCard(theme, student, index),
        );
      },
    );
  }
  
  Widget _buildStudentCard(ThemeData theme, Student student, int index) {
    final isResponded = student.status == StudentConnectionStatus.responded;
    final isDisconnected = student.status == StudentConnectionStatus.disconnected;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (student.status) {
      case StudentConnectionStatus.responded:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Respondió';
        break;
      case StudentConnectionStatus.notResponded:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pendiente';
        break;
      case StudentConnectionStatus.connected:
        statusColor = Colors.blue;
        statusIcon = Icons.circle;
        statusText = 'Conectado';
        break;
      case StudentConnectionStatus.disconnected:
        statusColor = Colors.grey;
        statusIcon = Icons.circle_outlined;
        statusText = 'Desconectado';
        break;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isDisconnected 
          ? Colors.grey.withOpacity(0.1)
          : Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isResponded 
              ? Colors.green.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: widget.onStudentTap != null
            ? () => widget.onStudentTap!(student.sessionId)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Posición/Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDisconnected
                        ? [Colors.grey, Colors.grey.shade700]
                        : [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Nombre y estado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            student.name,
                            style: TextStyle(
                              color: isDisconnected ? Colors.grey : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Mostrar medallas si tiene
                        if (student.medals.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            student.medalsDisplay,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                          ),
                        ),
                        // Mostrar racha si tiene
                        if (student.consecutiveCorrect > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🔥 ${student.consecutiveCorrect}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Porcentaje y Clasificación
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        student.classificationIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${student.accumulatedPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: _getPercentageColor(student.accumulatedPercentage),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  // Barra de progreso mini
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    height: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: student.accumulatedPercentage / 100,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(
                          _getPercentageColor(student.accumulatedPercentage),
                        ),
                      ),
                    ),
                ],
              ),
              
              // Botón de eliminar (Kick)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                onPressed: () => _confirmKickStudent(context, student),
                tooltip: 'Eliminar estudiante',
              ),
                ],
              ),
              
              // Botón de eliminar (Kick)
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.white38, size: 20),
                onPressed: () => _confirmKickStudent(context, student),
                tooltip: 'Eliminar estudiante',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmKickStudent(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('¿Eliminar estudiante?', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Seguro que deseas eliminar a ${student.name}?\nSe desconectará su sesión inmediatamente.',
          style: const TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TeacherService>().kickStudent(student.sessionId);
              
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Estudiante ${student.name} eliminado'))
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _confirmKickStudent(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar estudiante?'),
        content: Text('¿Seguro que deseas eliminar a ${student.name}? Se desconectará su sesión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Llamar al servicio para eliminar (necesitamos Provider aquí)
              // Como estamos dentro de un build method que usa theme, podemos usar context
               // IMPORTANTE: Asegurarse que StudentDashboardPanel tenga acceso a TeacherService 
               // Lo tiene en el contexto padre usualmente.
               // Pero mejor pasar un callback o usar context.read<TeacherService>()
               // Verificaremos imports.
               // Asumimos que se usa Provider.
               // Si no tengo acceso directo, debo agregarlo.
               try {
                 // Opción dinámica si no tengo el import
                 (context as dynamic).read(
                   // No puedo usar tipos genéricos dinámicos fácilmente en Dart sin import explicito
                   // Asumiré que TeacherService está disponible o pasaré el callback onKick
                 );
               } catch (e) {}
               // Mejor: Añadir onKick callback al widget o asumir Provider
               // Voy a asumir que puedo usar Provider.of<TeacherService>(context, listen: false)
               // Necesito importar provider.
               
               // SOLUCIÓN: Usar un callback nuevo en el widget.
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.lightGreen;
    if (percentage >= 50) return Colors.orange;
    return Colors.red.shade300;
  }
}

/// Widget compacto para mostrar resumen de estudiantes en la barra de navegación
class StudentSummaryBadge extends StatelessWidget {
  final int connectedCount;
  final int respondedCount;
  final int totalCount;
  
  const StudentSummaryBadge({
    super.key,
    required this.connectedCount,
    required this.respondedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Conectados
          Icon(
            Icons.people,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '$connectedCount',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Respondieron
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            '$respondedCount/$totalCount',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar notificación de nuevo estudiante
class StudentJoinedNotification extends StatelessWidget {
  final String studentName;
  final VoidCallback? onDismiss;
  
  const StudentJoinedNotification({
    super.key,
    required this.studentName,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInSlide(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              '$studentName se uni? a la clase',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
                iconSize: 16,
                color: Colors.white70,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

