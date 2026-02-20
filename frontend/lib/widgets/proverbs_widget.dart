import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ======================================================================
/// LIBRO DE PROVERBIOS — WIDGET 3D INTERACTIVO ULTRA PREMIUM
/// Instituto Bíblico Elim Internacional
/// ======================================================================
class ProverbsWidget extends StatefulWidget {
  const ProverbsWidget({super.key});

  @override
  State<ProverbsWidget> createState() => _ProverbsWidgetState();
}

class _ProverbsWidgetState extends State<ProverbsWidget>
    with TickerProviderStateMixin {
  int _currentPage = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final int _totalPages = 9;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _rotateController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A0A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Stack(children: [
        ..._buildBackgroundParticles(),
        Column(children: [
          _buildNavBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, anim) {
                return FadeTransition(opacity: anim,
                  child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(anim), child: child));
              },
              child: _buildPage(_currentPage),
            ),
          ),
          _buildBottomNav(),
        ]),
      ]),
    );
  }

  List<Widget> _buildBackgroundParticles() {
    return List.generate(12, (i) {
      final rng = Random(i * 42);
      return Positioned(
        left: rng.nextDouble() * 1920,
        top: rng.nextDouble() * 1080,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (_, __) => Opacity(
            opacity: _glowAnimation.value * 0.15,
            child: Container(
              width: 4 + rng.nextDouble() * 6,
              height: 4 + rng.nextDouble() * 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD54F),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: 0.5), blurRadius: 10)],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Row(children: [
        const Icon(Icons.menu_book_rounded, color: Color(0xFFFFD54F), size: 36),
        const SizedBox(width: 16),
        Text('LIBRO DE PROVERBIOS', style: GoogleFonts.cinzel(fontSize: 28, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold, letterSpacing: 3)),
        const Spacer(),
        ...List.generate(_totalPages, (i) => GestureDetector(
          onTap: () => setState(() => _currentPage = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _currentPage == i ? 36 : 12, height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: _currentPage == i ? const Color(0xFFFFD54F) : Colors.white24,
            ),
          ),
        )),
      ]),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        if (_currentPage > 0)
          ElevatedButton.icon(
            onPressed: () => setState(() => _currentPage--),
            icon: const Icon(Icons.arrow_back_rounded, size: 28),
            label: Text('ANTERIOR', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        else const SizedBox.shrink(),
        Text('${_currentPage + 1} / $_totalPages', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white38)),
        if (_currentPage < _totalPages - 1)
          ElevatedButton.icon(
            onPressed: () => setState(() => _currentPage++),
            icon: const Icon(Icons.arrow_forward_rounded, size: 28),
            label: Text('SIGUIENTE', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: const Color(0xFF1A0A2E),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        else const SizedBox.shrink(),
      ]),
    );
  }

  Widget _buildPage(int page) {
    switch (page) {
      case 0: return _buildPortada();
      case 1: return _buildNombre();
      case 2: return _buildAutor();
      case 3: return _buildProposito();
      case 4: return _buildEstructura();
      case 5: return _buildTemas();
      case 6: return _buildMujerVirtuosa();
      case 7: return _buildFormaLiteraria();
      case 8: return _buildTemasAmpliados();
      default: return _buildPortada();
    }
  }

  Widget _buildPortada() {
    return Center(
      key: const ValueKey('p0'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          AnimatedBuilder(
            animation: Listenable.merge([_glowAnimation, _floatAnimation]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      const Color(0xFFFFD54F).withValues(alpha: _glowAnimation.value * 0.5),
                      const Color(0xFFFF8F00).withValues(alpha: _glowAnimation.value * 0.2),
                      Colors.transparent,
                    ]),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: _glowAnimation.value * 0.4), blurRadius: 60, spreadRadius: 20),
                      BoxShadow(color: const Color(0xFFFF8F00).withValues(alpha: _glowAnimation.value * 0.2), blurRadius: 100, spreadRadius: 40),
                    ],
                  ),
                  child: const Icon(Icons.auto_stories_rounded, size: 120, color: Color(0xFFFFD54F)),
                ),
              );
            },
          ),
          const SizedBox(height: 50),
          Text('LIBRO DE\nPROVERBIOS', textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(fontSize: 80, fontWeight: FontWeight.w900,
              color: const Color(0xFFFFD54F), letterSpacing: 6, height: 1.15,
              shadows: [
                Shadow(color: Colors.black87, blurRadius: 30, offset: Offset(0, 6)),
                Shadow(color: const Color(0xFFFF8F00).withValues(alpha: 0.5), blurRadius: 40),
              ])),
          const SizedBox(height: 30),
          Container(width: 300, height: 3, decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFFFFD54F), Colors.transparent]),
            borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(height: 24),
          Wrap(spacing: 20, runSpacing: 14, alignment: WrapAlignment.center, children: [
            _buildKeywordChip('Sabiduría'),
            _buildKeywordChip('Prudencia'),
            _buildKeywordChip('Temor de Jehová'),
            _buildKeywordChip('Disciplina'),
          ]),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.2), width: 2),
            ),
            child: Column(children: [
              Text('«', style: GoogleFonts.cinzel(fontSize: 44, color: Color(0xFFFFD54F).withValues(alpha: 0.5))),
              Text('El principio de la sabiduría es el temor de Jehová.',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(fontSize: 42, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5)),
              Text('»', style: GoogleFonts.cinzel(fontSize: 44, color: Color(0xFFFFD54F).withValues(alpha: 0.5))),
              const SizedBox(height: 10),
              Text('Proverbios 1:7', style: GoogleFonts.cinzel(fontSize: 24, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildKeywordChip(String text) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnimation.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFFFFD54F).withValues(alpha: 0.25),
              const Color(0xFFFF8F00).withValues(alpha: 0.15),
            ]),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: 0.15), blurRadius: 15)],
          ),
          child: Text(text, style: GoogleFonts.cinzel(fontSize: 24, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildNombre() {
    return SingleChildScrollView(
      key: const ValueKey('p1'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader('1', 'NOMBRE', Icons.translate_rounded),
        const SizedBox(height: 30),
        Center(child: AnimatedBuilder(
          animation: Listenable.merge([_glowAnimation, _floatAnimation]),
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.5),
            child: Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                  const Color(0xFF1A237E).withValues(alpha: 0.7),
                  const Color(0xFF0D47A1).withValues(alpha: 0.4),
                ]),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: _glowAnimation.value * 0.6), width: 3),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 5),
                  BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: _glowAnimation.value * 0.15), blurRadius: 60, spreadRadius: 10),
                ],
              ),
              child: Column(children: [
                const Icon(Icons.history_edu_rounded, color: Color(0xFFFFD54F), size: 64),
                const SizedBox(height: 20),
                Text('Mashal', style: GoogleFonts.cinzel(fontSize: 72, color: Color(0xFFFFD54F), fontWeight: FontWeight.w900, letterSpacing: 8)),
                Text('מָשָׁל', style: TextStyle(fontSize: 60, color: Colors.white54, fontFamily: 'serif')),
                const SizedBox(height: 20),
                Container(width: 200, height: 2, color: const Color(0xFFFFD54F).withValues(alpha: 0.5)),
                const SizedBox(height: 20),
                Text('= Comparación o máxima breve', style: GoogleFonts.lato(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.5)),
                  ),
                  child: Text('Libro sapiencial práctico', style: GoogleFonts.lato(fontSize: 28, color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
          ),
        )),
        const SizedBox(height: 40),
        _buildInfoCard(Icons.lightbulb_outline, 'Proverbio = enseñanza corta y memorable',
          'Una frase práctica que transmite sabiduría divina para la vida cotidiana.', const Color(0xFFFFD54F)),
        const SizedBox(height: 16),
        _buildInfoCard(Icons.compare_arrows, 'Usa comparaciones',
          'El perezoso vs. la hormiga, el sabio vs. el necio, etc.', const Color(0xFF1E88E5)),
      ]),
    );
  }

  Widget _buildAutor() {
    return SingleChildScrollView(
      key: const ValueKey('p2'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader('2', 'AUTOR PRINCIPAL', Icons.person_rounded),
        const SizedBox(height: 30),
        Center(child: AnimatedBuilder(
          animation: Listenable.merge([_glowAnimation, _floatAnimation]),
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.5),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                  const Color(0xFF4A148C).withValues(alpha: 0.6),
                  const Color(0xFF7B1FA2).withValues(alpha: 0.3),
                ]),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5), width: 3),
                boxShadow: [BoxShadow(color: const Color(0xFF4A148C).withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 5)],
              ),
              child: Column(children: [
                Stack(alignment: Alignment.center, children: [
                  Container(width: 120, height: 120, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [const Color(0xFFFFD54F).withValues(alpha: 0.3), Colors.transparent]),
                  )),
                  const Icon(Icons.diamond_rounded, color: Color(0xFFFFD54F), size: 80),
                ]),
                const SizedBox(height: 20),
                Text('SALOMÓN', style: GoogleFonts.cinzel(fontSize: 56, color: Color(0xFFFFD54F), fontWeight: FontWeight.w900, letterSpacing: 6)),
                Text('Rey Sabio de Israel', style: GoogleFonts.lato(fontSize: 30, color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 4)),
                const SizedBox(height: 24),
                Wrap(spacing: 16, runSpacing: 12, alignment: WrapAlignment.center, children: [
                  _buildFactChip(Icons.family_restroom, 'Hijo de David'),
                  _buildFactChip(Icons.auto_awesome, 'Sabiduría extraordinaria'),
                  _buildFactChip(Icons.format_quote, '3,000 proverbios'),
                ]),
              ]),
            ),
          ),
        )),
        const SizedBox(height: 36),
        Text('También participaron:', style: GoogleFonts.cinzel(fontSize: 32, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildAuthorCard('Hombres de Ezequías', 'Cap. 25-29', Icons.groups_rounded, 'Copistas reales que recopilaron proverbios de Salomón', Color(0xFF1E88E5)),
        const SizedBox(height: 16),
        _buildAuthorCard('Agur', 'Cap. 30', Icons.account_circle_rounded, 'Autor misterioso. Sus palabras contienen profunda humildad', Color(0xFF43A047)),
        const SizedBox(height: 16),
        _buildAuthorCard('Lemuel', 'Cap. 31', Icons.workspace_premium_rounded, 'Rey instruido por su madre. Describe a la mujer virtuosa', Color(0xFFE53935)),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _buildProposito() {
    return SingleChildScrollView(
      key: const ValueKey('p3'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader('3', 'PROPÓSITO', Icons.track_changes_rounded),
        const SizedBox(height: 30),
        Center(child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
              const Color(0xFF1B5E20).withValues(alpha: 0.5),
              const Color(0xFF2E7D32).withValues(alpha: 0.3),
            ]),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4), width: 3),
            boxShadow: [BoxShadow(color: const Color(0xFF1B5E20).withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 5)],
          ),
          child: Column(children: [
            const Icon(Icons.menu_book_rounded, color: Color(0xFFFFD54F), size: 56),
            const SizedBox(height: 16),
            Text('Proverbios 1:7', style: GoogleFonts.cinzel(fontSize: 30, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('«', style: GoogleFonts.cinzel(fontSize: 44, color: Color(0xFFFFD54F).withValues(alpha: 0.5))),
            Text('El principio de la sabiduría\nes el temor de Jehová.',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(fontSize: 48, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5,
                shadows: [Shadow(color: Colors.black54, blurRadius: 10)])),
            Text('»', style: GoogleFonts.cinzel(fontSize: 44, color: Color(0xFFFFD54F).withValues(alpha: 0.5))),
          ]),
        )),
        const SizedBox(height: 36),
        Text('Enseña:', style: GoogleFonts.cinzel(fontSize: 36, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Wrap(spacing: 20, runSpacing: 20, alignment: WrapAlignment.center, children: [
          _buildConceptCard('Justicia', Icons.gavel_rounded, Color(0xFF1E88E5)),
          _buildConceptCard('Juicio', Icons.balance_rounded, Color(0xFF7B1FA2)),
          _buildConceptCard('Equidad', Icons.handshake_rounded, Color(0xFF43A047)),
          _buildConceptCard('Prudencia', Icons.psychology_rounded, Color(0xFFFF8F00)),
        ]),
      ]),
    );
  }

  Widget _buildEstructura() {
    return SingleChildScrollView(
      key: const ValueKey('p4'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader('4', 'ESTRUCTURA', Icons.account_tree_rounded),
        const SizedBox(height: 30),
        _buildStructureItem(0, '1-9', 'Discursos sobre la sabiduría', Icons.school_rounded, Color(0xFF1E88E5), 'Instrucciones de un padre a su hijo. La sabiduría personificada clama en las calles.'),
        const SizedBox(height: 12),
        _buildStructureItem(1, '10-22:16', 'Proverbios breves', Icons.format_list_bulleted_rounded, Color(0xFF43A047), 'Colección principal de máximas cortas de Salomón. Contrastes entre sabio y necio.'),
        const SizedBox(height: 12),
        _buildStructureItem(2, '22:17–24:34', 'Dichos de sabios', Icons.record_voice_over_rounded, Color(0xFF7B1FA2), 'Consejos de maestros sabios sobre temas prácticos de la vida diaria.'),
        const SizedBox(height: 12),
        _buildStructureItem(3, '25–29', 'Copiados por Ezequías', Icons.copy_rounded, Color(0xFFFF8F00), 'Proverbios de Salomón recopilados por los hombres del rey Ezequías.'),
        const SizedBox(height: 12),
        _buildStructureItem(4, '30–31', 'Agur y Lemuel', Icons.auto_awesome_rounded, Color(0xFFE53935), 'Palabras de Agur (reflexiones) y de Lemuel (la mujer virtuosa, cap. 31).'),
      ]),
    );
  }

  Widget _buildTemas() {
    return SingleChildScrollView(
      key: const ValueKey('p5'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader('5', 'TEMAS PRINCIPALES', Icons.category_rounded),
        const SizedBox(height: 30),
        Wrap(spacing: 20, runSpacing: 20, alignment: WrapAlignment.center, children: [
          _buildThemeCard('La Lengua', '15:1', 'La blanda respuesta quita la ira; la palabra áspera hace subir el furor.', Icons.record_voice_over_rounded, Color(0xFF1E88E5)),
          _buildThemeCard('Disciplina', '13:24', 'El que detiene el castigo, a su hijo aborrece.', Icons.school_rounded, Color(0xFFE53935)),
          _buildThemeCard('Trabajo', '6:6', 'Ve a la hormiga, oh perezoso, mira sus caminos, y sé sabio.', Icons.work_rounded, Color(0xFF43A047)),
          _buildThemeCard('Riqueza', '11:25', 'El alma generosa será prosperada.', Icons.account_balance_rounded, Color(0xFFFF8F00)),
          _buildThemeCard('Matrimonio', '18:22', 'El que halla esposa halla el bien, y alcanza la benevolencia de Jehová.', Icons.favorite_rounded, Color(0xFFE91E63)),
          _buildThemeCard('Mujer virtuosa', '31:10–31', '¿Mujer virtuosa, quién la hallará? Su estima sobrepasa a las piedras preciosas.', Icons.diamond_rounded, Color(0xFF7B1FA2)),
        ]),
      ]),
    );
  }

  Widget _buildMujerVirtuosa() {
    return SingleChildScrollView(
      key: const ValueKey('p6'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(children: [
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (_, __) => Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                const Color(0xFFE91E63).withValues(alpha: _glowAnimation.value * 0.4),
                Colors.transparent,
              ]),
              boxShadow: [BoxShadow(color: const Color(0xFFE91E63).withValues(alpha: _glowAnimation.value * 0.3), blurRadius: 50, spreadRadius: 15)],
            ),
            child: const Icon(Icons.diamond_rounded, size: 90, color: Color(0xFFE91E63)),
          ),
        ),
        const SizedBox(height: 30),
        Text('LA MUJER VIRTUOSA', textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFFE91E63), letterSpacing: 4)),
        Text('Proverbios 31:10-31', style: GoogleFonts.cinzel(fontSize: 26, color: Colors.white54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        Container(width: 250, height: 2, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFFE91E63), Colors.transparent]),
          borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF880E4F).withValues(alpha: 0.4),
              const Color(0xFFAD1457).withValues(alpha: 0.2),
            ]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.4), width: 2),
          ),
          child: Column(children: [
            Text('«', style: GoogleFonts.cinzel(fontSize: 40, color: Color(0xFFE91E63).withValues(alpha: 0.5))),
            Text('¿Mujer virtuosa, quién la hallará?\nSu estima sobrepasa largamente\na las piedras preciosas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(fontSize: 36, color: Colors.white, fontStyle: FontStyle.italic, height: 1.6)),
            Text('»', style: GoogleFonts.cinzel(fontSize: 40, color: Color(0xFFE91E63).withValues(alpha: 0.5))),
            const SizedBox(height: 10),
            Text('Proverbios 31:10', style: GoogleFonts.cinzel(fontSize: 22, color: Color(0xFFE91E63), fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 30),
        Wrap(spacing: 16, runSpacing: 16, alignment: WrapAlignment.center, children: [
          _buildVirtueChip('Trabaja con voluntad', Icons.volunteer_activism_rounded),
          _buildVirtueChip('Provee para su casa', Icons.home_rounded),
          _buildVirtueChip('Se levanta de madrugada', Icons.wb_sunny_rounded),
          _buildVirtueChip('Tiende su mano al pobre', Icons.handshake_rounded),
          _buildVirtueChip('Se viste de fuerza', Icons.shield_rounded),
          _buildVirtueChip('Ábre su boca con sabiduría', Icons.record_voice_over_rounded),
        ]),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.star_rounded, color: Color(0xFFE91E63), size: 32),
            const SizedBox(width: 16),
            Text('Su valor sobrepasa a las piedras preciosas',
              style: GoogleFonts.cinzel(fontSize: 24, color: Color(0xFFE91E63), fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            const Icon(Icons.star_rounded, color: Color(0xFFE91E63), size: 32),
          ]),
        ),
      ]),
    );
  }


  Widget _buildFormaLiteraria() {
    return SingleChildScrollView(
      key: const ValueKey('p7'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader('6', 'FORMA LITERARIA', Icons.format_quote_rounded),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF1A237E).withValues(alpha: 0.5),
              const Color(0xFF283593).withValues(alpha: 0.2),
            ]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.3), blurRadius: 30)],
          ),
          child: Row(children: [
            const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFD54F), size: 56),
            const SizedBox(width: 24),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('El libro se presenta en forma poética.',
                style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5)),
              const SizedBox(height: 10),
              Text('Su contenido no admite un análisis ordenado.',
                style: GoogleFonts.lato(fontSize: 26, color: Colors.white70, height: 1.4)),
            ])),
          ]),
        ),
        const SizedBox(height: 36),
        Text('Cinco clases de características:', style: GoogleFonts.cinzel(fontSize: 36, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildClassItem(1, 'Históricas', Icons.history_edu_rounded, Color(0xFF1E88E5), 'Proverbios basados en hechos y experiencias del pueblo de Israel.'),
        const SizedBox(height: 12),
        _buildClassItem(2, 'Metafóricas', Icons.compare_arrows_rounded, Color(0xFF43A047), 'Uso de imágenes y figuras para transmitir verdades espirituales.'),
        const SizedBox(height: 12),
        _buildClassItem(3, 'Enigmas', Icons.help_outline_rounded, Color(0xFFFF8F00), 'Dichos misteriosos que requieren reflexión profunda para comprenderlos.'),
        const SizedBox(height: 12),
        _buildClassItem(4, 'Parabólicas', Icons.auto_awesome_rounded, Color(0xFF7B1FA2), 'Enseñanzas narradas como breves historias o comparaciones.'),
        const SizedBox(height: 12),
        _buildClassItem(5, 'Didácticas', Icons.school_rounded, Color(0xFFE53935), 'Instrucción directa con fines educativos y morales.'),
        const SizedBox(height: 12),
        const SizedBox(height: 24),
        Text('Otras características literarias:', style: GoogleFonts.cinzel(fontSize: 32, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Wrap(spacing: 16, runSpacing: 14, alignment: WrapAlignment.center, children: [
          _buildLiteraryChip('Poemas'),
          _buildLiteraryChip('Parábolas'),
          _buildLiteraryChip('Preguntas directas'),
          _buildLiteraryChip('Verbos pareados'),
          _buildLiteraryChip('Antítesis'),
          _buildLiteraryChip('Comparación'),
          _buildLiteraryChip('Personificación'),
        ]),
      ]),
    );
  }

  Widget _buildClassItem(int number, String title, IconData icon, Color accent, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.2),
            border: Border.all(color: accent, width: 2),
          ),
          child: Center(child: Text('$number', style: GoogleFonts.orbitron(fontSize: 24, color: accent, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 20),
        Icon(icon, color: accent, size: 36),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.cinzel(fontSize: 28, color: accent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: GoogleFonts.lato(fontSize: 22, color: Colors.white70, height: 1.3)),
        ])),
      ]),
    );
  }

  Widget _buildLiteraryChip(String text) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnimation.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF00BCD4).withValues(alpha: 0.25),
              const Color(0xFF0097A7).withValues(alpha: 0.12),
            ]),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF00BCD4).withValues(alpha: 0.5), width: 2),
            boxShadow: [BoxShadow(color: const Color(0xFF00BCD4).withValues(alpha: 0.12), blurRadius: 12)],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.edit_note_rounded, color: Color(0xFF00BCD4), size: 24),
            const SizedBox(width: 8),
            Text(text, style: GoogleFonts.lato(fontSize: 24, color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTemasAmpliados() {
    return SingleChildScrollView(
      key: const ValueKey('p8'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionHeader('7', 'TEMAS DEL LIBRO', Icons.library_books_rounded),
        const SizedBox(height: 30),
        Wrap(spacing: 18, runSpacing: 18, alignment: WrapAlignment.center, children: [
          _buildAmpThemeCard('Juventud y disciplina', 'Pr. 15:32; 20:11; 29:15', Icons.escalator_warning_rounded, Color(0xFF1E88E5)),
          _buildAmpThemeCard('Vida familiar', 'Pr. 13:1; 20:20', Icons.family_restroom_rounded, Color(0xFFE91E63)),
          _buildAmpThemeCard('Dominio propio', 'Pr. 21:23', Icons.self_improvement_rounded, Color(0xFF43A047)),
          _buildAmpThemeCard('Resistencia a la tentación', 'Pr. 20:19; 22:3', Icons.shield_rounded, Color(0xFFFF8F00)),
          _buildAmpThemeCard('Asuntos de negocios', 'Pr. 31:18', Icons.store_rounded, Color(0xFF7B1FA2)),
          _buildAmpThemeCard('Palabras y lenguas', 'Pr. 15:24', Icons.record_voice_over_rounded, Color(0xFF00BCD4)),
          _buildAmpThemeCard('Conocimiento de Dios', 'Pr. 9:10', Icons.church_rounded, Color(0xFFFFD54F)),
          _buildAmpThemeCard('Matrimonio', 'Pr. 18:22', Icons.favorite_rounded, Color(0xFFE53935)),
          _buildAmpThemeCard('Búsqueda de la verdad', 'Pr. 8:7', Icons.search_rounded, Color(0xFF26A69A)),
          _buildAmpThemeCard('Riqueza y pobreza', 'Pr. 8:18', Icons.account_balance_rounded, Color(0xFFFF7043)),
          _buildAmpThemeCard('Inmoralidad', 'Pr. 6:12-15', Icons.warning_rounded, Color(0xFFAB47BC)),
          _buildAmpThemeCard('Sabiduría', 'Pr. 3:13; 4:7', Icons.psychology_alt_rounded, Color(0xFF42A5F5)),
        ]),
      ]),
    );
  }

  Widget _buildAmpThemeCard(String title, String reference, IconData icon, Color accent) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.2), accent.withValues(alpha: 0.06)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 2),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 16)],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.2),
            border: Border.all(color: accent, width: 2),
          ),
          child: Icon(icon, color: accent, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.cinzel(fontSize: 24, color: accent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Text(reference, style: GoogleFonts.orbitron(fontSize: 14, color: accent)),
          ),
        ])),
      ]),
    );
  }

  Widget _buildSectionHeader(String number, String title, IconData icon) {
    return Row(children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)]),
          boxShadow: [BoxShadow(color: const Color(0xFFFFD54F).withValues(alpha: 0.4), blurRadius: 15)],
        ),
        child: Center(child: Text(number, style: GoogleFonts.orbitron(fontSize: 28, color: Color(0xFF1A0A2E), fontWeight: FontWeight.w900))),
      ),
      const SizedBox(width: 20),
      Icon(icon, color: const Color(0xFFFFD54F), size: 40),
      const SizedBox(width: 16),
      Expanded(child: Text(title, style: GoogleFonts.cinzel(fontSize: 44, color: Color(0xFFFFD54F), fontWeight: FontWeight.w900, letterSpacing: 4))),
    ]);
  }

  Widget _buildInfoCard(IconData icon, String title, String description, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: accent, size: 40),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.cinzel(fontSize: 26, color: accent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(description, style: GoogleFonts.lato(fontSize: 22, color: Colors.white70)),
        ])),
      ]),
    );
  }

  Widget _buildFactChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: const Color(0xFFFFD54F), size: 28),
        const SizedBox(width: 10),
        Text(text, style: GoogleFonts.lato(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildAuthorCard(String name, String chapters, IconData icon, String desc, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.2),
            border: Border.all(color: accent, width: 2),
          ),
          child: Icon(icon, color: accent, size: 36),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(name, style: GoogleFonts.cinzel(fontSize: 28, color: accent, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Text(chapters, style: GoogleFonts.orbitron(fontSize: 16, color: accent)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(desc, style: GoogleFonts.lato(fontSize: 22, color: Colors.white70)),
        ])),
      ]),
    );
  }

  Widget _buildConceptCard(String title, IconData icon, Color accent) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnimation.value,
        child: Container(
          width: 280, height: 180,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [accent.withValues(alpha: 0.3), accent.withValues(alpha: 0.1)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2)],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: accent, size: 56),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.cinzel(fontSize: 28, color: accent, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _buildStructureItem(int index, String chapters, String title, IconData icon, Color accent, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: accent.withValues(alpha: 0.2),
            border: Border.all(color: accent, width: 2),
          ),
          child: Icon(icon, color: accent, size: 30),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
              child: Text(chapters, style: GoogleFonts.orbitron(fontSize: 18, color: accent, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.cinzel(fontSize: 26, color: accent, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.lato(fontSize: 22, color: Colors.white70, height: 1.4)),
        ])),
        if (index < 4)
          Container(width: 3, height: 60, margin: const EdgeInsets.only(left: 8), color: accent.withValues(alpha: 0.3)),
      ]),
    );
  }

  Widget _buildThemeCard(String title, String reference, String verse, IconData icon, Color accent) {
    return Container(
      width: 380, 
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.2), accent.withValues(alpha: 0.08)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.15), blurRadius: 20)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: accent, size: 36),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.cinzel(fontSize: 26, color: accent, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Text(reference, style: GoogleFonts.orbitron(fontSize: 16, color: accent)),
        ),
        const SizedBox(height: 12),
        Text('«$verse»', style: GoogleFonts.playfairDisplay(fontSize: 20, color: Colors.white70, fontStyle: FontStyle.italic, height: 1.5)),
      ]),
    );
  }

  Widget _buildVirtueChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE91E63).withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: const Color(0xFFE91E63), size: 26),
        const SizedBox(width: 10),
        Text(text, style: GoogleFonts.lato(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
