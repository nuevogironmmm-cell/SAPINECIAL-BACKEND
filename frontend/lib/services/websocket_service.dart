import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Servicio de conexión WebSocket con autenticación
/// 
/// Maneja la comunicación en tiempo real entre profesor y estudiantes.
/// Soporta reconexión automática y modo offline.
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

  // Configuración de reconexión
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  Timer? _reconnectTimer;
  bool _shouldReconnect = true;

  // Stream controller para mensajes entrantes
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  // URL del servidor (cambiar según entorno)
  static const String _baseUrl = 'ws://localhost:8000/ws';
  static const String _devUrl = 'ws://localhost:8000/ws-dev'; // Sin autenticación

  /// Conecta al WebSocket con autenticación
  /// 
  /// [role] puede ser 'teacher' o 'student'
  /// [token] es requerido para autenticación (profesor: 'profesor2026')
  Future<bool> connect(String role, {String? token}) async {
    if (isConnected) return true;
    
    currentRole = role;
    _authToken = token;
    _shouldReconnect = true;
    
    try {
      final uri = token != null && token.isNotEmpty
          ? Uri.parse('$_baseUrl/$role?token=$token')
          : Uri.parse('$_devUrl/$role');
      
      _channel = WebSocketChannel.connect(uri);
      
      // Escuchar mensajes del servidor
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          debugPrint('[WebSocket] Error: $error');
          _handleDisconnect();
          _attemptReconnect();
        },
        onDone: () {
          debugPrint('[WebSocket] conexión cerrada');
          _handleDisconnect();
          _attemptReconnect();
        },
      );

      isConnected = true;
      _reconnectAttempts = 0;
      debugPrint('[WebSocket] Conectado como: $role');
      notifyListeners();
      return true;
      
    } catch (e) {
      debugPrint('[WebSocket] Error al conectar: $e');
      isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Intenta reconectar con backoff exponencial
  void _attemptReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[WebSocket] Reconexión cancelada (intentos: $_reconnectAttempts)');
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

  void _handleMessage(dynamic rawMessage) {
    try {
      final Map<String, dynamic> message = json.decode(rawMessage);
      debugPrint('[WebSocket] Mensaje recibido: ${message['type']}');
      
      // Manejar error de autenticación
      if (message['type'] == 'ERROR') {
        final code = message['data']?['code'];
        if (code == 'AUTH_FAILED') {
          debugPrint('[WebSocket] Error de autenticación');
          _shouldReconnect = false;
        }
      }
      
      // Procesar según tipo de mensaje
      if (message['type'] == 'STATE_UPDATE') {
        final data = message['data'];
        if (data['state'] != null) currentState = data['state'];
        if (data['slide'] != null) currentSlide = data['slide'];
        if (data['block'] != null) currentBlock = data['block'];
        if (data['locked'] != null) isLocked = data['locked'];
        notifyListeners();
      }
      
      if (message['type'] == 'SLIDE_UPDATE') {
        final data = message['data'];
        if (data['slide'] != null) currentSlide = data['slide'];
        if (data['block'] != null) currentBlock = data['block'];
        notifyListeners();
      }
      
      if (message['type'] == 'ACTIVITY_STATUS') {
        final data = message['data'];
        if (data['locked'] != null) isLocked = data['locked'];
        notifyListeners();
      }
      
      // Emitir al stream para otros listeners
      _messageController.add(message);
      
    } catch (e) {
      debugPrint('[WebSocket] Error procesando mensaje: $e');
    }
  }

  void _handleDisconnect() {
    isConnected = false;
    _channel = null;
    notifyListeners();
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

  @override
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageController.close();
    super.dispose();
  }
}

