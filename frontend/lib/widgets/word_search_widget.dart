import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart';

import 'package:google_fonts/google_fonts.dart';

import 'dart:math';

import 'dart:async';



class WordSearchWidget extends StatefulWidget {

  final List<String> words;

  final int gridSize; // Mínimo 12x12

  final Function(List<String> foundWords) onWordFound;

  final Function(bool completed) onCompleted;

  final bool isReadOnly;

  final int timeLimitSeconds; // Por defecto 600 (10 min)

  final String? studentName; // Nombre del estudiante (para ranking)

  final Function(String name, int timeSeconds, int wordsFound)? onSubmitResult; // Callback al enviar

  final List<WordSearchRanking>? ranking; // Ranking de ganadores

  final String? seedKey; // Clave para generar la misma sopa en todos los dispositivos

  final bool forceSideList; // Forzar lista de palabras a la derecha

  final Function(int wordsFound, int totalWords, int elapsedSeconds)? onProgress; // Progreso en tiempo real



  const WordSearchWidget({

    Key? key,

    required this.words,

    this.gridSize = 12,

    required this.onWordFound,

    required this.onCompleted,

    this.isReadOnly = false,

    this.timeLimitSeconds = 600,

    this.studentName,

    this.onSubmitResult,

    this.ranking,

    this.seedKey,

    this.forceSideList = false,

    this.onProgress,

  }) : super(key: key);



  @override

  State<WordSearchWidget> createState() => _WordSearchWidgetState();

}



/// Modelo para ranking de sopa de letras

class WordSearchRanking {

  final String studentName;

  final int timeSeconds;

  final int wordsFound;

  final int totalWords;

  final DateTime completedAt;

  

  WordSearchRanking({

    required this.studentName,

    required this.timeSeconds,

    required this.wordsFound,

    required this.totalWords,

    required this.completedAt,

  });

  

  double get percentage => totalWords > 0 ? (wordsFound / totalWords) * 100 : 0;

  String get formattedTime => '${(timeSeconds ~/ 60).toString().padLeft(2, '0')}:${(timeSeconds % 60).toString().padLeft(2, '0')}';

  

  // Medalla según posición

  static String getMedal(int position) {

    switch (position) {

      case 0: return '👑'; // Primer lugar - Corona dorada

      case 1: return '🥈'; // Segundo lugar

      case 2: return '🥉'; // Tercer lugar

      default: return '⭐';

    }

  }

}



class _WordSearchWidgetState extends State<WordSearchWidget> {

  late List<List<String>> _grid;

  late List<String> _wordsToFind;

  final Set<String> _foundWords = {};

  

  // Estado del juego

  bool _isGameStarted = false;

  bool _isGameFinished = false;

  bool _hasSubmitted = false; // Si ya envió el resultado

  Timer? _timer;

  int _elapsedSeconds = 0;

  int _remainingSeconds = 0;



  // Estado de la selección

  Point<int>? _startPoint;

  Point<int>? _currentPoint;

  List<Point<int>> _selectedCells = [];

  

  // Colores visuales

  final List<Color> _wordColors = [

    Colors.redAccent.withValues(alpha: 0.5),

    Colors.blueAccent.withValues(alpha: 0.5),

    Colors.greenAccent.withValues(alpha: 0.5),

    Colors.orangeAccent.withValues(alpha: 0.5),

    Colors.purpleAccent.withValues(alpha: 0.5),

    Colors.tealAccent.withValues(alpha: 0.5),

    Colors.pinkAccent.withValues(alpha: 0.5),

    Colors.indigoAccent.withValues(alpha: 0.5),

  ];

  

  final Map<String, Color> _paintedCells = {}; // "x,y" -> Color



  // Mapa de acentos para mostrar las palabras correctamente en español

  static const Map<String, String> _accentMap = {

    'SATANAS': 'SATANÁS',

    'SABIDURIA': 'SABIDURÍA',

    'RESTAURACION': 'RESTAURACIÓN',

    'PROLOGO': 'PRÓLOGO',

    'EPILOGO': 'EPÍLOGO',

    'ELIU': 'ELIÚ',

    'SINONIMICO': 'SINONÍMICO',

    'ANTITETICO': 'ANTITÉTICO',

    'SINTETICO': 'SINTÉTICO',

    'CLIMATICO': 'CLIMÁTICO',

    'ECLESIASTES': 'ECLESIASTÉS',

    'ENSENANZA': 'ENSEÑANZA',

  };



  /// Devuelve el nombre con tildes para mostrar al usuario

  String _displayWord(String word) => _accentMap[word] ?? word;



  @override

  void initState() {

    super.initState();

    // Normalizar palabras (mayúsculas, sin tildes si fuera necesario, trim)

    _wordsToFind = widget.words.map((w) => w.toUpperCase().trim()).toList();

    _remainingSeconds = widget.timeLimitSeconds;

    _generateGrid();

    

    // Si es readOnly (ej. revisión), mostrar todo revelado o estado final

    if (widget.isReadOnly) {

      _isGameStarted = true;

      _isGameFinished = true;

    }

  }



