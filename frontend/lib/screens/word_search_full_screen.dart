import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/word_search_widget.dart';

class WordSearchFullScreen extends StatelessWidget {
  final List<String> words;
  final String activityId;
  final String studentName;
  final Function(List<String> foundWords) onWordFound;
  final Function(bool completed) onCompleted;
  final Function(int wordsFound, int totalWords, int elapsedSeconds) onProgress;
  final Function(String name, int timeSeconds, int wordsFound) onSubmitResult;
  final bool isReadOnly;

  const WordSearchFullScreen({
    Key? key,
    required this.words,
    required this.activityId,
    required this.studentName,
    required this.onWordFound,
    required this.onCompleted,
    required this.onProgress,
    required this.onSubmitResult,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text('Sopa de Letras', style: GoogleFonts.oswald()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Confirmar salida si no ha terminado
            if (!isReadOnly) {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('?Salir?'),
                  content: const Text('Si sales ahora, se guardar? tu progreso pero el tiempo seguir? corriendo.'),
                  actions: [
                    TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(c)),
                    TextButton(child: const Text('Salir'), onPressed: () {
                      Navigator.pop(c);
                      Navigator.pop(context);
                    }),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: WordSearchWidget(
          words: words,
          gridSize: 15,
          seedKey: activityId,
          studentName: studentName,
          isReadOnly: isReadOnly,
          forceSideList: false, // Responsivo
          onWordFound: onWordFound,
          onProgress: onProgress,
          onCompleted: onCompleted,
          onSubmitResult: (name, time, wordsFound) {
            onSubmitResult(name, time, wordsFound);
            // Salir después de enviar
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
