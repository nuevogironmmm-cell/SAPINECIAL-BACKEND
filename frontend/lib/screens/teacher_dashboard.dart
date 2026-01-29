import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/class_session_model.dart';
import '../data/mock_data.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
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

  @override
  void initState() {
    super.initState();
    // Escuchar atajos de teclado
    RawKeyboard.instance.addListener(_handleKeyPress);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleKeyPress);
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
    });
  }

  void _prevSlide() {
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
                              // Botones de navegacion
                              IconButton(
                                onPressed: _prevSlide,
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                                tooltip: "Anterior",
                              ),
                              Text(
                                "${currentSlideIndex + 1} / ${currentBlock.slides.length}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    return KeyedSubtree(
      key: ValueKey(slide.id),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen (si existe)
            if (slide.imageUrl != null) ...[
              _buildSlideImage(slide.imageUrl!),
              const SizedBox(height: 30),
            ],

            // Icono según tipo (solo si no hay imagen)
            if (slide.type == SlideType.title && slide.imageUrl == null)
               Padding(
                 padding: const EdgeInsets.only(bottom: 20),
                 child: Icon(Icons.auto_awesome, 
                   color: const Color(0xFFC5A065), 
                   size: _isProjectorMode ? 80 : 60
                 ),
               ),
            
            // Título - LETRAS MÁS GRANDES
            Text(
              slide.title.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: slide.imageUrl != null ? _titleWithImageFontSize : _titleFontSize,
                color: const Color(0xFFC5A065),
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0
              ),
            ),
            SizedBox(height: _isProjectorMode ? 40 : 30),
            
            // Contenido Principal - LETRAS MÁS GRANDES
            Text(
              slide.content,
              textAlign: TextAlign.center,
              style: GoogleFonts.merriweather(
                fontSize: slide.imageUrl != null ? _contentWithImageFontSize : _contentFontSize,
                color: Colors.white.withOpacity(0.95),
                height: 1.5
              ),
            ),

            // Referencia Bíblica
            if (slide.biblicalReference != null) ...[
              SizedBox(height: _isProjectorMode ? 35 : 25),
              Container(
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
            ],

            // Actividad
            if (slide.type == SlideType.activity && slide.activity != null) ...[
              SizedBox(height: _isProjectorMode ? 50 : 40),
              
              // Pregunta
              Text(
                slide.activity!.question,
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: _questionFontSize,
                  color: const Color(0xFFC5A065),
                  fontWeight: FontWeight.w600
                ),
              ),
              
              SizedBox(height: _isProjectorMode ? 40 : 30),

              // RENDERIZADO SEGUN TIPO DE ACTIVIDAD
              if (slide.activity!.type == ActivityType.multipleChoice) ...[
                // Opciones de respuesta
                ...List.generate(slide.activity!.options.length, (index) {
                   return _buildMultipleChoiceOption(slide, index);
                }),
              ] else if (slide.activity!.type == ActivityType.wordPuzzle) ...[
                _buildWordPuzzleUI(),
              ],
            ],
          ],
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
    
    return Padding(
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
               // Indicadores de estudiantes
              if (studentsForThisOption.isNotEmpty)
                Row(
                  children: studentsForThisOption.map((studentNum) {
                    return Padding(
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
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordPuzzleUI() {
    final currentBlock = session.blocks[currentBlockIndex];
    final currentSlide = currentBlock.slides[currentSlideIndex];
    final isRevealed = currentSlide.activity?.isRevealed ?? false;

    return Column(
      children: [
        // ZONA DE CONSTRUCCION (Tu respuesta)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(minHeight: 100),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _puzzleIsCorrect == true ? Colors.green : (_puzzleIsCorrect == false ? Colors.red : Colors.white24),
              width: 2
            ),
          ),
          child: _puzzleSelectedWords.isEmpty 
              ? Center(child: Text("Toca las palabras abajo para ordenar el versículo", style: TextStyle(color: Colors.white38, fontSize: _isProjectorMode ? 20 : 16)))
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _puzzleSelectedWords.map((word) => _buildPuzzleChip(word, true)).toList(),
                ),
        ),
        
        SizedBox(height: _isProjectorMode ? 40 : 30),
        
        // BANCO DE PALABRAS (si no está revelado)
        if (!isRevealed)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _puzzleAvailableWords.map((word) => _buildPuzzleChip(word, false)).toList(),
          ),

        SizedBox(height: _isProjectorMode ? 40 : 30),

        // CONTROLES Y RESPUESTA
        if (!isRevealed)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _revealAnswer,
                icon: Icon(Icons.visibility, size: _isProjectorMode ? 28 : 24),
                label: const Text("VER RESPUESTA"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: _resetPuzzle,
                icon: const Icon(Icons.refresh),
                label: const Text("REINICIAR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: _checkPuzzle,
                icon: const Icon(Icons.check_circle),
                label: const Text("VERIFICAR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A065),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: Colors.green.withOpacity(0.2),
                   border: Border.all(color: Colors.green, width: 2),
                   borderRadius: BorderRadius.circular(15)
                 ),
                 child: Column(
                   children: [
                     Text(
                       "ORDEN CORRECTO:", 
                       style: TextStyle(
                         color: Colors.greenAccent, 
                         fontSize: _isProjectorMode ? 18 : 14,
                         fontWeight: FontWeight.bold
                       )
                     ),
                     const SizedBox(height: 12),
                     Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: (currentSlide.activity?.correctWordOrder ?? []).map((word) => 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(word, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                          )
                        ).toList(),
                     ),
                     const SizedBox(height: 16),
                     Text(
                       currentSlide.activity?.explanation ?? "",
                       textAlign: TextAlign.center,
                       style: GoogleFonts.merriweather(
                         fontSize: _isProjectorMode ? 20 : 16, 
                         color: Colors.white70, 
                         fontStyle: FontStyle.italic
                       )
                     ),
                   ],
                 ),
               ),
               const SizedBox(height: 20),
               ElevatedButton.icon(
                onPressed: _resetPuzzle, // Reiniciar permite intentar de nuevo
                icon: const Icon(Icons.replay),
                label: const Text("INTENTAR DE NUEVO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),

        // MENSAJE DE RESULTADO (Validación manual)
        if (_puzzleIsCorrect != null && !isRevealed)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              _puzzleIsCorrect! ? "¡EXCELENTE! HAS ORDENADO EL VERSÍCULO." : "INTÉNTALO DE NUEVO.",
              style: GoogleFonts.oswald(
                fontSize: 24,
                color: _puzzleIsCorrect! ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPuzzleChip(String word, bool isSelected) {
    return GestureDetector(
      onTap: () => _onPuzzleWordTap(word, isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC5A065) : Colors.white24,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFC5A065).withOpacity(0.5),
                blurRadius: 8,
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