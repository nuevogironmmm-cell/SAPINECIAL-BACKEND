import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo de usuario para el sistema de autenticaci?n
class UserModel {
  final String id;
  final String username;
  final String password;
  final String nombre;
  final String rol; // 'docente' o 'estudiante'

  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.nombre,
    required this.rol,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'nombre': nombre,
    'rol': rol,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    username: json['username'] ?? '',
    password: '', // No almacenamos la contrase?a
    nombre: json['nombre'] ?? '',
    rol: json['rol'] ?? 'estudiante',
  );
}

/// Servicio de autenticaci?n local para modo pruebas
/// NO usar en producci?n - Solo para pruebas de flujo
class AuthService extends ChangeNotifier {
  // ???????????????????????????????????????????????????????????????
  // USUARIOS MOCK PARA PRUEBAS
  // ???????????????????????????????????????????????????????????????
  static const List<UserModel> _mockUsers = [
    // Docentes
    UserModel(
      id: 'doc_001',
      username: 'docente',
      password: '1234',
      nombre: 'Prof. Garc?a',
      rol: 'docente',
    ),
    UserModel(
      id: 'doc_002',
      username: 'profesor',
      password: '1234',
      nombre: 'Prof. Mart?nez',
      rol: 'docente',
    ),
    // Estudiantes
    UserModel(
      id: 'est_001',
      username: 'estudiante1',
      password: '1234',
      nombre: 'Mar?a L?pez',
      rol: 'estudiante',
    ),
    UserModel(
      id: 'est_002',
      username: 'estudiante2',
      password: '1234',
      nombre: 'Juan Pérez',
      rol: 'estudiante',
    ),
    UserModel(
      id: 'est_003',
      username: 'estudiante3',
      password: '1234',
      nombre: 'Ana Rodr?guez',
      rol: 'estudiante',
    ),
    // Usuario de prueba r?pida
    UserModel(
      id: 'test_001',
      username: 'test',
      password: 'test',
      nombre: 'Usuario de Prueba',
      rol: 'estudiante',
    ),
    UserModel(
      id: 'admin_001',
      username: 'admin',
      password: 'admin',
      nombre: 'Administrador',
      rol: 'docente',
    ),
  ];

  // ???????????????????????????????????????????????????????????????
  // ESTADO
  // ???????????????????????????????????????????????????????????????
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isDocente => _currentUser?.rol == 'docente';
  bool get isEstudiante => _currentUser?.rol == 'estudiante';

  // ???????????????????????????????????????????????????????????????
  // INICIALIZACI?N
  // ???????????????????????????????????????????????????????????????
  
  /// Inicializa el servicio y verifica si hay sesi?n guardada
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('auth_user_id');
      final savedUsername = prefs.getString('auth_username');
      final savedNombre = prefs.getString('auth_nombre');
      final savedRol = prefs.getString('auth_rol');

      if (savedUserId != null && savedUsername != null) {
        _currentUser = UserModel(
          id: savedUserId,
          username: savedUsername,
          password: '',
          nombre: savedNombre ?? 'Usuario',
          rol: savedRol ?? 'estudiante',
        );
        debugPrint('? Sesi?n restaurada: ${_currentUser!.nombre}');
      }
    } catch (e) {
      debugPrint('?? Error al restaurar sesi?n: $e');
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  // ???????????????????????????????????????????????????????????????
  // AUTENTICACI?N
  // ???????????????????????????????????????????????????????????????

  /// Intenta autenticar con usuario y contrase?a
  /// Retorna true si el login es exitoso
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simular delay de red (para UX realista)
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Buscar usuario en lista mock
      final user = _mockUsers.firstWhere(
        (u) => u.username.toLowerCase() == username.toLowerCase() && 
               u.password == password,
        orElse: () => const UserModel(
          id: '', username: '', password: '', nombre: '', rol: '',
        ),
      );

      if (user.id.isEmpty) {
        _errorMessage = 'Usuario o contrase?a incorrectos';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Guardar sesi?n
      _currentUser = user;
      await _saveSession(user);

      debugPrint('? Login exitoso: ${user.nombre} (${user.rol})');
      
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Error al iniciar sesi?n: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cierra la sesi?n actual
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_username');
      await prefs.remove('auth_nombre');
      await prefs.remove('auth_rol');

      debugPrint('? Sesi?n cerrada: ${_currentUser?.nombre}');
      _currentUser = null;

    } catch (e) {
      debugPrint('?? Error al cerrar sesi?n: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Guarda la sesi?n en SharedPreferences
  Future<void> _saveSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_user_id', user.id);
      await prefs.setString('auth_username', user.username);
      await prefs.setString('auth_nombre', user.nombre);
      await prefs.setString('auth_rol', user.rol);
    } catch (e) {
      debugPrint('?? Error al guardar sesi?n: $e');
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ???????????????????????????????????????????????????????????????
  // UTILIDADES
  // ???????????????????????????????????????????????????????????????

  /// Obtiene la lista de usuarios disponibles (solo para mostrar en UI de pruebas)
  List<Map<String, String>> getTestCredentials() {
    return _mockUsers.map((u) => {
      'username': u.username,
      'password': u.password,
      'nombre': u.nombre,
      'rol': u.rol,
    }).toList();
  }
}
