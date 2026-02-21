import os

# Character helpers for proper UTF-8
a_ = chr(0xE1)  # a with accent
e_ = chr(0xE9)  # e with accent
i_ = chr(0xED)  # i with accent
o_ = chr(0xF3)  # o with accent
u_ = chr(0xFA)  # u with accent
n_ = chr(0xF1)  # n tilde
A_ = chr(0xC1)  # A with accent
E_ = chr(0xC9)  # E with accent
I_ = chr(0xCD)  # I with accent
O_ = chr(0xD3)  # O with accent
U_ = chr(0xDA)  # U with accent
N_ = chr(0xD1)  # N tilde (uppercase)
qm = chr(0xBF)  # inverted question mark
ex = chr(0xA1)  # inverted exclamation

content = f"""import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =============================================================================
/// L{I_}NEA DE TIEMPO HIST{O_}RICA DE JOB - ANIMACI{O_}N DOCUMENTAL
/// Muestra cu{a_}ndo existi{o_} Job en relaci{o_}n con la historia b{i_}blica
/// Estilo: Acad{e_}mico, cinematogr{a_}fico, optimizado para proyecci{o_}n
/// Instituto B{i_}blico Elim Internacional
/// =============================================================================
class JobHistoricalTimeline extends StatefulWidget {{
  final bool isProjectorMode;
  final bool autoPlay;
  final bool isFullScreen;

  const JobHistoricalTimeline({{
    Key? key,
    this.isProjectorMode = false,
    this.autoPlay = true,
    this.isFullScreen = false,
  }}) : super(key: key);

  /// Abre el widget en pantalla completa
  static void openFullScreen(BuildContext context) {{
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (ctx, anim, anim2) {{
          return const Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: JobHistoricalTimeline(
                isProjectorMode: true,
                autoPlay: true,
                isFullScreen: true,
              ),
            ),
          );
        }},
        transitionsBuilder: (ctx, anim, anim2, child) {{
          return FadeTransition(opacity: anim, child: child);
        }},
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }}

  @override
  State<JobHistoricalTimeline> createState() => _JobHistoricalTimelineState();
}}

class _JobHistoricalTimelineState extends State<JobHistoricalTimeline>
    with TickerProviderStateMixin {{
  // Controladores de animaci{o_}n
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  // Animaciones
  late Animation<double> _lineProgress;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  // Estados de los hitos
  final List<bool> _milestonesRevealed = List.filled(6, false);

  // Datos de la l{i_}nea de tiempo con im{a_}genes b{i_}blicas
  final List<_TimelineMilestone> _milestones = [
    _TimelineMilestone(
      year: '~2100 a.C.',
      title: 'JOB',
      subtitle: 'Vida probable',
      description: 'Per{i_}odo patriarcal temprano',
      isMainFocus: true,
      color: const Color(0xFFD4AF37),
      icon: Icons.person,
      imageUrl: 'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=400',
    ),
    _TimelineMilestone(
      year: '~2000 a.C.',
      title: 'ABRAHAM',
      subtitle: 'Padre de la fe',
      description: 'Sale de Ur de los Caldeos',
      isMainFocus: false,
      color: const Color(0xFF6BA3D6),
      icon: Icons.directions_walk,
      imageUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
    ),
    _TimelineMilestone(
      year: '~1900 a.C.',
      title: 'ISAAC',
      subtitle: 'Hijo de la promesa',
      description: 'Nacimiento y vida',
      isMainFocus: false,
      color: const Color(0xFF6BA3D6),
      icon: Icons.child_care,
      imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400',
    ),
    _TimelineMilestone(
      year: '~1800 a.C.',
      title: 'JACOB',
      subtitle: 'Israel',
      description: '12 tribus originadas',
      isMainFocus: false,
      color: const Color(0xFF6BA3D6),
      icon: Icons.people,
      imageUrl: 'https://images.unsplash.com/photo-1532074534361-bb09b6cf6e11?w=400',
    ),
    _TimelineMilestone(
      year: '~1500 a.C.',
      title: 'MOIS{E_}S',
      subtitle: 'La Ley',
      description: '{E_}xodo y Sina{i_}',
      isMainFocus: false,
      color: const Color(0xFF7CB342),
      icon: Icons.menu_book,
      note: 'JOB antes de la Ley',
      imageUrl: 'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=400',
    ),
    _TimelineMilestone(
      year: '~1400 a.C.',
      title: 'JOSU{E_}',
      subtitle: 'Conquista',
      description: 'Entrada a Cana{a_}n',
      isMainFocus: false,
      color: const Color(0xFF7CB342),
      icon: Icons.flag,
      imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=400',
    ),
  ];

  @override
  void initState() {{
    super.initState();

    // Controlador principal de la l{i_}nea de tiempo
    _mainController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _lineProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    // Controlador de pulso para Job
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Controlador de brillo
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Listener para revelar hitos progresivamente
    _lineProgress.addListener(_updateMilestones);

    // Auto-play
    if (widget.autoPlay) {{
      Future.delayed(const Duration(milliseconds: 500), () {{
        if (mounted) _mainController.forward();
      }});
    }}
  }}

  void _updateMilestones() {{
    final progress = _lineProgress.value;
    final totalMilestones = _milestones.length;
    for (int i = 0; i < totalMilestones; i++) {{
      final threshold = (i + 1) / totalMilestones;
      if (progress >= threshold - 0.1 && !_milestonesRevealed[i]) {{
        setState(() {{
          _milestonesRevealed[i] = true;
        }});
      }}
    }}
  }}

  @override
  void dispose() {{
    _mainController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }}

  // ==========================================================================
  // TAMA{N_}OS DE FUENTE GRANDES PARA PROYECCI{O_}N
  // ==========================================================================
  double get _titleSize => widget.isProjectorMode ? 52.0 : 36.0;
  double get _subtitleSize => widget.isProjectorMode ? 32.0 : 22.0;
  double get _yearSize => widget.isProjectorMode ? 28.0 : 22.0;
  double get _nameSize => widget.isProjectorMode ? 30.0 : 24.0;
  double get _descSize => widget.isProjectorMode ? 22.0 : 18.0;
  double get _eraSize => widget.isProjectorMode ? 22.0 : 18.0;
  double get _keyTitleSize => widget.isProjectorMode ? 24.0 : 18.0;
  double get _keySubSize => widget.isProjectorMode ? 20.0 : 15.0;
  double get _footerSize => widget.isProjectorMode ? 22.0 : 16.0;
  double get _iconSize => widget.isProjectorMode ? 48.0 : 36.0;
  double get _circleSize => widget.isProjectorMode ? 110.0 : 85.0;
  double get _smallCircle => widget.isProjectorMode ? 80.0 : 62.0;

  @override
  Widget build(BuildContext context) {{
    return Container(
      decoration: BoxDecoration(
        borderRadius: widget.isFullScreen ? null : BorderRadius.circular(16),
        border: widget.isFullScreen
            ? null
            : Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 2,
              ),
        boxShadow: widget.isFullScreen
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.isFullScreen ? 0 : 14),
        child: Stack(
          children: [
            // Imagen de fondo b{i_}blica
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1533669955142-6a73332af4db?w=3840',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.82),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0D0A07),
                        Color(0xFF1A1510),
                        Color(0xFF0D0A07),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Contenido principal centrado
            Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildTimelineContent()),
                _buildKeyPoints(),
                _buildFooter(),
              ],
            ),
          ],
        ),
      ),
    );
  }}

  // ==========================================================================
  // HEADER CON BOT{O_}N DE PANTALLA COMPLETA
  // ==========================================================================
  Widget _buildHeader() {{
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.isProjectorMode ? 28 : 20,
        horizontal: 30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2318).withOpacity(0.95),
            const Color(0xFF1A1510).withOpacity(0.9),
          ],
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
      ),
      child: Row(
        children: [
          // Bot{o_}n pantalla completa (izquierda)
          if (!widget.isFullScreen)
            _buildFullScreenButton()
          else
            _buildCloseButton(),

          // T{i_}tulo centrado
          Expanded(
            child: Column(
              children: [
                Text(
                  'L{I_}NEA DE TIEMPO HIST{O_}RICA',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: _titleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '{qm}CU{A_}NDO EXISTI{O_} JOB?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: _subtitleSize,
                    color: const Color(0xFFBFA67A),
                    letterSpacing: 4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Bot{o_}n pantalla completa (derecha)
          if (!widget.isFullScreen)
            _buildFullScreenButton()
          else
            _buildCloseButton(),
        ],
      ),
    );
  }}

  Widget _buildFullScreenButton() {{
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => JobHistoricalTimeline.openFullScreen(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFB8942E)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fullscreen, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                'PANTALLA\\nCOMPLETA',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}

  Widget _buildCloseButton() {{
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fullscreen_exit, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Text(
                'SALIR',
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}

  // ==========================================================================
  // CONTENIDO DE LA L{I_}NEA DE TIEMPO
  // ==========================================================================
  Widget _buildTimelineContent() {{
    return Padding(
      padding: EdgeInsets.all(widget.isProjectorMode ? 40 : 28),
      child: LayoutBuilder(
        builder: (context, constraints) {{
          return Stack(
            children: [
              // L{i_}nea de tiempo base
              _buildTimelineBase(constraints),
              // L{i_}nea de progreso animada
              AnimatedBuilder(
                animation: _lineProgress,
                builder: (context, child) {{
                  return _buildProgressLine(constraints, _lineProgress.value);
                }},
              ),
              // Hitos
              ..._buildMilestoneWidgets(constraints),
              // Etiquetas de eras
              _buildEraLabels(constraints),
            ],
          );
        }},
      ),
    );
  }}

  Widget _buildTimelineBase(BoxConstraints constraints) {{
    return Positioned(
      left: 50,
      right: 50,
      top: constraints.maxHeight * 0.4,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFF3D3425),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }}

  Widget _buildProgressLine(BoxConstraints constraints, double progress) {{
    final lineWidth = (constraints.maxWidth - 100) * progress;
    return Positioned(
      left: 50,
      top: constraints.maxHeight * 0.4,
      child: Container(
        height: 10,
        width: lineWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD4AF37),
              const Color(0xFFD4AF37).withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.5),
              blurRadius: 14,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );
  }}

  List<Widget> _buildMilestoneWidgets(BoxConstraints constraints) {{
    final widgets = <Widget>[];
    final totalWidth = constraints.maxWidth - 100;
    const startX = 50.0;
    final itemWidth = widget.isProjectorMode ? 160.0 : 140.0;

    for (int i = 0; i < _milestones.length; i++) {{
      final milestone = _milestones[i];
      final x = startX + (totalWidth * (i / (_milestones.length - 1)));
      final isRevealed = _milestonesRevealed[i];

      widgets.add(
        Positioned(
          left: x - itemWidth / 2,
          top: constraints.maxHeight * 0.05,
          width: itemWidth,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: isRevealed ? 1.0 : 0.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 500),
              scale: isRevealed ? 1.0 : 0.5,
              child: milestone.isMainFocus
                  ? _buildMainMilestone(milestone, constraints)
                  : _buildMilestone(milestone),
            ),
          ),
        ),
      );
    }}
    return widgets;
  }}

  // ==========================================================================
  // HITO PRINCIPAL (JOB) CON IMAGEN B{I_}BLICA
  // ==========================================================================
  Widget _buildMainMilestone(
      _TimelineMilestone milestone, BoxConstraints constraints) {{
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {{
        return AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {{
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A{n_}o
                Text(
                  milestone.year,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono(
                    fontSize: _yearSize,
                    color: milestone.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // C{i_}rculo con imagen b{i_}blica (animado)
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: _circleSize,
                    height: _circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: milestone.color.withOpacity(_glowAnimation.value),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: milestone.color.withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 50,
                          spreadRadius: 18,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Imagen b{i_}blica de fondo
                          Image.network(
                            milestone.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: milestone.color,
                              child: Icon(milestone.icon, color: Colors.white, size: _iconSize),
                            ),
                          ),
                          // Overlay dorado
                          Container(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  milestone.color.withOpacity(0.3),
                                  milestone.color.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                          // {I_}cono centrado
                          Center(
                            child: Icon(
                              milestone.icon,
                              color: Colors.white,
                              size: _iconSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Nombre en tarjeta
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: milestone.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: milestone.color, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        milestone.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          fontSize: _nameSize,
                          fontWeight: FontWeight.bold,
                          color: milestone.color,
                        ),
                      ),
                      Text(
                        milestone.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: _descSize,
                          color: milestone.color.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Descripci{o_}n
                Text(
                  milestone.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: _descSize,
                    color: const Color(0xFFBFA67A),
                  ),
                ),
              ],
            );
          }},
        );
      }},
    );
  }}

  // ==========================================================================
  // HITOS SECUNDARIOS CON IM{A_}GENES B{I_}BLICAS
  // ==========================================================================
  Widget _buildMilestone(_TimelineMilestone milestone) {{
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A{n_}o
        Text(
          milestone.year,
          textAlign: TextAlign.center,
          style: GoogleFonts.robotoMono(
            fontSize: _yearSize - 4,
            color: const Color(0xFFBFA67A),
          ),
        ),
        const SizedBox(height: 8),

        // C{i_}rculo con imagen b{i_}blica
        Container(
          width: _smallCircle,
          height: _smallCircle,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: milestone.color.withOpacity(0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: milestone.color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen b{i_}blica
                Image.network(
                  milestone.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: milestone.color.withOpacity(0.2),
                    child: Icon(milestone.icon, color: milestone.color.withOpacity(0.8), size: _iconSize - 8),
                  ),
                ),
                // Overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
                // {I_}cono
                Center(
                  child: Icon(
                    milestone.icon,
                    color: milestone.color.withOpacity(0.9),
                    size: _iconSize - 8,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Nombre
        Text(
          milestone.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            fontSize: _nameSize - 4,
            color: milestone.color.withOpacity(0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          milestone.subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorantGaramond(
            fontSize: _descSize - 2,
            color: const Color(0xFFBFA67A).withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),

        // Nota especial
        if (milestone.note != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              milestone.note!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: _descSize - 2,
                color: Colors.red.shade300,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }}

  // ==========================================================================
  // ETIQUETAS DE ERAS (CENTRADAS)
  // ==========================================================================
  Widget _buildEraLabels(BoxConstraints constraints) {{
    return Positioned(
      left: 50,
      right: 50,
      bottom: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEraLabel('ERA PATRIARCAL', const Color(0xFFD4AF37), true),
          const SizedBox(width: 20),
          _buildEraLabel('PRE-LEY MOSAICA', const Color(0xFF6BA3D6), false),
          const SizedBox(width: 20),
          _buildEraLabel('ERA DE LA LEY', const Color(0xFF7CB342), false),
        ],
      ),
    );
  }}

  Widget _buildEraLabel(String text, Color color, bool isHighlighted) {{
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(isHighlighted ? 0.5 : 0.2),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          fontSize: _eraSize,
          color: color.withOpacity(isHighlighted ? 1.0 : 0.6),
          letterSpacing: 1,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }}

  // ==========================================================================
  // PUNTOS CLAVE (CENTRADOS)
  // ==========================================================================
  Widget _buildKeyPoints() {{
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isProjectorMode ? 40 : 28,
        vertical: widget.isProjectorMode ? 22 : 16,
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            _buildKeyPoint(Icons.schedule, 'Job ANTES de Israel', 'como naci{o_}n'),
            _buildKeyPoint(Icons.menu_book, 'Job ANTES de la Ley', 'mosaica'),
            _buildKeyPoint(Icons.people, 'Contempor{a_}neo o previo', 'a Abraham'),
            _buildKeyPoint(Icons.elderly, 'Longevidad coherente', 'con G{e_}nesis'),
          ],
        ),
      ),
    );
  }}

  Widget _buildKeyPoint(IconData icon, String title, String subtitle) {{
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2318).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFD4AF37).withOpacity(0.7),
            size: widget.isProjectorMode ? 32 : 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: _keyTitleSize,
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: _keySubSize,
                  color: const Color(0xFFBFA67A).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }}

  // ==========================================================================
  // FOOTER CENTRADO CON BOT{O_}N DE PANTALLA COMPLETA
  // ==========================================================================
  Widget _buildFooter() {{
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.isProjectorMode ? 18 : 14,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1510).withOpacity(0.9),
            const Color(0xFF2A2318).withOpacity(0.95),
          ],
        ),
        border: const Border(
          top: BorderSide(color: Color(0xFFD4AF37), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Informaci{o_}n centrada
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFBFA67A).withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Sacrificios familiares | Sin sacerdocio lev{i_}tico',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: _footerSize,
                    color: const Color(0xFFBFA67A).withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Botones centrados
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bot{o_}n Reproducir
                _buildFooterButton(
                  icon: Icons.replay,
                  label: 'REPRODUCIR',
                  onTap: () {{
                    setState(() {{
                      for (int i = 0; i < _milestonesRevealed.length; i++) {{
                        _milestonesRevealed[i] = false;
                      }}
                    }});
                    _mainController.reset();
                    _mainController.forward();
                  }},
                  color: const Color(0xFFD4AF37),
                ),

                const SizedBox(width: 20),

                // Bot{o_}n Pantalla Completa
                if (!widget.isFullScreen)
                  _buildFooterButton(
                    icon: Icons.fullscreen,
                    label: 'PANTALLA COMPLETA',
                    onTap: () => JobHistoricalTimeline.openFullScreen(context),
                    color: const Color(0xFF4CAF50),
                  ),

                if (widget.isFullScreen)
                  _buildFooterButton(
                    icon: Icons.fullscreen_exit,
                    label: 'SALIR',
                    onTap: () => Navigator.of(context).pop(),
                    color: Colors.red,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }}

  Widget _buildFooterButton({{
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }}) {{
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.cinzel(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}
}}

// =============================================================================
// MODELO DE DATOS PARA HITOS
// =============================================================================
class _TimelineMilestone {{
  final String year;
  final String title;
  final String subtitle;
  final String description;
  final bool isMainFocus;
  final Color color;
  final IconData icon;
  final String? note;
  final String imageUrl;

  const _TimelineMilestone({{
    required this.year,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isMainFocus,
    required this.color,
    required this.icon,
    this.note,
    required this.imageUrl,
  }});
}}
"""

filepath = os.path.join(
    r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales',
    'frontend', 'lib', 'widgets', 'job_historical_timeline.dart'
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"File written: {{len(content)}} chars, {{content.count(chr(10))}} lines")
print("Verified UTF-8 chars:")
for ch, name in [(a_, 'a_'), (e_, 'e_'), (i_, 'i_'), (o_, 'o_'), (u_, 'u_'),
                  (n_, 'n_'), (A_, 'A_'), (E_, 'E_'), (I_, 'I_'), (O_, 'O_'),
                  (qm, '?inv'), (ex, '!inv')]:
    print(f"  {name}: {ch} (U+{ord(ch):04X})")
