import 'package:flutter/foundation.dart';

/// Configuraci?n de la aplicaci?n
class AppConfig {
  // Detectar si estamos en modo producci?n (web release)
  static bool get isProduction => kReleaseMode;
  
  // URLs del backend
  // IMPORTANTE: Cambiar esta URL cuando despliegues el backend en Render/Railway
  static const String _productionBackendUrl = 'wss://sapinecial-backend.onrender.com';
  static const String _developmentBackendUrl = 'ws://localhost:8000';
  
  /// URL base del WebSocket
  static String get wsBaseUrl {
    if (kIsWeb && isProduction) {
      return _productionBackendUrl;
    }
    return _developmentBackendUrl;
  }
  
  /// URL del WebSocket para estudiantes
  static String get studentWsUrl => '$wsBaseUrl/ws/student';
  
  /// URL del WebSocket para docentes
  static String get teacherWsUrl => '$wsBaseUrl/ws/teacher';
  
  /// Token del docente (en producci?n deber?a ser m?s seguro)
  static const String teacherToken = 'docente_sapiencial_2024';
}
