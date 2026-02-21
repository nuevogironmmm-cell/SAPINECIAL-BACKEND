# -*- coding: utf-8 -*-
# Genera proverbs_activities_widget.dart
# 4 dinamicas interactivas para Proverbios con gamificacion
import os

output_path = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    'frontend', 'lib', 'widgets', 'proverbs_activities_widget.dart'
)

L = []
def w(s=''):
    L.append(s)

# --- Helpers for special chars ---
def E(c): return chr(c)  # shorthand

AACUTE = E(225)   # a with accent
EACUTE = E(233)   # e with accent
IACUTE = E(237)   # i with accent
OACUTE = E(243)   # o with accent
UACUTE = E(250)   # u with accent
NTILDE = E(241)   # n tilde
QUEST_INV = E(191) # inverted ?
EXCL_INV = E(161)  # inverted !
COMILLAS_A = E(171) # left guillemet
COMILLAS_C = E(187) # right guillemet
EMDASH = E(8212)

# ===============================================================
# IMPORTS
# ===============================================================
w("import 'dart:math';")
w("import 'package:flutter/material.dart';")
w("import 'package:google_fonts/google_fonts.dart';")
w()

# ===============================================================
# MAIN WIDGET
# ===============================================================
w("/// 4 Din" + AACUTE + "micas Interactivas de Proverbios")
w("/// 1. Diagn" + OACUTE + "stico personal: " + QUEST_INV + "Sabio o necio?")
w("/// 2. Debate: " + QUEST_INV + "Qu" + EACUTE + " es el temor de Jehov" + AACUTE + "?")
w("/// 3. Taller de comunicaci" + OACUTE + "n (Prov 15)")
w("/// 4. An" + AACUTE + "lisis de liderazgo (Prov 29)")
w("class ProverbsActivitiesWidget extends StatefulWidget {")
w("  final bool isTeacher;")
w("  const ProverbsActivitiesWidget({super.key, this.isTeacher = true});")
w()
w("  @override")
w("  State<ProverbsActivitiesWidget> createState() => _ProverbsActivitiesWidgetState();")
w("}")
w()

# ===============================================================
# STATE
# ===============================================================
w("class _ProverbsActivitiesWidgetState extends State<ProverbsActivitiesWidget>")
w("    with TickerProviderStateMixin {")
w()
w("  // Current dynamic (0=menu, 1-4=activities)")
w("  int _currentDynamic = 0;")
w("  int _currentStep = 0;")
w("  int _totalPoints = 0;")
w("  int _answeredCount = 0;")
w("  int? _selectedOption;")
w("  bool _showFeedback = false;")
w("  bool _activityComplete = false;")
w("  final Set<String> _earnedBadges = {};")
w()
w("  late AnimationController _glowCtrl;")
w("  late Animation<double> _glowAnim;")
w("  late AnimationController _pulseCtrl;")
w("  late Animation<double> _pulseAnim;")
w("  late AnimationController _floatCtrl;")
w("  late Animation<double> _floatAnim;")
w()

# ---------------------------------------------------------------
# ACTIVITY DATA STRUCTURES
# ---------------------------------------------------------------
w("  // Estructura de cada pregunta")
w("  static const List<Map<String, dynamic>> _sabioNecioQuestions = [")
# Activity 1: Sabio o Necio - 5 scenarios
scenarios = [
    {
        'scenario': f'Tu compa{NTILDE}ero de trabajo te cr{IACUTE}tica injustamente frente a todos. {QUEST_INV}C{OACUTE}mo reaccionas?',
        'verse': 'Proverbios 15:1',
        'options': [
            f'Respondes con calma y buscas conversar en privado',
            f'Le gritas de vuelta para defenderte',
            f'Guardas rencor y planeas venganza',
            f'Publicas su error en redes sociales',
        ],
        'correct': 0,
        'feedback': f'{COMILLAS_A}La blanda respuesta quita la ira; la palabra {AACUTE}spera hace subir el furor.{COMILLAS_C}',
        'type': 'Sabio',
    },
    {
        'scenario': f'Recibes una cr{IACUTE}tica constructiva de tu pastor. {QUEST_INV}Qu{EACUTE} haces?',
        'verse': 'Proverbios 12:1',
        'options': [
            f'Te enojas y dejas de asistir a la iglesia',
            f'La ignoras completamente',
            f'La recibes con humildad y buscas mejorar',
            f'Criticas al pastor con otros hermanos',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}El que ama la instrucci{OACUTE}n ama la sabidur{IACUTE}a; mas el que aborrece la reprensi{OACUTE}n es ignorante.{COMILLAS_C}',
        'type': 'Sabio',
    },
    {
        'scenario': f'Un amigo te pide prestado dinero que sabes que no devolver{AACUTE}. {QUEST_INV}Qu{EACUTE} decisiones tomas?',
        'verse': 'Proverbios 22:7',
        'options': [
            f'Le prestas sin preguntar nada',
            f'Le dices que no tienes dinero (mentira)',
            f'Le explicas con amor tu situaci{OACUTE}n y ofreces ayuda de otra forma',
            f'Lo ignoras y no contestas sus mensajes',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}El rico se ense{NTILDE}orea de los pobres, y el que toma prestado es siervo del que presta.{COMILLAS_C}',
        'type': 'Sabio',
    },
    {
        'scenario': f'Descubres un chisme jugoso sobre alguien de tu congregaci{OACUTE}n. {QUEST_INV}Qu{EACUTE} haces?',
        'verse': 'Proverbios 11:13',
        'options': [
            f'Lo compartes solo con tu mejor amigo',
            f'Lo publicas en el grupo de WhatsApp',
            f'Guardas silencio y oras por esa persona',
            f'Lo cuentas disfraz{AACUTE}ndolo como petici{OACUTE}n de oraci{OACUTE}n',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}El que anda en chismes descubre el secreto; mas el de esp{IACUTE}ritu fiel lo guarda todo.{COMILLAS_C}',
        'type': 'Sabio',
    },
    {
        'scenario': f'Tu hijo adolescente desaf{IACUTE}a tu autoridad repetidamente. {QUEST_INV}C{OACUTE}mo respondes?',
        'verse': 'Proverbios 29:17',
        'options': [
            f'Lo dejas hacer lo que quiera para evitar conflictos',
            f'Le gritas y lo castigas sin explicaci{OACUTE}n',
            f'Lo disciplinas con amor, explicando las razones b{IACUTE}blicas',
            f'Lo comparas con otros j{OACUTE}venes m{AACUTE}s obedientes',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}Corrige a tu hijo, y te dar{AACUTE} descanso, y dar{AACUTE} alegr{IACUTE}a a tu alma.{COMILLAS_C}',
        'type': 'Sabio',
    },
]

