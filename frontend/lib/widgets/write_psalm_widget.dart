import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<Map<String, String>> _inspirations = [
  {'ref': 'Salmo 23:1', 'text': 'Jehová es mi pastor; nada me faltará.'},
  {'ref': 'Salmo 100:1-2', 'text': 'Cantad alegres a Dios, habitantes de toda la tierra. Servid a Jehová con alegría.'},
  {'ref': 'Salmo 46:10', 'text': 'Estad quietos, y conoced que yo soy Dios.'},
  {'ref': 'Salmo 19:14', 'text': 'Sean gratos los dichos de mi boca y la meditación de mi corazón delante de ti.'},
  {'ref': 'Salmo 150:6', 'text': '¡Todo lo que respira alabe a Jah! ¡Aleluya!'},
];

const List<String> _writingTips = [
  'Comienza con una invocación a Dios.',
  'Expresa un sentimiento genuino: gratitud, asombro, súplica.',
  'Usa imágenes de la naturaleza como metáforas.',
  'Incluye una declaración de confianza en Dios.',
  'Termina con alabanza o esperanza.',
];

/// ======================================================================
/// ESCRIBE TU SALMO — ACTIVIDAD CREATIVA
/// Instituto Bíblico Elim Internacional
/// ======================================================================
class WritePsalmWidget extends StatefulWidget {
  final bool isTeacher;

  const WritePsalmWidget({super.key, this.isTeacher = true});

  @override
  State<WritePsalmWidget> createState() => _WritePsalmWidgetState();
}

