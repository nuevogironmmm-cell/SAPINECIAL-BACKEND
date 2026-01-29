import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_service.dart';
import '../utils/animations.dart';
import 'student_main_screen.dart';

/// Pantalla de login para estudiantes
/// 
/// Permite al estudiante ingresar su nombre para identificarse.
/// No requiere cuenta ni contraseña.
/// Valida:
/// - Mínimo 3 caracteres
/// - Máximo 50 caracteres
/// - Nombre no duplicado en la clase actual
class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  
  bool _isLoading = false;
  bool _isConnecting = false;
  String? _errorMessage;
  
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Animación del logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _logoAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoController.forward();
    
    // Intentar reconexión automática
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAutoReconnect();
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _logoController.dispose();
    super.dispose();
  }
  
  Future<void> _tryAutoReconnect() async {
    final studentService = context.read<StudentService>();
    
    setState(() => _isConnecting = true);
    
    // Primero conectar al servidor
    final connected = await studentService.connect();
    
    if (!connected) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'No se pudo conectar al servidor. Verifica tu conexión.';
      });
      return;
    }
    
    // Intentar reconectar con nombre guardado
    final reconnected = await studentService.tryReconnect();
    
    setState(() => _isConnecting = false);
    
    if (reconnected && mounted) {
      // Navegar a la pantalla principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentMainScreen()),
      );
    }
  }
  
  Future<void> _submitName() async {
    if (!_formKey.currentState!.validate()) return;
    
    final name = _nameController.text.trim();
    final studentService = context.read<StudentService>();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Conectar si no est? conectado
    if (!studentService.isConnected) {
      final connected = await studentService.connect();
      if (!connected) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No se pudo conectar al servidor';
        });
        return;
      }
    }
    
    // Registrar estudiante
    final success = await studentService.register(name);
    
    setState(() => _isLoading = false);
    
    if (success && mounted) {
      // Navegar a la pantalla principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StudentMainScreen()),
      );
    } else {
      setState(() {
        _errorMessage = studentService.errorMessage ?? 'Error al registrar';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
              const Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animado
                    ScaleTransition(
                      scale: _logoAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Título
                    FadeInSlide(
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Literatura Sapiencial',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    FadeInSlide(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'Acceso de Estudiante',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Estado de conexión
                    if (_isConnecting)
                      FadeInSlide(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Conectando al servidor...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // Formulario de nombre
                      FadeInSlide(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                        child: _buildNameForm(theme),
                      ),
                    
                    // Mensaje de error
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      ShakeAnimation(
                        shake: true,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 48),
                    
                    // Información adicional
                    FadeInSlide(
                      delay: const Duration(milliseconds: 600),
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary.withOpacity(0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ingresa tu nombre para unirte a la clase.\n'
                              'Si te desconectas, podr?s volver a entrar\n'
                              'con el mismo nombre.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white60,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNameForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de nombre
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            enabled: !_isLoading,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              labelText: 'Tu nombre',
              hintText: 'Ej: Juan P�rez',
              prefixIcon: Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                ),
              ),
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              if (value.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              if (value.trim().length > 50) {
                return 'El nombre es demasiado largo';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submitName(),
          ),
          
          const SizedBox(height: 24),
          
          // Bot?n de enviar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AnimatedButton(
              onPressed: _isLoading ? null : _submitName,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Unirme a la clase',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

