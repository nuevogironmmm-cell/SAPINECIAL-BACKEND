import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';
import '../config/app_config.dart';

/// Servicio de estudiante para gestión de sesión y comunicación en tiempo real
/// 
/// Maneja:
/// - Registro e identificación del estudiante (sin cuenta)
/// - conexión WebSocket con reconexión automática
/// - Envío de respuestas y reflexiones
/// - sincronización de estado con el servidor
class StudentService extends ChangeNotifier {
  // ============================================================
  // ESTADO DEL SERVICIO
  // ============================================================
  
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isRegistered = false;
  String? _errorMessage;
  
  // Datos del estudiante
  Student? _currentStudent;
  String? _sessionId;
  String? _studentName;
  
  // Actividad actual (la más reciente desbloqueada)
  StudentActivity? _currentActivity;
  bool _hasResponded = false;
  
  // LISTA DE TODAS LAS ACTIVIDADES ACTIVAS
  final List<StudentActivity> _activeActivities = [];
  final Map<String, bool> _activityResponses = {}; // activityId -> hasResponded
  
  // Estado de la clase
  String _classState = "LOBBY";
  int _currentSlide = 0;
  int _currentBlock = 0;
  
  // Configuración de reconexión
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  Timer? _reconnectTimer;
  bool _shouldReconnect = true;
  
  // Stream controllers
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _activityController = StreamController<StudentActivity?>.broadcast();
  final _activitiesController = StreamController<List<StudentActivity>>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  
  // URL del servidor (dinámica según entorno)
  String get _baseUrl => AppConfig.studentWsUrl;
  
  // ============================================================
  // GETTERS
  // ============================================================
  
  bool get isConnected => _isConnected;
  bool get isRegistered => _isRegistered;
  String? get errorMessage => _errorMessage;
  
  Student? get currentStudent => _currentStudent;
  String? get sessionId => _sessionId;
  String? get studentName => _studentName;
  
  StudentActivity? get currentActivity => _currentActivity;
  bool get hasResponded => _hasResponded;
  bool get canRespond => _currentActivity != null && 
                         _currentActivity!.isActive && 
                         !_hasResponded;
  
  // NUEVOS GETTERS PARA MÚLTIPLES ACTIVIDADES
  List<StudentActivity> get activeActivities => List.unmodifiable(_activeActivities);
  int get activeActivitiesCount => _activeActivities.length;
  int get pendingActivitiesCount => _activeActivities.where((a) => !hasRespondedActivity(a.id)).length;
  
  /// Verifica si ya respondió una actividad específica
  bool hasRespondedActivity(String activityId) {
    return _activityResponses[activityId] == true ||
           (_currentStudent?.hasResponded(activityId) ?? false);
  }
  
  /// Verifica si puede responder una actividad específica
  bool canRespondActivity(String activityId) {
    final activity = _activeActivities.firstWhere(
      (a) => a.id == activityId,
      orElse: () => StudentActivity(
        id: '', 
        question: '', 
        options: [], 
        percentageValue: 0,
        type: StudentActivityType.multipleChoice,
        correctOptionIndex: 0,
      ),
    );
    return activity.id.isNotEmpty && activity.isActive && !hasRespondedActivity(activityId);
  }
  
  String get classState => _classState;
  int get currentSlide => _currentSlide;
  int get currentBlock => _currentBlock;
  
  double get accumulatedPercentage => _currentStudent?.accumulatedPercentage ?? 0.0;
  String get motivationalMessage => _currentStudent?.motivationalMessage ?? '';
  String get classificationIcon => _currentStudent?.classificationIcon ?? '';
  
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<List<StudentActivity>> get activitiesStream => _activitiesController.stream;
  Stream<StudentActivity?> get activityStream => _activityController.stream;
  Stream<String> get errorStream => _errorController.stream;
  
  // ============================================================
  // conexión Y REGISTRO
  // ============================================================
  