class _WritePsalmWidgetState extends State<WritePsalmWidget>
    with TickerProviderStateMixin {
  int _page = 0; // 0=portada, 1=escribir, 2=preview
  final _controller = TextEditingController();
  String _psalmTitle = '';
  int _currentInspiration = 0;
  bool _submitted = false;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF162447)],
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: _page == 0 ? _buildCover() : _page == 1 ? _buildEditor() : _buildPreview(),
      ),
    );
  }

  Widget _buildCover() {
    return Center(
      key: const ValueKey('cover'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFFFFD54F).withValues(alpha: _glowAnimation.value * 0.4),
                    Colors.transparent,
                  ]),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFFFFD54F).withValues(alpha: _glowAnimation.value * 0.3),
                    blurRadius: 50, spreadRadius: 15,
                  )],
                ),
                child: const Icon(Icons.edit_note_rounded, size: 100, color: Color(0xFFFFD54F)),
              );
            },
          ),
          const SizedBox(height: 40),
          Text('ESCRIBE TU\nSALMO', textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(fontSize: 68, fontWeight: FontWeight.w900,
              color: const Color(0xFFFFD54F), letterSpacing: 4, height: 1.2,
              shadows: [Shadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 4))])),
          const SizedBox(height: 20),
          Text('Actividad Creativa', style: GoogleFonts.lato(fontSize: 36, color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 8)),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(30),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF1A237E).withValues(alpha: 0.5),
                const Color(0xFF0D47A1).withValues(alpha: 0.3),
              ]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.3), width: 2),
            ),
            child: Column(children: [
              Text('«', style: GoogleFonts.cinzel(fontSize: 40, color: Color(0xFFFFD54F).withValues(alpha: 0.5))),
              Text(_inspirations[_currentInspiration]['text']!, textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5)),
              Text('»', style: GoogleFonts.cinzel(fontSize: 40, color: Color(0xFFFFD54F).withValues(alpha: 0.5))),
              const SizedBox(height: 10),
              Text(_inspirations[_currentInspiration]['ref']!,
                style: GoogleFonts.cinzel(fontSize: 22, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() => _currentInspiration = (_currentInspiration + 1) % _inspirations.length),
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFFFD54F), size: 24),
            label: Text('Otra inspiración', style: GoogleFonts.lato(fontSize: 22, color: Color(0xFFFFD54F))),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(children: [
              Text('INSTRUCCIONES', style: GoogleFonts.cinzel(fontSize: 30, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTip(Icons.record_voice_over, 'Comienza con una invocación a Dios'),
              const SizedBox(height: 10),
              _buildTip(Icons.favorite, 'Expresa un sentimiento genuino'),
              const SizedBox(height: 10),
              _buildTip(Icons.park, 'Usa imágenes de la naturaleza'),
              const SizedBox(height: 10),
              _buildTip(Icons.shield, 'Incluye una declaración de confianza'),
              const SizedBox(height: 10),
              _buildTip(Icons.celebration, 'Termina con alabanza o esperanza'),
            ]),
          ),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: () => setState(() => _page = 1),
            icon: const Icon(Icons.create_rounded, size: 40),
            label: Text('COMENZAR A ESCRIBIR', style: GoogleFonts.cinzel(fontSize: 30, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: const Color(0xFF0D1B2A),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 12,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Row(children: [
      Icon(icon, color: Colors.white54, size: 28),
      const SizedBox(width: 14),
      Expanded(child: Text(text, style: GoogleFonts.lato(fontSize: 24, color: Colors.white70))),
    ]);
  }

  Widget _buildEditor() {
    return Center(
      key: const ValueKey('editor'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(children: [
          Row(children: [
            IconButton(onPressed: () => setState(() => _page = 0),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white54, size: 32)),
            const SizedBox(width: 12),
            Text('Escribe tu Salmo', style: GoogleFonts.cinzel(fontSize: 40, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 24),
          Text('Título de tu Salmo', style: GoogleFonts.lato(fontSize: 26, color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            onChanged: (v) => setState(() => _psalmTitle = v),
            style: GoogleFonts.cinzel(fontSize: 30, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: 'Ej: Salmo de gratitud',
              hintStyle: GoogleFonts.cinzel(fontSize: 26, color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFFFD54F).withValues(alpha: 0.3))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFFFD54F), width: 2)),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 24),
          Text('Tu Salmo', style: GoogleFonts.lato(fontSize: 26, color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            maxLines: 12,
            style: GoogleFonts.playfairDisplay(fontSize: 26, color: Colors.white, height: 1.8),
            decoration: InputDecoration(
              hintText: 'Oh Señor, mi Dios...\n\nEscribe tu salmo aquí...',
              hintStyle: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white24, fontStyle: FontStyle.italic),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFFFD54F).withValues(alpha: 0.3))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Color(0xFFFFD54F), width: 2)),
              contentPadding: const EdgeInsets.all(24),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${_controller.text.length} caracteres', style: GoogleFonts.lato(fontSize: 20, color: Colors.white38)),
            AnimatedBuilder(animation: _floatAnimation, builder: (ctx, _) {
              return Transform.translate(offset: Offset(0, _floatAnimation.value),
                child: const Icon(Icons.auto_awesome, color: Color(0xFFFFD54F), size: 28));
            }),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFFFFD54F), size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(_writingTips[_currentInspiration % _writingTips.length],
                style: GoogleFonts.lato(fontSize: 22, color: Colors.white70, fontStyle: FontStyle.italic))),
            ]),
          ),
          const SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: _controller.text.trim().length >= 20 ? () => setState(() => _page = 2) : null,
              icon: const Icon(Icons.visibility_rounded, size: 36),
              label: Text('VISTA PREVIA', style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD54F),
                foregroundColor: const Color(0xFF0D1B2A),
                disabledBackgroundColor: Colors.white12,
                disabledForegroundColor: Colors.white24,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
              ),
            ),
          ]),
          if (_controller.text.trim().length < 20)
            Padding(padding: const EdgeInsets.only(top: 12),
              child: Text('Escribe al menos 20 caracteres para continuar',
                style: GoogleFonts.lato(fontSize: 18, color: Colors.white38))),
        ]),
      ),
    );
  }

  Widget _buildPreview() {
    return Center(
      key: const ValueKey('preview'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(children: [
          Row(children: [
            IconButton(onPressed: () => setState(() => _page = 1),
              icon: const Icon(Icons.edit_rounded, color: Colors.white54, size: 32)),
            const SizedBox(width: 12),
            Text('Vista Previa', style: GoogleFonts.cinzel(fontSize: 36, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFF2C1810), Color(0xFF1A0F0A), Color(0xFF2C1810)],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFD4A574), width: 3),
              boxShadow: [
                BoxShadow(color: const Color(0xFFD4A574).withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5),
                const BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: Column(children: [
              const Icon(Icons.auto_awesome, color: Color(0xFFD4A574), size: 48),
              const SizedBox(height: 16),
              if (_psalmTitle.isNotEmpty)
                Text(_psalmTitle.toUpperCase(), textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(fontSize: 38, color: Color(0xFFD4A574), fontWeight: FontWeight.w900, letterSpacing: 4)),
              if (_psalmTitle.isNotEmpty) const SizedBox(height: 8),
              Container(width: 200, height: 2, color: const Color(0xFFD4A574).withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Text(_controller.text, textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(fontSize: 30, color: Color(0xFFE8D5B7), height: 1.8, fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
              Container(width: 200, height: 2, color: const Color(0xFFD4A574).withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text('— Estudiante del Instituto Bíblico Elim —',
                style: GoogleFonts.lato(fontSize: 20, color: Color(0xFFD4A574).withValues(alpha: 0.7))),
            ]),
          ),
          const SizedBox(height: 36),
          if (!_submitted)
            ElevatedButton.icon(
              onPressed: () => setState(() => _submitted = true),
              icon: const Icon(Icons.send_rounded, size: 36),
              label: Text('ENVIAR MI SALMO', style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
              ),
            ),
          if (_submitted)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF43A047).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF43A047)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 40),
                const SizedBox(width: 16),
                Text('¡Salmo enviado exitosamente!',
                  style: GoogleFonts.lato(fontSize: 28, color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
              ]),
            ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton.icon(
              onPressed: () => setState(() => _page = 1),
              icon: const Icon(Icons.edit, color: Colors.white54, size: 24),
              label: Text('Editar', style: GoogleFonts.lato(fontSize: 22, color: Colors.white54)),
            ),
            const SizedBox(width: 20),
            TextButton.icon(
              onPressed: () => setState(() {
                _page = 0; _controller.clear(); _psalmTitle = ''; _submitted = false;
              }),
              icon: const Icon(Icons.replay, color: Colors.white54, size: 24),
              label: Text('Nuevo salmo', style: GoogleFonts.lato(fontSize: 22, color: Colors.white54)),
            ),
          ]),
        ]),
      ),
    );
  }
}
