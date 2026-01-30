import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/student_model.dart';
import '../config/app_config.dart';

/// Servicio del docente para gestión de clase y estudiantes
/// 
/// Maneja:
/// - Conexión WebSocket con el servidor
/// - Activación/desactivación de actividades para estudiantes
/// - Monitoreo de estudiantes conectados y sus respuestas
/// - Revelación de respuestas correctas
class TeacherService extends ChangeNotifier {
  // ============================================================
  // ESTADO DEL SERVICIO
  // ============================================================
  
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _errorMessage;
  
  // Dashboard de estudiantes
  ClassDashboardSummary? _dashboardSummary;
  List<StudentReflection> _reflections = [];
  
  // Actividad actual
  String? _currentActivityId;
  bool _activityActive = false;
  
  // Configuración
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  bool _shouldReconnect = true;
  
  // Stream controllers
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _dashboardController = StreamController<ClassDashboardSummary?>.broadcast();
  
  // URL del servidor (dinámica según entorno)
  String get _baseUrl => AppConfig.teacherWsUrl;
  String get _teacherToken => AppConfig.teacherToken;
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  bool get isConnected => _isConnected;
  String? get errorMessage => _errorMessage;
  
  ClassDashboardSummary? get dashboardSummary => _dashboardSummary;
  List<StudentReflection> get reflections => _reflections;
  
  /// Lista de estudiantes conectados
  List<Student> get connectedStudents => _dashboardSummary?.connectedStudents ?? [];
  
  int get connectedStudentsCount => _dashboardSummary?.totalStudents ?? 0;
  int get respondedCount => _dashboardSummary?.respondedCount ?? 0;
  int get pendingCount => _dashboardSummary?.pendingCount ?? 0;
  double get responseRate => _dashboardSummary?.responseRate ?? 0;
  
  String? get currentActivityId => _currentActivityId;
  bool get activityActive => _activityActive;
  
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<ClassDashboardSummary?> get dashboardStream => _dashboardController.stream;
  
  // ============================================================
  // Conexión
  // ============================================================
  
  /// Conecta al servidor WebSocket como docente
  Future<bool> connect() async {
    if (_isConnected) return true;
    
    _shouldReconnect = true;
    _errorMessage = null;
    
    try {
      final uri = Uri.parse('$_baseUrl?token=$_teacherToken');
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('[TeacherService] Error: $error');
          _handleDisconnect();
          _attemptReconnect();
        },
        onDone: () {
          debugPrint('[TeacherService] Conexión cerrada');
          _handleDisconnect();
          _attemptReconnect();
        },
      );
      
