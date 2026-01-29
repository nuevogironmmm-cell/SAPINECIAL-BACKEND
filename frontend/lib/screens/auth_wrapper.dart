import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'auth_login_screen.dart';

/// Widget wrapper que protege rutas y gestiona autenticaci?n
/// Muestra el login si no hay sesi?n activa
class AuthWrapper extends StatefulWidget {
  final Widget child;
  
  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Inicializar el servicio de autenticaci?n
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // Mostrar loading mientras se inicializa
    if (!authService.isInitialized) {
      return const _LoadingScreen();
    }

    // Si no est? logueado, mostrar pantalla de login
    if (!authService.isLoggedIn) {
      return const AuthLoginScreen();
    }

    // Usuario autenticado, mostrar la app
    return widget.child;
  }
}

/// Pantalla de carga mientras se verifica la sesi?n
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              const Color(0xFF0d1b2a),
              const Color(0xFF1b263b),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Texto
              Text(
                'Literatura Sapiencial',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Loading indicator
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Verificando sesi?n...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bot?n de cerrar sesi?n reutilizable
class LogoutButton extends StatelessWidget {
  final bool showText;
  final Color? iconColor;
  
  const LogoutButton({
    super.key,
    this.showText = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    
    if (showText) {
      return TextButton.icon(
        onPressed: () => _confirmLogout(context, authService),
        icon: Icon(
          Icons.logout_rounded,
          color: iconColor ?? Colors.white70,
        ),
        label: Text(
          'Cerrar Sesi?n',
          style: TextStyle(color: iconColor ?? Colors.white70),
        ),
      );
    }
    
    return IconButton(
      onPressed: () => _confirmLogout(context, authService),
      icon: Icon(
        Icons.logout_rounded,
        color: iconColor ?? Colors.white70,
      ),
      tooltip: 'Cerrar Sesi?n',
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1b263b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Cerrar Sesi?n', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          '?Est?s seguro de que deseas cerrar sesi?n?\n\nUsuario: ${authService.currentUser?.nombre}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesi?n'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authService.logout();
    }
  }
}

/// Widget que muestra informaci?n del usuario actual
class UserInfoBadge extends StatelessWidget {
  const UserInfoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final theme = Theme.of(context);
    
    if (user == null) return const SizedBox.shrink();

    final isDocente = user.rol == 'docente';
    final color = isDocente ? theme.colorScheme.primary : Colors.teal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDocente ? Icons.person : Icons.school,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            user.nombre,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isDocente ? 'Docente' : 'Estudiante',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