for sc in scenarios:
    w("    {")
    w(f"      'scenario': '{sc['scenario']}',")
    w(f"      'verse': '{sc['verse']}',")
    w(f"      'options': {sc['options']},")
    w(f"      'correct': {sc['correct']},")
    w(f"      'feedback': \"{sc['feedback']}\",")
    w(f"      'type': '{sc['type']}',")
    w("    },")
w("  ];")
w()

# Activity 2: Temor de Jehova - debate with scenarios
w("  static const List<Map<String, dynamic>> _temorJehovaQuestions = [")
temor_qs = [
    {
        'scenario': f'{QUEST_INV}Qu{EACUTE} significa el temor de Jehov{AACUTE} en la vida pr{AACUTE}ctica?',
        'verse': 'Proverbios 1:7',
        'options': [
            f'Tenerle miedo a Dios y no pecar por temor al castigo',
            f'Reverenciar a Dios, obedecerle por amor y reconocer su soberan{IACUTE}a',
            f'Asistir a la iglesia todos los domingos',
            f'Leer la Biblia una vez al a{NTILDE}o',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}El principio de la sabidur{IACUTE}a es el temor de Jehov{AACUTE}; los insensatos desprecian la sabidur{IACUTE}a y la ense{NTILDE}anza.{COMILLAS_C}',
    },
    {
        'scenario': f'En tu trabajo te ofrecen un ascenso, pero debes comprometer tus principios {EACUTE}ticos. {QUEST_INV}Qu{EACUTE} refleja el temor de Jehov{AACUTE}?',
        'verse': 'Proverbios 16:6',
        'options': [
            f'Aceptas: Dios entender{AACUTE} que necesitas el dinero',
            f'Rechazas el ascenso confiando en la provisi{OACUTE}n de Dios',
            f'Aceptas y luego pides perd{OACUTE}n',
            f'Pides consejo al que m{AACUTE}s gana en la oficina',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}Con misericordia y verdad se corrige el pecado, y con el temor de Jehov{AACUTE} los hombres se apartan del mal.{COMILLAS_C}',
    },
    {
        'scenario': f'{QUEST_INV}C{OACUTE}mo se manifiesta el temor de Jehov{AACUTE} en la crianza de los hijos?',
        'verse': 'Proverbios 22:6',
        'options': [
            f'Dejar que la escuela les ense{NTILDE}e valores',
            f'Instruirlos en el camino de Dios desde peque{NTILDE}os con ejemplo y Palabra',
            f'Obligarlos a ir a la iglesia sin explicar por qu{EACUTE}',
            f'Esperar a que sean adultos para que decidan solos',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}Instruye al ni{NTILDE}o en su camino, y aun cuando fuere viejo no se apartar{AACUTE} de {EACUTE}l.{COMILLAS_C}',
    },
    {
        'scenario': f'Nadie est{AACUTE} mirando y tienes la oportunidad de tomar algo que no es tuyo. {QUEST_INV}Qu{EACUTE} haces?',
        'verse': 'Proverbios 15:3',
        'options': [
            f'Lo tomas: nadie se dar{AACUTE} cuenta',
            f'No lo tomas porque alguien podr{IACUTE}a verte',
            f'No lo tomas porque Dios ve todas las cosas y le temes',
            f'Lo tomas y lo devuelves despu{EACUTE}s',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}Los ojos de Jehov{AACUTE} est{AACUTE}n en todo lugar, mirando a los malos y a los buenos.{COMILLAS_C}',
    },
    {
        'scenario': f'{QUEST_INV}Cu{AACUTE}l es el resultado pr{AACUTE}ctico de vivir con temor de Jehov{AACUTE}?',
        'verse': 'Proverbios 14:26-27',
        'options': [
            f'Riqueza material asegurada',
            f'Confianza firme, refugio para los hijos y fuente de vida',
            f'Popularidad en la iglesia',
            f'Nunca tener problemas en la vida',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}En el temor de Jehov{AACUTE} est{AACUTE} la fuerte confianza; y esperanza tendr{AACUTE}n sus hijos.{COMILLAS_C}',
    },
]
for q in temor_qs:
    w("    {")
    w(f"      'scenario': '{q['scenario']}',")
    w(f"      'verse': '{q['verse']}',")
    w(f"      'options': {q['options']},")
    w(f"      'correct': {q['correct']},")
    w(f"      'feedback': \"{q['feedback']}\",")
    w("    },")
w("  ];")
w()

