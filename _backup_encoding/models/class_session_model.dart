enum SlideType { title, content, activity, reflection }

class ClassSession {
  final String id;
  final String title;
  final List<ClassBlock> blocks;

  ClassSession({required this.id, required this.title, required this.blocks});
}

class ClassBlock {
  final String title;
  final List<Slide> slides;

  ClassBlock({required this.title, required this.slides});
}

class Slide {
  final String id;
  final SlideType type;
  final String title;
  final String content; // Markdown o texto plano
  final String? biblicalReference;
  final String? imageUrl; // URL de imagen (opcional)
  final ActivityData? activity; // Solo si type == activity

  Slide({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.biblicalReference,
    this.imageUrl,
    this.activity,
  });
}

enum ActivityType {
  multipleChoice,
  trueFalse,
  wordPuzzle,
  wordSearch, // Nuevo tipo para sopa de letras real
}

class ActivityData {
  final String question;
  final List<String> options; // En wordPuzzle, estas son las palabras desordenadas
  final int correctOptionIndex; // No se usa en wordPuzzle (o se puede ignorar)
  final String? explanation; // Opcional - solo se revela si est? presente
  final ActivityType type;
  final List<String>? correctWordOrder; // Solo para wordPuzzle
  final double percentageValue; // Valor porcentual de la actividad (defecto 10%)
  bool isRevealed;

  ActivityData({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation, // Ahora es opcional
    this.type = ActivityType.multipleChoice,
    this.correctWordOrder,
    this.percentageValue = 5.0,
    this.isRevealed = false,
  });
}

