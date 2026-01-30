/// Modelos de datos para la sección de estudiantes
/// 
/// Sistema de identificación sin cuentas, basado en sesión temporal
/// Maneja actividades, respuestas, reflexiones, puntaje y MEDALLAS

import 'dart:convert';

// ============================================================
// ESTADO DE CONEXIÓN DEL ESTUDIANTE
// ============================================================

enum StudentConnectionStatus {
  connected,      // Conectado y activo
  responded,      // Ha respondido la actividad actual
  notResponded,   // No ha respondido aún
  disconnected,   // Desconectado
}

// ============================================================
// TIPOS DE ACTIVIDAD
// ============================================================

enum StudentActivityType {
  multipleChoice,   // Opción múltiple
  trueFalse,        // Verdadero / Falso
  shortAnswer,      // Respuesta corta
  wordSearch,       // Sopa de letras
}

// ============================================================
// ESTADO DE ACTIVIDAD
// ============================================================

enum ActivityState {
  locked,   // Bloqueada - estudiante no puede responder
  active,   // Activa - estudiante puede responder
  closed,   // Cerrada - tiempo agotado o docente cerró
}

// ============================================================
// CLASIFICACIÓN POR PORCENTAJE
// ============================================================

enum StudentClassification {
  winner,     // 100%
  excellent,  // 90%+
  veryGood,   // 80%+
  approved,   // 70%+
  basic,      // 60%+
  failed,     // <50% (solo visible para docente)
}

// ============================================================
// RESULTADO DE RESPUESTA (para feedback al estudiante)
// ============================================================

/// Resultado de una respuesta enviada por el estudiante
class AnswerResult {
  final String activityId;
  final int selectedIndex;
  final bool isCorrect;
  final double pointsEarned;
  final int? responseTimeMs;
  final DateTime answeredAt;
  final int? correctIndex;    // Se llena cuando el docente revela
  final bool isRevealed;      // Si ya se reveló la respuesta correcta

  AnswerResult({
    required this.activityId,
    required this.selectedIndex,
    required this.isCorrect,
    required this.pointsEarned,
    this.responseTimeMs,
    required this.answeredAt,
    this.correctIndex,
    this.isRevealed = false,
  });

  AnswerResult copyWith({
    String? activityId,
    int? selectedIndex,
    bool? isCorrect,
    double? pointsEarned,
    int? responseTimeMs,
    DateTime? answeredAt,
    int? correctIndex,
    bool? isRevealed,
  }) {
    return AnswerResult(
      activityId: activityId ?? this.activityId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      answeredAt: answeredAt ?? this.answeredAt,
      correctIndex: correctIndex ?? this.correctIndex,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'selectedIndex': selectedIndex,
    'isCorrect': isCorrect,
    'pointsEarned': pointsEarned,
    'responseTimeMs': responseTimeMs,
    'answeredAt': answeredAt.toIso8601String(),
    'correctIndex': correctIndex,
    'isRevealed': isRevealed,
  };
}

/// Evento cuando el docente revela la respuesta correcta
class AnswerRevealEvent {
  final String activityId;
  final int correctIndex;
  final int? studentAnswer;   // La respuesta que dio el estudiante (si respondió)
  final bool? wasCorrect;     // Si acertó o no (null si no respondió)

  AnswerRevealEvent({
    required this.activityId,
    required this.correctIndex,
    this.studentAnswer,
    this.wasCorrect,
  });
}

// ============================================================
// SISTEMA DE MEDALLAS
// ============================================================

enum MedalType {
  // Medallas de rendimiento
  gold,           // 🥇 Oro - Mejor puntaje
  silver,         // 🥈 Plata - 2do lugar
  bronze,         // 🥉 Bronce - 3er lugar
  
  // Medallas de logros
  perfectScore,   // 💯 Puntaje perfecto en actividad
  speedster,      // ⚡ Respuesta más rápida
  consistent,     // 🎯 3 respuestas correctas seguidas
  scholar,        // 📚 Respondió todas las actividades
  earlyBird,      // 🐦 Primero en responder
  improver,       // 📈 Mayor mejora entre actividades
  
