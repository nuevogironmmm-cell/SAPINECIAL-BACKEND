import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';

class WordSearchWidget extends StatefulWidget {
  final List<String> words;
  final int gridSize; // M?nimo 12x12
  final Function(List<String> foundWords) onWordFound;
  final Function(bool completed) onCompleted;
  final bool isReadOnly;
  final int timeLimitSeconds; // Por defecto 300 (5 min)

  const WordSearchWidget({
    Key? key,
    required this.words,
    this.gridSize = 12,
    required this.onWordFound,
    required this.onCompleted,
    this.isReadOnly = false,
    this.timeLimitSeconds = 300,
  }) : super(key: key);

  @override
  State<WordSearchWidget> createState() => _WordSearchWidgetState();
}

class _WordSearchWidgetState extends State<WordSearchWidget> {
  late List<List<String>> _grid;
  late List<String> _wordsToFind;
  final Set<String> _foundWords = {};
  
  // Estado del juego
  bool _isGameStarted = false;
  bool _isGameFinished = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _remainingSeconds = 0;

  // Estado de la selecci?n
  Point<int>? _startPoint;
  Point<int>? _currentPoint;
  List<Point<int>> _selectedCells = [];
  
  // Colores visuales
  final List<Color> _wordColors = [
    Colors.redAccent.withOpacity(0.5),
    Colors.blueAccent.withOpacity(0.5),
    Colors.greenAccent.withOpacity(0.5),
    Colors.orangeAccent.withOpacity(0.5),
    Colors.purpleAccent.withOpacity(0.5),
    Colors.tealAccent.withOpacity(0.5),
    Colors.pinkAccent.withOpacity(0.5),
    Colors.indigoAccent.withOpacity(0.5),
  ];
  
  final Map<String, Color> _paintedCells = {}; // "x,y" -> Color

  @override
  void initState() {
    super.initState();
    // Normalizar palabras (may?sculas, sin tildes si fuera necesario, trim)
    _wordsToFind = widget.words.map((w) => w.toUpperCase().trim()).toList();
    _remainingSeconds = widget.timeLimitSeconds;
    _generateGrid();
    
    // Si es readOnly (ej. revisi?n), mostrar todo revelado o estado final
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
    
    // Mostrar di?logo de resultados después de un breve delay
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
                success ? '?Felicidades!' : 'Tiempo Terminado',
                style: GoogleFonts.oswald(color: Colors.white, fontSize: 24),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                success 
                  ? 'Has encontrado todas las palabras y demostrado sabidur?a.'
                  : 'Se acab? el tiempo. ?Sigue practicando tu agudeza visual!',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              _buildResultRow(Icons.timer, 'Tiempo:', _formatTime(_elapsedSeconds)),
              _buildResultRow(Icons.check_circle_outline, 'Encontradas:', '${_foundWords.length}/${_wordsToFind.length}'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.format_quote, color: Colors.amber, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      success 
                        ? '"Bien hecho, sigue creciendo en sabidur?a y gracia."' 
                        : '"El principio de la sabidur?a es el temor de Jehov?."',
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

  // --- L?GICA DE GENERACI?N (Igual que antes pero optimizada) ---
  void _generateGrid() {
    _grid = List.generate(
      widget.gridSize,
      (_) => List.filled(widget.gridSize, ''),
    );
    final random = Random();
    
    // Ordenar palabras por longitud descendente para facilitar colocaci?n
    final sortedWords = List<String>.from(_wordsToFind)
      ..sort((a, b) => b.length.compareTo(a.length));

    for (String word in sortedWords) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 200) { // M?s intentos
        attempts++;
        int direction = random.nextInt(3); // 0:Hor, 1:Ver, 2:Diag
        int row = random.nextInt(widget.gridSize);
        int col = random.nextInt(widget.gridSize);
        if (_canPlaceWord(word, row, col, direction)) {
          _placeWord(word, row, col, direction);
          placed = true;
        }
      }
      if (!placed) debugPrint("?? No se pudo colocar: $word");
    }

    // Rellenar
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        if (_grid[i][j] == '') {
          _grid[i][j] = letters[random.nextInt(letters.length)];
        }
      }
    }
  }

  bool _canPlaceWord(String word, int row, int col, int direction) {
    // Verificaci?n de l?mites y colisiones
    if (direction == 0) { // Horizontal
      if (col + word.length > widget.gridSize) return false;
      for (int i = 0; i < word.length; i++) {
        if (_grid[row][col + i] != '' && _grid[row][col + i] != word[i]) return false;
      }
    } else if (direction == 1) { // Vertical
      if (row + word.length > widget.gridSize) return false;
      for (int i = 0; i < word.length; i++) {
        if (_grid[row + i][col] != '' && _grid[row + i][col] != word[i]) return false;
      }
    } else { // Diagonal
      if (row + word.length > widget.gridSize || col + word.length > widget.gridSize) return false;
      for (int i = 0; i < word.length; i++) {
        if (_grid[row + i][col + i] != '' && _grid[row + i][col + i] != word[i]) return false;
      }
    }
    return true;
  }

  void _placeWord(String word, int row, int col, int direction) {
    for (int i = 0; i < word.length; i++) {
      if (direction == 0) _grid[row][col + i] = word[i];
      else if (direction == 1) _grid[row + i][col] = word[i];
      else _grid[row + i][col + i] = word[i];
    }
  }

  // --- L?GICA DE INTERACCI?N (Gestos) ---
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
    // Invertir palabra también por si acaso (para soporte bidireccional si se quisiera)
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
        final bool isWide = constraints.maxWidth > 800;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Timer y Contador
            if (!widget.isReadOnly)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.only(bottom: 20),
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
                      'Encontradas: ${_foundWords.length} / ${_wordsToFind.length}',
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
                     Expanded(flex: 1, child: _buildWordListSection()),
                  ],
                ),
              )
            else
              Column(
                children: [
                  _buildGridSection(constraints),
                  const SizedBox(height: 30),
                  _buildWordListSection(),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildGridSection(BoxConstraints constraints) {
    return LayoutBuilder(
      builder: (context, gridConstraints) {
        // Calcular tama?o cuadrado
        final size = min(gridConstraints.maxWidth, gridConstraints.maxHeight > 300 ? gridConstraints.maxHeight : 500.0);
        final cellSize = size / widget.gridSize;

        return Center(
          child: Stack(
            children: [
              // La Cuadr?cula
              GestureDetector(
                onPanStart: (d) => _onPanStart(d, BoxConstraints(maxWidth: size, maxHeight: size)),
                onPanUpdate: (d) => _onPanUpdate(d, BoxConstraints(maxWidth: size, maxHeight: size)),
                onPanEnd: _onPanEnd,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 2),
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
                                  ? Colors.white.withOpacity(0.3) 
                                  : (isPainted ? _paintedCells[cellKey] : null),
                              border: Border.all(color: Colors.white10, width: 0.5),
                            ),
                            child: Text(
                              _grid[row][col],
                              style: GoogleFonts.robotoMono(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: cellSize * 0.6,
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
                          'Encuentra las palabras de sabidur?a',
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
                
              // Overlay de Game Over (?xito o Fracaso)
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isFound ? Colors.green.withOpacity(0.2) : Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFound ? Colors.green : Colors.white12,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      word,
                      style: TextStyle(
                        color: isFound ? Colors.green : Colors.white70,
                        decoration: isFound ? TextDecoration.lineThrough : null,
                        fontWeight: isFound ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    if (isFound) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check, size: 14, color: Colors.green),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
