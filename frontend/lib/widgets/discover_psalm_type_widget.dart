import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _PsalmQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;
  final String psalmRef;
  final String comment;
  final Color correctColor;

  const _PsalmQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.psalmRef,
    required this.comment,
    required this.correctColor,
  });
}

const List<_PsalmQuestion> _questions = [
  _PsalmQuestion(
    text: 'Levántate, oh Señor; defiéndeme;\\npelea contra los que me combaten.',
    options: ['Imprecatorio', 'Lamento', 'Alabanza'],
    correctIndex: 0,
    psalmRef: 'Salmo 35',
    comment: 'Aquí el salmista pide intervención divina contra enemigos.',
    correctColor: Color(0xFFE53935),
  ),
  _PsalmQuestion(
    text: '¿Hasta cuándo, Señor, me olvidarás para siempre?',
    options: ['Imprecatorio', 'Lamento', 'Alabanza'],
    correctIndex: 1,
    psalmRef: 'Salmo 13',
    comment: 'Expresa angustia y dolor profundo ante el silencio de Dios.',
    correctColor: Color(0xFF1E88E5),
  ),
  _PsalmQuestion(
    text: 'Alabad al Señor porque Él es bueno;\\nporque para siempre es su misericordia.',
    options: ['Imprecatorio', 'Lamento', 'Alabanza'],
    correctIndex: 2,
    psalmRef: 'Salmo 136',
    comment: 'Un himno de gratitud que celebra la bondad eterna de Dios.',
    correctColor: Color(0xFF43A047),
  ),
  _PsalmQuestion(
    text: 'Sean avergonzados y confundidos\\nlos que buscan mi vida.',
    options: ['Imprecatorio', 'Lamento', 'Alabanza'],
    correctIndex: 0,
    psalmRef: 'Salmo 70',
    comment: 'David clama por justicia divina contra sus perseguidores.',
    correctColor: Color(0xFFE53935),
  ),
  _PsalmQuestion(
    text: 'En mi angustia invoqué al Señor,\\ny clamé a mi Dios.',
    options: ['Imprecatorio', 'Lamento', 'Alabanza'],
    correctIndex: 1,
    psalmRef: 'Salmo 18',
    comment: 'Un clamor desde lo profundo que Dios escucha y responde.',
    correctColor: Color(0xFF1E88E5),
  ),
];

/// =============================================================================
/// DESCUBRE EL TIPO DE SALMO — ACTIVIDAD INTERACTIVA PARA PROYECCIÓN
/// Instituto Bíblico Elim Internacional
/// =============================================================================
class DiscoverPsalmTypeWidget extends StatefulWidget {
  final bool isTeacher;

  const DiscoverPsalmTypeWidget({
    super.key,
    this.isTeacher = true,
  });

  @override
  State<DiscoverPsalmTypeWidget> createState() => _DiscoverPsalmTypeWidgetState();
}