  @override

  void dispose() {

    _timer?.cancel();

    super.dispose();

  }



  void _startGame() {

    setState(() {

      _isGameStarted = true;

      _isGameFinished = false;

      _elapsedSeconds = 0;

      _remainingSeconds = widget.timeLimitSeconds;

    });



    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {

      if (mounted) {

        setState(() {

          _elapsedSeconds++;

          _remainingSeconds--;

        });



        if (_remainingSeconds <= 0) {

          _endGame(success: false);

        }

      }

    });

  }



  void _endGame({required bool success}) {

    _timer?.cancel();

    setState(() {

      _isGameFinished = true;

    });

    

    if (success) {

      widget.onCompleted(true);

    }

    

    // Auto-enviar resultado cuando se acaba el tiempo (si no se ha enviado)

    if (!success && !_hasSubmitted && widget.onSubmitResult != null && widget.studentName != null) {

      Future.delayed(const Duration(milliseconds: 200), () {

        if (mounted) _submitResult();

      });

    }

    

    // Mostrar dialogo de resultados despues de un breve delay

    Future.delayed(const Duration(milliseconds: 500), () {

      if (mounted) _showResultsDialog(success);

    });

  }



  void _showResultsDialog(bool success) {

    showDialog(

      context: context,

      barrierDismissible: false,

      builder: (context) {

        return AlertDialog(

          backgroundColor: const Color(0xFF1E1E1E),

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

          title: Row(

            children: [

              Icon(

                success ? Icons.emoji_events : Icons.timer_off,

                color: success ? Colors.amber : Colors.redAccent,

                size: 30,

              ),

              const SizedBox(width: 10),

              Text(

                success ? '¡Felicidades!' : 'Tiempo Terminado',

                style: GoogleFonts.oswald(color: Colors.white, fontSize: 24),

              ),

            ],

          ),

          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              Text(

                success 

                  ? 'Has encontrado todas las palabras y demostrado sabiduría.'

                  : 'Se acabó el tiempo. ?Sigue practicando tu agudeza visual!',

                style: const TextStyle(color: Colors.white70),

              ),

              const SizedBox(height: 20),

              _buildResultRow(Icons.timer, 'Tiempo:', _formatTime(_elapsedSeconds)),

              _buildResultRow(Icons.check_circle_outline, 'Encontradas:', '${_foundWords.length}/${_wordsToFind.length}'),

              const SizedBox(height: 20),

              Container(

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(

                  color: Colors.amber.withValues(alpha: 0.1),

                  borderRadius: BorderRadius.circular(10),

                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),

                ),

                child: Column(

                  children: [

                    const Icon(Icons.format_quote, color: Colors.amber, size: 20),

                    const SizedBox(height: 4),

                    Text(

                      success 

                        ? '"Bien hecho, sigue creciendo en sabiduría y gracia."' 

                        : '"El principio de la sabiduría es el temor de Jehová."',

                      textAlign: TextAlign.center,

                      style: GoogleFonts.merriweather(

                        color: Colors.amber.shade200,

                        fontStyle: FontStyle.italic,

                        fontSize: 14

                      ),

                    ),

                  ],

                ),

              )

            ],

          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);

              },

              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),

            ),

          ],

        );

      },

    );

  }



  Widget _buildResultRow(IconData icon, String label, String value) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        children: [

          Icon(icon, color: Colors.white54, size: 18),

          const SizedBox(width: 8),

          Text(label, style: const TextStyle(color: Colors.white54)),

          const Spacer(),

          Text(

            value, 

            style: const TextStyle(

              color: Colors.white, 

              fontWeight: FontWeight.bold,

              fontSize: 16

            )

          ),

        ],

      ),

    );

  }



  String _formatTime(int seconds) {

    final minutes = seconds ~/ 60;

    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

  }



  // --- LÓGICA DE GENERACIÓN MEJORADA: 8 DIRECCIONES ---

  // Direcciones: 0=Der, 1=Izq, 2=Abajo, 3=Arriba, 4=DiagDerAbajo, 5=DiagIzqArriba, 6=DiagDerArriba, 7=DiagIzqAbajo

  static const List<List<int>> _directions = [

    [0, 1],   // 0: Derecha (horizontal)

    [0, -1],  // 1: Izquierda (horizontal invertido)

    [1, 0],   // 2: Abajo (vertical)

    [-1, 0],  // 3: Arriba (vertical invertido)

    [1, 1],   // 4: Diagonal derecha-abajo

    [-1, -1], // 5: Diagonal izquierda-arriba

    [-1, 1],  // 6: Diagonal derecha-arriba

    [1, -1],  // 7: Diagonal izquierda-abajo

  ];



  void _generateGrid() {

    _grid = List.generate(

      widget.gridSize,

      (_) => List.filled(widget.gridSize, ''),

    );

    final seed = _computeSeed();

    final random = seed == null ? Random() : Random(seed);

    

    // Ordenar palabras por longitud descendente para facilitar colocación

    final sortedWords = List<String>.from(_wordsToFind)

      ..sort((a, b) => b.length.compareTo(a.length));



    for (String word in sortedWords) {

      bool placed = false;

      int attempts = 0;

      

      // Mezclar direcciones para mayor variedad

      final shuffledDirs = List<int>.generate(8, (i) => i)..shuffle(random);

      

      while (!placed && attempts < 300) {

        attempts++;

        // Elegir dirección aleatoria de las 8 posibles

        int dirIndex = shuffledDirs[attempts % 8];

        int row = random.nextInt(widget.gridSize);

        int col = random.nextInt(widget.gridSize);

        

        if (_canPlaceWord(word, row, col, dirIndex)) {

          _placeWord(word, row, col, dirIndex);

          placed = true;

        }

      }

      if (!placed) debugPrint("?? No se pudo colocar: $word");

    }



    // Rellenar con letras aleatorias (incluyendo Ñ para español)

    const letters = 'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ';

    for (int i = 0; i < widget.gridSize; i++) {

      for (int j = 0; j < widget.gridSize; j++) {

        if (_grid[i][j] == '') {

          _grid[i][j] = letters[random.nextInt(letters.length)];

        }

      }

    }

  }



  int? _computeSeed() {

    final normalizedSeedKey = (widget.seedKey ?? '').trim();

    final sortedSeedWords = List<String>.from(_wordsToFind)..sort();

    final seedSource = '${normalizedSeedKey.isEmpty ? 'default' : normalizedSeedKey}|${widget.gridSize}|${sortedSeedWords.join('|')}';

    return _stableHash(seedSource);

  }



  int _stableHash(String value) {

    const int fnvOffset = 0x811C9DC5;

    const int fnvPrime = 0x01000193;

    int hash = fnvOffset;



    for (int i = 0; i < value.length; i++) {

      hash ^= value.codeUnitAt(i);

      hash = (hash * fnvPrime) & 0x7fffffff;

    }

    return hash;

  }



  bool _canPlaceWord(String word, int row, int col, int dirIndex) {

    final dRow = _directions[dirIndex][0];

    final dCol = _directions[dirIndex][1];

    

    // Verificar que la palabra cabe en la dirección elegida

    final endRow = row + dRow * (word.length - 1);

    final endCol = col + dCol * (word.length - 1);

    

    if (endRow < 0 || endRow >= widget.gridSize) return false;

    if (endCol < 0 || endCol >= widget.gridSize) return false;

    

    // Verificar colisiones

    for (int i = 0; i < word.length; i++) {

      final r = row + dRow * i;

      final c = col + dCol * i;

      if (_grid[r][c] != '' && _grid[r][c] != word[i]) return false;

    }

    return true;

  }



  void _placeWord(String word, int row, int col, int dirIndex) {

    final dRow = _directions[dirIndex][0];

    final dCol = _directions[dirIndex][1];

    

    for (int i = 0; i < word.length; i++) {

      final r = row + dRow * i;

      final c = col + dCol * i;

      _grid[r][c] = word[i];

    }

  }



  // --- LÓGICA DE INTERACCIÓN (Gestos) ---

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {

    if (widget.isReadOnly || !_isGameStarted || _isGameFinished) return;

    

    final cellSize = constraints.maxWidth / widget.gridSize;

    final x = (details.localPosition.dx / cellSize).floor();

    final y = (details.localPosition.dy / cellSize).floor();



    if (x >= 0 && x < widget.gridSize && y >= 0 && y < widget.gridSize) {

      setState(() {

        _startPoint = Point(x, y);

        _currentPoint = Point(x, y);

        _updateSelectedCells();

      });

    }

  }



  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {

    if (widget.isReadOnly || !_isGameStarted || _isGameFinished || _startPoint == null) return;



    final cellSize = constraints.maxWidth / widget.gridSize;

    final x = (details.localPosition.dx / cellSize).floor();

    final y = (details.localPosition.dy / cellSize).floor();



    if (x >= 0 && x < widget.gridSize && y >= 0 && y < widget.gridSize) {

      if (_currentPoint!.x != x || _currentPoint!.y != y) {

        setState(() {

          _currentPoint = Point(x, y);

          _updateSelectedCells();

        });

      }

    }

  }



  void _onPanEnd(DragEndDetails details) {

    if (widget.isReadOnly || !_isGameStarted || _isGameFinished || _startPoint == null) return;



    final word = _getSelectedWord();

    // Invertir palabra tambin por si acaso (para soporte bidireccional si se quisiera)

    final reversedWord = word.split('').reversed.join();

    

    if ((_wordsToFind.contains(word) && !_foundWords.contains(word)) || 

        (_wordsToFind.contains(reversedWord) && !_foundWords.contains(reversedWord))) {

      

      final actualWord = _wordsToFind.contains(word) ? word : reversedWord;

      

      setState(() {

        _foundWords.add(actualWord);

        final color = _wordColors[_foundWords.length % _wordColors.length];

        for (final p in _selectedCells) {

          _paintedCells["${p.x},${p.y}"] = color;

        }

      });



      widget.onWordFound(_foundWords.toList());

      widget.onProgress?.call(_foundWords.length, _wordsToFind.length, _elapsedSeconds);



      if (_foundWords.length == _wordsToFind.length) {

        _endGame(success: true);

      }

    }



    setState(() {

      _startPoint = null;

      _currentPoint = null;

      _selectedCells = [];

    });

  }



  void _updateSelectedCells() {

    _selectedCells = [];

    if (_startPoint == null || _currentPoint == null) return;



    final dx = _currentPoint!.x - _startPoint!.x;

    final dy = _currentPoint!.y - _startPoint!.y;



    int steps;

    int xDir = 0;

    int yDir = 0;



    // Forzar 8 direcciones (Horizontal, Vertical, Diagonal)

    if (dx == 0 && dy == 0) {

      steps = 0;

    } else if (dx.abs() >= dy.abs() * 2) { // Horizontal dominant

      steps = dx.abs();

      xDir = dx.sign;

    } else if (dy.abs() >= dx.abs() * 2) { // Vertical dominant

      steps = dy.abs();

      yDir = dy.sign;

    } else { // Diagonal dominant

      if (dx.abs() == dy.abs()) {

        steps = dx.abs();

        xDir = dx.sign;

        yDir = dy.sign; 

      } else {

         // Snap to perfect diagonal

         steps = max(dx.abs(), dy.abs());

         xDir = dx.sign;

         yDir = dy.sign;

      }

    }



    for (int i = 0; i <= steps; i++) {

        final cx = _startPoint!.x + (xDir * i);

        final cy = _startPoint!.y + (yDir * i);

        if (cx >= 0 && cx < widget.gridSize && cy >= 0 && cy < widget.gridSize) {

          _selectedCells.add(Point(cx, cy));

        }

    }

  }



  String _getSelectedWord() {

    return _selectedCells.map((p) => _grid[p.y][p.x]).join();

  }



  // --- UI BUILDING ---



  @override

  Widget build(BuildContext context) {

    // Determinar layout basado en ancho disponible

    return LayoutBuilder(

      builder: (context, constraints) {

        // Si hay espacio suficiente (> 800px), poner lista a la derecha. Si no, abajo.

        final bool isWide = widget.forceSideList || constraints.maxWidth > 800;

        

        return Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            // Header: Timer y Contador

            if (!widget.isReadOnly)

              Container(

                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                margin: const EdgeInsets.only(bottom: 8),

                decoration: BoxDecoration(

                  color: Colors.black26,

                  borderRadius: BorderRadius.circular(50),

                  border: Border.all(color: Colors.white10),

                ),

                child: Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [

                    Row(

                      children: [

                        Icon(Icons.timer, color: _remainingSeconds < 60 ? Colors.redAccent : Colors.white70),

                        const SizedBox(width: 8),

                        Text(

                          _formatTime(_remainingSeconds),

                          style: GoogleFonts.robotoMono(

                            fontSize: 20,

                            fontWeight: FontWeight.bold,

                            color: _remainingSeconds < 60 ? Colors.redAccent : Colors.white,

                          ),

                        ),

                      ],

                    ),

                    Text(

                      'Encontradas: ${_foundWords.length} / ${_wordsToFind.length} (v3.0)',

                      style: GoogleFonts.oswald(

                        fontSize: 18,

                        color: Colors.amber,

                      ),

                    ),

                  ],

                ),

              ),

            

            // Cuerpo del juego

            if (isWide)

              Expanded(

                child: Row(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Expanded(flex: 3, child: _buildGridSection(constraints)),

                    const SizedBox(width: 30),

                    Expanded(

                      flex: 1,

                      child: SingleChildScrollView(

                        child: _buildWordListSection(),

                      ),

                    ),

                  ],

                ),

              )

            else

              // Layout móvil: grid arriba, lista de palabras SIEMPRE visible abajo (v4.0)

              Expanded(

                child: Column(

                  children: [

                    // Grid - ocupa el espacio disponible arriba

                    Expanded(

                      child: _buildGridSection(constraints),

                    ),

                    const SizedBox(height: 8),

                    // Lista de palabras - SIEMPRE visible en la parte inferior

                    ConstrainedBox(

                      constraints: BoxConstraints(

                        maxHeight: MediaQuery.of(context).size.height * 0.28,

                      ),

                      child: SingleChildScrollView(

                        physics: const BouncingScrollPhysics(),

                        child: _buildWordListSection(),

                      ),

                    ),

                  ],

                ),

              ),

          ],

        );

      },

    );

  }



  void _showWordListModal() {

    showModalBottomSheet(

      context: context,

      backgroundColor: Colors.transparent,

      isScrollControlled: true,

      builder: (context) => Container(

        height: MediaQuery.of(context).size.height * 0.75,

        decoration: BoxDecoration(

          color: const Color(0xFF1E1E1E),

          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withValues(alpha: 0.5),

              blurRadius: 20,

              offset: const Offset(0, -5),

            ),

          ],

        ),

        child: Column(

          children: [

            // Handle bar

            Center(

              child: Container(

                margin: const EdgeInsets.only(top: 12, bottom: 8),

                width: 40,

                height: 4,

                decoration: BoxDecoration(

                  color: Colors.white24,

                  borderRadius: BorderRadius.circular(2),

                ),

              ),

            ),

            // Header modal

            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

              child: Row(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                   Text(

                    'Palabras a buscar',

                    style: GoogleFonts.oswald(

                      fontSize: 22,

                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  IconButton(

                    icon: const Icon(Icons.close, color: Colors.white70),

                    onPressed: () => Navigator.pop(context),

                  ),

                ],

              ),

            ),

            const Divider(color: Colors.white10),

            // Lista scrollable

            Expanded(

              child: SingleChildScrollView(

                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.all(24),

                child: Column(

                  children: [

                    _buildWordListSection(),

                    const SizedBox(height: 32),

                    // Mensaje si ya terminó

                    if (_foundWords.length == _wordsToFind.length)

                      Container(

                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(

                          color: Colors.amber.withValues(alpha: 0.1),

                          borderRadius: BorderRadius.circular(12),

                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),

                        ),

                        child: Row(

                          children: [

                            const Icon(Icons.emoji_events, color: Colors.amber),

                            const SizedBox(width: 12),

                            Expanded(child: Text(

                              '¡Has encontrado todas las palabras! Envía tu resultado.',

                              style: TextStyle(color: Colors.amber.shade100),

                            )),

                          ],

                        ),

                      ),

                    const SizedBox(height: 100), // Espacio extra

                  ],

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildGridSection(BoxConstraints constraints) {

    return LayoutBuilder(

      builder: (context, gridConstraints) {

        // Calcular tamaño cuadrado (v4.0)

        // El grid debe caber en el espacio disponible (bounded por Expanded en móvil)

        final screenHeight = MediaQuery.of(context).size.height;

        final isNarrow = !widget.forceSideList && constraints.maxWidth <= 800;

        final maxGridSize = isNarrow ? screenHeight * 0.42 : screenHeight * 0.55;

        final maxH = gridConstraints.maxHeight.isFinite ? gridConstraints.maxHeight : 500.0;

        final baseSize = min(gridConstraints.maxWidth, maxH);

        final size = min(baseSize, maxGridSize);

        final cellSize = size / widget.gridSize;



        return Center(

          child: Stack(

            children: [

              // La Cuadrícula

              // Cuadrícula con gestos de selección

              RawGestureDetector(

                  gestures: {

                    EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(

                      () => EagerGestureRecognizer(),

                      (EagerGestureRecognizer instance) {

                        instance.onStart = (d) => _onPanStart(d, BoxConstraints(maxWidth: size, maxHeight: size));

                        instance.onUpdate = (d) => _onPanUpdate(d, BoxConstraints(maxWidth: size, maxHeight: size));

                        instance.onEnd = (d) => _onPanEnd(d);

                      },

                    ),

                  },

                  behavior: HitTestBehavior.opaque,

                  child: Container(

                  width: size,

                  height: size,

                  decoration: BoxDecoration(

                    color: Colors.black45,

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),

                    boxShadow: [

                      BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),

                    ],

                  ),

                  child: Stack(

                    children: [

                      ...List.generate(widget.gridSize * widget.gridSize, (index) {

                        final row = index ~/ widget.gridSize;

                        final col = index % widget.gridSize;

                        final cellKey = "$col,$row";

                        final isSelected = _selectedCells.any((p) => p.x == col && p.y == row);

                        final isPainted = _paintedCells.containsKey(cellKey);

                        

                        return Positioned(

                          left: col * cellSize,

                          top: row * cellSize,

                          width: cellSize,

                          height: cellSize,

                          child: Container(

                            alignment: Alignment.center,

                            decoration: BoxDecoration(

                              color: isSelected 

                                  ? Colors.white.withValues(alpha: 0.3) 

                                  : (isPainted ? _paintedCells[cellKey] : null),

                              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.3),

                            ),

                            child: Text(

                              _grid[row][col],

                              style: GoogleFonts.robotoMono(

                                color: Colors.white,

                                fontWeight: FontWeight.bold,

                                fontSize: cellSize * 0.75, // Aumentado de 0.6 a 0.75 para mejor visibilidad móvil

                                shadows: [Shadow(color: Colors.black, blurRadius: 2)],

                              ),

                            ),

                          ),

                        );

                      }),

                    ],

                  ),

                ),

              ),



              // Overlay de Inicio

              if (!_isGameStarted && !widget.isReadOnly)

                Positioned.fill(

                  child: Container(

                    decoration: BoxDecoration(

                      color: Colors.black87,

                      borderRadius: BorderRadius.circular(16),

                    ),

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        const Icon(Icons.grid_on, size: 60, color: Colors.amber),

                        const SizedBox(height: 20),

                        Text(

                          'Sopa de Letras',

                          style: GoogleFonts.cinzel(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),

                        ),

                        const SizedBox(height: 10),

                        const Text(

                          'Encuentra las palabras de sabiduría',

                          style: TextStyle(color: Colors.white70),

                        ),

                        const SizedBox(height: 30),

                        ElevatedButton.icon(

                          onPressed: _startGame,

                          icon: const Icon(Icons.play_arrow),

                          label: const Text('Iniciar Juego'),

                          style: ElevatedButton.styleFrom(

                            backgroundColor: Colors.amber,

                            foregroundColor: Colors.black,

                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),

                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),

                          ),

                        ),

                      ],

                    ),

                  ),

                ),

                

              // Overlay de Game Over (éxito o Fracaso)

              if (_isGameFinished && !widget.isReadOnly && _remainingSeconds <= 0)

                 Positioned.fill(

                  child: Container(

                    decoration: BoxDecoration(

                      color: Colors.black54,

                      borderRadius: BorderRadius.circular(16),

                    ),

                    child: Center(

                      child: Container(

                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                        decoration: BoxDecoration(

                          color: Colors.redAccent,

                          borderRadius: BorderRadius.circular(20),

                        ),

                        child: const Text(

                          'TIEMPO FINALIZADO',

                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),

                        ),

                      ),

                    ),

                  ),

                ),

            ],

          ),

        );

      },

    );

  }



  Widget _buildWordListSection() {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.amber.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 1.5),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisSize: MainAxisSize.min,

        children: [

          Row(

            children: [

              const Icon(Icons.list, color: Colors.amber, size: 20),

              const SizedBox(width: 8),

              Text(

                'Palabras a buscar:',

                style: GoogleFonts.oswald(fontSize: 18, color: Colors.white),

              ),

            ],

          ),

          const SizedBox(height: 20),

          Wrap(

            spacing: 10,

            runSpacing: 10,

            children: _wordsToFind.map((word) {

              final isFound = _foundWords.contains(word);

              return AnimatedScale(

                scale: isFound ? 1.1 : 1.0,

                duration: const Duration(milliseconds: 300),

                child: AnimatedContainer(

                  duration: const Duration(milliseconds: 300),

                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                  decoration: BoxDecoration(

                    color: isFound ? Colors.green.withValues(alpha: 0.2) : Colors.black26,

                    borderRadius: BorderRadius.circular(8),

                    border: Border.all(

                      color: isFound ? Colors.green : Colors.white12,

                      width: isFound ? 2 : 1,

                    ),

                    boxShadow: isFound ? [

                      BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)

                    ] : null,

                  ),

                  child: Row(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      Text(

                        _displayWord(word),

                        style: TextStyle(

                          color: isFound ? Colors.greenAccent : Colors.white70,

                          decoration: isFound ? TextDecoration.lineThrough : null,

                          fontWeight: isFound ? FontWeight.bold : FontWeight.normal,

                          fontSize: isFound ? 14 : 13,

                        ),

                      ),

                      if (isFound) ...[

                        const SizedBox(width: 6),

                        const Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),

                      ],

                    ],

                  ),

                ),

              );

            }).toList(),

          ),

          

          // ============================================================

          // BOTÓN DE ENVIAR RESULTADO (solo para estudiantes)

          // ============================================================

          if (_isGameStarted && widget.studentName != null && widget.onSubmitResult != null) ...[

            const SizedBox(height: 24),

            _buildSubmitButton(),

          ],

          

          // ============================================================

          // RANKING DE GANADORES ORDENADO POR TIEMPO (si está disponible)

          // ============================================================

          if (widget.ranking != null && widget.ranking!.isNotEmpty) ...[

            const SizedBox(height: 24),

            _buildRankingSection(),

          ],

        ],

      ),

    );

  }

  

  // ============================================================

  // BOTÓN DE ENVIAR RESULTADO

  // ============================================================

  Widget _buildSubmitButton() {

    final canSubmit = _foundWords.isNotEmpty && !_hasSubmitted;

    final isComplete = _foundWords.length == _wordsToFind.length;

    

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        gradient: LinearGradient(

          colors: _hasSubmitted 

              ? [Colors.green.withValues(alpha: 0.2), Colors.green.withValues(alpha: 0.1)]

              : isComplete 

                  ? [Colors.amber.withValues(alpha: 0.3), Colors.orange.withValues(alpha: 0.2)]

                  : [Colors.blue.withValues(alpha: 0.2), Colors.blue.withValues(alpha: 0.1)],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,

        ),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(

          color: _hasSubmitted ? Colors.green : isComplete ? Colors.amber : Colors.blue.withValues(alpha: 0.5),

          width: 2,

        ),

      ),

      child: Column(

        children: [

          if (_hasSubmitted) ...[

            // Mensaje de confirmación

            Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Icon(Icons.check_circle, color: Colors.green, size: 28),

                const SizedBox(width: 10),

                Text(

                  '¡Resultado enviado!',

                  style: GoogleFonts.oswald(

                    color: Colors.green,

                    fontSize: 18,

                    fontWeight: FontWeight.bold,

                  ),

                ),

              ],

            ),

            const SizedBox(height: 8),

            Text(

              'Tu tiempo: ${_formatTime(_elapsedSeconds)}  ${_foundWords.length}/${_wordsToFind.length} palabras',

              style: const TextStyle(color: Colors.white70),

            ),

          ] else ...[

            // Botón de enviar

            Material(

              color: Colors.transparent,

              child: InkWell(

                onTap: canSubmit ? _submitResult : null,

                borderRadius: BorderRadius.circular(30),

                child: Container(

                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),

                  decoration: BoxDecoration(

                    gradient: canSubmit 

                        ? LinearGradient(

                            colors: isComplete 

                                ? [Colors.amber, Colors.orange]

                                : [Colors.blue, Colors.blueAccent],

                          )

                        : null,

                    color: canSubmit ? null : Colors.grey.withValues(alpha: 0.3),

                    borderRadius: BorderRadius.circular(30),

                    boxShadow: canSubmit ? [

                      BoxShadow(

                        color: (isComplete ? Colors.amber : Colors.blue).withValues(alpha: 0.4),

                        blurRadius: 10,

                        spreadRadius: 2,

                      ),

                    ] : null,

                  ),

                  child: Row(

                    mainAxisSize: MainAxisSize.min,

                    children: [

                      Icon(

                        isComplete ? Icons.emoji_events : Icons.send,

                        color: canSubmit ? Colors.white : Colors.white38,

                        size: 24,

                      ),

                      const SizedBox(width: 10),

                      Text(

                        isComplete ? '🏆 ¡ENVIAR RESULTADO!' : 'Enviar progreso',

                        style: GoogleFonts.oswald(

                          color: canSubmit ? Colors.white : Colors.white38,

                          fontSize: 16,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                    ],

                  ),

                ),

              ),

            ),

            const SizedBox(height: 10),

            Text(

              isComplete 

                  ? '¡Completaste todo! Envía tu resultado para el ranking'

                  : 'Encuentra más palabras para mejorar tu posición',

              style: TextStyle(

                color: isComplete ? Colors.amber.shade200 : Colors.white54,

                fontSize: 12,

              ),

              textAlign: TextAlign.center,

            ),

          ],

        ],

      ),

    );

  }

  

  void _submitResult() {

    if (_hasSubmitted || widget.onSubmitResult == null) return;

    

    setState(() {

      _hasSubmitted = true;

    });

    

    widget.onSubmitResult!(

      widget.studentName!,

      _elapsedSeconds,

      _foundWords.length,

    );

    

    // Mostrar confirmación

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        backgroundColor: Colors.green,

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

        content: Row(

          children: [

            const Icon(Icons.send, color: Colors.white),

            const SizedBox(width: 12),

            Expanded(

              child: Text(

                '¡Tu resultado fue enviado al docente!',

                style: GoogleFonts.oswald(color: Colors.white, fontSize: 16),

              ),

            ),

          ],

        ),

        duration: const Duration(seconds: 3),

      ),

    );

  }

  

  // ============================================================

  // SECCIÓN DE RANKING CON CORONAS

  // ============================================================

  Widget _buildRankingSection() {

    // Ordenar por tiempo (más rápido primero)

    final sortedRanking = List<WordSearchRanking>.from(widget.ranking!)

      ..sort((a, b) => a.timeSeconds.compareTo(b.timeSeconds));

    

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        gradient: LinearGradient(

          colors: [

            Colors.amber.withValues(alpha: 0.15),

            Colors.orange.withValues(alpha: 0.1),

          ],

          begin: Alignment.topCenter,

          end: Alignment.bottomCenter,

        ),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),

      ),

      child: Column(

        children: [

          // Título del ranking con ícono de velocidad

          Row(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(Icons.speed, color: Colors.amber, size: 24),

              const SizedBox(width: 8),

              Text(

                'RANKING POR TIEMPO',

                style: GoogleFonts.oswald(

                  color: Colors.amber,

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(width: 8),

              const Icon(Icons.emoji_events, color: Colors.amber, size: 24),

            ],

          ),

          const SizedBox(height: 8),

          Text(

            '🏆 El más rápido gana la corona 👑',

            style: TextStyle(

              color: Colors.amber.shade200,

              fontSize: 12,

              fontStyle: FontStyle.italic,

            ),

          ),

          const SizedBox(height: 16),

          

          // Lista de rankings ordenados por tiempo

          ...sortedRanking.asMap().entries.map((entry) {

            final index = entry.key;

            final rank = entry.value;

            final isFastest = index == 0; // El más rápido

            final isTop3 = index < 3;

            

            return Container(

              margin: const EdgeInsets.only(bottom: 8),

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

              decoration: BoxDecoration(

                color: isFastest 

                    ? Colors.amber.withValues(alpha: 0.3)

                    : isTop3 

                        ? _getPositionColor(index).withValues(alpha: 0.2)

                        : Colors.white.withValues(alpha: 0.05),

                borderRadius: BorderRadius.circular(12),

                border: Border.all(

                  color: isFastest 

                      ? Colors.amber.withValues(alpha: 0.8)

                      : isTop3 

                          ? _getPositionColor(index).withValues(alpha: 0.5) 

                          : Colors.white10,

                  width: isFastest ? 3 : isTop3 ? 2 : 1,

                ),

                boxShadow: isFastest ? [

                  BoxShadow(

                    color: Colors.amber.withValues(alpha: 0.4),

                    blurRadius: 12,

                    spreadRadius: 2,

                  ),

                ] : null,

              ),

              child: Row(

                children: [

                  // Medalla o posición con efecto especial para el más rápido

                  Container(

                    width: 50,

                    height: 50,

                    alignment: Alignment.center,

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      gradient: isFastest 

                          ? LinearGradient(

                              colors: [Colors.amber.shade200, Colors.amber.shade800],

                              begin: Alignment.topLeft,

                              end: Alignment.bottomRight,

                            )

                          : isTop3 

                              ? LinearGradient(

                                  colors: _getPositionGradient(index),

                                  begin: Alignment.topLeft,

                                  end: Alignment.bottomRight,

                                )

                              : null,

                      color: !isTop3 && !isFastest ? Colors.grey.shade800 : null,

                      boxShadow: [

                        BoxShadow(

                          color: isFastest 

                              ? Colors.amber.withValues(alpha: 0.6)

                              : isTop3 

                                  ? _getPositionColor(index).withValues(alpha: 0.5)

                                  : Colors.black26,

                          blurRadius: isFastest ? 12 : 8,

                          spreadRadius: isFastest ? 2 : 1,

                        ),

                      ],

                    ),

                    child: isFastest 

                        ? const Text('🏆', style: TextStyle(fontSize: 28))

                        : Text(

                            WordSearchRanking.getMedal(index),

                            style: TextStyle(fontSize: isTop3 ? 24 : 18),

                          ),

                  ),

                  const SizedBox(width: 12),

                  

                  // Nombre del estudiante con indicador de velocidad

                  Expanded(

                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        Row(

                          children: [

                            if (isFastest) ...[

                              const Icon(Icons.local_fire_department, 

                                color: Colors.redAccent, size: 16),

                              const SizedBox(width: 4),

                            ],

                            Expanded(

                              child: Text(

                                rank.studentName,

                                style: GoogleFonts.oswald(

                                  color: isFastest 

                                      ? Colors.amber.shade100

                                      : isTop3 

                                          ? _getPositionColor(index) 

                                          : Colors.white,

                                  fontSize: isFastest ? 18 : isTop3 ? 16 : 14,

                                  fontWeight: isFastest 

                                      ? FontWeight.bold 

                                      : isTop3 

                                          ? FontWeight.bold 

                                          : FontWeight.normal,

                                ),

                              ),

                            ),

                          ],

                        ),

                        Text(

                          '${rank.wordsFound}/${rank.totalWords} palabras',

                          style: TextStyle(

                            color: isFastest ? Colors.amber.shade200 : Colors.white54,

                            fontSize: 12,

                          ),

                        ),

                        if (isFastest) ...[

                          const SizedBox(height: 2),

                          Text(

                            '🚀 ¡RÉCORD DE VELOCIDAD! 🚀',

                            style: TextStyle(

                              color: Colors.redAccent,

                              fontSize: 10,

                              fontWeight: FontWeight.bold,

                              fontStyle: FontStyle.italic,

                            ),

                          ),

                        ],

                      ],

                    ),

                  ),

                  

                  // Tiempo destacado

                  Container(

                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

                    decoration: BoxDecoration(

                      color: isFastest 

                          ? Colors.redAccent.withValues(alpha: 0.9)

                          : Colors.black38,

                      borderRadius: BorderRadius.circular(20),

                      border: isFastest ? Border.all(

                        color: Colors.amber.withValues(alpha: 0.8), 

                        width: 2

                      ) : null,

                    ),

                    child: Row(

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        Icon(

                          isFastest ? Icons.flash_on : Icons.timer,

                          size: 16,

                          color: isFastest ? Colors.yellow : Colors.white70,

                        ),

                        const SizedBox(width: 6),

                        Text(

                          rank.formattedTime,

                          style: GoogleFonts.robotoMono(

                            color: isFastest ? Colors.white : Colors.white70,

                            fontWeight: FontWeight.bold,

                            fontSize: isFastest ? 16 : 14,

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            );

          }).toList(),

        ],

      ),

    );

  }

  

  Color _getPositionColor(int position) {

    switch (position) {

      case 0: return Colors.amber; // Oro - Más rápido

      case 1: return Colors.grey.shade400; // Plata

      case 2: return Colors.orange.shade700; // Bronce

      default: return Colors.white70;

    }

  }

  

  List<Color> _getPositionGradient(int position) {

    switch (position) {

      case 0: return [Colors.amber.shade200, Colors.amber.shade800]; // Oro - Más rápido

      case 1: return [Colors.grey.shade300, Colors.grey.shade500]; // Plata

      case 2: return [Colors.orange.shade400, Colors.orange.shade800]; // Bronce

      default: return [Colors.grey.shade400, Colors.grey.shade600];

    }

  }

}





class EagerGestureRecognizer extends PanGestureRecognizer {

  @override

  void addAllowedPointer(PointerDownEvent event) {

    super.addAllowedPointer(event);

    resolve(GestureDisposition.accepted);

  }



  @override

  String get debugDescription => 'EagerGestureRecognizer';

}