# Activity 3: Taller de Comunicacion - Proverbios 15
w("  static const List<Map<String, dynamic>> _comunicacionQuestions = [")
com_qs = [
    {
        'scenario': f'Tu c{OACUTE}nyuge llega estresado del trabajo y te habla de forma brusca. {QUEST_INV}C{OACUTE}mo respondes?',
        'verse': 'Proverbios 15:1',
        'options': [
            f'Le respondes con el mismo tono agresivo',
            f'Le dices con suavidad: Entiendo que est{AACUTE}s cansado, hablemos cuando est{EACUTE}s tranquilo',
            f'Te encierras en tu cuarto sin hablar',
            f'Lo ignoras y te pones a ver el tel{EACUTE}fono',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}La blanda respuesta quita la ira; mas la palabra {AACUTE}spera hace subir el furor.{COMILLAS_C} (Pr. 15:1)',
    },
    {
        'scenario': f'En una reuni{OACUTE}n de l{IACUTE}deres, alguien propone algo que sabes que est{AACUTE} mal. {QUEST_INV}C{OACUTE}mo lo expresas?',
        'verse': 'Proverbios 15:2',
        'options': [
            f'Te callas por temor a conflictos',
            f'Dices que es una idea terrible frente a todos',
            f'Con sabidur{IACUTE}a y gentileza compartes tu perspectiva b{IACUTE}blica',
            f'Hablas mal de la idea despu{EACUTE}s, a espaldas',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}La lengua de los sabios adornar{AACUTE} la sabidur{IACUTE}a; mas la boca de los necios hablar{AACUTE} sandeces.{COMILLAS_C} (Pr. 15:2)',
    },
    {
        'scenario': f'Un hermano de la iglesia te conf{IACUTE}a un problema personal. {QUEST_INV}Qu{EACUTE} haces con esa informaci{OACUTE}n?',
        'verse': 'Proverbios 15:4',
        'options': [
            f'La usas como ejemplo en tu pr{OACUTE}ximo estudio b{IACUTE}blico',
            f'La compartes como pedido de oraci{OACUTE}n',
            f'Guardas confidencialidad y lo animas con la Palabra',
            f'Le dices a tu esposa y le pides que no cuente',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}La sana lengua es {AACUTE}rbol de vida; mas la perversidad de ella es quebrantamiento de esp{IACUTE}ritu.{COMILLAS_C} (Pr. 15:4)',
    },
    {
        'scenario': f'Tu jefe te pide que le cubras una mentira ante un cliente. {QUEST_INV}Qu{EACUTE} palabras eliges?',
        'verse': 'Proverbios 15:23',
        'options': [
            f'Mientes para no perder tu empleo',
            f'Le dices con respeto que no puedes mentir y propones una soluci{OACUTE}n honesta',
            f'Le dices que es un corrupto frente a todos',
            f'Aceptas pero te sientes mal internamente',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}El hombre se alegra con la respuesta de su boca; y la palabra a su tiempo, {EXCL_INV}cu{AACUTE}n buena es!{COMILLAS_C} (Pr. 15:23)',
    },
    {
        'scenario': f'{QUEST_INV}C{OACUTE}mo debe ser tu comunicaci{OACUTE}n cuando corriges a alguien menor que t{UACUTE}?',
        'verse': 'Proverbios 15:28',
        'options': [
            f'R{AACUTE}pida y directa: hay que ser frontal',
            f'Pensada, medida y con amor antes de hablar',
            f'Por mensaje de texto para no confrontar',
            f'Delegar la correcci{OACUTE}n a alguien m{AACUTE}s',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}El coraz{OACUTE}n del justo piensa para responder; mas la boca de los imp{IACUTE}os derrama malas cosas.{COMILLAS_C} (Pr. 15:28)',
    },
]
for q in com_qs:
    w("    {")
    w(f"      'scenario': '{q['scenario']}',")
    w(f"      'verse': '{q['verse']}',")
    w(f"      'options': {q['options']},")
    w(f"      'correct': {q['correct']},")
    w(f"      'feedback': \"{q['feedback']}\",")
    w("    },")
w("  ];")
w()

# Activity 4: Analisis de Liderazgo - Proverbios 29
w("  static const List<Map<String, dynamic>> _liderazgoQuestions = [")
lid_qs = [
    {
        'scenario': f'Eres l{IACUTE}der de un ministerio y un miembro comete un error grave. {QUEST_INV}C{OACUTE}mo lo manejas?',
        'verse': 'Proverbios 29:2',
        'options': [
            f'Lo expones p{UACUTE}blicamente como ejemplo',
            f'Lo ignoras para no causar problemas',
            f'Lo confrontas en privado con gracia, buscando restauraci{OACUTE}n',
            f'Lo sacas del ministerio sin explicaci{OACUTE}n',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}Cuando los justos dominan, el pueblo se alegra; mas cuando domina el imp{IACUTE}o, el pueblo gime.{COMILLAS_C} (Pr. 29:2)',
    },
    {
        'scenario': f'Como l{IACUTE}der, recibes halagos constantes. {QUEST_INV}C{OACUTE}mo manejas la adulaci{OACUTE}n?',
        'verse': 'Proverbios 29:5',
        'options': [
            f'La disfrutas: te la mereces por tu trabajo',
            f'Reconoces que puede ser una trampa y mantienes humildad',
            f'La usas para pedir m{AACUTE}s autoridad',
            f'Exiges que todos te reconozcan m{AACUTE}s',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}El hombre que lisonjea a su pr{OACUTE}jimo, red tiende delante de sus pasos.{COMILLAS_C} (Pr. 29:5)',
    },
    {
        'scenario': f'Un grupo en tu iglesia se queja de tu liderazgo. {QUEST_INV}Cu{AACUTE}l es la respuesta sabia?',
        'verse': 'Proverbios 29:11',
        'options': [
            f'Explotas y les dices que se vayan si no les gusta',
            f'Escuchas con paciencia, reflexionas y buscas consejo de Dios',
            f'Renuncias inmediatamente',
            f'Los ignoras: los cr{IACUTE}ticos siempre existir{AACUTE}n',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}El necio da rienda suelta a toda su ira, mas el sabio al fin la sosiega.{COMILLAS_C} (Pr. 29:11)',
    },
    {
        'scenario': f'Debes tomar una decisi{OACUTE}n importante para la iglesia pero no tienes toda la informaci{OACUTE}n. {QUEST_INV}Qu{EACUTE} haces?',
        'verse': 'Proverbios 29:18',
        'options': [
            f'Decides r{AACUTE}pido: un l{IACUTE}der debe ser decisivo',
            f'Buscas la visi{OACUTE}n de Dios en oraci{OACUTE}n y consejo de otros l{IACUTE}deres',
            f'Dejas que otro decida por ti',
            f'Pospones la decisi{OACUTE}n indefinidamente',
        ],
        'correct': 1,
        'feedback': f'{COMILLAS_A}Sin profec{IACUTE}a el pueblo se desenfrena; mas el que guarda la ley es bienaventurado.{COMILLAS_C} (Pr. 29:18)',
    },
    {
        'scenario': f'{QUEST_INV}Qu{EACUTE} tipo de l{IACUTE}der es el que disciplina con amor seg{UACUTE}n Proverbios 29?',
        'verse': 'Proverbios 29:17',
        'options': [
            f'El que castiga sin misericordia',
            f'El que deja hacer cualquier cosa',
            f'El que corrige a tiempo y con sabidur{IACUTE}a, buscando el bien de su pueblo',
            f'El que solo predica pero no act{UACUTE}a',
        ],
        'correct': 2,
        'feedback': f'{COMILLAS_A}Corrige a tu hijo, y te dar{AACUTE} descanso, y dar{AACUTE} alegr{IACUTE}a a tu alma.{COMILLAS_C} (Pr. 29:17)',
    },
]
for q in lid_qs:
    w("    {")
    w(f"      'scenario': '{q['scenario']}',")
    w(f"      'verse': '{q['verse']}',")
    w(f"      'options': {q['options']},")
    w(f"      'correct': {q['correct']},")
    w(f"      'feedback': \"{q['feedback']}\",")
    w("    },")