  // Medallas especiales
  champion,       // 🏆 Campeón de la sesión
  star,           // ⭐ Excelencia (>90%)
  fire,           // 🔥 En racha (5 correctas)
  crown,          // 👑 Líder actual
}

/// Información de una medalla
class Medal {
  final MedalType type;
  final String name;
  final String description;
  final String emoji;
  final DateTime earnedAt;
  final String? activityId;  // Actividad donde se ganó (si aplica)

  Medal({
    required this.type,
    required this.name,
    required this.description,
    required this.emoji,
    DateTime? earnedAt,
    this.activityId,
  }) : earnedAt = earnedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'name': name,
    'description': description,
    'emoji': emoji,
    'earnedAt': earnedAt.toIso8601String(),
    'activityId': activityId,
  };

  factory Medal.fromJson(Map<String, dynamic> json) => Medal(
    type: MedalType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MedalType.star,
    ),
    name: json['name'],
    description: json['description'],
    emoji: json['emoji'],
    earnedAt: json['earnedAt'] != null ? DateTime.parse(json['earnedAt']) : null,
    activityId: json['activityId'],
  );
}

/// Factory para crear medallas predefinidas
class MedalFactory {
  static Medal gold() => Medal(
    type: MedalType.gold,
    name: 'Oro',
    description: '¡Primer lugar en la clase!',
    emoji: '🥇',
  );

  static Medal silver() => Medal(
    type: MedalType.silver,
    name: 'Plata',
    description: '¡Segundo lugar - Excelente!',
    emoji: '🥈',
  );

  static Medal bronze() => Medal(
    type: MedalType.bronze,
    name: 'Bronce',
    description: '¡Tercer lugar - Muy bien!',
    emoji: '🥉',
  );

  static Medal perfectScore({String? activityId}) => Medal(
    type: MedalType.perfectScore,
    name: 'Perfecto',
    description: '¡Respuesta perfecta!',
    emoji: '💯',
    activityId: activityId,
  );

  static Medal speedster({String? activityId}) => Medal(
    type: MedalType.speedster,
    name: 'Veloz',
    description: '¡Respuesta más rápida!',
    emoji: '⚡',
    activityId: activityId,
  );

  static Medal consistent() => Medal(
    type: MedalType.consistent,
    name: 'Consistente',
    description: '3 respuestas correctas seguidas',
    emoji: '🎯',
  );

  static Medal scholar() => Medal(
    type: MedalType.scholar,
    name: 'Estudioso',
    description: 'Respondió todas las actividades',
    emoji: '📚',
  );

  static Medal earlyBird({String? activityId}) => Medal(
    type: MedalType.earlyBird,
    name: 'Madrugador',
    description: '¡Primero en responder!',
    emoji: '🐦',
    activityId: activityId,
  );

  static Medal improver() => Medal(
    type: MedalType.improver,
    name: 'Mejorando',
    description: '¡Gran mejora desde la última actividad!',
    emoji: '📈',
  );

  static Medal champion() => Medal(
    type: MedalType.champion,
    name: 'Campeón',
    description: '¡Campeón de la sesión!',
    emoji: '🏆',
  );

  static Medal star() => Medal(
    type: MedalType.star,
    name: 'Estrella',
    description: '¡Rendimiento excelente!',
    emoji: '⭐',
  );

  static Medal fire() => Medal(
    type: MedalType.fire,
    name: 'En Racha',
    description: '¡5 respuestas correctas seguidas!',
    emoji: '🔥',
  );

  static Medal crown() => Medal(
    type: MedalType.crown,
    name: 'Líder',
    description: '¡Eres el líder de la clase!',
    emoji: '👑',
  );
}

