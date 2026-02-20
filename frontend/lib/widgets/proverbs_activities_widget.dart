import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 4 Dinámicas Interactivas de Proverbios
/// 1. Diagnóstico personal: ¿Sabio o necio?
/// 2. Debate: ¿Qué es el temor de Jehová?
/// 3. Taller de comunicación (Prov 15)
/// 4. Análisis de liderazgo (Prov 29)
class ProverbsActivitiesWidget extends StatefulWidget {
  final bool isTeacher;
  const ProverbsActivitiesWidget({super.key, this.isTeacher = true});

  @override
  State<ProverbsActivitiesWidget> createState() => _ProverbsActivitiesWidgetState();
}

class _ProverbsActivitiesWidgetState extends State<ProverbsActivitiesWidget>
    with TickerProviderStateMixin {

  // Current dynamic (0=menu, 1-4=activities)
  int _currentDynamic = 0;
  int _currentStep = 0;
  int _totalPoints = 0;
  int _answeredCount = 0;
  int? _selectedOption;
  bool _showFeedback = false;
  bool _activityComplete = false;
  final Set<String> _earnedBadges = {};

  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;

  // Estructura de cada pregunta
  static const List<Map<String, dynamic>> _sabioNecioQuestions = [
    {
      'scenario': 'Tu compañero de trabajo te crítica injustamente frente a todos. ¿Cómo reaccionas?',
      'verse': 'Proverbios 15:1',
      'options': ['Respondes con calma y buscas conversar en privado', 'Le gritas de vuelta para defenderte', 'Guardas rencor y planeas venganza', 'Publicas su error en redes sociales'],
      'correct': 0,
      'feedback': "«La blanda respuesta quita la ira; la palabra áspera hace subir el furor.»",
      'type': 'Sabio',
    },
    {
      'scenario': 'Recibes una crítica constructiva de tu pastor. ¿Qué haces?',
      'verse': 'Proverbios 12:1',
      'options': ['Te enojas y dejas de asistir a la iglesia', 'La ignoras completamente', 'La recibes con humildad y buscas mejorar', 'Criticas al pastor con otros hermanos'],
      'correct': 2,
      'feedback': "«El que ama la instrucción ama la sabiduría; mas el que aborrece la reprensión es ignorante.»",
      'type': 'Sabio',
    },
    {
      'scenario': 'Un amigo te pide prestado dinero que sabes que no devolverá. ¿Qué decisiones tomas?',
      'verse': 'Proverbios 22:7',
      'options': ['Le prestas sin preguntar nada', 'Le dices que no tienes dinero (mentira)', 'Le explicas con amor tu situación y ofreces ayuda de otra forma', 'Lo ignoras y no contestas sus mensajes'],
      'correct': 2,
      'feedback': "«El rico se enseñorea de los pobres, y el que toma prestado es siervo del que presta.»",
      'type': 'Sabio',
    },
    {
      'scenario': 'Descubres un chisme jugoso sobre alguien de tu congregación. ¿Qué haces?',
      'verse': 'Proverbios 11:13',
      'options': ['Lo compartes solo con tu mejor amigo', 'Lo publicas en el grupo de WhatsApp', 'Guardas silencio y oras por esa persona', 'Lo cuentas disfrazándolo como petición de oración'],
      'correct': 2,
      'feedback': "«El que anda en chismes descubre el secreto; mas el de espíritu fiel lo guarda todo.»",
      'type': 'Sabio',
    },
    {
      'scenario': 'Tu hijo adolescente desafía tu autoridad repetidamente. ¿Cómo respondes?',
      'verse': 'Proverbios 29:17',
      'options': ['Lo dejas hacer lo que quiera para evitar conflictos', 'Le gritas y lo castigas sin explicación', 'Lo disciplinas con amor, explicando las razones bíblicas', 'Lo comparas con otros jóvenes más obedientes'],
      'correct': 2,
      'feedback': "«Corrige a tu hijo, y te dará descanso, y dará alegría a tu alma.»",
      'type': 'Sabio',
    },
  ];

  static const List<Map<String, dynamic>> _temorJehovaQuestions = [
    {
      'scenario': '¿Qué significa el temor de Jehová en la vida práctica?',
      'verse': 'Proverbios 1:7',
      'options': ['Tenerle miedo a Dios y no pecar por temor al castigo', 'Reverenciar a Dios, obedecerle por amor y reconocer su soberanía', 'Asistir a la iglesia todos los domingos', 'Leer la Biblia una vez al año'],
      'correct': 1,
      'feedback': "«El principio de la sabiduría es el temor de Jehová; los insensatos desprecian la sabiduría y la enseñanza.»",
    },
    {
      'scenario': 'En tu trabajo te ofrecen un ascenso, pero debes comprometer tus principios éticos. ¿Qué refleja el temor de Jehová?',
      'verse': 'Proverbios 16:6',
      'options': ['Aceptas: Dios entenderá que necesitas el dinero', 'Rechazas el ascenso confiando en la provisión de Dios', 'Aceptas y luego pides perdón', 'Pides consejo al que más gana en la oficina'],
      'correct': 1,
      'feedback': "«Con misericordia y verdad se corrige el pecado, y con el temor de Jehová los hombres se apartan del mal.»",
    },
    {
      'scenario': '¿Cómo se manifiesta el temor de Jehová en la crianza de los hijos?',
      'verse': 'Proverbios 22:6',
      'options': ['Dejar que la escuela les enseñe valores', 'Instruirlos en el camino de Dios desde pequeños con ejemplo y Palabra', 'Obligarlos a ir a la iglesia sin explicar por qué', 'Esperar a que sean adultos para que decidan solos'],
      'correct': 1,
      'feedback': "«Instruye al niño en su camino, y aun cuando fuere viejo no se apartará de él.»",
    },
    {
      'scenario': 'Nadie está mirando y tienes la oportunidad de tomar algo que no es tuyo. ¿Qué haces?',
      'verse': 'Proverbios 15:3',
      'options': ['Lo tomas: nadie se dará cuenta', 'No lo tomas porque alguien podría verte', 'No lo tomas porque Dios ve todas las cosas y le temes', 'Lo tomas y lo devuelves después'],
      'correct': 2,
      'feedback': "«Los ojos de Jehová están en todo lugar, mirando a los malos y a los buenos.»",
    },
    {
      'scenario': '¿Cuál es el resultado práctico de vivir con temor de Jehová?',
      'verse': 'Proverbios 14:26-27',
      'options': ['Riqueza material asegurada', 'Confianza firme, refugio para los hijos y fuente de vida', 'Popularidad en la iglesia', 'Nunca tener problemas en la vida'],
      'correct': 1,
      'feedback': "«En el temor de Jehová está la fuerte confianza; y esperanza tendrán sus hijos.»",
    },
  ];

  static const List<Map<String, dynamic>> _comunicacionQuestions = [
    {
      'scenario': 'Tu cónyuge llega estresado del trabajo y te habla de forma brusca. ¿Cómo respondes?',
      'verse': 'Proverbios 15:1',
      'options': ['Le respondes con el mismo tono agresivo', 'Le dices con suavidad: Entiendo que estás cansado, hablemos cuando estés tranquilo', 'Te encierras en tu cuarto sin hablar', 'Lo ignoras y te pones a ver el teléfono'],
      'correct': 1,
      'feedback': "«La blanda respuesta quita la ira; mas la palabra áspera hace subir el furor.» (Pr. 15:1)",
    },
    {
      'scenario': 'En una reunión de líderes, alguien propone algo que sabes que está mal. ¿Cómo lo expresas?',
      'verse': 'Proverbios 15:2',
      'options': ['Te callas por temor a conflictos', 'Dices que es una idea terrible frente a todos', 'Con sabiduría y gentileza compartes tu perspectiva bíblica', 'Hablas mal de la idea después, a espaldas'],
      'correct': 2,
      'feedback': "«La lengua de los sabios adornará la sabiduría; mas la boca de los necios hablará sandeces.» (Pr. 15:2)",
    },
    {
      'scenario': 'Un hermano de la iglesia te confía un problema personal. ¿Qué haces con esa información?',
      'verse': 'Proverbios 15:4',
      'options': ['La usas como ejemplo en tu próximo estudio bíblico', 'La compartes como pedido de oración', 'Guardas confidencialidad y lo animas con la Palabra', 'Le dices a tu esposa y le pides que no cuente'],
      'correct': 2,
      'feedback': "«La sana lengua es árbol de vida; mas la perversidad de ella es quebrantamiento de espíritu.» (Pr. 15:4)",
    },
    {
      'scenario': 'Tu jefe te pide que le cubras una mentira ante un cliente. ¿Qué palabras eliges?',
      'verse': 'Proverbios 15:23',
      'options': ['Mientes para no perder tu empleo', 'Le dices con respeto que no puedes mentir y propones una solución honesta', 'Le dices que es un corrupto frente a todos', 'Aceptas pero te sientes mal internamente'],
      'correct': 1,
      'feedback': "«El hombre se alegra con la respuesta de su boca; y la palabra a su tiempo, ¡cuán buena es!» (Pr. 15:23)",
    },
    {
      'scenario': '¿Cómo debe ser tu comunicación cuando corriges a alguien menor que tú?',
      'verse': 'Proverbios 15:28',
      'options': ['Rápida y directa: hay que ser frontal', 'Pensada, medida y con amor antes de hablar', 'Por mensaje de texto para no confrontar', 'Delegar la corrección a alguien más'],
      'correct': 1,
      'feedback': "«El corazón del justo piensa para responder; mas la boca de los impíos derrama malas cosas.» (Pr. 15:28)",
    },
  ];

  static const List<Map<String, dynamic>> _liderazgoQuestions = [
    {
      'scenario': 'Eres líder de un ministerio y un miembro comete un error grave. ¿Cómo lo manejas?',
      'verse': 'Proverbios 29:2',
      'options': ['Lo expones públicamente como ejemplo', 'Lo ignoras para no causar problemas', 'Lo confrontas en privado con gracia, buscando restauración', 'Lo sacas del ministerio sin explicación'],
      'correct': 2,
      'feedback': "«Cuando los justos dominan, el pueblo se alegra; mas cuando domina el impío, el pueblo gime.» (Pr. 29:2)",
    },
    {
      'scenario': 'Como líder, recibes halagos constantes. ¿Cómo manejas la adulación?',
      'verse': 'Proverbios 29:5',
      'options': ['La disfrutas: te la mereces por tu trabajo', 'Reconoces que puede ser una trampa y mantienes humildad', 'La usas para pedir más autoridad', 'Exiges que todos te reconozcan más'],
      'correct': 1,
      'feedback': "«El hombre que lisonjea a su prójimo, red tiende delante de sus pasos.» (Pr. 29:5)",
    },
    {
      'scenario': 'Un grupo en tu iglesia se queja de tu liderazgo. ¿Cuál es la respuesta sabia?',
      'verse': 'Proverbios 29:11',
      'options': ['Explotas y les dices que se vayan si no les gusta', 'Escuchas con paciencia, reflexionas y buscas consejo de Dios', 'Renuncias inmediatamente', 'Los ignoras: los críticos siempre existirán'],
      'correct': 1,
      'feedback': "«El necio da rienda suelta a toda su ira, mas el sabio al fin la sosiega.» (Pr. 29:11)",
    },
    {
      'scenario': 'Debes tomar una decisión importante para la iglesia pero no tienes toda la información. ¿Qué haces?',
      'verse': 'Proverbios 29:18',
      'options': ['Decides rápido: un líder debe ser decisivo', 'Buscas la visión de Dios en oración y consejo de otros líderes', 'Dejas que otro decida por ti', 'Pospones la decisión indefinidamente'],
      'correct': 1,
      'feedback': "«Sin profecía el pueblo se desenfrena; mas el que guarda la ley es bienaventurado.» (Pr. 29:18)",
    },
    {
      'scenario': '¿Qué tipo de líder es el que disciplina con amor según Proverbios 29?',
      'verse': 'Proverbios 29:17',
      'options': ['El que castiga sin misericordia', 'El que deja hacer cualquier cosa', 'El que corrige a tiempo y con sabiduría, buscando el bien de su pueblo', 'El que solo predica pero no actúa'],
      'correct': 2,
      'feedback': "«Corrige a tu hijo, y te dará descanso, y dará alegría a tu alma.» (Pr. 29:17)",
    },
  ];

  static const List<Map<String, dynamic>> _activityMeta = [
    {
      'title': '¿Sabio o Necio?',
      'subtitle': 'Diagnóstico personal',
      'verse': 'Proverbios 15:1',
      'objective': 'Evalúa si tus reacciones diarias reflejan sabiduría o necedad.',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF1E88E5),
      'badge': 'Espíritu Sabio',
      'challenge': "Esta semana, antes de reaccionar a cualquier situación, deténte 5 segundos y piensa: ¿Qué haría el sabio?",
      'selfEval': "¿En cuál área de tu vida necesitas más sabiduría: familia, trabajo, iglesia o amistades?",
    },
    {
      'title': 'Temor de Jehová',
      'subtitle': 'Debate interactivo',
      'verse': 'Proverbios 1:7',
      'objective': 'Comprende y aplica el temor de Jehová como fundamento de la vida cristiana.',
      'icon': Icons.church_rounded,
      'color': Color(0xFFFFD54F),
      'badge': 'Reverente',
      'challenge': "Cada mañana de esta semana, ora diciendo: Señor, ayúdame a vivir con reverencia hoy.",
      'selfEval': "¿Temes a Dios por amor o por miedo al castigo?",
    },
    {
      'title': 'Comunicación Sabia',
      'subtitle': 'Taller práctico',
      'verse': 'Proverbios 15',
      'objective': 'Transforma tu manera de comunicarte según los principios de Proverbios 15.',
      'icon': Icons.record_voice_over_rounded,
      'color': Color(0xFF43A047),
      'badge': 'Comunicador del Rey',
      'challenge': "Practica la regla 5-5: Antes de hablar, espera 5 segundos. Después, piensa 5 segundos si tus palabras edifican.",
      'selfEval': "¿Cuántas veces esta semana tus palabras causaron daño en lugar de bendición?",
    },
    {
      'title': 'Líder Bíblico',
      'subtitle': 'Análisis de liderazgo',
      'verse': 'Proverbios 29',
      'objective': 'Identifica qué tipo de líder eres según Proverbios 29.',
      'icon': Icons.groups_rounded,
      'color': Color(0xFF7B1FA2),
      'badge': 'Líder Justo',
      'challenge': "Si lideras algún área, esta semana pide retroalimentación honesta a una persona de confianza.",
      'selfEval': "¿Tu liderazgo hace que la gente se alegre o que gima? (Pr. 29:2)",
    },
  ];

  List<Map<String, dynamic>> _getQuestions() {
    switch (_currentDynamic) {
      case 1: return _sabioNecioQuestions;
      case 2: return _temorJehovaQuestions;
      case 3: return _comunicacionQuestions;
      case 4: return _liderazgoQuestions;
      default: return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _startActivity(int index) {
    setState(() {
      _currentDynamic = index;
      _currentStep = 0;
      _totalPoints = 0;
      _answeredCount = 0;
      _selectedOption = null;
      _showFeedback = false;
      _activityComplete = false;
    });
  }

  void _selectOption(int idx) {
    if (_showFeedback) return;
    setState(() { _selectedOption = idx; });
  }

  void _confirmAnswer() {
    if (_selectedOption == null) return;
    final qs = _getQuestions();
    final correct = qs[_currentStep]['correct'] as int;
    setState(() {
      _showFeedback = true;
      _answeredCount++;
      if (_selectedOption == correct) { _totalPoints += 20; }
    });
  }

  void _nextStep() {
    final qs = _getQuestions();
    if (_currentStep < qs.length - 1) {
      setState(() {
        _currentStep++;
        _selectedOption = null;
        _showFeedback = false;
      });
    } else {
      // Activity done
      final meta = _activityMeta[_currentDynamic - 1];
      final badge = meta['badge'] as String;
      setState(() {
        _activityComplete = true;
        if (_totalPoints >= 60) { _earnedBadges.add(badge); }
      });
    }
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _currentDynamic == 0
          ? _buildMenu()
          : _activityComplete ? _buildResults() : _buildActivity(),
      ),
    );
  }

  Widget _buildMenu() {
    return SingleChildScrollView(
      key: const ValueKey('menu'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(children: [
        AnimatedBuilder(
          animation: _floatAnim,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFFFD54F).withValues(alpha: 0.3),
                  Colors.transparent,
                ]),
              ),
              child: const Icon(Icons.extension_rounded, size: 80, color: Color(0xFFFFD54F)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('DINÁMICAS INTERACTIVAS', style: GoogleFonts.cinzel(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFFFFD54F), letterSpacing: 4)),
        const SizedBox(height: 8),
        Text('Libro de Proverbios — Actividades de 5 minutos', style: GoogleFonts.lato(fontSize: 24, color: Colors.white54)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFFFD54F), size: 28),
            const SizedBox(width: 10),
            Text('Insignias: ${_earnedBadges.length} / 4', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 36),
        Wrap(spacing: 24, runSpacing: 24, alignment: WrapAlignment.center, children: [
          ...List.generate(4, (i) => _buildActivityCard(i)),
        ]),
      ]),
    );
  }

  Widget _buildActivityCard(int index) {
    final meta = _activityMeta[index];
    final color = meta['color'] as Color;
    final icon = meta['icon'] as IconData;
    final badge = meta['badge'] as String;
    final earned = _earnedBadges.contains(badge);

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnim.value,
        child: GestureDetector(
          onTap: () => _startActivity(index + 1),
          child: Container(
            width: 400, height: 260,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)]),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 25, spreadRadius: 3)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.25),
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const Spacer(),
                if (earned) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), size: 20),
                    const SizedBox(width: 6),
                    Text(badge, style: GoogleFonts.lato(fontSize: 14, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              Text(meta['title'] as String, style: GoogleFonts.cinzel(fontSize: 28, color: color, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(meta['subtitle'] as String, style: GoogleFonts.lato(fontSize: 20, color: Colors.white54)),
              const Spacer(),
              Row(children: [
                Icon(Icons.menu_book_rounded, color: color.withValues(alpha: 0.6), size: 20),
                const SizedBox(width: 8),
                Text(meta['verse'] as String, style: GoogleFonts.orbitron(fontSize: 16, color: color.withValues(alpha: 0.7))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('INICIAR', style: GoogleFonts.lato(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildActivity() {
    final meta = _activityMeta[_currentDynamic - 1];
    final color = meta['color'] as Color;
    final qs = _getQuestions();
    final q = qs[_currentStep];

    return Column(
      key: ValueKey('act_${_currentDynamic}_$_currentStep'),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Row(children: [
            IconButton(
              onPressed: () => setState(() { _currentDynamic = 0; }),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 30),
            ),
            const SizedBox(width: 12),
            Text(meta['title'] as String, style: GoogleFonts.cinzel(fontSize: 28, color: color, fontWeight: FontWeight.bold)),
            const Spacer(),
            ...List.generate(qs.length, (i) => Container(
              width: i == _currentStep ? 36 : 12, height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: i < _currentStep ? const Color(0xFFFFD54F)
                  : i == _currentStep ? color : Colors.white24,
              ),
            )),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 22),
                const SizedBox(width: 6),
                Text('$_totalPoints pts', style: GoogleFonts.orbitron(fontSize: 18, color: Color(0xFFFFD54F))),
              ]),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.menu_book_rounded, color: color, size: 22),
                  const SizedBox(width: 10),
                  Text(q['verse'] as String, style: GoogleFonts.orbitron(fontSize: 18, color: color)),
                ]),
              )),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ]),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.question_answer_rounded, color: color, size: 36),
                  const SizedBox(width: 20),
                  Expanded(child: Text(
                    q['scenario'] as String,
                    style: GoogleFonts.lato(fontSize: 26, color: Colors.white, height: 1.5, fontWeight: FontWeight.w500),
                  )),
                ]),
              ),
              const SizedBox(height: 24),
              ...List.generate((q['options'] as List).length, (i) {
                final opt = (q['options'] as List)[i] as String;
                final correct = q['correct'] as int;
                final isSelected = _selectedOption == i;
                final isCorrect = i == correct;

                Color borderC = Colors.white24;
                Color bgC = Colors.white.withValues(alpha: 0.04);
                IconData? trailingIcon;

                if (_showFeedback) {
                  if (isCorrect) { borderC = const Color(0xFF43A047); bgC = const Color(0xFF43A047).withValues(alpha: 0.15); trailingIcon = Icons.check_circle_rounded; }
                  else if (isSelected) { borderC = const Color(0xFFE53935); bgC = const Color(0xFFE53935).withValues(alpha: 0.1); trailingIcon = Icons.cancel_rounded; }
                } else if (isSelected) {
                  borderC = color; bgC = color.withValues(alpha: 0.1);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _selectOption(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: bgC,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderC, width: 2),
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                            border: Border.all(color: isSelected ? color : Colors.white24),
                          ),
                          child: Center(child: Text(String.fromCharCode(65 + i), style: GoogleFonts.orbitron(fontSize: 18, color: isSelected ? color : Colors.white54))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Text(opt, style: GoogleFonts.lato(fontSize: 22, color: Colors.white, height: 1.4))),
                        if (trailingIcon != null) Icon(trailingIcon!, color: isCorrect ? const Color(0xFF43A047) : const Color(0xFFE53935), size: 30),
                      ]),
                    ),
                  ),
                );
              }),
              if (_showFeedback) Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFF1B5E20).withValues(alpha: 0.3),
                    const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  ]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.5), width: 2),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Retroalimentación Bíblica', style: GoogleFonts.cinzel(fontSize: 22, color: Color(0xFF43A047), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(q['feedback'] as String, style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5)),
                ]),
              ),
            ]),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('${_currentStep + 1} / ${qs.length}', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white38)),
            const Spacer(),
            if (!_showFeedback)
              ElevatedButton.icon(
                onPressed: _selectedOption != null ? _confirmAnswer : null,
                icon: const Icon(Icons.check_rounded, size: 26),
                label: Text('CONFIRMAR', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white30,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            if (_showFeedback)
              ElevatedButton.icon(
                onPressed: _nextStep,
                icon: const Icon(Icons.arrow_forward_rounded, size: 26),
                label: Text(_currentStep < qs.length - 1 ? 'SIGUIENTE' : 'VER RESULTADOS', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: const Color(0xFF1A0A2E),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
          ]),
        ),
      ],
    );
  }

  Widget _buildResults() {
    final meta = _activityMeta[_currentDynamic - 1];
    final color = meta['color'] as Color;
    final badge = meta['badge'] as String;
    final earned = _totalPoints >= 60;
    final percentage = (_totalPoints / 100 * 100).round();

    return SingleChildScrollView(
      key: const ValueKey('results'),
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
      child: Column(children: [
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                (earned ? const Color(0xFFFFD54F) : const Color(0xFFE53935)).withValues(alpha: _glowAnim.value * 0.4),
                Colors.transparent,
              ]),
              boxShadow: [BoxShadow(
                color: (earned ? const Color(0xFFFFD54F) : const Color(0xFFE53935)).withValues(alpha: _glowAnim.value * 0.3),
                blurRadius: 40, spreadRadius: 10)],
            ),
            child: Icon(
              earned ? Icons.emoji_events_rounded : Icons.school_rounded,
              size: 90, color: earned ? const Color(0xFFFFD54F) : Colors.white54),
          ),
        ),
        const SizedBox(height: 24),
        Text(earned ? '¡EXCELENTE!' : 'SIGUE CRECIENDO', style: GoogleFonts.cinzel(fontSize: 48, fontWeight: FontWeight.w900, color: earned ? Color(0xFFFFD54F) : Colors.white54, letterSpacing: 4)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 36),
            const SizedBox(width: 16),
            Text('$_totalPoints / 100 puntos', style: GoogleFonts.orbitron(fontSize: 32, color: Color(0xFFFFD54F))),
          ]),
        ),
        const SizedBox(height: 24),
        if (earned) Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFFFFD54F).withValues(alpha: 0.2),
              const Color(0xFFFF8F00).withValues(alpha: 0.1),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5), width: 2),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), size: 36),
            const SizedBox(width: 16),
            Text('Insignia: $badge', style: GoogleFonts.cinzel(fontSize: 26, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),
          ]),
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.08),
            ]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.flag_rounded, color: color, size: 30),
              const SizedBox(width: 12),
              Text('RETO SEMANAL', style: GoogleFonts.cinzel(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Text(meta['challenge'] as String, style: GoogleFonts.lato(fontSize: 22, color: Colors.white, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.self_improvement_rounded, color: Colors.white70, size: 30),
              const SizedBox(width: 12),
              Text('AUTOEVALUACIÓN', style: GoogleFonts.cinzel(fontSize: 24, color: Colors.white70, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Text(meta['selfEval'] as String, style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5)),
          ]),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () => setState(() { _currentDynamic = 0; }),
          icon: const Icon(Icons.arrow_back_rounded, size: 26),
          label: Text('VOLVER AL MENÚ', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            foregroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ]),
    );
  }
}
