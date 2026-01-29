import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/websocket_service.dart';
import 'screens/teacher_dashboard.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebSocketService()),
      ],
      child: const SapiencialApp(),
    ),
  );
}

class SapiencialApp extends StatelessWidget {
  const SapiencialApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Modo offline: No conectar WebSocket autom?ticamente
    // La app funciona con datos locales (mock_data.dart)
    // Para habilitar sincronizaci?n en tiempo real, descomentar:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<WebSocketService>().connect("teacher");
    // });

    return MaterialApp(
      title: 'Literatura Sapiencial - Docente',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const TeacherDashboard(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0A192F), // Azul Oscuro Profundo
        brightness: Brightness.dark,
        primary: const Color(0xFFC5A065), // Dorado Antiguo
        surface: const Color(0xFF0A192F),
        background: const Color(0xFF020c1b),
      ),
      textTheme: GoogleFonts.merriweatherTextTheme(
        ThemeData.dark().textTheme,
      ),
    );
  }
}