class _DiscoverPsalmTypeWidgetState extends State<DiscoverPsalmTypeWidget>
    with TickerProviderStateMixin {

  int _currentQuestion = 0;
  bool _questionActive = false;
  bool _answerRevealed = false;
  int? _selectedOption;
  bool _answerLocked = false;

  Timer? _timer;
  int _secondsLeft = 30;
  static const int _totalSeconds = 30;

  int _score = 0;
  int _correctAnswers = 0;
  final List<int?> _studentAnswers = List.filled(5, null);

  late AnimationController _timerPulseController;
  late Animation<double> _timerPulseAnimation;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  int _page = 0; // 0=portada, 1..5=preguntas, 6=resultados

  @override
  void initState() {
    super.initState();
    _timerPulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _timerPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _timerPulseController, curve: Curves.easeInOut));
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _revealAnimation = CurvedAnimation(parent: _revealController, curve: Curves.elasticOut);
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerPulseController.dispose();
    _revealController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { _secondsLeft = _totalSeconds; });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 5 && _secondsLeft > 0) {
          _timerPulseController.forward().then((_) => _timerPulseController.reverse());
        }
        if (_secondsLeft <= 0) { timer.cancel(); _answerLocked = true; }
      });
    });
  }

  void _activateQuestion() {
    setState(() {
      _questionActive = true;
      _answerRevealed = false;
      _selectedOption = null;
      _answerLocked = false;
    });
    _revealController.reset();
    _startTimer();
  }

  void _selectOption(int index) {
    if (_answerLocked || _answerRevealed || _selectedOption != null) return;
    setState(() {
      _selectedOption = index;
      _answerLocked = true;
      _studentAnswers[_currentQuestion] = index;
    });
  }

  void _revealAnswer() {
    _timer?.cancel();
    setState(() {
      _answerRevealed = true;
      _answerLocked = true;
      if (_selectedOption == _questions[_currentQuestion].correctIndex) {
        _score++; _correctAnswers++;
      }
    });
    _revealController.forward();
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _page = _currentQuestion + 1;
        _questionActive = false;
        _answerRevealed = false;
        _selectedOption = null;
        _answerLocked = false;
        _secondsLeft = _totalSeconds;
      });
      _revealController.reset();
    } else {
      setState(() { _page = 6; });
    }
  }

  void _restart() {
    setState(() {
      _page = 0; _currentQuestion = 0; _questionActive = false;
      _answerRevealed = false; _selectedOption = null; _answerLocked = false;
      _score = 0; _correctAnswers = 0; _secondsLeft = _totalSeconds;
      for (int i = 0; i < _studentAnswers.length; i++) _studentAnswers[i] = null;
    });
    _revealController.reset();
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
        child: _buildCurrentPage(),
      ),
    );
  }

  Widget _buildCurrentPage() {
    if (_page == 0) return _buildCoverPage();
    if (_page == 6) return _buildResultsPage();
    return _buildQuestionPage();
  }

  Widget _buildCoverPage() {
    return Center(
      key: const ValueKey('cover'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  child: const Icon(Icons.lock_open_rounded, size: 100, color: Color(0xFFFFD54F)),
                );
              },
            ),
            const SizedBox(height: 40),
            Text(
              'DESCUBRE EL TIPO\nDE SALMO',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD54F),
                letterSpacing: 4,
                height: 1.2,
                shadows: [Shadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 4))],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Actividad Interactiva',
              style: GoogleFonts.lato(fontSize: 40, color: Colors.white70, fontWeight: FontWeight.w300, letterSpacing: 8),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 24, runSpacing: 20, alignment: WrapAlignment.center,
              children: [
                _buildInfoChip(Icons.quiz_rounded, '5 Preguntas'),
                _buildInfoChip(Icons.timer_rounded, '30 seg c/u'),
                _buildInfoChip(Icons.school_rounded, 'Docente controla'),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(30),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                children: [
                  Text('REGLAS', style: GoogleFonts.cinzel(fontSize: 36, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _buildRule(Icons.play_circle_outline, 'El docente activa cada pregunta'),
                  const SizedBox(height: 12),
                  _buildRule(Icons.touch_app, 'Selecciona una opción antes que termine el tiempo'),
                  const SizedBox(height: 12),
                  _buildRule(Icons.lock_clock, 'No puedes cambiar tu respuesta'),
                  const SizedBox(height: 12),
                  _buildRule(Icons.visibility_off, 'El resultado se revela cuando el docente lo decide'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => setState(() { _page = 1; }),
              icon: const Icon(Icons.play_arrow_rounded, size: 44),
              label: Text('COMENZAR', style: GoogleFonts.cinzel(fontSize: 36, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD54F),
                foregroundColor: const Color(0xFF0D1B2A),
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFD54F), size: 32),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.lato(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRule(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 30),
        const SizedBox(width: 14),
        Expanded(child: Text(text, style: GoogleFonts.lato(fontSize: 28, color: Colors.white70))),
      ],
    );
  }

  Widget _buildQuestionPage() {
    final q = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Center(
      key: ValueKey('q_$_currentQuestion'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Text('Pregunta ${_currentQuestion + 1} de ${_questions.length}',
                  style: GoogleFonts.lato(fontSize: 32, color: Colors.white70, fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Puntos: $_score',
                    style: GoogleFonts.orbitron(fontSize: 28, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress, minHeight: 10,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
              ),
            ),
            const SizedBox(height: 24),

            if (_questionActive) ...[
              ScaleTransition(
                scale: _secondsLeft <= 5 ? _timerPulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: SizedBox(
                  width: 160, height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(width: 160, height: 160,
                        child: CircularProgressIndicator(
                          value: _secondsLeft / _totalSeconds, strokeWidth: 12,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _secondsLeft <= 5 ? const Color(0xFFE53935) :
                            _secondsLeft <= 10 ? const Color(0xFFFF9800) : const Color(0xFF43A047)),
                        ),
                      ),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('$_secondsLeft', style: GoogleFonts.orbitron(
                          fontSize: 56, fontWeight: FontWeight.w900,
                          color: _secondsLeft <= 5 ? const Color(0xFFE53935) : Colors.white)),
                        Text('seg', style: GoogleFonts.lato(fontSize: 20, color: Colors.white54)),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
                  const Color(0xFF1A237E).withValues(alpha: 0.6),
                  const Color(0xFF0D47A1).withValues(alpha: 0.4),
                ]),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.3), width: 3),
                boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 5)],
              ),
              child: Column(children: [
                const Icon(Icons.menu_book_rounded, color: Color(0xFFFFD54F), size: 56),
                const SizedBox(height: 16),
                Text('«', style: GoogleFonts.cinzel(fontSize: 52, color: Color(0xFFFFD54F).withValues(alpha: 0.5))),
                Text(q.text, textAlign: TextAlign.center, style: GoogleFonts.playfairDisplay(
                  fontSize: 48, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4, fontStyle: FontStyle.italic)),
                Text('»', style: GoogleFonts.cinzel(fontSize: 52, color: Color(0xFFFFD54F).withValues(alpha: 0.5))),
              ]),
            ),
            const SizedBox(height: 30),

            if (_questionActive)
              ...List.generate(q.options.length, (i) {
                final isSelected = _selectedOption == i;
                final isCorrect = i == q.correctIndex;
                Color bgColor; Color borderColor;
                if (_answerRevealed) {
                  if (isCorrect) { bgColor = const Color(0xFF43A047).withValues(alpha: 0.3); borderColor = const Color(0xFF43A047); }
                  else if (isSelected && !isCorrect) { bgColor = const Color(0xFFE53935).withValues(alpha: 0.3); borderColor = const Color(0xFFE53935); }
                  else { bgColor = Colors.white.withValues(alpha: 0.05); borderColor = Colors.white24; }
                } else {
                  bgColor = isSelected ? const Color(0xFFFFD54F).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05);
                  borderColor = isSelected ? const Color(0xFFFFD54F) : Colors.white24;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectOption(i),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
                        decoration: BoxDecoration(
                          color: bgColor, borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor, width: 3),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? const Color(0xFFFFD54F) : Colors.white38, width: 3),
                              color: isSelected ? const Color(0xFFFFD54F).withValues(alpha: 0.3) : Colors.transparent,
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Color(0xFFFFD54F), size: 28) : null,
                          ),
                          const SizedBox(width: 24),
                          Text(q.options[i], style: GoogleFonts.lato(
                            fontSize: 40, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: Colors.white)),
                          const Spacer(),
                          if (_answerRevealed && isCorrect) const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 44),
                          if (_answerRevealed && isSelected && !isCorrect) const Icon(Icons.cancel, color: Color(0xFFE53935), size: 44),
                        ]),
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
            if (widget.isTeacher) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4), width: 2),
                ),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.admin_panel_settings, color: Color(0xFFFFD54F), size: 36),
                    const SizedBox(width: 12),
                    Text('PANEL DEL DOCENTE', style: GoogleFonts.cinzel(fontSize: 28, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 20),
                  Wrap(spacing: 20, runSpacing: 16, alignment: WrapAlignment.center, children: [
                    if (!_questionActive)
                      ElevatedButton.icon(
                        onPressed: _activateQuestion,
                        icon: const Icon(Icons.play_arrow_rounded, size: 40),
                        label: Text('ACTIVAR PREGUNTA', style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                        ),
                      ),
                    if (_questionActive && !_answerRevealed)
                      ElevatedButton.icon(
                        onPressed: _revealAnswer,
                        icon: const Icon(Icons.lock_open_rounded, size: 40),
                        label: Text('REVELAR RESPUESTA', style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                        ),
                      ),
                    if (_answerRevealed)
                      ElevatedButton.icon(
                        onPressed: _nextQuestion,
                        icon: Icon(_currentQuestion < _questions.length - 1 ? Icons.arrow_forward_rounded : Icons.emoji_events_rounded, size: 40),
                        label: Text(
                          _currentQuestion < _questions.length - 1 ? 'SIGUIENTE PREGUNTA' : 'VER RESULTADOS',
                          style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD54F),
                          foregroundColor: const Color(0xFF0D1B2A),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                        ),
                      ),
                  ]),
                ]),
              ),
            ],

            if (_answerRevealed) ...[
              const SizedBox(height: 28),
              ScaleTransition(
                scale: _revealAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      q.correctColor.withValues(alpha: 0.3), q.correctColor.withValues(alpha: 0.1)]),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: q.correctColor, width: 3),
                    boxShadow: [BoxShadow(color: q.correctColor.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)],
                  ),
                  child: Column(children: [
                    Icon(_selectedOption == q.correctIndex ? Icons.celebration_rounded : Icons.info_outline_rounded,
                      color: q.correctColor, size: 64),
                    const SizedBox(height: 16),
                    Text('Correcta: ${q.options[q.correctIndex]}',
                      style: GoogleFonts.cinzel(fontSize: 40, color: q.correctColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Pertenece al ${q.psalmRef}',
                      style: GoogleFonts.lato(fontSize: 32, color: Colors.white70, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFFFD54F), size: 32),
                        const SizedBox(width: 16),
                        Expanded(child: Text(q.comment, style: GoogleFonts.lato(
                          fontSize: 28, color: Colors.white70, fontStyle: FontStyle.italic))),
                      ]),
                    ),
                    if (_selectedOption == q.correctIndex) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text('+1 PUNTO', style: GoogleFonts.orbitron(fontSize: 28, color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ]),
                ),
              ),
            ],

            if (!_questionActive && !_answerRevealed)
              Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.hourglass_empty_rounded, color: Colors.white38, size: 44),
                  const SizedBox(width: 20),
                  Text('Esperando que el docente\nactive la pregunta...',
                    style: GoogleFonts.lato(fontSize: 32, color: Colors.white38),
                    textAlign: TextAlign.center),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsPage() {
    final percentage = (_correctAnswers / _questions.length * 100).round();
    String emoji; String message; Color accentColor;
    if (percentage >= 80) {
      emoji = '🏆'; message = '¡Excelente! Dominas los tipos de salmos.';
      accentColor = const Color(0xFFFFD54F);
    } else if (percentage >= 60) {
      emoji = '💪'; message = '¡Buen trabajo! Sigue estudiando.';
      accentColor = const Color(0xFF43A047);
    } else {
      emoji = '📚'; message = 'Necesitas repasar los tipos de salmos.';
      accentColor = const Color(0xFF1E88E5);
    }

    return Center(
      key: const ValueKey('results'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(emoji, style: const TextStyle(fontSize: 100)),
          const SizedBox(height: 24),
          Text('RESULTADOS', style: GoogleFonts.cinzel(
            fontSize: 64, fontWeight: FontWeight.w900, color: Color(0xFFFFD54F), letterSpacing: 4)),
          const SizedBox(height: 30),
          Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [accentColor.withValues(alpha: 0.3), Colors.transparent]),
              border: Border.all(color: accentColor, width: 5),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$_correctAnswers/${_questions.length}',
                style: GoogleFonts.orbitron(fontSize: 60, fontWeight: FontWeight.w900, color: accentColor)),
              Text('correctas', style: GoogleFonts.lato(fontSize: 24, color: Colors.white54)),
            ]),
          ),
          const SizedBox(height: 20),
          Text('$percentage%', style: GoogleFonts.orbitron(fontSize: 52, color: accentColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(message, style: GoogleFonts.lato(fontSize: 32, color: Colors.white70), textAlign: TextAlign.center),
          const SizedBox(height: 36),

          Text('RESUMEN DE RESPUESTAS', style: GoogleFonts.cinzel(fontSize: 32, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...List.generate(_questions.length, (i) {
            final question = _questions[i];
            final answer = _studentAnswers[i];
            final isCorrect = answer == question.correctIndex;
            return Container(
              width: double.infinity, margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isCorrect ? const Color(0xFF43A047) : const Color(0xFFE53935)).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (isCorrect ? const Color(0xFF43A047) : const Color(0xFFE53935)).withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? const Color(0xFF43A047) : const Color(0xFFE53935), size: 40),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(question.psalmRef, style: GoogleFonts.cinzel(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(answer != null ? 'Tu respuesta: ${question.options[answer]}' : 'Sin respuesta',
                    style: GoogleFonts.lato(fontSize: 22, color: Colors.white54)),
                ])),
                Text(question.options[question.correctIndex],
                  style: GoogleFonts.lato(fontSize: 24, color: question.correctColor, fontWeight: FontWeight.bold)),
              ]),
            );
          }),
          const SizedBox(height: 36),
          ElevatedButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.replay_rounded, size: 40),
            label: Text('REPETIR ACTIVIDAD', style: GoogleFonts.cinzel(fontSize: 32, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: const Color(0xFF0D1B2A),
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 8,
            ),
          ),
        ]),
      ),
    );
  }
}