      _isConnected = true;
      _reconnectAttempts = 0;
      debugPrint('[TeacherService] Conectado al servidor');
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('[TeacherService] Error al conectar: $e');
      _errorMessage = 'No se pudo conectar al servidor';
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }
  
  // ============================================================
  // gestión DE ACTIVIDADES
  // ============================================================
  
  /// Registra una nueva actividad antes de habilitarla
  void registerActivity({
    required String activityId,
    required String question,
    required List<String> options,
    required int correctIndex,
    double percentageValue = 10.0,
    String activityType = 'multipleChoice',
    int? timeLimitSeconds,
    String? title,
    String? slideContent,
    String? biblicalReference,
  }) {
    _sendMessage({
      'action': 'REGISTER_ACTIVITY',
      'payload': {
        'activityId': activityId,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'percentageValue': percentageValue,
        'activityType': activityType,
        'timeLimitSeconds': timeLimitSeconds,
        'title': title,
        'slideContent': slideContent,
        'biblicalReference': biblicalReference,
      }
    });
    
    _currentActivityId = activityId;
    notifyListeners();
  }
  
  /// Habilita la actividad para que los estudiantes respondan
  void unlockActivity(String activityId) {
    _sendMessage({
      'action': 'UNLOCK_ACTIVITY',
      'payload': {'activityId': activityId}
    });
    
    _currentActivityId = activityId;
    _activityActive = true;
    notifyListeners();
  }
  
  /// Bloquea la actividad (estudiantes ya no pueden responder)
  void lockActivity() {
    _sendMessage({
      'action': 'LOCK_ACTIVITY',
      'payload': {}
    });
    
    _activityActive = false;
    notifyListeners();
  }
  
  /// Bloquea una actividad específica por su ID
  void lockSpecificActivity(String activityId) {
    _sendMessage({
      'action': 'LOCK_ACTIVITY',
      'payload': {'activityId': activityId}
    });
    
    if (_currentActivityId == activityId) {
      _activityActive = false;
    }
    notifyListeners();
  }
  
  /// Bloquea TODAS las actividades activas de una vez
  void lockAllActivities() {
    _sendMessage({
      'action': 'LOCK_ALL_ACTIVITIES',
      'payload': {}
    });
    
    _currentActivityId = null;
    _activityActive = false;
    notifyListeners();
  }
  
  /// Reinicia el progreso de TODOS los estudiantes (función de administrador)
  void resetAllStudentsProgress() {
    _sendMessage({
      'action': 'RESET_ALL_STUDENTS_PROGRESS',
      'payload': {}
    });
    
    // Limpiar estado local
    _currentActivityId = null;
    _activityActive = false;
    notifyListeners();
  }
  
  /// Revela la respuesta correcta a todos
  void revealAnswer(String activityId) {
    _sendMessage({
      'action': 'REVEAL_ANSWER',
      'payload': {'activityId': activityId}
    });
  }

  /// Expulsa a un estudiante de la clase
  void kickStudent(String studentId) {
    _sendMessage({
      'action': 'KICK_STUDENT',
      'payload': {'studentId': studentId}
    });
  }
  
  /// Solicita actualización del dashboard
  void requestDashboardUpdate() {
    _sendMessage({
      'action': 'REQUEST_DASHBOARD',
      'payload': {}
    });
  }
  
  /// Solicita lista de reflexiones
  void requestReflections() {
    _sendMessage({
      'action': 'GET_REFLECTIONS',
      'payload': {}
    });
  }
  
  /// Actualiza el slide actual
  void setSlide(int slideIndex, int blockIndex) {
    _sendMessage({
      'action': 'SET_SLIDE',
      'payload': {
        'slide': slideIndex,
        'block': blockIndex,
      }
    });
  }
  
  // ============================================================
  // MANEJO DE MENSAJES
  // ============================================================
  
  void _handleMessage(dynamic rawMessage) {
    try {
      final Map<String, dynamic> message = json.decode(rawMessage);
      debugPrint('[TeacherService] Mensaje: ${message['type']}');
      
      final type = message['type'];
      final data = message['data'] ?? {};
      
      switch (type) {
        case 'STATE_UPDATE':
          // Estado general de la clase
          break;
          
        case 'DASHBOARD_UPDATE':
          _handleDashboardUpdate(data);
          break;
          
        case 'ACTIVITY_REGISTERED':
          debugPrint('[TeacherService] Actividad registrada: ${data['id']}');
          break;
          
        case 'STUDENT_JOINED':
          // Un estudiante se uni?
          requestDashboardUpdate();
          break;
          
        case 'STUDENT_LEFT':
          // Un estudiante se desconect?
          requestDashboardUpdate();
          break;
          
        case 'STUDENT_RESPONDED':
          // Un estudiante respondió
          requestDashboardUpdate();
          break;
          
        case 'REFLECTIONS_LIST':
          _handleReflectionsList(data);
          break;
          
        case 'NEW_REFLECTION':
          _handleNewReflection(data);
          break;
        
        case 'STUDENTS_RESET_COMPLETE':
          // Progreso de estudiantes reiniciado
          debugPrint('[TeacherService] Progreso reiniciado: ${data['message']}');
          requestDashboardUpdate();
          break;
          
        case 'ERROR':
          _errorMessage = data['message'] ?? 'Error desconocido';
          notifyListeners();
          break;
      }
      
      _messageController.add(message);
      
    } catch (e) {
      debugPrint('[TeacherService] Error procesando mensaje: $e');
    }
  }
  
  void _handleDashboardUpdate(Map<String, dynamic> data) {
    _dashboardSummary = ClassDashboardSummary.fromJson(data);
    _dashboardController.add(_dashboardSummary);
    notifyListeners();
  }
  
  void _handleReflectionsList(Map<String, dynamic> data) {
    final reflectionsList = data['reflections'] as List? ?? [];
    _reflections = reflectionsList
        .map((r) => StudentReflection.fromJson(r))
        .toList();
    notifyListeners();
  }
  
  void _handleNewReflection(Map<String, dynamic> data) {
    final reflection = StudentReflection.fromJson(data);
    _reflections.insert(0, reflection);
    notifyListeners();
  }
  
  // ============================================================
  // REConexión
  // ============================================================
  
  void _handleDisconnect() {
    _isConnected = false;
    notifyListeners();
  }
  
  void _attemptReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[TeacherService] ReConexión cancelada');
      return;
    }
    
    _reconnectAttempts++;
    final delay = _initialReconnectDelay * (1 << (_reconnectAttempts - 1));
    
    debugPrint('[TeacherService] Reintentando en ${delay.inSeconds}s');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () => connect());
  }
  
  // ============================================================
  // UTILIDADES
  // ============================================================
  
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(json.encode(message));
        debugPrint('[TeacherService] Enviado: ${message['action']}');
      } catch (e) {
        debugPrint('[TeacherService] Error enviando: $e');
      }
    } else {
      debugPrint('[TeacherService] No conectado');
    }
  }
  
  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _dashboardSummary = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    disconnect();
    _messageController.close();
    _dashboardController.close();
    super.dispose();
  }
}

