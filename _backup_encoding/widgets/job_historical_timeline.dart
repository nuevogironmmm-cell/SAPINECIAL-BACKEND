import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =============================================================================
/// L?NEA DE TIEMPO HIST?RICA DE JOB - ANIMACI?N DOCUMENTAL
/// Muestra cu?ndo existi? Job en relaci?n con la historia b?blica
/// Estilo: Académico, minimalista, animado
/// =============================================================================
class JobHistoricalTimeline extends StatefulWidget {
  final bool isProjectorMode;
  final bool autoPlay;
  
  const JobHistoricalTimeline({
    Key? key,
    this.isProjectorMode = false,
    this.autoPlay = true,
  }) : super(key: key);

  @override
  State<JobHistoricalTimeline> createState() => _JobHistoricalTimelineState();
}

class _JobHistoricalTimelineState extends State<JobHistoricalTimeline>
    with TickerProviderStateMixin {
  
  // Controladores de animaci?n
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  
  // Animaciones
  late Animation<double> _lineProgress;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
  // Estados de los hitos
  final List<bool> _milestonesRevealed = List.filled(6, false);
  
  // Datos de la l?nea de tiempo
  final List<_TimelineMilestone> _milestones = [
    _TimelineMilestone(
      year: '~2100 a.C.',
      title: 'JOB',
      subtitle: 'Vida probable',
      description: 'Per?odo patriarcal temprano',
      isMainFocus: true,
      color: const Color(0xFFD4AF37),
      icon: Icons.person,
    ),
    _TimelineMilestone(
      year: '~2000 a.C.',
      title: 'ABRAHAM',
      subtitle: 'Padre de la fe',
      description: 'Sale de Ur de los Caldeos',
      isMainFocus: false,
      color: const Color(0xFF6BA3D6),
      icon: Icons.directions_walk,
    ),
    _TimelineMilestone(
      year: '~1900 a.C.',
      title: 'ISAAC',
      subtitle: 'Hijo de la promesa',
      description: 'Nacimiento y vida',
      isMainFocus: false,
      color: const Color(0xFF6BA3D6),
      icon: Icons.child_care,
    ),
    _TimelineMilestone(
      year: '~1800 a.C.',
      title: 'JACOB',
      subtitle: 'Israel',
      description: '12 tribus originadas',
      isMainFocus: false,
      color: const Color(0xFF6BA3D6),
      icon: Icons.people,
    ),
    _TimelineMilestone(
      year: '~1500 a.C.',
      title: 'MOIS?S',
      subtitle: 'La Ley',
      description: '?xodo y Sina?',
      isMainFocus: false,
      color: const Color(0xFF7CB342),
      icon: Icons.menu_book,
      note: 'JOB antes de la Ley',
    ),
    _TimelineMilestone(
      year: '~1400 a.C.',
      title: 'JOSU?',
      subtitle: 'Conquista',
      description: 'Entrada a Cana?n',
      isMainFocus: false,
      color: const Color(0xFF7CB342),
      icon: Icons.flag,
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Controlador principal de la l?nea de tiempo
    _mainController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _lineProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutCubic,
      ),
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
    if (widget.autoPlay) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _mainController.forward();
      });
    }
  }
  
  void _updateMilestones() {
    final progress = _lineProgress.value;
    final totalMilestones = _milestones.length;
    
    for (int i = 0; i < totalMilestones; i++) {
      final threshold = (i + 1) / totalMilestones;
      if (progress >= threshold - 0.1 && !_milestonesRevealed[i]) {
        setState(() {
          _milestonesRevealed[i] = true;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.isProjectorMode ? 1200 : 1000,
        maxHeight: widget.isProjectorMode ? 650 : 520,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D0A07),
            const Color(0xFF1A1510),
            const Color(0xFF0D0A07),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildTimelineContent()),
            _buildKeyPoints(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final titleSize = widget.isProjectorMode ? 24.0 : 20.0;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.isProjectorMode ? 20 : 16,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2318).withValues(alpha: 0.9),
            const Color(0xFF1A1510).withValues(alpha: 0.8),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            color: const Color(0xFFD4AF37),
            size: widget.isProjectorMode ? 28 : 24,
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                'L?NEA DE TIEMPO HIST?RICA',
                style: GoogleFonts.cinzel(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '?CU?NDO EXISTI? JOB?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: widget.isProjectorMode ? 14 : 12,
                  color: const Color(0xFFBFA67A),
                  letterSpacing: 4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.history,
            color: const Color(0xFFD4AF37),
            size: widget.isProjectorMode ? 28 : 24,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimelineContent() {
    return Padding(
      padding: EdgeInsets.all(widget.isProjectorMode ? 30 : 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // L?nea de tiempo base
              _buildTimelineBase(constraints),
              
              // L?nea de progreso animada
              AnimatedBuilder(
                animation: _lineProgress,
                builder: (context, child) {
                  return _buildProgressLine(constraints, _lineProgress.value);
                },
              ),
              
              // Hitos
              ..._buildMilestoneWidgets(constraints),
              
              // Era labels
              _buildEraLabels(constraints),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildTimelineBase(BoxConstraints constraints) {
    return Positioned(
      left: 40,
      right: 40,
      top: constraints.maxHeight * 0.4,
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: const Color(0xFF3D3425),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressLine(BoxConstraints constraints, double progress) {
    final lineWidth = (constraints.maxWidth - 80) * progress;
    
    return Positioned(
      left: 40,
      top: constraints.maxHeight * 0.4,
      child: Container(
        height: 6,
        width: lineWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFD4AF37),
              const Color(0xFFD4AF37).withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
  
  List<Widget> _buildMilestoneWidgets(BoxConstraints constraints) {
    final widgets = <Widget>[];
    final totalWidth = constraints.maxWidth - 80;
    final startX = 40.0;
    
    for (int i = 0; i < _milestones.length; i++) {
      final milestone = _milestones[i];
      final x = startX + (totalWidth * (i / (_milestones.length - 1)));
      final isRevealed = _milestonesRevealed[i];
      
      widgets.add(
        Positioned(
          left: x - 50,
          top: constraints.maxHeight * 0.15,
          width: 100,
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
    }
    
    return widgets;
  }
  
  Widget _buildMainMilestone(_TimelineMilestone milestone, BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // A?o
                Text(
                  milestone.year,
                  style: GoogleFonts.robotoMono(
                    fontSize: widget.isProjectorMode ? 14 : 12,
                    color: milestone.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // C?rculo con ?cono (animado)
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: widget.isProjectorMode ? 70 : 60,
                    height: widget.isProjectorMode ? 70 : 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          milestone.color,
                          milestone.color.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: milestone.color.withValues(alpha: _glowAnimation.value),
                          blurRadius: 25,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: milestone.color.withValues(alpha: _glowAnimation.value * 0.5),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: Icon(
                      milestone.icon,
                      color: Colors.white,
                      size: widget.isProjectorMode ? 32 : 28,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Nombre
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: milestone.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: milestone.color),
                  ),
                  child: Column(
                    children: [
                      Text(
                        milestone.title,
                        style: GoogleFonts.cinzel(
                          fontSize: widget.isProjectorMode ? 16 : 14,
                          fontWeight: FontWeight.bold,
                          color: milestone.color,
                        ),
                      ),
                      Text(
                        milestone.subtitle,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: widget.isProjectorMode ? 11 : 10,
                          color: milestone.color.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Descripci?n
                Text(
                  milestone.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: widget.isProjectorMode ? 10 : 9,
                    color: const Color(0xFFBFA67A),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Widget _buildMilestone(_TimelineMilestone milestone) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A?o
        Text(
          milestone.year,
          style: GoogleFonts.robotoMono(
            fontSize: widget.isProjectorMode ? 11 : 10,
            color: const Color(0xFFBFA67A),
          ),
        ),
        const SizedBox(height: 6),
        
        // C?rculo con ?cono
        Container(
          width: widget.isProjectorMode ? 45 : 40,
          height: widget.isProjectorMode ? 45 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: milestone.color.withValues(alpha: 0.2),
            border: Border.all(
              color: milestone.color.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: Icon(
            milestone.icon,
            color: milestone.color.withValues(alpha: 0.8),
            size: widget.isProjectorMode ? 20 : 18,
          ),
        ),
        
        const SizedBox(height: 6),
        
        // Nombre
        Text(
          milestone.title,
          style: GoogleFonts.cinzel(
            fontSize: widget.isProjectorMode ? 11 : 10,
            color: milestone.color.withValues(alpha: 0.9),
            fontWeight: FontWeight.w600,
          ),
        ),
        
        Text(
          milestone.subtitle,
          style: GoogleFonts.cormorantGaramond(
            fontSize: widget.isProjectorMode ? 9 : 8,
            color: const Color(0xFFBFA67A).withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
        
        // Nota especial
        if (milestone.note != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              milestone.note!,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 8,
                color: Colors.red.shade300,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildEraLabels(BoxConstraints constraints) {
    return Positioned(
      left: 40,
      right: 40,
      bottom: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildEraLabel('ERA PATRIARCAL', const Color(0xFFD4AF37), true),
          _buildEraLabel('PRE-LEY MOSAICA', const Color(0xFF6BA3D6), false),
          _buildEraLabel('ERA DE LA LEY', const Color(0xFF7CB342), false),
        ],
      ),
    );
  }
  
  Widget _buildEraLabel(String text, Color color, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withValues(alpha: isHighlighted ? 0.5 : 0.2),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          fontSize: widget.isProjectorMode ? 10 : 9,
          color: color.withValues(alpha: isHighlighted ? 1.0 : 0.6),
          letterSpacing: 1,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildKeyPoints() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isProjectorMode ? 30 : 20,
        vertical: widget.isProjectorMode ? 16 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildKeyPoint(Icons.schedule, 'Job ANTES de Israel', 'como naci?n'),
          _buildKeyPoint(Icons.menu_book, 'Job ANTES de la Ley', 'mosaica'),
          _buildKeyPoint(Icons.people, 'Contempor?neo o previo', 'a Abraham'),
          _buildKeyPoint(Icons.elderly, 'Longevidad coherente', 'con Génesis'),
        ],
      ),
    );
  }
  
  Widget _buildKeyPoint(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2318).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
            size: widget.isProjectorMode ? 20 : 16,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: widget.isProjectorMode ? 11 : 9,
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: widget.isProjectorMode ? 10 : 8,
                  color: const Color(0xFFBFA67A).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.isProjectorMode ? 12 : 10,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1510).withValues(alpha: 0.8),
            const Color(0xFF2A2318).withValues(alpha: 0.9),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFFBFA67A).withValues(alpha: 0.5),
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                'Sacrificios familiares | Sin sacerdocio lev?tico',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: widget.isProjectorMode ? 11 : 10,
                  color: const Color(0xFFBFA67A).withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          
          // Bot?n de reproducir
          IconButton(
            onPressed: () {
              setState(() {
                for (int i = 0; i < _milestonesRevealed.length; i++) {
                  _milestonesRevealed[i] = false;
                }
              });
              _mainController.reset();
              _mainController.forward();
            },
            icon: Icon(
              Icons.replay,
              color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
              size: 20,
            ),
            tooltip: 'Reproducir animaci?n',
          ),
        ],
      ),
    );
  }
}

// Modelo de datos para hitos
class _TimelineMilestone {
  final String year;
  final String title;
  final String subtitle;
  final String description;
  final bool isMainFocus;
  final Color color;
  final IconData icon;
  final String? note;
  
  const _TimelineMilestone({
    required this.year,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isMainFocus,
    required this.color,
    required this.icon,
    this.note,
  });
}
