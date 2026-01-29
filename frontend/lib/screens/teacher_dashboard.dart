import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/class_session_model.dart';
import '../data/mock_data.dart';
import '../utils/animations.dart';

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
  
  // Controladores de animación
  late AnimationController _slideAnimController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Escuchar atajos de teclado
    RawKeyboard.instance.addListener(_handleKeyPress);
    
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
      } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
        final currentBlock = session.blocks[currentBlockIndex];
        final currentSlide = currentBlock.slides[currentSlideIndex];
        if (currentSlide.type == SlideType.activity) {
          _revealAnswer();
        }
      }
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
                // BARRA LATERAL (oculta en modo proyector)
                if (_showSidebar)
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
                      
                      // BARRA SUPERIOR DE HERRAMIENTAS
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
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
                            ],
                          ),
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
                    // Opciones de respuesta con animación escalonada
                    ...List.generate(slide.activity!.options.length, (index) {
                      return FadeInSlide(
                        duration: const Duration(milliseconds: 350),
                        delay: Duration(milliseconds: 400 + (index * 80)),
                        beginOffset: const Offset(0.1, 0),
                        child: _buildMultipleChoiceOption(slide, index),
                      );
                    }),
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
          child: Row(
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
               // Indicadores de estudiantes con animación de entrada
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
}