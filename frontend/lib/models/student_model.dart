/// Modelos de datos para la secci?n de estudiantes
/// 
/// Sistema de identificaci?n sin cuentas, basado en sesi?n temporal
/// Maneja actividades, respuestas, reflexiones y puntaje acumulado

import 'dart:convert';

// ============================================================
// ESTADO DE CONEXI?N DEL ESTUDIANTE
// ============================================================

enum StudentConnectionStatus {
  connected,      // Conectado y activo
  responded,      // Ha respondido la actividad actual
  notResponded,   // No ha respondido a?n
  disconnected,   // Desconectado
}

// ============================================================
// TIPOS DE ACTIVIDAD
// ============================================================

enum StudentActivityType {
  multipleChoice,   // Opci?n m?ltiple
  trueFalse,        // Verdadero / Falso
  shortAnswer,      // Respuesta corta
}

// ============================================================
// ESTADO DE ACTIVIDAD
// ============================================================

enum ActivityState {
  locked,   // Bloqueada - estudiante no puede responder
  active,   // Activa - estudiante puede responder
  closed,   // Cerrada - tiempo agotado o docente cerr?
}

// ============================================================
// CLASIFICACI?N POR PORCENTAJE
// ============================================================

enum StudentClassification {
  winner,     // 100%
  excellent,  // 90%+
  veryGood,   // 80%+
  approved,   // 70%+
  basic,      // 60%+
  failed,     // <50% (solo visible para docente)
}

/// Obtiene la clasificaci?n seg?n el porcentaje
StudentClassification getClassification(double percentage) {
  if (percentage >= 100) return StudentClassification.winner;
  if (percentage >= 90) return StudentClassification.excellent;
  if (percentage >= 80) return StudentClassification.veryGood;
  if (percentage >= 70) return StudentClassification.approved;
  if (percentage >= 60) return StudentClassification.basic;
  return StudentClassification.failed;
}

/// Obtiene el texto de clasificaci?n (para docente)
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
      return 'B?sico';
    case StudentClassification.failed:
      return 'Pérdida';
  }
}

/// Obtiene el ?cono de clasificaci?n
String getClassificationIcon(StudentClassification classification) {
  switch (classification) {
    case StudentClassification.winner:
      return '??';
    case StudentClassification.excellent:
      return '?';
    case StudentClassification.veryGood:
      return '??';
    case StudentClassification.approved:
      return '??';
    case StudentClassification.basic:
      return '??';
    case StudentClassification.failed:
      return '??';
  }
}

/// Obtiene mensaje motivacional para el estudiante
String getMotivationalMessage(double percentage) {
  if (percentage >= 100) return '?Excelente! Dominaste el tema ??';
  if (percentage >= 90) return 'Muy buen trabajo, casi perfecto ??';
  if (percentage >= 80) return 'Vas muy bien, sigue as? ??';
  if (percentage >= 70) return 'Buen avance, puedes mejorar ??';
  if (percentage >= 60) return 'Buen intento, sigue practicando ??';
  return '?nimo, cada clase es una nueva oportunidad ??';
}

// ============================================================
// MODELO: ESTUDIANTE
// ============================================================

class Student {
  final String sessionId;       // ID temporal de sesi?n (generado)
  final String name;            // Nombre ingresado
  StudentConnectionStatus status;
  double accumulatedPercentage; // Porcentaje acumulado (0-100)
  final DateTime connectedAt;
  DateTime? lastActivityAt;
  
  // Respuestas del estudiante: activityId -> StudentResponse
  final Map<String, StudentResponse> responses;
  
  // Reflexiones del estudiante
  final List<StudentReflection> reflections;

  Student({
    required this.sessionId,
    required this.name,
    this.status = StudentConnectionStatus.connected,
    this.accumulatedPercentage = 0.0,
    DateTime? connectedAt,
    this.lastActivityAt,
    Map<String, StudentResponse>? responses,
    List<StudentReflection>? reflections,
  }) : connectedAt = connectedAt ?? DateTime.now(),
       responses = responses ?? {},
       reflections = reflections ?? [];