/// Obtiene la CLASIFICACIÓN según el porcentaje
StudentClassification getClassification(double percentage) {
  if (percentage >= 100) return StudentClassification.winner;
  if (percentage >= 90) return StudentClassification.excellent;
  if (percentage >= 80) return StudentClassification.veryGood;
  if (percentage >= 70) return StudentClassification.approved;
  if (percentage >= 60) return StudentClassification.basic;
  return StudentClassification.failed;
}

/// Obtiene el texto de CLASIFICACIÓN (para docente)
String getClassificationText(StudentClassification classification) {
  switch (classification) {
    case StudentClassification.winner:
      return 'Ganador';
    case StudentClassification.excellent:
      return 'Excelente';
    case StudentClassification.veryGood:
      return 'Muy bueno';
    case StudentClassification.approved:
      return 'Aprobado';
    case StudentClassification.basic:
      return 'Básico';
    case StudentClassification.failed:
      return 'Pérdida';
  }
}

/// Obtiene el ícono de CLASIFICACIÓN
String getClassificationIcon(StudentClassification classification) {
  switch (classification) {
    case StudentClassification.winner:
      return '🏆';
    case StudentClassification.excellent:
      return '⭐';
    case StudentClassification.veryGood:
      return '👍';
    case StudentClassification.approved:
      return '✅';
    case StudentClassification.basic:
      return '📚';
    case StudentClassification.failed:
      return '💪';
  }
}

/// Obtiene mensaje motivacional para el estudiante
String getMotivationalMessage(double percentage) {
  if (percentage >= 100) return '¡Excelente! Dominaste el tema 👏';
  if (percentage >= 90) return 'Muy buen trabajo, casi perfecto 💪';
  if (percentage >= 80) return 'Vas muy bien, sigue así 🔥';
  if (percentage >= 70) return 'Buen avance, puedes mejorar 👍';
  if (percentage >= 60) return 'Buen intento, sigue practicando 📘';
  return '¡Ánimo, cada clase es una nueva oportunidad! 🌱';
}

// ============================================================
// MODELO: ESTUDIANTE
// ============================================================

class Student {
  final String sessionId;       // ID temporal de sesión (generado)
  final String name;            // Nombre ingresado
  StudentConnectionStatus status;
  double accumulatedPercentage; // Porcentaje acumulado (0-100)
  final DateTime connectedAt;
  DateTime? lastActivityAt;
  
  // Respuestas del estudiante: activityId -> StudentResponse
  final Map<String, StudentResponse> responses;
  
  // Reflexiones del estudiante
  final List<StudentReflection> reflections;
  
  // SISTEMA DE MEDALLAS
  final List<Medal> medals;
  int consecutiveCorrect;  // Respuestas correctas consecutivas
  int totalActivitiesAnswered;

  Student({
    required this.sessionId,
    required this.name,
    this.status = StudentConnectionStatus.connected,
    this.accumulatedPercentage = 0.0,
    DateTime? connectedAt,
    this.lastActivityAt,
    Map<String, StudentResponse>? responses,
    List<StudentReflection>? reflections,
    List<Medal>? medals,
    this.consecutiveCorrect = 0,
    this.totalActivitiesAnswered = 0,
  }) : connectedAt = connectedAt ?? DateTime.now(),
       responses = responses ?? {},
       reflections = reflections ?? [],
       medals = medals ?? [];

  /// CLASIFICACIÓN actual del estudiante
  StudentClassification get classification => 
      getClassification(accumulatedPercentage);
  
  /// Mensaje motivacional actual
  String get motivationalMessage => 
      getMotivationalMessage(accumulatedPercentage);
  
  /// ícono de CLASIFICACIÓN
  String get classificationIcon => 
      getClassificationIcon(classification);
  
  /// Cantidad total de medallas
  int get medalCount => medals.length;
  
  /// Verifica si tiene una medalla específica
  bool hasMedal(MedalType type) => medals.any((m) => m.type == type);
  