w("  ];")
w()

# Activity meta data
w("  static const List<Map<String, dynamic>> _activityMeta = [")
activities_meta = [
    {
        'title': f'{QUEST_INV}Sabio o Necio?',
        'subtitle': f'Diagn{OACUTE}stico personal',
        'verse': 'Proverbios 15:1',
        'objective': f'Eval{UACUTE}a si tus reacciones diarias reflejan sabidur{IACUTE}a o necedad.',
        'icon': 'Icons.psychology_rounded',
        'color': '0xFF1E88E5',
        'badge': f'Esp{IACUTE}ritu Sabio',
        'challenge': f'Esta semana, antes de reaccionar a cualquier situaci{OACUTE}n, det{EACUTE}nte 5 segundos y piensa: {QUEST_INV}Qu{EACUTE} har{IACUTE}a el sabio?',
        'selfEval': f'{QUEST_INV}En cu{AACUTE}l {AACUTE}rea de tu vida necesitas m{AACUTE}s sabidur{IACUTE}a: familia, trabajo, iglesia o amistades?',
    },
    {
        'title': f'Temor de Jehov{AACUTE}',
        'subtitle': f'Debate interactivo',
        'verse': 'Proverbios 1:7',
        'objective': f'Comprende y aplica el temor de Jehov{AACUTE} como fundamento de la vida cristiana.',
        'icon': 'Icons.church_rounded',
        'color': '0xFFFFD54F',
        'badge': f'Reverente',
        'challenge': f'Cada ma{NTILDE}ana de esta semana, ora diciendo: Se{NTILDE}or, ay{UACUTE}dame a vivir con reverencia hoy.',
        'selfEval': f'{QUEST_INV}Temes a Dios por amor o por miedo al castigo?',
    },
    {
        'title': f'Comunicaci{OACUTE}n Sabia',
        'subtitle': 'Taller pr' + AACUTE + 'ctico',
        'verse': 'Proverbios 15',
        'objective': f'Transforma tu manera de comunicarte seg{UACUTE}n los principios de Proverbios 15.',
        'icon': 'Icons.record_voice_over_rounded',
        'color': '0xFF43A047',
        'badge': f'Comunicador del Rey',
        'challenge': f'Practica la regla 5-5: Antes de hablar, espera 5 segundos. Despu{EACUTE}s, piensa 5 segundos si tus palabras edifican.',
        'selfEval': f'{QUEST_INV}Cu{AACUTE}ntas veces esta semana tus palabras causaron da{NTILDE}o en lugar de bendici{OACUTE}n?',
    },
    {
        'title': f'L{IACUTE}der B{IACUTE}blico',
        'subtitle': f'An{AACUTE}lisis de liderazgo',
        'verse': 'Proverbios 29',
        'objective': f'Identifica qu{EACUTE} tipo de l{IACUTE}der eres seg{UACUTE}n Proverbios 29.',
        'icon': 'Icons.groups_rounded',
        'color': '0xFF7B1FA2',
        'badge': f'L{IACUTE}der Justo',
        'challenge': f'Si lideras alg{UACUTE}n {AACUTE}rea, esta semana pide retroalimentaci{OACUTE}n honesta a una persona de confianza.',
        'selfEval': f'{QUEST_INV}Tu liderazgo hace que la gente se alegre o que gima? (Pr. 29:2)',
    },
]
for m in activities_meta:
    w("    {")
    w(f"      'title': '{m['title']}',")
    w(f"      'subtitle': '{m['subtitle']}',")
    w(f"      'verse': '{m['verse']}',")
    w(f"      'objective': '{m['objective']}',")
    w(f"      'icon': {m['icon']},")
    w(f"      'color': Color({m['color']}),")
    w(f"      'badge': '{m['badge']}',")
    w(f"      'challenge': \"{m['challenge']}\",")
    w(f"      'selfEval': \"{m['selfEval']}\",")
    w("    },")
w("  ];")
w()

# Get questions for current activity
w("  List<Map<String, dynamic>> _getQuestions() {")
w("    switch (_currentDynamic) {")
w("      case 1: return _sabioNecioQuestions;")
w("      case 2: return _temorJehovaQuestions;")
w("      case 3: return _comunicacionQuestions;")
w("      case 4: return _liderazgoQuestions;")
w("      default: return [];")
w("    }")
w("  }")
w()