  /// Conecta al servidor WebSocket
  Future<bool> connect() async {
    if (_isConnected) return true;
    
    _shouldReconnect = true;
    _errorMessage = null;
    
    try {
      final uri = Uri.parse(_baseUrl);
      _channel = WebSocketChannel.connect(uri);
      
      // Escuchar mensajes
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('[StudentService] Error: $error');
          _handleDisconnect();
          _attemptReconnect();
        },
        onDone: () {
          debugPrint('[StudentService] Conexión cerrada');
          _handleDisconnect();
          _attemptReconnect();
        },
      );
      
      _isConnected = true;
      _reconnectAttempts = 0;
      debugPrint('[StudentService] Conectado al servidor');
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('[StudentService] Error al conectar: $e');
      _errorMessage = 'No se pudo conectar al servidor';
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Registra al estudiante con su nombre
  Future<bool> register(String name, {bool reconnect = false}) async {
    if (!_isConnected) {
      final connected = await connect();
      if (!connected) return false;
    }
    
    name = name.trim();
    
    // Validación local
    if (name.length < 3) {
      _errorMessage = 'El nombre debe tener al menos 3 caracteres';
      notifyListeners();
      return false;
    }
    
    if (name.length > 50) {
      _errorMessage = 'El nombre no puede exceder 50 caracteres';
      notifyListeners();
      return false;
    }
    
    // Enviar solicitud de registro
    _sendMessage({
      'action': 'REGISTER',
      'payload': {
        'name': name,
        'reconnect': reconnect,
      }
    });
    
    // Esperar respuesta (con timeout más corto para mejor UX)
    try {
      final response = await messageStream
          .where((msg) => msg['type'] == 'REGISTRATION_SUCCESS' || 
                         msg['type'] == 'REGISTRATION_ERROR')
          .first
          .timeout(const Duration(seconds: 30));
      
      if (response['type'] == 'REGISTRATION_SUCCESS') {
        final data = response['data'];
        _sessionId = data['sessionId'];
        _studentName = data['name'];
        _isRegistered = true;
        
        // Crear objeto Student
        _currentStudent = Student.fromJson(data);
        
        // Guardar nombre para reconexión
        await _saveStudentName(name);
        
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['data']?['message'] ?? 'Error al registrar';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Tiempo de espera agotado';
      notifyListeners();
      return false;
    }
  }
  
  /// Intenta reconectar con nombre guardado
  Future<bool> tryReconnect() async {
    final savedName = await _getSavedStudentName();
    if (savedName != null && savedName.isNotEmpty) {
      return await register(savedName, reconnect: true);
    }
    return false;
  }
  
  // ============================================================
  // ACCIONES DE ESTUDIANTE
  // ============================================================
  
  /// Envía respuesta a una actividad específica
  Future<bool> submitAnswerForActivity(String activityId, int answerIndex, {int? responseTimeMs}) async {
    if (!canRespondActivity(activityId)) {
      _errorMessage = 'No puedes responder esta actividad';
      notifyListeners();
      return false;
    }
    
    _sendMessage({
      'action': 'SUBMIT_ANSWER',
      'payload': {
        'activityId': activityId,
        'answer': answerIndex,
        'responseTimeMs': responseTimeMs,
      }
    });
    
    // Marcar como respondido localmente
    _activityResponses[activityId] = true;
    if (_currentActivity?.id == activityId) {
      _hasResponded = true;
    }
    notifyListeners();
    
    // Esperar confirmación
    try {
      final response = await messageStream
          .where((msg) => msg['type'] == 'ANSWER_RECEIVED' || 
                         msg['type'] == 'ERROR')
          .first
          .timeout(const Duration(seconds: 15));
      
      if (response['type'] == 'ANSWER_RECEIVED') {
        final data = response['data'];
        // Actualizar porcentaje acumulado
        if (_currentStudent != null) {
          _currentStudent!.accumulatedPercentage = 
              (data['accumulatedPercentage'] ?? 0).toDouble();
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['data']?['message'] ?? 'Error al enviar respuesta';
        _activityResponses[activityId] = false; // Permitir reintentar
        if (_currentActivity?.id == activityId) {
          _hasResponded = false;
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión';
      _activityResponses[activityId] = false;
      if (_currentActivity?.id == activityId) {
        _hasResponded = false;
      }
      notifyListeners();
      return false;
    }
  }
  
  /// Envía respuesta a la actividad actual (método legacy)
  Future<bool> submitAnswer(int answerIndex, {int? responseTimeMs}) async {
    if (!canRespond) {
      _errorMessage = 'No puedes responder en este momento';
      notifyListeners();
      return false;
    }
    
    return submitAnswerForActivity(_currentActivity!.id, answerIndex, responseTimeMs: responseTimeMs);
  }
  
  /// Obtiene una actividad específica de la lista de activas
  StudentActivity? getActivity(String activityId) {
    try {
      return _activeActivities.firstWhere((a) => a.id == activityId);
    } catch (_) {
      return null;
    }
  }
  
  /// Envía una reflexión
  Future<bool> submitReflection(String topic, String content) async {
    if (!_isRegistered) {
      _errorMessage = 'Debes registrarte primero';
      notifyListeners();
      return false;
    }
    
    content = content.trim();
    if (content.length < 10) {
      _errorMessage = 'La reflexión debe tener al menos 10 caracteres';
      notifyListeners();
      return false;
    }
    
    _sendMessage({
      'action': 'SUBMIT_REFLECTION',
      'payload': {
        'topic': topic,
        'content': content,
      }
    });
    
    // Esperar confirmación
    try {
      final response = await messageStream
          .where((msg) => msg['type'] == 'REFLECTION_RECEIVED' || 
                         msg['type'] == 'ERROR')
          .first
          .timeout(const Duration(seconds: 15));
      
      if (response['type'] == 'REFLECTION_RECEIVED') {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['data']?['message'] ?? 'Error al enviar reflexión';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexión';
      notifyListeners();
      return false;
    }
  }
  
  /// Solicita actualización de estado
  void requestStateUpdate() {
    _sendMessage({'action': 'GET_STATE', 'payload': {}});
  }
  
  // ============================================================
  // MANEJO DE MENSAJES
  // ============================================================
  
  void _handleMessage(dynamic rawMessage) {
    try {
      final Map<String, dynamic> message = json.decode(rawMessage);
      debugPrint('[StudentService] Mensaje: ${message['type']}');
      
      final type = message['type'];
      final data = message['data'] ?? {};
      
      switch (type) {
        case 'REGISTRATION_REQUIRED':
          // El servidor solicita registro
          break;
          
        case 'REGISTRATION_SUCCESS':
          // Manejado en register()
          break;
          
        case 'REGISTRATION_ERROR':
          // Manejado en register()
          break;
          
        case 'STATE_UPDATE':
          _handleStateUpdate(data);
          break;
          
        case 'SLIDE_UPDATE':
          _currentSlide = data['slide'] ?? _currentSlide;
          _currentBlock = data['block'] ?? _currentBlock;
          notifyListeners();
          break;
          
        case 'ACTIVITY_UNLOCKED':
          _handleActivityUnlocked(data);
          break;
          
        case 'ACTIVITY_LOCKED':
          _currentActivity?.state = ActivityState.closed;
          _activityController.add(_currentActivity);
          notifyListeners();
          break;
        
        case 'ALL_ACTIVITIES_LOCKED':
          // Cerrar TODAS las actividades
          _handleAllActivitiesLocked();
          break;
          
        case 'ANSWER_RECEIVED':
          // Manejado en submitAnswer()
          break;
          
        case 'ANSWER_REVEALED':
          _handleAnswerRevealed(data);
          break;
          
        case 'STUDENT_UPDATE':
          if (_currentStudent != null) {
            _currentStudent = Student.fromJson(data);
            notifyListeners();
          }
          break;
          
        case 'ERROR':
          final errorMsg = data['message'] ?? 'Error desconocido';
          _errorMessage = errorMsg;
          _errorController.add(errorMsg);
          notifyListeners();
          break;
      }
      
      // Emitir al stream
      _messageController.add(message);
      
    } catch (e) {
      debugPrint('[StudentService] Error procesando mensaje: $e');
    }
  }
  
  void _handleStateUpdate(Map<String, dynamic> data) {
    _classState = data['state'] ?? _classState;
    _currentSlide = data['slide'] ?? _currentSlide;
    _currentBlock = data['block'] ?? _currentBlock;
    
    // Actualizar actividad actual si existe
    if (data['currentActivity'] != null) {
      _currentActivity = StudentActivity.fromJson(data['currentActivity']);
      _hasResponded = _currentStudent?.hasResponded(_currentActivity!.id) ?? false;
      _activityController.add(_currentActivity);
      
      // También agregar a la lista de activas si no existe
      _addActivityToActiveList(_currentActivity!);
    }
    
    // Si hay lista de actividades activas, cargarlas
    if (data['activeActivities'] != null) {
      final List activities = data['activeActivities'];
      for (final actData in activities) {
        final activity = StudentActivity.fromJson(actData);
        _addActivityToActiveList(activity);
      }
    }
    
    notifyListeners();
  }
  
  void _handleActivityUnlocked(Map<String, dynamic> data) {
    final newActivity = StudentActivity.fromJson(data);
    _currentActivity = newActivity;
    _hasResponded = false; // Nueva actividad
    
    // AGREGAR A LA LISTA DE ACTIVIDADES ACTIVAS
    _addActivityToActiveList(newActivity);
    
    _activityController.add(_currentActivity);
    _activitiesController.add(_activeActivities);
    notifyListeners();
  }
  
  /// Maneja cuando el docente cierra TODAS las actividades
  void _handleAllActivitiesLocked() {
    // Cerrar todas las actividades activas
    for (final activity in _activeActivities) {
      activity.state = ActivityState.closed;
    }
    
    // Limpiar la lista de actividades activas
    _activeActivities.clear();
    _currentActivity = null;
    _hasResponded = false;
    
    _activityController.add(null);
    _activitiesController.add(_activeActivities);
    notifyListeners();
    
    debugPrint('[StudentService] Todas las actividades cerradas');
  }
  
  /// Agrega una actividad a la lista de activas si no existe
  void _addActivityToActiveList(StudentActivity activity) {
    final existingIndex = _activeActivities.indexWhere((a) => a.id == activity.id);
    if (existingIndex == -1) {
      _activeActivities.add(activity);
      _activityResponses[activity.id] = false;
      debugPrint('[StudentService] Actividad añadida: ${activity.id} - Total: ${_activeActivities.length}');
    } else {
      // Actualizar la existente
      _activeActivities[existingIndex] = activity;
    }
  }
  
  void _handleAnswerRevealed(Map<String, dynamic> data) {
    // El docente reveló la respuesta correcta
    // El estudiante ahora puede ver si acertó
    final correctIndex = data['correctIndex'];
    if (_currentActivity != null && _currentStudent != null) {
      final response = _currentStudent!.responses[_currentActivity!.id];
      if (response != null) {
        // Marcar si fue correcta
        response.isCorrect;
      }
    }
    notifyListeners();
  }
  
  // ============================================================
  // reconexión
  // ============================================================
  
  void _handleDisconnect() {
    _isConnected = false;
    notifyListeners();
  }
  
  void _attemptReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[StudentService] reconexión cancelada');
      return;
    }
    
    _reconnectAttempts++;
    final delay = _initialReconnectDelay * (1 << (_reconnectAttempts - 1));
    
    debugPrint('[StudentService] Reintentando en ${delay.inSeconds}s');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      final connected = await connect();
      if (connected && _studentName != null) {
        // Intentar reconectar con el nombre guardado
        await register(_studentName!, reconnect: true);
      }
    });
  }
  
  // ============================================================
  // UTILIDADES
  // ============================================================
  
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(json.encode(message));
      } catch (e) {
        debugPrint('[StudentService] Error enviando: $e');
      }
    }
  }
  
  Future<void> _saveStudentName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_name', name);
    } catch (e) {
      debugPrint('[StudentService] Error guardando nombre: $e');
    }
  }
  
  Future<String?> _getSavedStudentName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('student_name');
    } catch (e) {
      return null;
    }
  }
  
  Future<void> clearSavedName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('student_name');
    } catch (e) {
      debugPrint('[StudentService] Error limpiando nombre: $e');
    }
  }
  
  /// Desconecta y limpia el estado
  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _isRegistered = false;
    _currentStudent = null;
    _sessionId = null;
    _currentActivity = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    disconnect();
    _messageController.close();
    _activityController.close();
    _errorController.close();
    super.dispose();
  }
}

