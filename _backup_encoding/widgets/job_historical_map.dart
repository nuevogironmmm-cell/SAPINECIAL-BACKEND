import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

/// =============================================================================
/// MAPA HISTORICO DE UZ - ESTILO PERGAMINO PROFESIONAL
/// Todo generado por codigo - Sin dependencias de imagenes externas
/// Periodo: 2000-1800 a.C. (Era Patriarcal Pre-Mosaica)
/// =============================================================================
class JobHistoricalMap extends StatefulWidget {
  final bool isProjectorMode;
  
  const JobHistoricalMap({
    Key? key,
    this.isProjectorMode = false,
  }) : super(key: key);

  @override
  State<JobHistoricalMap> createState() => _JobHistoricalMapState();
}

class _JobHistoricalMapState extends State<JobHistoricalMap> 
    with TickerProviderStateMixin {
  
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _routeController;
  late AnimationController _shimmerController;
  
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _routeAnimation;
  late Animation<double> _shimmerAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _routeController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _routeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_routeController);
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }
  
  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _routeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double maxW = widget.isProjectorMode ? 1200 : 1000;
    final double maxH = widget.isProjectorMode ? 750 : 620;
    
    return Container(
      constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8B7355), width: 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo pergamino generado
            CustomPaint(
              painter: _ParchmentBackgroundPainter(),
              size: Size.infinite,
            ),
            
            // Mapa geografico pintado
            CustomPaint(
              painter: _MapGeographyPainter(isProjectorMode: widget.isProjectorMode),
              size: Size.infinite,
            ),
            
            // Rutas comerciales animadas
            AnimatedBuilder(
              animation: _routeAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _TradeRoutesPainter(
                    progress: _routeAnimation.value,
                    isProjectorMode: widget.isProjectorMode,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // Brillo en region Uz
            _buildUzGlow(),
            
            // Marcador de Uz animado
            _buildUzMarker(),
            
            // Etiquetas de regiones
            _buildRegionLabels(),
            
            // Titulo superior
            _buildTitle(),
            
            // Leyenda inferior
            _buildLegend(),
            
            // Rosa de los vientos
            _buildCompass(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUzGlow() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned(
          left: widget.isProjectorMode ? 420 : 350,
          top: widget.isProjectorMode ? 340 : 280,
          child: Container(
            width: widget.isProjectorMode ? 180 : 150,
            height: widget.isProjectorMode ? 140 : 115,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6B35).withValues(alpha: 0.5 * _glowAnimation.value),
                  const Color(0xFFFF8C42).withValues(alpha: 0.25 * _glowAnimation.value),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.4 * _glowAnimation.value),
                  blurRadius: 50,
                  spreadRadius: 25,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildUzMarker() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Positioned(
              left: widget.isProjectorMode ? 470 : 395,
              top: widget.isProjectorMode ? 370 : 310,
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.isProjectorMode ? 70 : 58,
                  height: widget.isProjectorMode ? 70 : 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD700),
                        const Color(0xFFD4AF37),
                      ],
                    ),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: _glowAnimation.value),
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: _glowAnimation.value * 0.5),
                        blurRadius: 40,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.place,
                    color: Colors.white,
                    size: widget.isProjectorMode ? 40 : 34,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildRegionLabels() {
    final fontSize = widget.isProjectorMode ? 18.0 : 15.0;
    final smallFontSize = widget.isProjectorMode ? 14.0 : 12.0;
    
    return Stack(
      children: [
        // Mar Mediterraneo
        Positioned(
          left: 20,
          top: widget.isProjectorMode ? 200 : 170,
          child: RotatedBox(
            quarterTurns: 3,
            child: _regionLabel('MAR MEDITERRANEO', const Color(0xFF2E5984), fontSize),
          ),
        ),
        
        // Canaan
        Positioned(
          left: widget.isProjectorMode ? 180 : 150,
          top: widget.isProjectorMode ? 180 : 150,
          child: _regionLabel('CANAAN', const Color(0xFF4A7C59), fontSize),
        ),
        
        // Damasco
        Positioned(
          left: widget.isProjectorMode ? 350 : 290,
          top: widget.isProjectorMode ? 100 : 85,
          child: _cityLabel('Damasco', smallFontSize),
        ),
        
        // Rio Eufrates
        Positioned(
          right: widget.isProjectorMode ? 250 : 210,
          top: widget.isProjectorMode ? 80 : 65,
          child: Text(
            'R. Eufrates',
            style: GoogleFonts.cormorantGaramond(
              fontSize: smallFontSize,
              color: const Color(0xFF2E5984),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        
        // Mesopotamia
        Positioned(
          right: widget.isProjectorMode ? 80 : 60,
          top: widget.isProjectorMode ? 120 : 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _regionLabel('MESOPOTAMIA', const Color(0xFF8B7355), fontSize),
              Text(
                'Babilonia',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: smallFontSize,
                  color: const Color(0xFF6B5344),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        
        // Edom
        Positioned(
          left: widget.isProjectorMode ? 280 : 230,
          top: widget.isProjectorMode ? 340 : 285,
          child: _cityLabel('Edom', smallFontSize),
        ),
        
        // Bozra
        Positioned(
          left: widget.isProjectorMode ? 320 : 265,
          top: widget.isProjectorMode ? 400 : 335,
          child: _cityLabel('Bozra', smallFontSize),
        ),
        
        // Region de Uz - Etiqueta principal
        Positioned(
          left: widget.isProjectorMode ? 430 : 360,
          top: widget.isProjectorMode ? 440 : 370,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF3D2914).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'Region de Uz',
                  style: GoogleFonts.cinzel(
                    fontSize: widget.isProjectorMode ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                Text(
                  '(Tierra de Job)',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: widget.isProjectorMode ? 16 : 13,
                    color: const Color(0xFFE8D5B7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Dedan
        Positioned(
          right: widget.isProjectorMode ? 200 : 165,
          top: widget.isProjectorMode ? 400 : 335,
          child: _cityLabel('Dedan', smallFontSize),
        ),
        
        // Arabia
        Positioned(
          right: widget.isProjectorMode ? 120 : 95,
          bottom: widget.isProjectorMode ? 180 : 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _regionLabel('ARABIA', const Color(0xFFB8860B), fontSize),
              Text(
                '(Sabeos)',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: smallFontSize,
                  color: const Color(0xFF8B7355),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        
        // Desierto de Arabia
        Positioned(
          right: widget.isProjectorMode ? 80 : 65,
          bottom: widget.isProjectorMode ? 250 : 210,
          child: Text(
            'Desierto de Arabia',
            style: GoogleFonts.cormorantGaramond(
              fontSize: smallFontSize,
              color: const Color(0xFF8B7355).withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        
        // Mar Muerto
        Positioned(
          left: widget.isProjectorMode ? 220 : 185,
          top: widget.isProjectorMode ? 280 : 235,
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              'Mar Muerto',
              style: GoogleFonts.cormorantGaramond(
                fontSize: smallFontSize,
                color: const Color(0xFF2E5984),
              ),
            ),
          ),
        ),
        
        // Gaza
        Positioned(
          left: widget.isProjectorMode ? 130 : 105,
          top: widget.isProjectorMode ? 230 : 195,
          child: _cityLabel('Gaza', smallFontSize),
        ),
        
        // Peninsula del Sinai
        Positioned(
          left: widget.isProjectorMode ? 200 : 165,
          bottom: widget.isProjectorMode ? 130 : 105,
          child: Text(
            'Peninsula\ndel Sinai',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: smallFontSize,
              color: const Color(0xFF8B7355).withValues(alpha: 0.8),
            ),
          ),
        ),
        
        // Golfo de Aqaba
        Positioned(
          left: widget.isProjectorMode ? 260 : 215,
          bottom: widget.isProjectorMode ? 80 : 65,
          child: Text(
            'Golfo de\nAqaba',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: smallFontSize - 2,
              color: const Color(0xFF2E5984),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _regionLabel(String text, Color color, double fontSize) {
    return Text(
      text,
      style: GoogleFonts.cinzel(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 2,
        shadows: [
          Shadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
  
  Widget _cityLabel(String text, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF5D4E37),
            border: Border.all(color: const Color(0xFF3D2914), width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.cormorantGaramond(
            fontSize: fontSize,
            color: const Color(0xFF3D2914),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTitle() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: widget.isProjectorMode ? 18 : 14,
          horizontal: 30,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3D2914).withValues(alpha: 0.95),
              const Color(0xFF3D2914).withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(_shimmerAnimation.value - 1, 0),
                      end: Alignment(_shimmerAnimation.value, 0),
                      colors: const [
                        Color(0xFFD4AF37),
                        Color(0xFFFFD700),
                        Color(0xFFD4AF37),
                      ],
                    ).createShader(bounds);
                  },
                  child: Text(
                    'MAPA GEOGRAFICO DE LA REGION DE UZ',
                    style: GoogleFonts.cinzel(
                      fontSize: widget.isProjectorMode ? 32 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              'Contexto historico del libro de Job',
              style: GoogleFonts.cormorantGaramond(
                fontSize: widget.isProjectorMode ? 18 : 15,
                color: const Color(0xFFE8D5B7),
                fontStyle: FontStyle.italic,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegend() {
    return Positioned(
      bottom: 10,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5E6D3).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8B7355), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'La Region de Uz (Tierra de Job)',
              style: GoogleFonts.cinzel(
                fontSize: widget.isProjectorMode ? 14 : 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3D2914),
              ),
            ),
            Text(
              'Probable ubicacion en el sureste de\nEdom, cerca de Arabia.',
              style: GoogleFonts.cormorantGaramond(
                fontSize: widget.isProjectorMode ? 12 : 10,
                color: const Color(0xFF5D4E37),
              ),
            ),
            const SizedBox(height: 8),
            _legendItem('- - -', 'Ruta Comercial'),
            _legendItem('^^^', 'Desierto'),
            _legendItem('/\\  /\\', 'Montanas'),
          ],
        ),
      ),
    );
  }
  
  Widget _legendItem(String symbol, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          child: Text(
            symbol,
            style: GoogleFonts.robotoMono(
              fontSize: widget.isProjectorMode ? 11 : 9,
              color: const Color(0xFF5D4E37),
            ),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cormorantGaramond(
            fontSize: widget.isProjectorMode ? 12 : 10,
            color: const Color(0xFF5D4E37),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCompass() {
    return Positioned(
      top: widget.isProjectorMode ? 90 : 75,
      right: widget.isProjectorMode ? 30 : 25,
      child: Container(
        width: widget.isProjectorMode ? 80 : 65,
        height: widget.isProjectorMode ? 80 : 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF5E6D3),
          border: Border.all(color: const Color(0xFF8B7355), width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cruz cardinal
            CustomPaint(
              size: Size(widget.isProjectorMode ? 70 : 55, widget.isProjectorMode ? 70 : 55),
              painter: _CompassPainter(),
            ),
            // Letras
            Positioned(top: 5, child: Text('N', style: _compassTextStyle())),
            Positioned(bottom: 5, child: Text('S', style: _compassTextStyle())),
            Positioned(left: 8, child: Text('W', style: _compassTextStyle())),
            Positioned(right: 8, child: Text('E', style: _compassTextStyle())),
          ],
        ),
      ),
    );
  }
  
  TextStyle _compassTextStyle() {
    return GoogleFonts.cinzel(
      fontSize: widget.isProjectorMode ? 12 : 10,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF3D2914),
    );
  }
}

// =============================================================================
// PAINTERS
// =============================================================================

class _ParchmentBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fondo base pergamino
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFFE8D5B7),
          Color(0xFFDCC9A3),
          Color(0xFFD4BC8A),
          Color(0xFFCDB07A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Textura de pergamino
    final texturePaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42);
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, texturePaint);
    }
    
    // Bordes envejecidos
    final edgePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.9,
        colors: [
          Colors.transparent,
          const Color(0xFF8B7355).withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), edgePaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapGeographyPainter extends CustomPainter {
  final bool isProjectorMode;
  
  _MapGeographyPainter({required this.isProjectorMode});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Mar Mediterraneo
    final seaPaint = Paint()
      ..color = const Color(0xFF6BA3D6).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    final seaPath = Path();
    seaPath.moveTo(0, size.height * 0.1);
    seaPath.quadraticBezierTo(size.width * 0.08, size.height * 0.3, size.width * 0.05, size.height * 0.5);
    seaPath.quadraticBezierTo(size.width * 0.1, size.height * 0.7, 0, size.height * 0.85);
    seaPath.lineTo(0, size.height * 0.1);
    canvas.drawPath(seaPath, seaPaint);
    
    // Mar Muerto
    final deadSeaPaint = Paint()
      ..color = const Color(0xFF4A7BA7).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.2, size.height * 0.45),
        width: size.width * 0.03,
        height: size.height * 0.15,
      ),
      deadSeaPaint,
    );
    
    // Golfo de Aqaba
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25, size.height * 0.85),
        width: size.width * 0.02,
        height: size.height * 0.12,
      ),
      deadSeaPaint,
    );
    
    // Region de Uz (destacada)
    final uzPaint = Paint()
      ..color = const Color(0xFFE07B39).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    
    final uzPath = Path();
    uzPath.moveTo(size.width * 0.38, size.height * 0.42);
    uzPath.quadraticBezierTo(size.width * 0.5, size.height * 0.38, size.width * 0.58, size.height * 0.45);
    uzPath.quadraticBezierTo(size.width * 0.62, size.height * 0.55, size.width * 0.55, size.height * 0.65);
    uzPath.quadraticBezierTo(size.width * 0.45, size.height * 0.68, size.width * 0.38, size.height * 0.58);
    uzPath.quadraticBezierTo(size.width * 0.35, size.height * 0.50, size.width * 0.38, size.height * 0.42);
    canvas.drawPath(uzPath, uzPaint);
    
    // Borde de la region de Uz
    final uzBorderPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(uzPath, uzBorderPaint);
    
    // Desierto (textura)
    final desertPaint = Paint()
      ..color = const Color(0xFFDAA520).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (double y = size.height * 0.5; y < size.height * 0.9; y += 20) {
      for (double x = size.width * 0.5; x < size.width * 0.9; x += 25) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + 15, y - 5),
          desertPaint,
        );
        canvas.drawLine(
          Offset(x + 15, y - 5),
          Offset(x + 30, y),
          desertPaint,
        );
      }
    }
    
    // Montanas (simbolos)
    final mountainPaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Montanas en Edom
    _drawMountain(canvas, Offset(size.width * 0.3, size.height * 0.55), 15, mountainPaint);
    _drawMountain(canvas, Offset(size.width * 0.32, size.height * 0.58), 12, mountainPaint);
    _drawMountain(canvas, Offset(size.width * 0.28, size.height * 0.60), 10, mountainPaint);
    
    // Rio Eufrates
    final riverPaint = Paint()
      ..color = const Color(0xFF4A7BA7).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final riverPath = Path();
    riverPath.moveTo(size.width * 0.65, 0);
    riverPath.quadraticBezierTo(size.width * 0.7, size.height * 0.15, size.width * 0.75, size.height * 0.25);
    riverPath.quadraticBezierTo(size.width * 0.8, size.height * 0.4, size.width * 0.9, size.height * 0.6);
    canvas.drawPath(riverPath, riverPaint);
    
    // Rutas comerciales (lineas punteadas estaticas)
    final routePaint = Paint()
      ..color = const Color(0xFF5D4E37).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    _drawDashedLine(canvas, 
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.5),
      routePaint
    );
    
    _drawDashedLine(canvas,
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.5),
      routePaint
    );
    
    _drawDashedLine(canvas,
      Offset(size.width * 0.7, size.height * 0.75),
      Offset(size.width * 0.5, size.height * 0.55),
      routePaint
    );
  }
  
  void _drawMountain(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx - size, center.dy);
    path.lineTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    canvas.drawPath(path, paint);
  }
  
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    final dashLength = 8.0;
    final gapLength = 5.0;
    final steps = (distance / (dashLength + gapLength)).floor();
    
    for (int i = 0; i < steps; i++) {
      final t1 = i * (dashLength + gapLength) / distance;
      final t2 = (i * (dashLength + gapLength) + dashLength) / distance;
      if (t2 <= 1.0) {
        canvas.drawLine(
          Offset(start.dx + dx * t1, start.dy + dy * t1),
          Offset(start.dx + dx * t2, start.dy + dy * t2),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TradeRoutesPainter extends CustomPainter {
  final double progress;
  final bool isProjectorMode;
  
  _TradeRoutesPainter({required this.progress, required this.isProjectorMode});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final dotSize = isProjectorMode ? 8.0 : 6.0;
    
    // Puntos animados en rutas
    final routes = [
      [Offset(size.width * 0.75, size.height * 0.2), Offset(size.width * 0.5, size.height * 0.5)],
      [Offset(size.width * 0.15, size.height * 0.25), Offset(size.width * 0.5, size.height * 0.5)],
      [Offset(size.width * 0.7, size.height * 0.75), Offset(size.width * 0.5, size.height * 0.55)],
    ];
    
    for (final route in routes) {
      final start = route[0];
      final end = route[1];
      
      for (int i = 0; i < 4; i++) {
        final phase = (progress + i * 0.25) % 1.0;
        final x = start.dx + (end.dx - start.dx) * phase;
        final y = start.dy + (end.dy - start.dy) * phase;
        final opacity = math.sin(phase * math.pi);
        
        paint.color = const Color(0xFFD4AF37).withValues(alpha: 0.3 + 0.5 * opacity);
        canvas.drawCircle(Offset(x, y), dotSize * (0.6 + 0.4 * opacity), paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant _TradeRoutesPainter oldDelegate) => oldDelegate.progress != progress;
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Cruz
    canvas.drawLine(Offset(center.dx, 8), Offset(center.dx, size.height - 8), paint);
    canvas.drawLine(Offset(8, center.dy), Offset(size.width - 8, center.dy), paint);
    
    // Flecha Norte
    final arrowPaint = Paint()
      ..color = const Color(0xFF3D2914)
      ..style = PaintingStyle.fill;
    
    final arrowPath = Path();
    arrowPath.moveTo(center.dx, 12);
    arrowPath.lineTo(center.dx - 6, 22);
    arrowPath.lineTo(center.dx + 6, 22);
    arrowPath.close();
    canvas.drawPath(arrowPath, arrowPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