# ---------------------------------------------------------------
# INIT / DISPOSE
# ---------------------------------------------------------------
w("  @override")
w("  void initState() {")
w("    super.initState();")
w("    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);")
w("    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));")
w("    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);")
w("    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));")
w("    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);")
w("    _floatAnim = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));")
w("  }")
w()
w("  @override")
w("  void dispose() {")
w("    _glowCtrl.dispose();")
w("    _pulseCtrl.dispose();")
w("    _floatCtrl.dispose();")
w("    super.dispose();")
w("  }")
w()

# ---------------------------------------------------------------
# RESET
# ---------------------------------------------------------------
w("  void _startActivity(int index) {")
w("    setState(() {")
w("      _currentDynamic = index;")
w("      _currentStep = 0;")
w("      _totalPoints = 0;")
w("      _answeredCount = 0;")
w("      _selectedOption = null;")
w("      _showFeedback = false;")
w("      _activityComplete = false;")
w("    });")
w("  }")
w()
w("  void _selectOption(int idx) {")
w("    if (_showFeedback) return;")
w("    setState(() { _selectedOption = idx; });")
w("  }")
w()
w("  void _confirmAnswer() {")
w("    if (_selectedOption == null) return;")
w("    final qs = _getQuestions();")
w("    final correct = qs[_currentStep]['correct'] as int;")
w("    setState(() {")
w("      _showFeedback = true;")
w("      _answeredCount++;")
w("      if (_selectedOption == correct) { _totalPoints += 20; }")
w("    });")
w("  }")
w()
w("  void _nextStep() {")
w("    final qs = _getQuestions();")
w("    if (_currentStep < qs.length - 1) {")
w("      setState(() {")
w("        _currentStep++;")
w("        _selectedOption = null;")
w("        _showFeedback = false;")
w("      });")
w("    } else {")
w("      // Activity done")
w("      final meta = _activityMeta[_currentDynamic - 1];")
w("      final badge = meta['badge'] as String;")
w("      setState(() {")
w("        _activityComplete = true;")
w("        if (_totalPoints >= 60) { _earnedBadges.add(badge); }")
w("      });")
w("    }")
w("  }")
w()

# ---------------------------------------------------------------
# BUILD
# ---------------------------------------------------------------
w("  @override")
w("  Widget build(BuildContext context) {")
w("    return Container(")
w("      decoration: const BoxDecoration(")
w("        gradient: LinearGradient(")
w("          begin: Alignment.topLeft, end: Alignment.bottomRight,")
w("          colors: [Color(0xFF1A0A2E), Color(0xFF16213E), Color(0xFF0F3460)],")
w("        ),")
w("      ),")
w("      child: AnimatedSwitcher(")
w("        duration: const Duration(milliseconds: 500),")
w("        child: _currentDynamic == 0")
w("          ? _buildMenu()")
w("          : _activityComplete ? _buildResults() : _buildActivity(),")
w("      ),")
w("    );")
w("  }")
w()

# ---------------------------------------------------------------
# MENU PAGE
# ---------------------------------------------------------------
w("  Widget _buildMenu() {")
w("    return SingleChildScrollView(")
w("      key: const ValueKey('menu'),")
w("      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),")
w("      child: Column(children: [")
# Header with animated icon
w("        AnimatedBuilder(")
w("          animation: _floatAnim,")
w("          builder: (_, __) => Transform.translate(")
w("            offset: Offset(0, _floatAnim.value),")
w("            child: Container(")
w("              padding: const EdgeInsets.all(30),")
w("              decoration: BoxDecoration(")
w("                shape: BoxShape.circle,")
w("                gradient: RadialGradient(colors: [")
w("                  const Color(0xFFFFD54F).withValues(alpha: 0.3),")
w("                  Colors.transparent,")
w("                ]),")
w("              ),")
w("              child: const Icon(Icons.extension_rounded, size: 80, color: Color(0xFFFFD54F)),")
w("            ),")
w("          ),")
w("        ),")
w("        const SizedBox(height: 20),")
w(f"        Text('DIN{E(193)}MICAS INTERACTIVAS', style: GoogleFonts.cinzel(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFFFFD54F), letterSpacing: 4)),")
w("        const SizedBox(height: 8),")
w(f"        Text('Libro de Proverbios {EMDASH} Actividades de 5 minutos', style: GoogleFonts.lato(fontSize: 24, color: Colors.white54)),")
w("        const SizedBox(height: 12),")
# Points & badges bar
w("        Container(")
w("          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),")
w("          decoration: BoxDecoration(")
w("            color: Colors.white.withValues(alpha: 0.06),")
w("            borderRadius: BorderRadius.circular(20),")
w("            border: Border.all(color: Colors.white12),")
w("          ),")
w("          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [")
w("            const Icon(Icons.stars_rounded, color: Color(0xFFFFD54F), size: 28),")
w("            const SizedBox(width: 10),")
w(f"            Text('Insignias: ${{_earnedBadges.length}} / 4', style: GoogleFonts.orbitron(fontSize: 20, color: Colors.white70)),")
w("          ]),")
w("        ),")
w("        const SizedBox(height: 36),")
# 4 activity cards
w("        Wrap(spacing: 24, runSpacing: 24, alignment: WrapAlignment.center, children: [")
w("          ...List.generate(4, (i) => _buildActivityCard(i)),")
w("        ]),")
w("      ]),")
w("    );")
w("  }")
w()

