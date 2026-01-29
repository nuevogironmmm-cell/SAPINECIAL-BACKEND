import 'package:flutter/foundation.dart';

/// Configuraci?n de la aplicaci?n
class AppConfig {
  // Detectar si estamos en modo producci?n (web release)
  static bool get isProduction => kReleaseMode || kIsWeb;
  
  // URLs del backend
  // IMPORTANTE: Cambiar esta URL cuando despliegues el backend en Render/Railway
  static const String _productionBackendUrl = 'wss://sapinecial-backend.onrender.com';
  static const String _developmentBackendUrl = 'ws://localhost:8000';
  
  /// URL base del WebSocket
  static String get wsBaseUrl {
    // En web SIEMPRE usar producci?n (Netlify se conecta a Render)
    if (kIsWeb) {
      return _productionBackendUrl;
    }
    // En desktop/m?vil, depende del modo
    if (isProduction) {
      return _productionBackendUrl;
    }
    return _developmentBackendUrl;
  }
  
  /// URL del WebSocket para estudiantes
  static String get studentWsUrl => '$wsBaseUrl/ws/student';
  
  /// URL del WebSocket para docentes
  static String get teacherWsUrl => '$wsBaseUrl/ws/teacher';
  
  /// Token del docente (debe coincidir con el backend)
  static const String teacherToken = 'profesor2026';
}
