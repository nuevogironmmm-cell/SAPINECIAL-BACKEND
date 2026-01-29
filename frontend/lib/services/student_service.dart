import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student_model.dart';

/// Servicio de estudiante para gesti?n de sesi?n y comunicaci?n en tiempo real
/// 
/// Maneja:
/// - Registro e identificaci?n del estudiante (sin cuenta)
/// - Conexi?n WebSocket con reconexi?n autom?tica
/// - Env?o de respuestas y reflexiones
/// - Sincronizaci?n de estado con el servidor
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
  
  // Actividad actual
  StudentActivity? _currentActivity;
  bool _hasResponded = false;
  
  // Estado de la clase
  String _classState = "LOBBY";
  int _currentSlide = 0;
  int _currentBlock = 0;
  
  // Configuraci?n de reconexi?n
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  Timer? _reconnectTimer;
  bool _shouldReconnect = true;
  
  // Stream controllers
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _activityController = StreamController<StudentActivity?>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  
  // URL del servidor
  static const String _baseUrl = 'ws://localhost:8000/ws/student';
  
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
  
  String get classState => _classState;
  int get currentSlide => _currentSlide;
  int get currentBlock => _currentBlock;
  
  double get accumulatedPercentage => _currentStudent?.accumulatedPercentage ?? 0.0;
  String get motivationalMessage => _currentStudent?.motivationalMessage ?? '';
  String get classificationIcon => _currentStudent?.classificationIcon ?? '';
  
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<StudentActivity?> get activityStream => _activityController.stream;
  Stream<String> get errorStream => _errorController.stream;
  
  // ============================================================
  // CONEXI?N Y REGISTRO
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
          debugPrint('[StudentService] Conexi?n cerrada');
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
    
    // Validaci?n local
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
    
    // Esperar respuesta (con timeout)
    try {
      final response = await messageStream
          .where((msg) => msg['type'] == 'REGISTRATION_SUCCESS' || 
                         msg['type'] == 'REGISTRATION_ERROR')
          .first
          .timeout(const Duration(seconds: 5));
      
      if (response['type'] == 'REGISTRATION_SUCCESS') {
        final data = response['data'];
        _sessionId = data['sessionId'];
        _studentName = data['name'];
        _isRegistered = true;
        
        // Crear objeto Student
        _currentStudent = Student.fromJson(data);
        
        // Guardar nombre para reconexi?n
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
  
  /// Env?a respuesta a una actividad
  Future<bool> submitAnswer(int answerIndex, {int? responseTimeMs}) async {
    if (!canRespond) {
      _errorMessage = 'No puedes responder en este momento';
      notifyListeners();
      return false;
    }
    
    _sendMessage({
      'action': 'SUBMIT_ANSWER',
      'payload': {
        'activityId': _currentActivity!.id,
        'answer': answerIndex,
        'responseTimeMs': responseTimeMs,
      }
    });
    
    // Marcar como respondido localmente
    _hasResponded = true;
    notifyListeners();
    
    // Esperar confirmaci?n
    try {
      final response = await messageStream
          .where((msg) => msg['type'] == 'ANSWER_RECEIVED' || 
                         msg['type'] == 'ERROR')
          .first
          .timeout(const Duration(seconds: 5));
      
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
        _hasResponded = false; // Permitir reintentar
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexi?n';
      _hasResponded = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Env?a una reflexi?n
  Future<bool> submitReflection(String topic, String content) async {
    if (!_isRegistered) {
      _errorMessage = 'Debes registrarte primero';
      notifyListeners();
      return false;
    }
    
    content = content.trim();
    if (content.length < 10) {
      _errorMessage = 'La reflexi?n debe tener al menos 10 caracteres';
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
    
    // Esperar confirmaci?n
    try {
      final response = await messageStream
          .where((msg) => msg['type'] == 'REFLECTION_RECEIVED' || 
                         msg['type'] == 'ERROR')
          .first
          .timeout(const Duration(seconds: 5));
      
      if (response['type'] == 'REFLECTION_RECEIVED') {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['data']?['message'] ?? 'Error al enviar reflexi?n';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error de conexi?n';
      notifyListeners();
      return false;
    }
  }
  
  /// Solicita actualizaci?n de estado
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
    }
    
    notifyListeners();
  }
  
  void _handleActivityUnlocked(Map<String, dynamic> data) {
    _currentActivity = StudentActivity.fromJson(data);
    _hasResponded = false; // Nueva actividad
    _activityController.add(_currentActivity);
    notifyListeners();
  }
  
  void _handleAnswerRevealed(Map<String, dynamic> data) {
    // El docente revel? la respuesta correcta
    // El estudiante ahora puede ver si acert?
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
  // RECONEXI?N
  // ============================================================
  
  void _handleDisconnect() {
    _isConnected = false;
    notifyListeners();
  }
  
  void _attemptReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[StudentService] Reconexi?n cancelada');
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