# Activity card
w("  Widget _buildActivityCard(int index) {")
w("    final meta = _activityMeta[index];")
w("    final color = meta['color'] as Color;")
w("    final icon = meta['icon'] as IconData;")
w("    final badge = meta['badge'] as String;")
w("    final earned = _earnedBadges.contains(badge);")
w()
w("    return AnimatedBuilder(")
w("      animation: _pulseAnim,")
w("      builder: (_, __) => Transform.scale(")
w("        scale: _pulseAnim.value,")
w("        child: GestureDetector(")
w("          onTap: () => _startActivity(index + 1),")
w("          child: Container(")
w("            width: 400, height: 260,")
w("            padding: const EdgeInsets.all(28),")
w("            decoration: BoxDecoration(")
w("              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,")
w("                colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)]),")
w("              borderRadius: BorderRadius.circular(28),")
w("              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),")
w("              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 25, spreadRadius: 3)],")
w("            ),")
w("            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w("              Row(children: [")
w("                Container(")
w("                  padding: const EdgeInsets.all(14),")
w("                  decoration: BoxDecoration(")
w("                    shape: BoxShape.circle,")
w("                    color: color.withValues(alpha: 0.25),")
w("                    border: Border.all(color: color, width: 2),")
w("                  ),")
w("                  child: Icon(icon, color: color, size: 32),")
w("                ),")
w("                const Spacer(),")
w("                if (earned) Container(")
w("                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),")
w("                  decoration: BoxDecoration(")
w("                    color: const Color(0xFFFFD54F).withValues(alpha: 0.2),")
w("                    borderRadius: BorderRadius.circular(20),")
w("                    border: Border.all(color: const Color(0xFFFFD54F)),")
w("                  ),")
w("                  child: Row(mainAxisSize: MainAxisSize.min, children: [")
w("                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), size: 20),")
w("                    const SizedBox(width: 6),")
w("                    Text(badge, style: GoogleFonts.lato(fontSize: 14, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),")
w("                  ]),")
w("                ),")
w("              ]),")
w("              const SizedBox(height: 16),")
w("              Text(meta['title'] as String, style: GoogleFonts.cinzel(fontSize: 28, color: color, fontWeight: FontWeight.w900)),")
w("              const SizedBox(height: 6),")
w("              Text(meta['subtitle'] as String, style: GoogleFonts.lato(fontSize: 20, color: Colors.white54)),")
w("              const Spacer(),")
w("              Row(children: [")
w("                Icon(Icons.menu_book_rounded, color: color.withValues(alpha: 0.6), size: 20),")
w("                const SizedBox(width: 8),")
w("                Text(meta['verse'] as String, style: GoogleFonts.orbitron(fontSize: 16, color: color.withValues(alpha: 0.7))),")
w("                const Spacer(),")
w("                Container(")
w("                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),")
w("                  decoration: BoxDecoration(")
w("                    color: color.withValues(alpha: 0.2),")
w("                    borderRadius: BorderRadius.circular(20),")
w("                  ),")
w(f"                  child: Text('INICIAR', style: GoogleFonts.lato(fontSize: 18, color: color, fontWeight: FontWeight.bold)),")
w("                ),")
w("              ]),")
w("            ]),")
w("          ),")
w("        ),")
w("      ),")
w("    );")
w("  }")
w()

# ---------------------------------------------------------------
# ACTIVITY VIEW
# ---------------------------------------------------------------
w("  Widget _buildActivity() {")
w("    final meta = _activityMeta[_currentDynamic - 1];")
w("    final color = meta['color'] as Color;")
w("    final qs = _getQuestions();")
w("    final q = qs[_currentStep];")
w()
w("    return Column(")
w("      key: ValueKey('act_${_currentDynamic}_$_currentStep'),")
w("      children: [")
# Top bar
w("        Container(")
w("          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),")
w("          child: Row(children: [")
w("            IconButton(")
w("              onPressed: () => setState(() { _currentDynamic = 0; }),")
w("              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 30),")
w("            ),")
w("            const SizedBox(width: 12),")
w("            Text(meta['title'] as String, style: GoogleFonts.cinzel(fontSize: 28, color: color, fontWeight: FontWeight.bold)),")
w("            const Spacer(),")
# Progress
w("            ...List.generate(qs.length, (i) => Container(")
w("              width: i == _currentStep ? 36 : 12, height: 12,")
w("              margin: const EdgeInsets.symmetric(horizontal: 3),")
w("              decoration: BoxDecoration(")
w("                borderRadius: BorderRadius.circular(6),")
w("                color: i < _currentStep ? const Color(0xFFFFD54F)")
w("                  : i == _currentStep ? color : Colors.white24,")
w("              ),")
w("            )),")
w("            const SizedBox(width: 16),")
# Points
w("            Container(")
w("              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),")
w("              decoration: BoxDecoration(")
w("                color: const Color(0xFFFFD54F).withValues(alpha: 0.15),")
w("                borderRadius: BorderRadius.circular(20),")
w("                border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4)),")
w("              ),")
w("              child: Row(mainAxisSize: MainAxisSize.min, children: [")
w("                const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 22),")
w("                const SizedBox(width: 6),")
w("                Text('$_totalPoints pts', style: GoogleFonts.orbitron(fontSize: 18, color: Color(0xFFFFD54F))),")
w("              ]),")
w("            ),")
w("          ]),")
w("        ),")
# Content
w("        Expanded(")
w("          child: SingleChildScrollView(")
w("            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),")
w("            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
# Verse badge
w("              Center(child: Container(")
w("                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),")
w("                decoration: BoxDecoration(")
w("                  color: color.withValues(alpha: 0.15),")
w("                  borderRadius: BorderRadius.circular(20),")
w("                  border: Border.all(color: color.withValues(alpha: 0.4)),")
w("                ),")
w("                child: Row(mainAxisSize: MainAxisSize.min, children: [")
w("                  Icon(Icons.menu_book_rounded, color: color, size: 22),")
w("                  const SizedBox(width: 10),")
w("                  Text(q['verse'] as String, style: GoogleFonts.orbitron(fontSize: 18, color: color)),")
w("                ]),")
w("              )),")
w("              const SizedBox(height: 24),")
# Scenario
w("              Container(")
w("                width: double.infinity,")
w("                padding: const EdgeInsets.all(28),")
w("                decoration: BoxDecoration(")
w("                  gradient: LinearGradient(colors: [")
w("                    color.withValues(alpha: 0.15),")
w("                    color.withValues(alpha: 0.05),")
w("                  ]),")
w("                  borderRadius: BorderRadius.circular(24),")
w("                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2),")
w("                ),")
w("                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w("                  Icon(Icons.scenario_rounded, color: color, size: 36),")
w("                  const SizedBox(width: 20),")
w("                  Expanded(child: Text(")
w("                    q['scenario'] as String,")
w("                    style: GoogleFonts.lato(fontSize: 26, color: Colors.white, height: 1.5, fontWeight: FontWeight.w500),")
w("                  )),")
w("                ]),")
w("              ),")
w("              const SizedBox(height: 24),")
# Options
w("              ...List.generate((q['options'] as List).length, (i) {")
w("                final opt = (q['options'] as List)[i] as String;")
w("                final correct = q['correct'] as int;")
w("                final isSelected = _selectedOption == i;")
w("                final isCorrect = i == correct;")
w()
w("                Color borderC = Colors.white24;")
w("                Color bgC = Colors.white.withValues(alpha: 0.04);")
w("                IconData? trailingIcon;")
w()
w("                if (_showFeedback) {")
w("                  if (isCorrect) { borderC = const Color(0xFF43A047); bgC = const Color(0xFF43A047).withValues(alpha: 0.15); trailingIcon = Icons.check_circle_rounded; }")
w("                  else if (isSelected) { borderC = const Color(0xFFE53935); bgC = const Color(0xFFE53935).withValues(alpha: 0.1); trailingIcon = Icons.cancel_rounded; }")
w("                } else if (isSelected) {")
w("                  borderC = color; bgC = color.withValues(alpha: 0.1);")
w("                }")
w()
w("                return Padding(")
w("                  padding: const EdgeInsets.only(bottom: 12),")
w("                  child: GestureDetector(")
w("                    onTap: () => _selectOption(i),")
w("                    child: AnimatedContainer(")
w("                      duration: const Duration(milliseconds: 300),")
w("                      width: double.infinity,")
w("                      padding: const EdgeInsets.all(20),")
w("                      decoration: BoxDecoration(")
w("                        color: bgC,")
w("                        borderRadius: BorderRadius.circular(18),")
w("                        border: Border.all(color: borderC, width: 2),")
w("                      ),")
w("                      child: Row(children: [")
w("                        Container(")
w("                          width: 40, height: 40,")
w("                          decoration: BoxDecoration(")
w("                            shape: BoxShape.circle,")
w("                            color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),")
w("                            border: Border.all(color: isSelected ? color : Colors.white24),")
w("                          ),")
w("                          child: Center(child: Text(String.fromCharCode(65 + i), style: GoogleFonts.orbitron(fontSize: 18, color: isSelected ? color : Colors.white54))),")
w("                        ),")
w("                        const SizedBox(width: 16),")
w("                        Expanded(child: Text(opt, style: GoogleFonts.lato(fontSize: 22, color: Colors.white, height: 1.4))),")
w("                        if (trailingIcon != null) Icon(trailingIcon!, color: isCorrect ? const Color(0xFF43A047) : const Color(0xFFE53935), size: 30),")
w("                      ]),")
w("                    ),")
w("                  ),")
w("                );")
w("              }),")
# Feedback
w("              if (_showFeedback) Container(")
w("                width: double.infinity,")
w("                margin: const EdgeInsets.only(top: 8),")
w("                padding: const EdgeInsets.all(24),")
w("                decoration: BoxDecoration(")
w("                  gradient: LinearGradient(colors: [")
w("                    const Color(0xFF1B5E20).withValues(alpha: 0.3),")
w("                    const Color(0xFF2E7D32).withValues(alpha: 0.15),")
w("                  ]),")
w("                  borderRadius: BorderRadius.circular(20),")
w("                  border: Border.all(color: const Color(0xFF43A047).withValues(alpha: 0.5), width: 2),")
w("                ),")
w("                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w(f"                  Text('Retroalimentaci{OACUTE}n B{IACUTE}blica', style: GoogleFonts.cinzel(fontSize: 22, color: Color(0xFF43A047), fontWeight: FontWeight.bold)),")
w("                  const SizedBox(height: 10),")
w("                  Text(q['feedback'] as String, style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5)),")
w("                ]),")
w("              ),")
w("            ]),")
w("          ),")
w("        ),")
# Bottom bar
w("        Container(")
w("          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),")
w("          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [")
w("            Text('${_currentStep + 1} / ${qs.length}', style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white38)),")
w("            const Spacer(),")
w("            if (!_showFeedback)")
w("              ElevatedButton.icon(")
w("                onPressed: _selectedOption != null ? _confirmAnswer : null,")
w("                icon: const Icon(Icons.check_rounded, size: 26),")
w(f"                label: Text('CONFIRMAR', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),")
w("                style: ElevatedButton.styleFrom(")
w("                  backgroundColor: color,")
w("                  foregroundColor: Colors.white,")
w("                  disabledBackgroundColor: Colors.white12,")
w("                  disabledForegroundColor: Colors.white30,")
w("                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),")
w("                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),")
w("                ),")
w("              ),")
w("            if (_showFeedback)")
w("              ElevatedButton.icon(")
w("                onPressed: _nextStep,")
w("                icon: const Icon(Icons.arrow_forward_rounded, size: 26),")
w(f"                label: Text(_currentStep < qs.length - 1 ? 'SIGUIENTE' : 'VER RESULTADOS', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),")
w("                style: ElevatedButton.styleFrom(")
w("                  backgroundColor: const Color(0xFFFFD54F),")
w("                  foregroundColor: const Color(0xFF1A0A2E),")
w("                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),")
w("                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),")
w("                ),")
w("              ),")
w("          ]),")
w("        ),")
w("      ],")
w("    );")
w("  }")
w()

# ---------------------------------------------------------------
# RESULTS VIEW
# ---------------------------------------------------------------
w("  Widget _buildResults() {")
w("    final meta = _activityMeta[_currentDynamic - 1];")
w("    final color = meta['color'] as Color;")
w("    final badge = meta['badge'] as String;")
w("    final earned = _totalPoints >= 60;")
w("    final percentage = (_totalPoints / 100 * 100).round();")
w()
w("    return SingleChildScrollView(")
w("      key: const ValueKey('results'),")
w("      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),")
w("      child: Column(children: [")
# Icon
w("        AnimatedBuilder(")
w("          animation: _glowAnim,")
w("          builder: (_, __) => Container(")
w("            padding: const EdgeInsets.all(30),")
w("            decoration: BoxDecoration(")
w("              shape: BoxShape.circle,")
w("              gradient: RadialGradient(colors: [")
w("                (earned ? const Color(0xFFFFD54F) : const Color(0xFFE53935)).withValues(alpha: _glowAnim.value * 0.4),")
w("                Colors.transparent,")
w("              ]),")
w("              boxShadow: [BoxShadow(")
w("                color: (earned ? const Color(0xFFFFD54F) : const Color(0xFFE53935)).withValues(alpha: _glowAnim.value * 0.3),")
w("                blurRadius: 40, spreadRadius: 10)],")
w("            ),")
w("            child: Icon(")
w("              earned ? Icons.emoji_events_rounded : Icons.school_rounded,")
w("              size: 90, color: earned ? const Color(0xFFFFD54F) : Colors.white54),")
w("          ),")
w("        ),")
w("        const SizedBox(height: 24),")
# Title
w(f"        Text(earned ? '{EXCL_INV}EXCELENTE!' : 'SIGUE CRECIENDO', style: GoogleFonts.cinzel(fontSize: 48, fontWeight: FontWeight.w900, color: earned ? Color(0xFFFFD54F) : Colors.white54, letterSpacing: 4)),")
w("        const SizedBox(height: 16),")
# Score
w("        Container(")
w("          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),")
w("          decoration: BoxDecoration(")
w("            color: Colors.white.withValues(alpha: 0.06),")
w("            borderRadius: BorderRadius.circular(24),")
w("            border: Border.all(color: color.withValues(alpha: 0.4)),")
w("          ),")
w("          child: Row(mainAxisSize: MainAxisSize.min, children: [")
w("            const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 36),")
w("            const SizedBox(width: 16),")
w("            Text('$_totalPoints / 100 puntos', style: GoogleFonts.orbitron(fontSize: 32, color: Color(0xFFFFD54F))),")
w("          ]),")
w("        ),")
w("        const SizedBox(height: 24),")
# Badge earned
w("        if (earned) Container(")
w("          padding: const EdgeInsets.all(20),")
w("          decoration: BoxDecoration(")
w("            gradient: LinearGradient(colors: [")
w("              const Color(0xFFFFD54F).withValues(alpha: 0.2),")
w("              const Color(0xFFFF8F00).withValues(alpha: 0.1),")
w("            ]),")
w("            borderRadius: BorderRadius.circular(20),")
w("            border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5), width: 2),")
w("          ),")
w("          child: Row(mainAxisSize: MainAxisSize.min, children: [")
w("            const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD54F), size: 36),")
w("            const SizedBox(width: 16),")
w(f"            Text('Insignia: $badge', style: GoogleFonts.cinzel(fontSize: 26, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),")
w("          ]),")
w("        ),")
w("        const SizedBox(height: 28),")
# Challenge
w("        Container(")
w("          width: double.infinity,")
w("          padding: const EdgeInsets.all(28),")
w("          decoration: BoxDecoration(")
w("            gradient: LinearGradient(colors: [")
w("              color.withValues(alpha: 0.2),")
w("              color.withValues(alpha: 0.08),")
w("            ]),")
w("            borderRadius: BorderRadius.circular(24),")
w("            border: Border.all(color: color.withValues(alpha: 0.4), width: 2),")
w("          ),")
w("          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w("            Row(children: [")
w("              Icon(Icons.flag_rounded, color: color, size: 30),")
w("              const SizedBox(width: 12),")
w(f"              Text('RETO SEMANAL', style: GoogleFonts.cinzel(fontSize: 24, color: color, fontWeight: FontWeight.bold)),")
w("            ]),")
w("            const SizedBox(height: 12),")
w("            Text(meta['challenge'] as String, style: GoogleFonts.lato(fontSize: 22, color: Colors.white, height: 1.5)),")
w("          ]),")
w("        ),")
w("        const SizedBox(height: 20),")
# Self-evaluation
w("        Container(")
w("          width: double.infinity,")
w("          padding: const EdgeInsets.all(28),")
w("          decoration: BoxDecoration(")
w("            color: Colors.white.withValues(alpha: 0.05),")
w("            borderRadius: BorderRadius.circular(24),")
w("            border: Border.all(color: Colors.white24),")
w("          ),")
w("          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w("            Row(children: [")
w("              const Icon(Icons.self_improvement_rounded, color: Colors.white70, size: 30),")
w("              const SizedBox(width: 12),")
w(f"              Text('AUTOEVALUACI{E(211)}N', style: GoogleFonts.cinzel(fontSize: 24, color: Colors.white70, fontWeight: FontWeight.bold)),")
w("            ]),")
w("            const SizedBox(height: 12),")
w("            Text(meta['selfEval'] as String, style: GoogleFonts.playfairDisplay(fontSize: 24, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5)),")
w("          ]),")
w("        ),")
w("        const SizedBox(height: 30),")
# Back button
w("        ElevatedButton.icon(")
w("          onPressed: () => setState(() { _currentDynamic = 0; }),")
w("          icon: const Icon(Icons.arrow_back_rounded, size: 26),")
w(f"          label: Text('VOLVER AL MEN{E(218)}', style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold)),")
w("          style: ElevatedButton.styleFrom(")
w("            backgroundColor: Colors.white.withValues(alpha: 0.1),")
w("            foregroundColor: Colors.white70,")
w("            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),")
w("            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),")
w("          ),")
w("        ),")
w("      ]),")
w("    );")
w("  }")

# Close class
w("}")

content = '\n'.join(L) + '\n'
os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, 'w', encoding='utf-8') as f:
    f.write(content)
print(f'Generated: {output_path}')
print(f'Lines: {len(L)}')