  /// Clasificaci?n actual del estudiante
  StudentClassification get classification => 
      getClassification(accumulatedPercentage);
  
  /// Mensaje motivacional actual
  String get motivationalMessage => 
      getMotivationalMessage(accumulatedPercentage);
  
  /// ?cono de clasificaci?n
  String get classificationIcon => 
      getClassificationIcon(classification);

  /// Verifica si el estudiante ya respondi? una actividad
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

  /// Agrega una reflexi?n
  void addReflection(StudentReflection reflection) {
    reflections.add(reflection);
    lastActivityAt = DateTime.now();
  }

  /// Resetea el estado para nueva actividad
  void resetForNewActivity() {
    status = StudentConnectionStatus.notResponded;
  }

  /// Convierte a JSON para env?o por WebSocket
  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'name': name,
    'status': status.name,
    'accumulatedPercentage': accumulatedPercentage,
    'connectedAt': connectedAt.toIso8601String(),
    'lastActivityAt': lastActivityAt?.toIso8601String(),
    'classification': classification.name,
    'classificationIcon': classificationIcon,
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
  );

  /// Versi?n resumida para dashboard (sin datos sensibles)
  Map<String, dynamic> toSummary() => {
    'sessionId': sessionId,
    'name': name,
    'status': status.name,
    'accumulatedPercentage': accumulatedPercentage,
    'classification': classification.name,
    'classificationIcon': classificationIcon,
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
// MODELO: REFLEXI?N DE ESTUDIANTE
// ============================================================

class StudentReflection {
  final String id;
  final String studentSessionId;
  final String studentName;
  final String topic;             // Tema asociado
  final String content;           // Texto de la reflexi?n
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
    studentName: json['studentName'] ?? 'An?nimo',
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
  final int? timeLimitSeconds;          // L?mite de tiempo opcional
  final int correctOptionIndex;         // ?ndice correcto (no visible para estudiante)
  
  StudentActivity({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.percentageValue,
    this.state = ActivityState.locked,
    this.timeLimitSeconds,
    required this.correctOptionIndex,
  });

  bool get isLocked => state == ActivityState.locked;
  bool get isActive => state == ActivityState.active;
  bool get isClosed => state == ActivityState.closed;

  /// Versi?n para estudiante (sin respuesta correcta)
  Map<String, dynamic> toStudentJson() => {
    'id': id,
    'type': type.name,
    'question': question,
    'options': options,
    'percentageValue': percentageValue,
    'state': state.name,
    'timeLimitSeconds': timeLimitSeconds,
  };

  /// Versi?n completa (para backend/docente)
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
    correctOptionIndex: json['correctOptionIndex'] ?? 0,
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

  ClassDashboardSummary({
    required this.connectedStudents,
    required this.totalStudents,
    required this.respondedCount,
    required this.notRespondedCount,
    this.currentActivityId,
    this.currentActivityState,
  });

  int get pendingCount => totalStudents - respondedCount;
  
  double get responseRate => totalStudents > 0 
      ? (respondedCount / totalStudents) * 100 
      : 0;

  Map<String, dynamic> toJson() => {
    'students': connectedStudents.map((s) => s.toSummary()).toList(),
    'totalStudents': totalStudents,
    'respondedCount': respondedCount,
    'notRespondedCount': notRespondedCount,
    'currentActivityId': currentActivityId,
    'currentActivityState': currentActivityState?.name,
    'responseRate': responseRate,
  };

  factory ClassDashboardSummary.fromJson(Map<String, dynamic> json) {
    final studentsList = (json['students'] as List?)
        ?.map((s) => Student.fromJson(s))
        .toList() ?? [];
    
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
    );
  }
}
