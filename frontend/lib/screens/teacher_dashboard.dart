import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../models/class_session_model.dart';
import '../models/student_model.dart';
import '../data/mock_data.dart';
import '../utils/animations.dart';
import '../services/teacher_service.dart';
import '../services/export_service.dart';
import '../widgets/student_dashboard_panel.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with TickerProviderStateMixin {
  ClassSession session = mockClassSession;
  int currentBlockIndex = 0;
  int currentSlideIndex = 0;
  Map<String, List<int>> studentSelections = {};
  
  // MODO PROYECTOR - Pantalla completa y letras grandes
  bool _isProjectorMode = true; // Activado por defecto
  bool _showSidebar = true;
  bool _showStudentPanel = false; // Panel de estudiantes

  // ESTADO PARA WORD PUZZLE
  List<String> _puzzleAvailableWords = [];
  List<String> _puzzleSelectedWords = [];
  bool? _puzzleIsCorrect;

  // ============================================================
  // ESTADO PARA ANIMACIONES EDUCATIVAS
  // ============================================================
  bool _showCelebration = false;  // Celebración por respuesta correcta
  bool _showShake = false;        // Sacudida por respuesta incorrecta
  bool _slideTransitionActive = false;
  int _slideDirection = 1; // 1 = siguiente, -1 = anterior
  
  // ============================================================
  // ESTADO PARA ACTIVIDADES DE ESTUDIANTES
  // ============================================================
  bool _activityEnabledForStudents = false;
  
  // Mapa de actividades habilitadas por ID de slide
  final Map<String, bool> _enabledActivities = {};
  
  // Controladores de animación
  late AnimationController _slideAnimController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Escuchar atajos de teclado
    RawKeyboard.instance.addListener(_handleKeyPress);
    
    // Conectar al servicio de docente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectTeacherService();
    });
    
    // Inicializar controlador de animación para transiciones de slides
    _slideAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideAnimController, curve: Curves.easeInOut),
    );
  }

  Future<void> _connectTeacherService() async {
    final teacherService = context.read<TeacherService>();
    await teacherService.connect();
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyPress);
    _slideAnimController.dispose();
    super.dispose();
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight || 
          event.logicalKey == LogicalKeyboardKey.space) {
        _nextSlide();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _prevSlide();
      } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        _toggleProjectorMode();
      } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
        setState(() => _showSidebar = !_showSidebar);
      } else if (event.logicalKey == LogicalKeyboardKey.keyE) {
        // Mostrar/ocultar panel de estudiantes
        setState(() => _showStudentPanel = !_showStudentPanel);
      } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
        // Activar/desactivar actividad para estudiantes
        _toggleActivityForStudents();
      } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
        final currentBlock = session.blocks[currentBlockIndex];
        final currentSlide = currentBlock.slides[currentSlideIndex];
        if (currentSlide.type == SlideType.activity) {
          _revealAnswer();
        }
      }
    }
  }
  
  /// Verifica si una actividad específica está habilitada
  bool _isActivityEnabled(String slideId) {
    return _enabledActivities[slideId] ?? false;
  }
  
  /// Activa o desactiva la actividad actual para estudiantes
  void _toggleActivityForStudents() {
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    
    if (currentSlide.type != SlideType.activity || currentSlide.activity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay actividad en esta diapositiva'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    _toggleActivityForSlide(currentSlide);
  }
  
  /// Activa o desactiva una actividad específica por su slide
  void _toggleActivityForSlide(Slide slide) {
    if (slide.type != SlideType.activity || slide.activity == null) return;
    
    final teacherService = context.read<TeacherService>();
    final activity = slide.activity!;
    final slideId = slide.id;
    final isCurrentlyEnabled = _enabledActivities[slideId] ?? false;
    
    if (!isCurrentlyEnabled) {
      // Extraer solo "Actividad N" del título para no revelar la respuesta
      String safeTitle = slide.title;
      final activityMatch = RegExp(r'^(Actividad\s*\d+)').firstMatch(slide.title);
      if (activityMatch != null) {
        safeTitle = activityMatch.group(1)!;  // Solo "Actividad 1", "Actividad 2", etc.
      }
      
      // Registrar y activar
      teacherService.registerActivity(
        activityId: slideId,
        question: activity.question,
        options: activity.options,
        correctIndex: activity.correctOptionIndex,
        percentageValue: 10.0,
        activityType: activity.type == ActivityType.multipleChoice 
            ? 'multipleChoice' 
            : activity.type == ActivityType.wordPuzzle 
                ? 'wordPuzzle' 
                : 'multipleChoice',
        title: safeTitle,  // Título sin revelar respuesta
        slideContent: slide.content,  // Contenido (la cita bíblica)
        biblicalReference: slide.biblicalReference,  // Referencia bíblica
      );
      
      // Pequeño delay para asegurar registro
      Future.delayed(const Duration(milliseconds: 100), () {
        teacherService.unlockActivity(slideId);
      });
      
      setState(() {
        _enabledActivities[slideId] = true;
        _activityEnabledForStudents = true;  // Mantener compatibilidad
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('¡$safeTitle habilitada para ${teacherService.connectedStudentsCount} estudiantes!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Desactivar esta actividad específica
      teacherService.lockSpecificActivity(slideId);
      setState(() {
        _enabledActivities[slideId] = false;
        // Verificar si hay alguna actividad habilitada
        _activityEnabledForStudents = _enabledActivities.values.any((enabled) => enabled);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock, color: Colors.white),
              SizedBox(width: 8),
              Text('Actividad bloqueada para estudiantes'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// Cierra TODAS las actividades activas de una vez
  void _lockAllActivities() {
    final teacherService = context.read<TeacherService>();
    teacherService.lockAllActivities();
    setState(() => _activityEnabledForStudents = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Todas las actividades han sido cerradas'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  /// Reinicia el progreso de TODOS los estudiantes (función de administrador)
  void _resetAllStudentsProgress() {
    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                '⚠️ Reiniciar Progreso',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Esta acción eliminará:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 12),
              Text('• Todas las respuestas de estudiantes', style: TextStyle(color: Colors.red)),
              Text('• Todo el progreso acumulado', style: TextStyle(color: Colors.red)),
              Text('• Todas las lecciones completadas', style: TextStyle(color: Colors.red)),
              Text('• Todos los logros obtenidos', style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              Text(
                '¿Estás seguro de continuar?',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _executeResetAllStudents();
              },
              child: const Text('SÍ, REINICIAR TODO', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  
  /// Ejecuta el reinicio de progreso de estudiantes
  void _executeResetAllStudents() {
    final teacherService = context.read<TeacherService>();
    teacherService.resetAllStudentsProgress();
    
    // Limpiar estado local también
    setState(() {
      _activityEnabledForStudents = false;
      _enabledActivities.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.restart_alt, color: Colors.white),
            SizedBox(width: 8),
            Text('✅ Progreso de todos los estudiantes reiniciado'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  /// Exporta los resultados a Excel
  Future<void> _exportToExcel() async {
    final teacherService = context.read<TeacherService>();
    final students = teacherService.connectedStudents;
    
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 8),
              Text('No hay estudiantes para exportar'),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando Excel...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // Convertir estudiantes a formato exportable
    final exportData = students.map((s) => {
      'name': s.name,
      'percentage': s.accumulatedPercentage,
      'status': s.status.name,
      'responses': s.responses.map((key, value) => MapEntry(key, value.toJson())),
      'lastActivity': s.lastActivityAt?.toString() ?? '-',
      'medals': s.medals.map((m) => m.toJson()).toList(),
      'consecutiveCorrect': s.consecutiveCorrect,
      'totalActivitiesAnswered': s.totalActivitiesAnswered,
      'classification': s.classification.name,
      'classificationIcon': s.classificationIcon,
    }).toList();
    
    final success = await ExportService.exportStudentResults(
      students: exportData,
      sessionTitle: session.title,
      context: context,
    );
    
    // Cerrar diálogo de carga
    if (mounted) Navigator.of(context).pop();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('¡Excel exportado exitosamente!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error al exportar Excel'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  /// Revela la respuesta a todos los estudiantes
  void _revealAnswerToStudents() {
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    
    if (currentSlide.type == SlideType.activity) {
      final teacherService = context.read<TeacherService>();
      teacherService.revealAnswer(currentSlide.id);
    }
  }

  void _toggleProjectorMode() {
    setState(() {
      _isProjectorMode = !_isProjectorMode;
      if (_isProjectorMode) {
        _showSidebar = false;
      } else {
        _showSidebar = true;
      }
    });
  }

  void _nextSlide() {
    _slideDirection = 1;
    setState(() {
      final currentBlock = session.blocks[currentBlockIndex];
      if (currentSlideIndex < currentBlock.slides.length - 1) {
        currentSlideIndex++;
      } else if (currentBlockIndex < session.blocks.length - 1) {
        currentBlockIndex++;
        currentSlideIndex = 0;
      }
      
      // Chequear si hay que iniciar puzzle en la nueva slide
      final nextBlock = session.blocks[currentBlockIndex];
      final nextSlide = nextBlock.slides[currentSlideIndex];
      if (nextSlide.activity?.type == ActivityType.wordPuzzle) {
        _initPuzzle();
      }
      
      // Resetear estados de animación de celebración/error
      _showCelebration = false;
      _showShake = false;
    });
  }

  void _prevSlide() {
    _slideDirection = -1;
    setState(() {
      if (currentSlideIndex > 0) {
        currentSlideIndex--;
      } else if (currentBlockIndex > 0) {
        currentBlockIndex--;
        currentSlideIndex = session.blocks[currentBlockIndex].slides.length - 1;
      }
      
      // Chequear si hay que iniciar puzzle
      final prevBlock = session.blocks[currentBlockIndex];
      final prevSlide = prevBlock.slides[currentSlideIndex];
      if (prevSlide.activity?.type == ActivityType.wordPuzzle) {
        _initPuzzle();
      }
    });
  }

  void _jumpToSlide(int targetIndex) {
    final currentBlock = session.blocks[currentBlockIndex];
    if (targetIndex < 0 || targetIndex >= currentBlock.slides.length) return;
    setState(() {
      currentSlideIndex = targetIndex;
      
      final slide = currentBlock.slides[currentSlideIndex];
      if (slide.activity?.type == ActivityType.wordPuzzle) {
        _initPuzzle();
      }
    });
  }

  Future<void> _printCurrentSlide() async {
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  currentSlide.title,
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  currentSlide.content,
                  style: const pw.TextStyle(fontSize: 16, lineSpacing: 2),
                ),
                if (currentSlide.biblicalReference != null) ...[
                  pw.SizedBox(height: 16),
                  pw.Text(
                    currentSlide.biblicalReference!,
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.brown600),
                  ),
                ],
                pw.SizedBox(height: 16),
                pw.Text(
                  'Bloque: ${currentBlock.title} | Diapositiva ${currentSlideIndex + 1} de ${currentBlock.slides.length}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  // --- LOGICA DE PUZZLE ---

  void _initPuzzle() {
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    if (currentSlide.activity?.type == ActivityType.wordPuzzle) {
      // Usar addPostFrameCallback para evitar conflictos de setState durante el build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           setState(() {
            _puzzleAvailableWords = List.from(currentSlide.activity!.options);
            _puzzleSelectedWords = [];
            _puzzleIsCorrect = null;
          }); 
        }
      });
    }
  }

  void _onPuzzleWordTap(String word, bool isSelected) {
    setState(() {
      if (isSelected) {
        _puzzleSelectedWords.remove(word);
        _puzzleAvailableWords.add(word);
      } else {
        _puzzleAvailableWords.remove(word);
        _puzzleSelectedWords.add(word);
      }
      _puzzleIsCorrect = null; 
    });
  }

  void _checkPuzzle() {
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    final correctOrder = currentSlide.activity?.correctWordOrder;

    if (correctOrder != null) {
      setState(() {
        bool isCorrect = true;
        if (_puzzleSelectedWords.length != correctOrder.length) {
          isCorrect = false;
        } else {
          for (int i = 0; i < correctOrder.length; i++) {
            if (_puzzleSelectedWords[i] != correctOrder[i]) {
              isCorrect = false;
              break;
            }
          }
        }
        _puzzleIsCorrect = isCorrect;
        
        // Activar animación según resultado
        if (isCorrect) {
          _showCelebration = true;
          _showShake = false;
        } else {
          _showShake = true;
          _showCelebration = false;
          // Resetear shake después de la animación
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) setState(() => _showShake = false);
          });
        }
      });
    }
  }

  void _resetPuzzle() {
    // Re-iniciar manualmente para evitar el postframecallback asincrono si es interaccion de usuario
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    setState(() {
      _puzzleAvailableWords = List.from(currentSlide.activity!.options);
      _puzzleSelectedWords = [];
      _puzzleIsCorrect = null;
      _showCelebration = false;
      _showShake = false;
      // Resetear también el estado de revelación para poder intentar de nuevo
      if (currentSlide.activity != null) {
        currentSlide.activity!.isRevealed = false;
      }
    });
  }

  void _revealAnswer() {
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    if (currentSlide.type == SlideType.activity && currentSlide.activity != null) {
      setState(() {
        currentSlide.activity!.isRevealed = true;
      });
    }
  }

  void _selectOption(String slideId, int optionIndex) {
    setState(() {
      if (!studentSelections.containsKey(slideId)) {
        studentSelections[slideId] = [];
      }
      final selections = studentSelections[slideId]!;
      if (selections.length < 5) {
        selections.add(optionIndex);
      }
    });
  }

  void _resetSelections(String slideId) {
    setState(() {
      studentSelections[slideId] = [];
      final currentBlock = session.blocks[currentBlockIndex];
      final currentSlide = currentBlock.slides[currentSlideIndex];
      if (currentSlide.activity != null) {
        currentSlide.activity!.isRevealed = false;
      }
    });
  }

  Widget _buildSlideImage(String url) {
    final isNetwork = url.startsWith('http');
    final imageWidget = isNetwork
        ? Image.network(
            url,
            height: _isProjectorMode ? 350 : 250,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
          )
        : Image.asset(
            url,
            height: _isProjectorMode ? 350 : 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: imageWidget,
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: _isProjectorMode ? 300 : 200,
      child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 80),
    );
  }

  // Tamaños de fuente para modo proyector
  double get _titleFontSize => _isProjectorMode ? 72 : 52;
  double get _titleWithImageFontSize => _isProjectorMode ? 60 : 44;
  double get _contentFontSize => _isProjectorMode ? 48 : 34;
  double get _contentWithImageFontSize => _isProjectorMode ? 40 : 28;
  double get _referenceFontSize => _isProjectorMode ? 36 : 24;
  double get _questionFontSize => _isProjectorMode ? 44 : 32;
  double get _optionFontSize => _isProjectorMode ? 36 : 24;

  @override
  Widget build(BuildContext context) {
    if (session.blocks.isEmpty) {
      return const Scaffold(body: Center(child: Text('Cargando datos...')));
    }

    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027), 
              Color(0xFF203A43), 
              Color(0xFF2C5364)
            ],
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // BARRA LATERAL (solo en desktop, oculta en modo proyector)
                if (_showSidebar && !isMobile)
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      border: const Border(right: BorderSide(color: Colors.white10)),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            "LITERATURA\nSAPIENCIAL", 
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cinzel(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold, 
                              color: const Color(0xFFC5A065)
                            )
                          ),
                          const Divider(color: Colors.white24, height: 40),
                          Expanded(
                            child: ListView.builder(
                              itemCount: session.blocks.length,
                              itemBuilder: (context, idx) {
                                final block = session.blocks[idx];
                                final isSelected = idx == currentBlockIndex;
                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: Colors.white10,
                                  leading: Icon(
                                    Icons.menu_book, 
                                    color: isSelected ? const Color(0xFFC5A065) : Colors.white24
                                  ),
                                  title: Text(
                                    block.title,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white60,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      currentBlockIndex = idx;
                                      currentSlideIndex = 0;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // AREA PRINCIPAL
                Expanded(
                  child: Stack(
                    children: [
                      // CONTENIDO
                      _buildSlideContent(currentSlide),
                      
                      // BARRA SUPERIOR DE HERRAMIENTAS - Responsive para móvil
                      Positioned(
                        top: isMobile ? 10 : 20,
                        left: isMobile ? 10 : null,
                        right: isMobile ? 10 : 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: isMobile ? 4 : 8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(isMobile ? 15 : 30),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: isMobile 
                            ? _buildMobileToolbar(currentSlide, currentBlock)
                            : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _toggleProjectorMode,
                                    icon: Icon(
                                      _isProjectorMode ? Icons.fullscreen_exit : Icons.fullscreen,
                                      color: _isProjectorMode ? const Color(0xFFC5A065) : Colors.white70,
                                      size: _isProjectorMode ? 32 : 24,
                                    ),
                                    tooltip: _isProjectorMode ? "Salir modo proyector (F)" : "Modo proyector (F)",
                                  ),
                                  IconButton(
                                    onPressed: () => _printCurrentSlide(),
                                    icon: Icon(Icons.print, 
                                      color: Colors.white70,
                                      size: _isProjectorMode ? 28 : 24,
                                    ),
                                    tooltip: "Imprimir como PDF",
                                  ),
                                  PopupMenuButton<int>(
                                    tooltip: "Ir a diapositiva específica",
                                    icon: Icon(Icons.list, 
                                      color: Colors.white70,
                                      size: _isProjectorMode ? 28 : 24,
                                    ),
                                    color: Colors.black.withOpacity(0.9),
                                    onSelected: (value) => _jumpToSlide(value),
                                    itemBuilder: (context) {
                                      return List.generate(currentBlock.slides.length, (index) {
                                        final isCurrent = index == currentSlideIndex;
                                        return PopupMenuItem<int>(
                                          value: index,
                                          child: Text(
                                            "${index + 1}. ${currentBlock.slides[index].title}",
                                            style: TextStyle(
                                              color: isCurrent ? const Color(0xFFC5A065) : Colors.white,
                                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Container(height: 20, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 10)),
                              // Botones de navegación con animación
                              IconButton(
                                onPressed: _prevSlide,
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                                tooltip: "Anterior",
                              ),
                              // Indicador de progreso animado
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${currentSlideIndex + 1} / ${currentBlock.slides.length}",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 60,
                                    child: AnimatedProgressBar(
                                      progress: (currentSlideIndex + 1) / currentBlock.slides.length,
                                      height: 3,
                                      progressColor: const Color(0xFFC5A065),
                                      backgroundColor: Colors.white24,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: _nextSlide,
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                                tooltip: "Siguiente",
                              ),
                              // Separador
                              Container(height: 20, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 10)),
                              // BOTONES DE CONTROL DE ESTUDIANTES
                              _buildStudentControlButtons(currentSlide),
                            ],
                          ),
                        ),
                      ),
                      
                      // PANEL DE ESTUDIANTES (lado derecho - solo desktop)
                      if (_showStudentPanel && !isMobile)
                        Positioned(
                          top: 80,
                          right: 20,
                          bottom: 20,
                          width: 350,
                          child: Consumer<TeacherService>(
                            builder: (context, teacherService, _) {
                              return StudentDashboardPanel(
                                summary: teacherService.dashboardSummary,
                                onClose: () => setState(() => _showStudentPanel = false),
                              );
                            },
                          ),
                        ),
                      
                      // LOGO / MARCA DE AGUA (si no está en modo proyector o si se desea branding)
                      if (!_isProjectorMode)
                         Positioned(
                           bottom: 20,
                           right: 20,
                           child: Opacity(
                             opacity: 0.3,
                             child: Text("SAPIENTIAL", style: GoogleFonts.cinzel(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                           ),
                         ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Botón flotante para mostrar sidebar en modo proyector
            if (_isProjectorMode && !_showSidebar)
              Positioned(
                left: 10,
                top: 10,
                child: IconButton(
                  onPressed: () => setState(() => _showSidebar = true),
                  icon: const Icon(Icons.menu, color: Colors.white24, size: 28),
                  tooltip: "Mostrar menú (S)",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcut(String key, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(key, style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'monospace')),
          ),
          const SizedBox(width: 8),
          Text(action, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSlideContent(Slide slide) {
    // Envolver en AnimatedSwitcher para transiciones suaves entre slides
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Transición con fade y deslizamiento sutil
        final slideOffset = Tween<Offset>(
          begin: Offset(0.03 * _slideDirection, 0),
          end: Offset.zero,
        ).animate(animation);
        
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideOffset,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(slide.id),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _isProjectorMode ? 80 : 40,
              vertical: _isProjectorMode ? 60 : 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Imagen con animación de entrada (si existe)
                if (slide.imageUrl != null) ...[
                  FadeInSlide(
                    duration: const Duration(milliseconds: 500),
                    beginOffset: const Offset(0, 0.05),
                    child: _buildSlideImage(slide.imageUrl!),
                  ),
                  const SizedBox(height: 30),
                ],

                // Icono animado según tipo (solo si no hay imagen)
                if (slide.type == SlideType.title && slide.imageUrl == null)
                  ScaleIn(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Icon(Icons.auto_awesome, 
                        color: const Color(0xFFC5A065), 
                        size: _isProjectorMode ? 80 : 60
                      ),
                    ),
                  ),
                
                // Título con animación de entrada
                FadeInSlide(
                  duration: const Duration(milliseconds: 450),
                  delay: const Duration(milliseconds: 150),
                  beginOffset: const Offset(0, 0.08),
                  child: Text(
                    slide.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cinzel(
                      fontSize: slide.imageUrl != null ? _titleWithImageFontSize : _titleFontSize,
                      color: const Color(0xFFC5A065),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0
                    ),
                  ),
                ),
                SizedBox(height: _isProjectorMode ? 40 : 30),
                
                // Contenido Principal con animación
                FadeInSlide(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 250),
                  beginOffset: const Offset(0, 0.06),
                  child: Text(
                    slide.content,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.merriweather(
                      fontSize: slide.imageUrl != null ? _contentWithImageFontSize : _contentFontSize,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.5
                    ),
                  ),
                ),

                // Referencia Bíblica con animación
                if (slide.biblicalReference != null) ...[
                  SizedBox(height: _isProjectorMode ? 35 : 25),
                  ScaleIn(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 400),
                    beginScale: 0.9,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _isProjectorMode ? 32 : 24, 
                        vertical: _isProjectorMode ? 16 : 12
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFC5A065), width: 2),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(
                        slide.biblicalReference!,
                        style: GoogleFonts.cinzel(
                          fontSize: _referenceFontSize,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFC5A065)
                        ),
                      ),
                    ),
                  ),
                ],

                // Actividad con animaciones
                if (slide.type == SlideType.activity && slide.activity != null) ...[
                  SizedBox(height: _isProjectorMode ? 50 : 40),
                  
                  // Pregunta con animación
                  FadeInSlide(
                    duration: const Duration(milliseconds: 450),
                    delay: const Duration(milliseconds: 300),
                    beginOffset: const Offset(0, 0.1),
                    child: Text(
                      slide.activity!.question,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                        fontSize: _questionFontSize,
                        color: const Color(0xFFC5A065),
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  
                  SizedBox(height: _isProjectorMode ? 40 : 30),

                  // RENDERIZADO SEGUN TIPO DE ACTIVIDAD con entrada escalonada
                  if (slide.activity!.type == ActivityType.multipleChoice) ...[
                    // Opciones de respuesta con Consumer para votos en vivo
                    Consumer<TeacherService>(
                      builder: (context, teacherService, _) {
                        return Column(
                          children: List.generate(slide.activity!.options.length, (index) {
                            return FadeInSlide(
                              duration: const Duration(milliseconds: 350),
                              delay: Duration(milliseconds: 400 + (index * 80)),
                              beginOffset: const Offset(0.1, 0),
                              child: _buildMultipleChoiceOption(slide, index),
                            );
                          }),
                        );
                      },
                    ),
                  ] else if (slide.activity!.type == ActivityType.wordPuzzle) ...[
                    FadeInSlide(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 400),
                      beginOffset: const Offset(0, 0.05),
                      child: _buildWordPuzzleUI(),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE UI PARA ACTIVIDADES ---

  Widget _buildMultipleChoiceOption(Slide slide, int index) {
    final selections = studentSelections[slide.id] ?? [];
    final studentsForThisOption = selections.asMap().entries
        .where((entry) => entry.value == index)
        .map((entry) => entry.key + 1)
        .toList();
    final isCorrect = slide.activity!.isRevealed && index == slide.activity!.correctOptionIndex;
    final isWrong = slide.activity!.isRevealed && index != slide.activity!.correctOptionIndex && studentsForThisOption.isNotEmpty;
    
    // Obtener votos en vivo del servidor
    final teacherService = context.read<TeacherService>();
    final dashboard = teacherService.dashboardSummary;
    final voteCount = dashboard?.getVoteCount(index) ?? 0;
    final totalVotes = dashboard?.totalVotes ?? 0;
    final totalStudents = dashboard?.totalStudents ?? 0;
    
    // Calcular porcentaje de votos
    final votePercentage = totalVotes > 0 ? (voteCount / totalVotes * 100) : 0.0;
    
    // Widget base de la opción
    Widget optionWidget = Padding(
      padding: EdgeInsets.symmetric(vertical: _isProjectorMode ? 10.0 : 8.0),
      child: InkWell(
        onTap: !slide.activity!.isRevealed && selections.length < 5
            ? () => _selectOption(slide.id, index)
            : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(_isProjectorMode ? 24 : 20),
          decoration: BoxDecoration(
            color: isCorrect 
                ? Colors.green.withOpacity(0.2) 
                : (slide.activity!.isRevealed && index != slide.activity!.correctOptionIndex && studentsForThisOption.isNotEmpty)
                    ? Colors.red.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isCorrect 
                  ? Colors.green 
                  : (slide.activity!.isRevealed && index != slide.activity!.correctOptionIndex && studentsForThisOption.isNotEmpty)
                      ? Colors.red
                      : Colors.white24,
              width: 1.5
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: _isProjectorMode ? 50 : 40,
                    height: _isProjectorMode ? 50 : 40,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.white10,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C...
                      style: GoogleFonts.oswald(
                        fontSize: _isProjectorMode ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                  SizedBox(width: _isProjectorMode ? 24 : 16),
                  Expanded(
                    child: Text(
                      slide.activity!.options[index],
                      style: GoogleFonts.merriweather(
                        fontSize: _optionFontSize,
                        color: Colors.white
                      ),
                    ),
                  ),
                  // NUEVO: Badge de votos en vivo
                  if (_activityEnabledForStudents && voteCount > 0) ...[
                    ScaleIn(
                      duration: const Duration(milliseconds: 300),
                      beginScale: 0.5,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isProjectorMode ? 16 : 12,
                          vertical: _isProjectorMode ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCorrect && slide.activity!.isRevealed
                                ? [Colors.green.shade600, Colors.green.shade800]
                                : [const Color(0xFFC5A065), const Color(0xFF8B7355)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isCorrect && slide.activity!.isRevealed 
                                  ? Colors.green 
                                  : const Color(0xFFC5A065)).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.how_to_vote_rounded,
                              color: Colors.white,
                              size: _isProjectorMode ? 20 : 16,
                            ),
                            SizedBox(width: _isProjectorMode ? 8 : 6),
                            Text(
                              '$voteCount',
                              style: GoogleFonts.oswald(
                                fontSize: _isProjectorMode ? 22 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (totalVotes > 0) ...[
                              SizedBox(width: _isProjectorMode ? 6 : 4),
                              Text(
                                '(${votePercentage.toStringAsFixed(0)}%)',
                                style: GoogleFonts.oswald(
                                  fontSize: _isProjectorMode ? 16 : 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                  // Indicadores de estudiantes con animación de entrada (modo local)
                  if (studentsForThisOption.isNotEmpty)
                    Row(
                      children: studentsForThisOption.map((studentNum) {
                        return ScaleIn(
                          duration: const Duration(milliseconds: 300),
                          beginScale: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: _isProjectorMode ? 48 : 40,
                              height: _isProjectorMode ? 48 : 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC5A065),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1
                                  )
                                ]
                              ),
                              child: Center(
                                child: Text(
                                  '$studentNum',
                                  style: GoogleFonts.oswald(
                                    fontSize: _isProjectorMode ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
              // NUEVO: Barra de progreso de votos
              if (_activityEnabledForStudents && totalStudents > 0 && voteCount > 0) ...[
                SizedBox(height: _isProjectorMode ? 12 : 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: votePercentage / 100),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: _isProjectorMode ? 8 : 6,
                        backgroundColor: Colors.white12,
                        valueColor: AlwaysStoppedAnimation(
                          isCorrect && slide.activity!.isRevealed
                              ? Colors.green
                              : const Color(0xFFC5A065),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    
    // Envolver con animación de celebración o sacudida según estado
    if (isCorrect) {
      return SuccessCelebration(
        celebrate: slide.activity!.isRevealed,
        child: optionWidget,
      );
    }
    
    return optionWidget;
  }

  Widget _buildWordPuzzleUI() {
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    final isRevealed = currentSlide.activity?.isRevealed ?? false;

    // Widget principal del puzzle con animaciones de feedback
    Widget puzzleContent = Column(
      children: [
        // ZONA DE CONSTRUCCION con animación de shake para errores
        ShakeAnimation(
          shake: _showShake,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(minHeight: 100),
            decoration: BoxDecoration(
              color: _puzzleIsCorrect == true 
                  ? Colors.green.withOpacity(0.15)
                  : _puzzleIsCorrect == false 
                      ? Colors.red.withOpacity(0.1)
                      : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _puzzleIsCorrect == true 
                    ? Colors.green 
                    : (_puzzleIsCorrect == false ? Colors.red : Colors.white24),
                width: _puzzleIsCorrect != null ? 3 : 2
              ),
              boxShadow: _puzzleIsCorrect == true ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ] : null,
            ),
            child: _puzzleSelectedWords.isEmpty 
                ? Center(
                    child: Text(
                      "Toca las palabras abajo para ordenar el versículo", 
                      style: TextStyle(
                        color: Colors.white38, 
                        fontSize: _isProjectorMode ? 20 : 16
                      )
                    )
                  )
                : Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _puzzleSelectedWords.map((word) => _buildPuzzleChip(word, true)).toList(),
                  ),
          ),
        ),
        
        SizedBox(height: _isProjectorMode ? 40 : 30),
        
        // BANCO DE PALABRAS con animación (si no está revelado)
        if (!isRevealed)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _puzzleAvailableWords.isEmpty ? 0.5 : 1.0,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _puzzleAvailableWords.map((word) => _buildPuzzleChip(word, false)).toList(),
            ),
          ),

        SizedBox(height: _isProjectorMode ? 40 : 30),

        // CONTROLES Y RESPUESTA con botones animados
        if (!isRevealed)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedButton(
                icon: Icons.visibility,
                label: "VER RESPUESTA",
                color: Colors.blueGrey,
                onPressed: _revealAnswer,
              ),
              const SizedBox(width: 20),
              _buildAnimatedButton(
                icon: Icons.refresh,
                label: "REINICIAR",
                color: Colors.white24,
                onPressed: _resetPuzzle,
              ),
              const SizedBox(width: 20),
              _buildAnimatedButton(
                icon: Icons.check_circle,
                label: "VERIFICAR",
                color: const Color(0xFFC5A065),
                textColor: Colors.black,
                onPressed: _checkPuzzle,
              ),
            ],
          )
        else
          // Respuesta revelada con animación de celebración
          ConfettiBurst(
            trigger: _showCelebration,
            child: Column(
              children: [
                ScaleIn(
                  duration: const Duration(milliseconds: 500),
                  beginScale: 0.8,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.greenAccent,
                              size: _isProjectorMode ? 28 : 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "ORDEN CORRECTO:", 
                              style: TextStyle(
                                color: Colors.greenAccent, 
                                fontSize: _isProjectorMode ? 18 : 14,
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: (currentSlide.activity?.correctWordOrder ?? []).asMap().entries.map((entry) => 
                            FadeInSlide(
                              duration: const Duration(milliseconds: 300),
                              delay: Duration(milliseconds: 100 + (entry.key * 50)),
                              beginOffset: const Offset(0, 0.2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                child: Text(entry.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                              ),
                            )
                          ).toList(),
                        ),
                        const SizedBox(height: 16),
                        FadeInSlide(
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 600),
                          beginOffset: const Offset(0, 0.1),
                          child: Text(
                            currentSlide.activity?.explanation ?? "",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.merriweather(
                              fontSize: _isProjectorMode ? 20 : 16, 
                              color: Colors.white70, 
                              fontStyle: FontStyle.italic
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedButton(
                  icon: Icons.replay,
                  label: "INTENTAR DE NUEVO",
                  color: Colors.orange,
                  onPressed: _resetPuzzle,
                ),
              ],
            ),
          ),

        // MENSAJE DE RESULTADO animado (Validación manual)
        if (_puzzleIsCorrect != null && !isRevealed)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: 1.0,
            child: ScaleIn(
              duration: const Duration(milliseconds: 400),
              beginScale: 0.8,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _puzzleIsCorrect! ? Icons.celebration : Icons.refresh,
                      color: _puzzleIsCorrect! ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _puzzleIsCorrect! ? "¡EXCELENTE! HAS ORDENADO EL VERSÍCULO." : "INTÉNTALO DE NUEVO.",
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        color: _puzzleIsCorrect! ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
    
    return puzzleContent;
  }
  
  // Widget de botón animado reutilizable
  Widget _buildAnimatedButton({
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return AnimatedButton(
      backgroundColor: color,
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _isProjectorMode ? 28 : 24, color: textColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: _isProjectorMode ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleChip(String word, bool isSelected) {
    return GestureDetector(
      onTap: () => _onPuzzleWordTap(word, isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC5A065) : Colors.white24,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFC5A065).withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 2
              )
          ]
        ),
        child: Text(
          word,
          style: GoogleFonts.merriweather(
            fontSize: _isProjectorMode ? 28 : 20,
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
  
  // ============================================================
  // TOOLBAR PARA MÓVIL
  // ============================================================
  
  Widget _buildMobileToolbar(Slide currentSlide, ClassBlock currentBlock) {
    return Consumer<TeacherService>(
      builder: (context, teacherService, _) {
        final connectedCount = teacherService.connectedStudentsCount;
        final isActivity = currentSlide.type == SlideType.activity && currentSlide.activity != null;
        final isThisActivityEnabled = _isActivityEnabled(currentSlide.id);
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Menú de Bloques (NAVEGACIÓN)
              IconButton(
                onPressed: () => _showBlocksModal(),
                icon: const Icon(
                  Icons.menu_book,
                  color: Color(0xFFC5A065),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: 'Bloques',
              ),
              
              // Separador
              Container(height: 16, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 4)),
              
              // Navegación de slides
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _prevSlide,
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  GestureDetector(
                    onTap: () => _showSlideSelector(currentBlock),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${currentSlideIndex + 1}/${currentBlock.slides.length}",
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _nextSlide,
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              
              // Separador
              Container(height: 16, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 4)),
              
              // Controles principales
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Estudiantes conectados
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => _showStudentsModal(context),
                        icon: Icon(
                          Icons.people_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      if (connectedCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$connectedCount',
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  // BOTÓN EXCEL VISIBLE DIRECTAMENTE
                  IconButton(
                    onPressed: _exportToExcel,
                    icon: const Icon(Icons.table_chart, color: Colors.green, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    tooltip: 'Exportar Excel',
                  ),
                  
                  // Activar actividad (si aplica)
                  if (isActivity)
                    IconButton(
                      onPressed: _toggleActivityForStudents,
                      icon: Icon(
                        isThisActivityEnabled ? Icons.play_circle_filled : Icons.play_circle_outline,
                        color: isThisActivityEnabled ? Colors.green : Colors.white70,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Activar actividad',
                    ),
                    
                  // Revelar respuesta (si es actividad y está habilitada)
                  if (isActivity && isThisActivityEnabled)
                    IconButton(
                      onPressed: () {
                        _revealAnswer();
                        _revealAnswerToStudents();
                      },
                      icon: const Icon(Icons.visibility, color: Colors.amber, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      tooltip: 'Revelar respuesta',
                    ),
                  
                  // Menú adicional (opciones menos usadas)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
                    padding: EdgeInsets.zero,
                    color: Colors.black.withOpacity(0.9),
                    onSelected: (value) {
                      switch (value) {
                        case 'projector':
                          _toggleProjectorMode();
                          break;
                        case 'print':
                          _printCurrentSlide();
                          break;
                        case 'lockAll':
                          _lockAllActivities();
                          break;
                        case 'resetAll':
                          _resetAllStudentsProgress();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'projector',
                        child: Row(
                          children: [
                            Icon(_isProjectorMode ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text(_isProjectorMode ? 'Salir proyector' : 'Modo proyector', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'print',
                        child: Row(
                          children: [
                            Icon(Icons.print, color: Colors.white70, size: 18),
                            SizedBox(width: 8),
                            Text('Imprimir PDF', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'lockAll',
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Cerrar TODAS las actividades', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'resetAll',
                        child: Row(
                          children: [
                            Icon(Icons.restart_alt, color: Colors.orange, size: 18),
                            SizedBox(width: 8),
                            Text('🔄 Reiniciar progreso estudiantes', style: TextStyle(color: Colors.orange)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Muestra el selector de bloques en móvil
  void _showBlocksModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book, color: Color(0xFFC5A065)),
                  const SizedBox(width: 12),
                  Text(
                    'Bloques del Curso',
                    style: GoogleFonts.cinzel(
                      color: const Color(0xFFC5A065),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: session.blocks.length,
                  itemBuilder: (context, idx) {
                    final block = session.blocks[idx];
                    final isSelected = idx == currentBlockIndex;
                    final slideCount = block.slides.length;
                    final activityCount = block.slides.where((s) => s.type == SlideType.activity).length;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFC5A065).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFC5A065) : Colors.white10,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFC5A065) : Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          block.title,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFC5A065) : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '$slideCount slides • $activityCount actividades',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: Color(0xFFC5A065))
                            : const Icon(Icons.chevron_right, color: Colors.white24),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            currentBlockIndex = idx;
                            currentSlideIndex = 0;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Muestra un selector de slides en móvil
  void _showSlideSelector(ClassBlock currentBlock) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ir a diapositiva',
                style: GoogleFonts.cinzel(
                  color: const Color(0xFFC5A065),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentBlock.slides.length,
                  itemBuilder: (context, index) {
                    final isCurrent = index == currentSlideIndex;
                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xFFC5A065) : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.black : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        currentBlock.slides[index].title,
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFFC5A065) : Colors.white,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: currentBlock.slides[index].type == SlideType.activity
                          ? const Icon(Icons.quiz, color: Colors.orange, size: 18)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        _jumpToSlide(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Muestra el panel de estudiantes como modal en móvil
  void _showStudentsModal(BuildContext context) {
    final teacherService = context.read<TeacherService>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  // Handle de arrastre
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.people, color: Color(0xFFC5A065), size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Estudiantes',
                              style: GoogleFonts.cinzel(
                                color: const Color(0xFFC5A065),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Botón Excel
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _exportToExcel();
                              },
                              icon: const Icon(Icons.table_chart, color: Colors.green, size: 22),
                              tooltip: 'Exportar Excel',
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10),
                  // Contenido - Panel de estudiantes
                  Expanded(
                    child: StudentDashboardPanel(
                      summary: teacherService.dashboardSummary,
                      onClose: () => Navigator.pop(context),
                      isEmbedded: true,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // ============================================================
  // CONTROLES DE ESTUDIANTES
  // ============================================================
  
  Widget _buildStudentControlButtons(Slide currentSlide) {
    final isActivity = currentSlide.type == SlideType.activity && currentSlide.activity != null;
    final isThisActivityEnabled = _isActivityEnabled(currentSlide.id);
    
    return Consumer<TeacherService>(
      builder: (context, teacherService, _) {
        final connectedCount = teacherService.connectedStudentsCount;
        final respondedCount = teacherService.respondedCount;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón para ver panel de estudiantes
            Stack(
              children: [
                IconButton(
                  onPressed: () => setState(() => _showStudentPanel = !_showStudentPanel),
                  icon: Icon(
                    _showStudentPanel ? Icons.people : Icons.people_outline,
                    color: _showStudentPanel ? Colors.green : Colors.white70,
                    size: _isProjectorMode ? 28 : 24,
                  ),
                  tooltip: "Ver estudiantes (E)",
                ),
                if (connectedCount > 0)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$connectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // BOTÓN EXPORTAR EXCEL - Siempre visible
            IconButton(
              onPressed: _exportToExcel,
              icon: Icon(
                Icons.table_chart,
                color: Colors.green,
                size: _isProjectorMode ? 28 : 24,
              ),
              tooltip: "Exportar a Excel",
            ),
            
            // =====================================================
            // BOTÓN DE REINICIO DE PROGRESO (ADMINISTRADOR)
            // =====================================================
            PopupMenuButton<String>(
              icon: Icon(
                Icons.admin_panel_settings,
                color: Colors.orange,
                size: _isProjectorMode ? 28 : 24,
              ),
              tooltip: "Opciones de administrador",
              color: Colors.grey[900],
              onSelected: (value) {
                if (value == 'reset_all') {
                  _resetAllStudentsProgress();
                } else if (value == 'lock_all') {
                  _lockAllActivities();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'reset_all',
                  child: Row(
                    children: [
                      const Icon(Icons.restart_alt, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reiniciar progreso de estudiantes',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Borra TODO el avance de todos',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'lock_all',
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cerrar todas las actividades',
                            style: TextStyle(color: Colors.orange),
                          ),
                          Text(
                            'Bloquea respuestas pendientes',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Botón para activar/desactivar actividad (solo si es actividad)
            if (isActivity) ...[
              const SizedBox(width: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isThisActivityEnabled 
                      ? Colors.green.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: _toggleActivityForStudents,
                  icon: Icon(
                    isThisActivityEnabled 
                        ? Icons.play_circle_filled 
                        : Icons.play_circle_outline,
                    color: isThisActivityEnabled 
                        ? Colors.green 
                        : Colors.white70,
                    size: _isProjectorMode ? 28 : 24,
                  ),
                  tooltip: isThisActivityEnabled 
                      ? "Desactivar actividad para estudiantes (A)"
                      : "Activar actividad para estudiantes (A)",
                ),
              ),
              
              // Indicador de respuestas
              if (isThisActivityEnabled && connectedCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: respondedCount == connectedCount 
                          ? Colors.green 
                          : Colors.orange.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        respondedCount == connectedCount 
                            ? Icons.check_circle 
                            : Icons.pending,
                        color: respondedCount == connectedCount 
                            ? Colors.green 
                            : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$respondedCount / $connectedCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: _isProjectorMode ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Botón para revelar respuesta a estudiantes
              if (_activityEnabledForStudents) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () {
                    _revealAnswer();
                    _revealAnswerToStudents();
                  },
                  icon: Icon(
                    Icons.visibility,
                    color: Colors.amber,
                    size: _isProjectorMode ? 28 : 24,
                  ),
                  tooltip: "Revelar respuesta a todos (R)",
                ),
              ],
            ],
          ],
        );
      },
    );
  }
}