  /// Obtiene las medallas más recientes (hasta 5)
  List<Medal> get recentMedals => 
      medals.length <= 5 ? medals : medals.sublist(medals.length - 5);
  
  /// String con emojis de las medallas recientes
  String get medalsDisplay => medals.map((m) => m.emoji).join(' ');

  /// Verifica si el estudiante ya respondió una actividad
  bool hasResponded(String activityId) => responses.containsKey(activityId);

  /// Agrega una respuesta y recalcula el porcentaje
  void addResponse(StudentResponse response) {
    responses[response.activityId] = response;
    lastActivityAt = DateTime.now();
    
    if (response.isCorrect) {
      accumulatedPercentage += response.percentageValue;
      // Limitar a 100%
      if (accumulatedPercentage > 100) accumulatedPercentage = 100;
    }
    
    status = StudentConnectionStatus.responded;
  }

  /// Agrega una reflexión
  void addReflection(StudentReflection reflection) {
    reflections.add(reflection);
    lastActivityAt = DateTime.now();
  }

  /// Resetea el estado para nueva actividad
  void resetForNewActivity() {
    status = StudentConnectionStatus.notResponded;
  }

  /// Agrega una medalla al estudiante
  void addMedal(Medal medal) {
    // Evitar duplicados del mismo tipo
    if (!hasMedal(medal.type)) {
      medals.add(medal);
    }
  }
  
  /// Actualiza rachas de respuestas correctas
  void updateStreak(bool isCorrect, {String? activityId}) {
    totalActivitiesAnswered++;
    
    if (isCorrect) {
      consecutiveCorrect++;
      
      // Medalla por 3 correctas seguidas
      if (consecutiveCorrect == 3 && !hasMedal(MedalType.consistent)) {
        addMedal(MedalFactory.consistent());
      }
      
      // Medalla por 5 correctas seguidas (racha de fuego)
      if (consecutiveCorrect == 5 && !hasMedal(MedalType.fire)) {
        addMedal(MedalFactory.fire());
      }
    } else {
      consecutiveCorrect = 0;  // Resetea la racha
    }
  }

  /// Convierte a JSON para envío por WebSocket
  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'name': name,
    'status': status.name,
    'accumulatedPercentage': accumulatedPercentage,
    'connectedAt': connectedAt.toIso8601String(),
    'lastActivityAt': lastActivityAt?.toIso8601String(),
    'classification': classification.name,
    'classificationIcon': classificationIcon,
    'medals': medals.map((m) => m.toJson()).toList(),
    'medalsDisplay': medalsDisplay,
    'medalCount': medalCount,
    'consecutiveCorrect': consecutiveCorrect,
    'totalActivitiesAnswered': totalActivitiesAnswered,
  };

  /// Crea estudiante desde JSON
  factory Student.fromJson(Map<String, dynamic> json) => Student(
    sessionId: json['sessionId'],
    name: json['name'],
    status: StudentConnectionStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => StudentConnectionStatus.connected,
    ),
    accumulatedPercentage: (json['accumulatedPercentage'] ?? 0).toDouble(),
    connectedAt: json['connectedAt'] != null 
        ? DateTime.parse(json['connectedAt']) 
        : null,
    lastActivityAt: json['lastActivityAt'] != null 
        ? DateTime.parse(json['lastActivityAt']) 
        : null,
    medals: json['medals'] != null
        ? (json['medals'] as List).map((m) => Medal.fromJson(m)).toList()
        : null,
    consecutiveCorrect: json['consecutiveCorrect'] ?? 0,
    totalActivitiesAnswered: json['totalActivitiesAnswered'] ?? 0,
  );

  /// Versión resumida para dashboard (con medallas)
  Map<String, dynamic> toSummary() => {
    'sessionId': sessionId,
    'name': name,
    'status': status.name,
    'accumulatedPercentage': accumulatedPercentage,
    'classification': classification.name,
    'classificationIcon': classificationIcon,
    'medalsDisplay': medalsDisplay,
    'medalCount': medalCount,
    'consecutiveCorrect': consecutiveCorrect,
  };
}

