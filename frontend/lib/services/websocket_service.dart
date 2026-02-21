import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/app_config.dart';

/// Servicio de conexión WebSocket con autenticación mejorada (Phase 1)
/// Maneja la comunicación en tiempo real entre profesor y estudiantes.
/// Soporta reconexión automática, manejo de errores mejorado y JWT integration.
class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool isConnected = false;
  String? currentRole;
  String? _authToken;
  
  // Estado sincronizado desde el servidor
  String currentState = "LOBBY";
  int currentSlide = 0;
  int currentBlock = 0;
  bool isLocked = true;

  // Configuración de reconexión mejorada
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  Timer? _reconnectTimer;
  bool _shouldReconnect = true;

  // Estados de conexión mejorados
  String? _lastError;
  DateTime? _lastConnectedAt;
  int _connectionAttempts = 0;

  // Stream controller para mensajes entrantes
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  // URLs del servidor (centralizadas en AppConfig)
  String get _baseUrl => AppConfig.wsBaseUrl;
  String get _devUrl => '${AppConfig.wsBaseUrl}/ws-dev'; // Sin autenticación

  /// Conecta al WebSocket con autenticación
  /// [role] puede ser 'teacher' o 'student'
  /// [token] es requerido para autenticación (profesor: AppConfig.teacherToken)
  Future<bool> connect(String role, {String? token}) async {
    if (isConnected) return true;
    
    currentRole = role;
    _authToken = token;
    _shouldReconnect = true;
    
    try {
      final uri = _getWebSocketUri(role, token);
      _channel = WebSocketChannel.connect(uri);
      
      // Escuchar mensajes del servidor
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          _handleError(error);
          _handleDisconnect();
          _attemptReconnect();
        },
        onDone: () {
          debugPrint('[WebSocket] Conexión cerrada normalmente');
          _handleDisconnect();
          _attemptReconnect();
        },
      );

      isConnected = true;
      _reconnectAttempts = 0;
      _lastConnectedAt = DateTime.now();
      _connectionAttempts++;
      _lastError = null;
      
      debugPrint('[WebSocket] Conectado como: $role');
      notifyListeners();
      return true;
      
    } catch (e) {
      _handleError(e.toString());
      _handleDisconnect();
      notifyListeners();
      return false;
    }
  }

  /// Construye la URI del WebSocket según rol y token
  Uri _getWebSocketUri(String role, String? token) {
    // Usar siempre la URL de producción para evitar errores en modo desarrollo
    if (token != null && token.isNotEmpty) {
      return Uri.parse('${AppConfig.wsBaseUrl}/ws/$role?token=$token');
    } else {
      // Para desarrollo sin autenticación, usar endpoint de desarrollo
      return Uri.parse('$_devUrl/$role');
    }
  }

  /// Intenta reconectar con backoff exponencial
  void _attemptReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[WebSocket] Reconexión cancelada (intentos: $_reconnectAttempts/$_maxReconnectAttempts)');
      return;
    }

    _reconnectAttempts++;
    final delay = _initialReconnectDelay * (1 << (_reconnectAttempts - 1));
    
    debugPrint('[WebSocket] Reintentando en ${delay.inSeconds}s (intento $_reconnectAttempts/$_maxReconnectAttempts)');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (currentRole != null) {
        connect(currentRole!, token: _authToken);
      }
    });
  }

  /// Maneja errores de conexión
  void _handleError(String error) {
    _lastError = error;
    debugPrint('[WebSocket] Error: $error');
    
    // Analizar tipo de error para acciones específicas
    if (error.contains('AUTH_FAILED')) {
      debugPrint('[WebSocket] Error de autenticación - Cancelando reconexión');
      _shouldReconnect = false;
    } else if (error.contains('Connection refused')) {
      debugPrint('[WebSocket] Conexión rechazada - Posible servidor no iniciado');
    } else if (error.contains('Network is unreachable')) {
      debugPrint('[WebSocket] Sin conexión a red - Reintentando...');
    }
  }

  /// Maneja desconexión
  void _handleDisconnect() {
    isConnected = false;
    debugPrint('[WebSocket] Desconectado');
    notifyListeners();
  }

  /// Procesa mensajes del servidor
  void _handleMessage(dynamic rawMessage) {
    try {
      final Map<String, dynamic> message = json.decode(rawMessage);
      debugPrint('[WebSocket] Mensaje recibido: ${message['type']}');
      
      // Manejar error de autenticación
      if (message['type'] == 'ERROR') {
        final code = message['data']?['code'];
        if (code == 'AUTH_FAILED') {
          debugPrint('[WebSocket] Error de autenticación detectado');
          _shouldReconnect = false;
          _lastError = 'Autenticación fallida';
        }
      }
      
      // Procesar según tipo de mensaje
      switch (message['type']) {
        case 'STATE_UPDATE':
          _handleStateUpdate(message['data']);
          break;
        case 'SLIDE_UPDATE':
          _handleSlideUpdate(message['data']);
          break;
        case 'ACTIVITY_STATUS':
          _handleActivityStatus(message['data']);
          break;
        case 'ACTIVITY_UNLOCKED':
          _handleActivityUnlocked(message['data']);
          break;
        case 'ACTIVITY_LOCKED':
          _handleActivityLocked();
          break;
        case 'ANSWER_REVEALED':
          _handleAnswerRevealed(message['data']);
          break;
        case 'REGISTRATION_REQUIRED':
          _handleRegistrationRequired();
          break;
        case 'REGISTRATION_SUCCESS':
          _handleRegistrationSuccess(message['data']);
          break;
        case 'REGISTRATION_ERROR':
          _handleRegistrationError(message['data']);
          break;
        case 'ANSWER_RECEIVED':
          _handleAnswerReceived(message['data']);
          break;
        case 'PROGRESS_RESET':
          _handleProgressReset(message['data']);
          break;
        case 'RANKING_UPDATE':
          _handleRankingUpdate(message['data']);
          break;
        case 'WORD_SEARCH_PROGRESS':
          _handleWordSearchProgress(message['data']);
          break;
        case 'WORD_SEARCH_RESULT':
          _handleWordSearchResult(message['data']);
          break;
        case 'NEW_REFLECTION':
          _handleNewReflection(message['data']);
          break;
        case 'REFLECTION_RECEIVED':
          _handleReflectionReceived();
          break;
        case 'DASHBOARD_UPDATE':
        case 'STUDENT_JOINED':
        case 'STUDENT_LEFT':
        case 'STUDENT_RESPONDED':
        case 'STUDENT_UPDATE':
          // Estos mensajes se manejan en los widgets correspondientes
          break;
        default:
          debugPrint('[WebSocket] Tipo de mensaje no manejado: ${message['type']}');
      }
      
      // Emitir al stream para otros listeners
      _messageController.add(message);
      
    } catch (e) {
      debugPrint('[WebSocket] Error procesando mensaje: $e');
    }
  }

  /// Maneja actualización de estado
  void _handleStateUpdate(Map<String, dynamic> data) {
    if (data['state'] != null) currentState = data['state'];
    notifyListeners();
  }

  /// Maneja actualización de slide
  void _handleSlideUpdate(Map<String, dynamic> data) {
    if (data['slide'] != null) currentSlide = data['slide'];
    if (data['block'] != null) currentBlock = data['block'];
    notifyListeners();
  }

  /// Maneja estado de actividad
  void _handleActivityStatus(Map<String, dynamic> data) {
    if (data['locked'] != null) isLocked = data['locked'];
    notifyListeners();
  }

  /// Maneja actividad desbloqueada
  void _handleActivityUnlocked(Map<String, dynamic> data) {
    // El data contiene la actividad completa
    debugPrint('[WebSocket] Actividad desbloqueada: ${data['activity']?['id']}');
    notifyListeners();
  }

  /// Maneja actividad bloqueada
  void _handleActivityLocked() {
    isLocked = true;
    notifyListeners();
  }

  /// Maneja revelación de respuesta
  void _handleAnswerRevealed(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Respuesta revelada para actividad: ${data['activityId']}');
    notifyListeners();
  }

  /// Maneja requerimiento de registro
  void _handleRegistrationRequired() {
    debugPrint('[WebSocket] Se requiere registro de estudiante');
    notifyListeners();
  }

  /// Maneja éxito de registro
  void _handleRegistrationSuccess(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Registro exitoso: ${data['name']}');
    notifyListeners();
  }

  /// Maneja error de registro
  void _handleRegistrationError(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Error en registro: ${data['message']}');
    _lastError = data['message'];
    notifyListeners();
  }

  /// Maneja respuesta recibida
  void _handleAnswerReceived(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Respuesta procesada para estudiante: ${data['pointsEarned']} puntos');
    notifyListeners();
  }

  /// Maneja reinicio de progreso
  void _handleProgressReset(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Progreso reiniciado: ${data['message']}');
    notifyListeners();
  }

  /// Maneja actualización de ranking
  void _handleRankingUpdate(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Ranking actualizado');
    notifyListeners();
  }

  /// Maneja progreso de sopa de letras
  void _handleWordSearchProgress(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Progreso sopa de letras: ${data['studentName']} - ${data['wordsFound']}/${data['totalWords']}');
    notifyListeners();
  }

  /// Maneja resultado de sopa de letras
  void _handleWordSearchResult(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Resultado sopa de letras: ${data['studentName']} - ${data['pointsEarned']} puntos');
    notifyListeners();
  }

  /// Maneja nueva reflexión
  void _handleNewReflection(Map<String, dynamic> data) {
    debugPrint('[WebSocket] Nueva reflexión: ${data['topic']}');
    notifyListeners();
  }

  /// Maneja confirmación de reflexión
  void _handleReflectionReceived() {
    debugPrint('[WebSocket] Reflexión confirmada');
    notifyListeners();
  }

  // --- Acciones del Profesor ---
  
  void setState(String newState) {
    sendMessage({
      'action': 'SET_STATE',
      'payload': {'state': newState}
    });
  }

  void setSlide(int slideIndex, {int? blockIndex}) {
    sendMessage({
      'action': 'SET_SLIDE',
      'payload': {
        'slide': slideIndex,
        if (blockIndex != null) 'block': blockIndex,
      }
    });
  }

  void unlockActivity(String activityId) {
    sendMessage({
      'action': 'UNLOCK_ACTIVITY',
      'payload': {'activityId': activityId}
    });
  }

  void lockActivity() {
    sendMessage({
      'action': 'LOCK_ACTIVITY',
      'payload': {}
    });
  }

  void revealAnswer(String activityId, int correctIndex) {
    sendMessage({
      'action': 'REVEAL_ANSWER',
      'payload': {
        'activityId': activityId,
        'correctIndex': correctIndex,
      }
    });
  }

  void resetActivity(String activityId) {
    sendMessage({
      'action': 'RESET_ACTIVITY',
      'payload': {'activityId': activityId}
    });
  }

  // --- Acciones del Estudiante ---

  void submitAnswer(String activityId, int optionIndex) {
    sendMessage({
      'action': 'SUBMIT_ANSWER',
      'payload': {
        'activityId': activityId,
        'optionIndex': optionIndex,
      }
    });
  }

  void registerStudent(String name, {bool reconnect = false}) {
    sendMessage({
      'action': 'REGISTER',
      'payload': {
        'name': name,
        'reconnect': reconnect,
      }
    });
  }

  void submitReflection(String topic, String content) {
    sendMessage({
      'action': 'SUBMIT_REFLECTION',
      'payload': {
        'topic': topic,
        'content': content,
      }
    });
  }

  void requestState() {
    sendMessage({
      'action': 'GET_STATE',
    });
  }

  void submitWordSearchProgress(String activityId, int wordsFound, int totalWords, int elapsedSeconds) {
    sendMessage({
      'action': 'WORD_SEARCH_PROGRESS',
      'payload': {
        'activityId': activityId,
        'wordsFound': wordsFound,
        'totalWords': totalWords,
        'elapsedSeconds': elapsedSeconds,
      }
    });
  }

  void submitWordSearchResult(String activityId, int timeSeconds, int wordsFound, int totalWords) {
    sendMessage({
      'action': 'WORD_SEARCH_RESULT',
      'payload': {
        'activityId': activityId,
        'timeSeconds': timeSeconds,
        'wordsFound': wordsFound,
        'totalWords': totalWords,
      }
    });
  }

  /// Envía un mensaje al servidor
  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && isConnected) {
      _channel!.sink.add(json.encode(message));
      debugPrint('[WebSocket] Mensaje enviado: ${message['action']}');
    } else {
      debugPrint('[WebSocket] No conectado. Mensaje no enviado.');
    }
  }

  /// Desconecta del servidor
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _handleDisconnect();
  }

  /// Reinicia el contador de reconexiones
  void resetReconnection() {
    _reconnectAttempts = 0;
    _shouldReconnect = true;
  }

  /// Obtiene información de conexión para debugging
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': isConnected,
      'currentRole': currentRole,
      'currentState': currentState,
      'currentSlide': currentSlide,
      'currentBlock': currentBlock,
      'isLocked': isLocked,
      'lastError': _lastError,
      'lastConnectedAt': _lastConnectedAt?.toIso8601String(),
      'connectionAttempts': _connectionAttempts,
      'reconnectAttempts': _reconnectAttempts,
    };
  }

  @override
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageController.close();
    super.dispose();
  }
}