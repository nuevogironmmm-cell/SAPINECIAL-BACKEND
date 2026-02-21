import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget interactivo de mapa para mostrar la ubicaci?n de Uz
/// Dise?o profesional y din?mico para presentaciones educativas
class UzMapWidget extends StatefulWidget {
  final bool isProjectorMode;
  
  const UzMapWidget({
    Key? key,
    this.isProjectorMode = false,
  }) : super(key: key);

  @override
  State<UzMapWidget> createState() => _UzMapWidgetState();
}

class _UzMapWidgetState extends State<UzMapWidget> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  // Estado de la regi?n seleccionada
  String? _selectedRegion;
  
  @override
  void initState() {
    super.initState();
    
    // Animaci?n de pulso para Uz
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Animaci?n de fade para las regiones
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = widget.isProjectorMode ? 16.0 : 14.0;
    final titleSize = widget.isProjectorMode ? 24.0 : 20.0;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: widget.isProjectorMode ? 1000 : 800,
          maxHeight: widget.isProjectorMode ? 700 : 550,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // T?tulo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withValues(alpha: 0.2),
                    Colors.orange.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('???', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    'MAPA: LA TIERRA DE UZ',
                    style: GoogleFonts.oswald(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('???', style: TextStyle(fontSize: 28)),
                ],
              ),
            ),
            
            // Mapa interactivo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Mapa visual
                    Expanded(
                      flex: 3,
                      child: _buildMapVisualization(),
                    ),
                    const SizedBox(width: 20),
                    // Panel de informaci?n
                    Expanded(
                      flex: 2,
                      child: _buildInfoPanel(fontSize),
                    ),
                  ],
                ),
              ),
            ),
            
            // Leyenda inferior
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('??', 'Uz (Edom)', Colors.amber),
                  const SizedBox(width: 24),
                  _buildLegendItem('??', 'Aram (Siria)', Colors.blue),
                  const SizedBox(width: 24),
                  _buildLegendItem('??', 'Israel', Colors.green),
                  const SizedBox(width: 24),
                  _buildLegendItem('???', 'Arabia', Colors.orange.shade300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(String emoji, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
  
  Widget _buildMapVisualization() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Fondo del mapa con gradiente
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    const Color(0xFF2D3250),
                    const Color(0xFF1A1A2E),
                  ],
                ),
                border: Border.all(color: Colors.white10),
              ),
            ),
            
            // Mar Mediterr?neo (izquierda)
            Positioned(
              left: 0,
              top: constraints.maxHeight * 0.1,
              bottom: constraints.maxHeight * 0.1,
              width: constraints.maxWidth * 0.15,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'MAR MEDITERR?NEO',
                      style: GoogleFonts.oswald(
                        color: Colors.blue.shade300,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // ARAM (Siria) - Norte
            _buildRegion(
              left: constraints.maxWidth * 0.2,
              top: constraints.maxHeight * 0.05,
              width: constraints.maxWidth * 0.6,
              height: constraints.maxHeight * 0.25,
              name: 'ARAM',
              subtitle: '(Siria)',
              color: Colors.blue,
              isSelected: _selectedRegion == 'ARAM',
              emoji: '??',
              isPossibleUz: true,
              onTap: () => _selectRegion('ARAM'),
            ),
            
            // R?o ?ufrates (l?nea decorativa)
            Positioned(
              right: constraints.maxWidth * 0.1,
              top: constraints.maxHeight * 0.05,
              bottom: constraints.maxHeight * 0.5,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade400,
                      Colors.blue.shade700.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              right: constraints.maxWidth * 0.02,
              top: constraints.maxHeight * 0.15,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  '?ufrates',
                  style: TextStyle(color: Colors.blue.shade300, fontSize: 10),
                ),
              ),
            ),
            
            // ISRAEL - Centro
            _buildRegion(
              left: constraints.maxWidth * 0.15,
              top: constraints.maxHeight * 0.32,
              width: constraints.maxWidth * 0.25,
              height: constraints.maxHeight * 0.35,
              name: 'ISRAEL',
              subtitle: '',
              color: Colors.green,
              isSelected: _selectedRegion == 'ISRAEL',
              emoji: '??',
              onTap: () => _selectRegion('ISRAEL'),
            ),
            
            // Jerusalén marker
            Positioned(
              left: constraints.maxWidth * 0.25,
              top: constraints.maxHeight * 0.45,
              child: _buildCityMarker('Jerusalén', Colors.green),
            ),
            
            // Mar Muerto
            Positioned(
              left: constraints.maxWidth * 0.38,
              top: constraints.maxHeight * 0.4,
              width: constraints.maxWidth * 0.08,
              height: constraints.maxHeight * 0.25,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.cyan.shade900.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      'Mar Muerto',
                      style: TextStyle(
                        color: Colors.cyan.shade300,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // AM?N y MOAB
            _buildRegion(
              left: constraints.maxWidth * 0.48,
              top: constraints.maxHeight * 0.32,
              width: constraints.maxWidth * 0.18,
              height: constraints.maxHeight * 0.35,
              name: 'AM?N\nMOAB',
              subtitle: '',
              color: Colors.purple.shade300,
              isSelected: _selectedRegion == 'MOAB',
              emoji: '??',
              onTap: () => _selectRegion('MOAB'),
            ),
            
            // EDOM / UZ - Sur (DESTACADO con animaci?n)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return _buildRegion(
                  left: constraints.maxWidth * 0.2,
                  top: constraints.maxHeight * 0.68,
                  width: constraints.maxWidth * 0.5,
                  height: constraints.maxHeight * 0.27,
                  name: 'EDOM',
                  subtitle: '(Tierra de Uz)',
                  color: Colors.amber,
                  isSelected: _selectedRegion == 'EDOM' || _selectedRegion == null,
                  emoji: '??',
                  isMainLocation: true,
                  scale: _pulseAnimation.value,
                  onTap: () => _selectRegion('EDOM'),
                );
              },
            ),
            
            // Ciudades de Edom
            Positioned(
              left: constraints.maxWidth * 0.35,
              top: constraints.maxHeight * 0.78,
              child: _buildCityMarker('Petra', Colors.amber),
            ),
            Positioned(
              left: constraints.maxWidth * 0.55,
              top: constraints.maxHeight * 0.75,
              child: _buildCityMarker('Bosra', Colors.amber),
            ),
            
            // ARABIA - Derecha
            Positioned(
              right: 0,
              top: constraints.maxHeight * 0.4,
              bottom: 0,
              width: constraints.maxWidth * 0.2,
              child: GestureDetector(
                onTap: () => _selectRegion('ARABIA'),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.orange.shade900.withValues(alpha: 0.2),
                        Colors.orange.shade900.withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('???', style: TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        RotatedBox(
                          quarterTurns: 1,
                          child: Text(
                            'ARABIA',
                            style: GoogleFonts.oswald(
                              color: Colors.orange.shade300,
                              fontSize: 12,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '(Sabeos)',
                          style: TextStyle(
                            color: Colors.orange.shade400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Flecha indicando direcci?n a Caldea
            Positioned(
              right: constraints.maxWidth * 0.05,
              top: constraints.maxHeight * 0.15,
              child: Column(
                children: [
                  Text('? Caldea', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  Text('(Babilonia)', style: TextStyle(color: Colors.white38, fontSize: 9)),
                ],
              ),
            ),
            
            // Indicador de "Uz est? aqu?" 
            Positioned(
              left: constraints.maxWidth * 0.42,
              top: constraints.maxHeight * 0.58,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place, color: Colors.black87, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'UZ',
                      style: GoogleFonts.oswald(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildRegion({
    required double left,
    required double top,
    required double width,
    required double height,
    required String name,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required String emoji,
    bool isPossibleUz = false,
    bool isMainLocation = false,
    double scale = 1.0,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Transform.scale(
          scale: isMainLocation ? scale : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isSelected ? 0.35 : 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: isSelected ? 0.8 : 0.4),
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isMainLocation ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: TextStyle(fontSize: isMainLocation ? 28 : 20)),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      color: color,
                      fontSize: isMainLocation ? 16 : 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.8),
                        fontSize: isMainLocation ? 12 : 10,
                      ),
                    ),
                  if (isPossibleUz)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '?Posible Uz?',
                        style: TextStyle(color: Colors.white54, fontSize: 9),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCityMarker(String name, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          name,
          style: TextStyle(
            color: color.withValues(alpha: 0.9),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoPanel(double fontSize) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              'Ubicaci?n Principal',
              'EDOM (m?s probable)',
              Colors.amber,
              [
                '? Suroeste de Jordania actual',
                '? Sur del Mar Muerto',
                '? Lamentaciones 4:21 lo confirma',
                '? Regi?n rica en sabidur?a',
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              'Teor?a Alternativa',
              'ARAM (Siria)',
              Colors.blue,
              [
                '? Norte de Mesopotamia',
                '? Uz, hijo de Aram (Gén 10:23)',
                '? Rollos del Mar Muerto',
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              '?Por qué importa?',
              'Job fuera de Israel',
              Colors.green,
              [
                '? No menciona la Ley de Moisés',
                '? No habla del Templo',
                '? Era sacerdote de su familia',
                '? Atacado por sabeos y caldeos',
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoSection(String title, String subtitle, Color color, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.oswald(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.oswald(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            point,
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        )),
      ],
    );
  }
  
  void _selectRegion(String region) {
    setState(() {
      _selectedRegion = _selectedRegion == region ? null : region;
    });
  }
}