// ============================================================
// MODELO: RESPUESTA DE ESTUDIANTE
// ============================================================

class StudentResponse {
  final String activityId;
  final String studentSessionId;
  final StudentActivityType activityType;
  final dynamic answer;           // int para MC, bool para T/F, String para corta
  final bool isCorrect;
  final double percentageValue;   // Valor porcentual de la actividad
  final DateTime answeredAt;
  final int? responseTimeMs;      // Tiempo de respuesta en milisegundos

  StudentResponse({
    required this.activityId,
    required this.studentSessionId,
    required this.activityType,
    required this.answer,
    required this.isCorrect,
    required this.percentageValue,
    DateTime? answeredAt,
    this.responseTimeMs,
  }) : answeredAt = answeredAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'activityId': activityId,
    'studentSessionId': studentSessionId,
    'activityType': activityType.name,
    'answer': answer,
    'isCorrect': isCorrect,
    'percentageValue': percentageValue,
    'answeredAt': answeredAt.toIso8601String(),
    'responseTimeMs': responseTimeMs,
  };

  factory StudentResponse.fromJson(Map<String, dynamic> json) => StudentResponse(
    activityId: json['activityId'],
    studentSessionId: json['studentSessionId'],
    activityType: StudentActivityType.values.firstWhere(
      (e) => e.name == json['activityType'],
      orElse: () => StudentActivityType.multipleChoice,
    ),
    answer: json['answer'],
    isCorrect: json['isCorrect'] ?? false,
    percentageValue: (json['percentageValue'] ?? 0).toDouble(),
    answeredAt: json['answeredAt'] != null 
        ? DateTime.parse(json['answeredAt']) 
        : null,
    responseTimeMs: json['responseTimeMs'],
  );
}

// ============================================================
// MODELO: reflexión DE ESTUDIANTE
// ============================================================

class StudentReflection {
  final String id;
  final String studentSessionId;
  final String studentName;
  final String topic;             // Tema asociado
  final String content;           // Texto de la reflexión
  final DateTime createdAt;

  StudentReflection({
    required this.id,
    required this.studentSessionId,
    required this.studentName,
    required this.topic,
    required this.content,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentSessionId': studentSessionId,
    'studentName': studentName,
    'topic': topic,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
  };

  factory StudentReflection.fromJson(Map<String, dynamic> json) => StudentReflection(
    id: json['id'],
    studentSessionId: json['studentSessionId'],
    studentName: json['studentName'] ?? 'Anónimo',
    topic: json['topic'],
    content: json['content'],
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : null,
  );
}

// ============================================================
// MODELO: ACTIVIDAD PARA ESTUDIANTE
// ============================================================

class StudentActivity {
  final String id;
  final StudentActivityType type;
  final String question;
  final List<String> options;           // Opciones (MC) o ["Verdadero", "Falso"] (T/F)
  final double percentageValue;         // Valor porcentual (ej: 10%)
  ActivityState state;
  final int? timeLimitSeconds;          // Límite de tiempo opcional
  final int correctOptionIndex;         // Índice correcto (NO visible para estudiante, -1 si no se conoce)
  final String? title;                  // Título de la actividad (ej: "Actividad 3: Identifica el libro")
  final String? slideContent;           // Contenido de la diapositiva (ej: la cita bíblica)
  final String? biblicalReference;      // Referencia bíblica (ej: "Eclesiastés 1:2")
  
  StudentActivity({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.percentageValue,
    this.state = ActivityState.locked,
    this.timeLimitSeconds,
    this.correctOptionIndex = -1,  // -1 significa "no revelado"
    this.title,
    this.slideContent,
    this.biblicalReference,
  });

  bool get isLocked => state == ActivityState.locked;
  bool get isActive => state == ActivityState.active;
  bool get isClosed => state == ActivityState.closed;

  /// Versión para estudiante (sin respuesta correcta)
  Map<String, dynamic> toStudentJson() => {
    'id': id,
    'type': type.name,
    'question': question,
    'options': options,
    'percentageValue': percentageValue,
    'state': state.name,
    'timeLimitSeconds': timeLimitSeconds,
    'title': title,
    'slideContent': slideContent,
    'biblicalReference': biblicalReference,
  };

  /// Versión completa (para backend/docente)
  Map<String, dynamic> toJson() => {
    ...toStudentJson(),
    'correctOptionIndex': correctOptionIndex,
  };

  factory StudentActivity.fromJson(Map<String, dynamic> json) => StudentActivity(
    id: json['id'],
    type: StudentActivityType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => StudentActivityType.multipleChoice,
    ),
    question: json['question'],
    options: List<String>.from(json['options'] ?? []),
    percentageValue: (json['percentageValue'] ?? 0).toDouble(),
    state: ActivityState.values.firstWhere(
      (e) => e.name == json['state'],
      orElse: () => ActivityState.locked,
    ),
    timeLimitSeconds: json['timeLimitSeconds'],
    correctOptionIndex: json['correctOptionIndex'] ?? json['correctIndex'] ?? -1,  // -1 si no viene del servidor
    title: json['title'],
    slideContent: json['slideContent'],
    biblicalReference: json['biblicalReference'],
  );
}

// ============================================================
// MODELO: RESUMEN DE CLASE PARA DASHBOARD DOCENTE
// ============================================================

class ClassDashboardSummary {
  final List<Student> connectedStudents;
  final int totalStudents;
  final int respondedCount;
  final int notRespondedCount;
  final String? currentActivityId;
  final ActivityState? currentActivityState;
  final Map<String, int> voteCounts; // Nuevo: conteo de votos por opción

  ClassDashboardSummary({
    required this.connectedStudents,
    required this.totalStudents,
    required this.respondedCount,
    required this.notRespondedCount,
    this.currentActivityId,
    this.currentActivityState,
    this.voteCounts = const {},
  });

  int get pendingCount => totalStudents - respondedCount;
  
  double get responseRate => totalStudents > 0 
      ? (respondedCount / totalStudents) * 100 
      : 0;
  
  /// Obtiene el conteo de votos para una opción específica
  int getVoteCount(int optionIndex) => voteCounts[optionIndex.toString()] ?? 0;
  
  /// Obtiene el total de votos
  int get totalVotes => voteCounts.values.fold(0, (sum, count) => sum + count);

  Map<String, dynamic> toJson() => {
    'students': connectedStudents.map((s) => s.toSummary()).toList(),
    'totalStudents': totalStudents,
    'respondedCount': respondedCount,
    'notRespondedCount': notRespondedCount,
    'currentActivityId': currentActivityId,
    'currentActivityState': currentActivityState?.name,
    'responseRate': responseRate,
    'voteCounts': voteCounts,
  };

  factory ClassDashboardSummary.fromJson(Map<String, dynamic> json) {
    final studentsList = (json['students'] as List?)
        ?.map((s) => Student.fromJson(s))
        .toList() ?? [];
    
    // Parsear voteCounts
    final voteCountsRaw = json['voteCounts'] as Map<String, dynamic>? ?? {};
    final voteCounts = voteCountsRaw.map((key, value) => MapEntry(key, value as int));
    
    return ClassDashboardSummary(
      connectedStudents: studentsList,
      totalStudents: json['totalStudents'] ?? studentsList.length,
      respondedCount: json['respondedCount'] ?? 0,
      notRespondedCount: json['notRespondedCount'] ?? 0,
      currentActivityId: json['currentActivityId'],
      currentActivityState: json['currentActivityState'] != null
          ? ActivityState.values.firstWhere(
              (e) => e.name == json['currentActivityState'],
              orElse: () => ActivityState.locked,
            )
          : null,
      voteCounts: voteCounts,
    );
  }
}

