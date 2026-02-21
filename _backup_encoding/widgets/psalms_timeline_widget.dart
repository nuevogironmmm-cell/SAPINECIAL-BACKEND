import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PsalmsTimelineWidget extends StatefulWidget {
  const PsalmsTimelineWidget({super.key});

  @override
  State<PsalmsTimelineWidget> createState() => _PsalmsTimelineWidgetState();
}

class _PsalmsTimelineWidgetState extends State<PsalmsTimelineWidget> {
  final List<bool> _milestonesRevealed = [false, false, false, false];

  final List<_PsalmsMilestone> _milestones = [
    _PsalmsMilestone(
      year: '1400 a.C.',
      title: 'Moisés',
      subtitle: 'El inicio',
      description: 'Salmo 90: El salmo m?s antiguo. Inicia la tradici?n poética de Israel.',
      color: Colors.amber,
      icon: Icons.history_edu,
    ),
    _PsalmsMilestone(
      year: '1000 a.C.',
      title: 'David',
      subtitle: 'La Edad de Oro',
      description: 'El "Dulce Cantor de Israel". Compuso la mayor?a de los salmos. Estableci? la m?sica en el culto.',
      color: Colors.orange,
      icon: Icons.music_note,
      isMain: true,
    ),
    _PsalmsMilestone(
      year: '700 a.C.',
      title: 'Ezequ?as',
      subtitle: 'La Colecci?n',
      description: 'El rey Ezequ?as mand? recopilar los salmos de David y Asaf para el culto en el Templo.',
      color: Colors.deepPurple,
      icon: Icons.library_books,
    ),
    _PsalmsMilestone(
      year: '450 a.C.',
      title: 'Esdras y Nehem?as',
      subtitle: 'Forma Final',
      description: 'Después del exilio, se recopilaron los 5 libros finales (el "Pentateuco de David"). Himnario definitivo.',
      color: Colors.blue,
      icon: Icons.account_balance, // Templo restaurado
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < _milestones.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _milestonesRevealed[i] = true;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e), // Dark background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cronolog?a de los Salmos',
            style: GoogleFonts.cinzel(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1000 a?os de alabanza (Moisés a Esdras)',
            style: GoogleFonts.lato(
              fontSize: 18,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Stack(
              children: [
                // L?nea de tiempo base
                Positioned(
                  left: 50,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.amber,
                          Colors.blue,
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),
                // Hitos
                ListView.builder(
                  itemCount: _milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = _milestones[index];
                    final isRevealed = _milestonesRevealed[index];
                    
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 600),
                      opacity: isRevealed ? 1.0 : 0.0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 600),
                        offset: isRevealed ? Offset.zero : const Offset(0.2, 0),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // A?o y Punto
                              SizedBox(
                                width: 100,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: milestone.color,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: milestone.color.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        milestone.icon,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      milestone.year,
                                      style: GoogleFonts.oswald(
                                        color: milestone.color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Contenido
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border(
                                      left: BorderSide(
                                        color: milestone.color,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        milestone.title,
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        milestone.subtitle.toUpperCase(),
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white54,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        milestone.description,
                                        style: GoogleFonts.sourceSans3(
                                          fontSize: 16,
                                          color: Colors.white70,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                 for(int i=0; i<_milestonesRevealed.length; i++) _milestonesRevealed[i] = false;
                });
                _startAnimation();
              },
              icon: const Icon(Icons.replay, color: Colors.white54),
              label: const Text('Repetir Animaci?n', style: TextStyle(color: Colors.white54)),
            ),
          )
        ],
      ),
    );
  }
}

class _PsalmsMilestone {
  final String year;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final IconData icon;
  final bool isMain;

  const _PsalmsMilestone({
    required this.year,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.icon,
    this.isMain = false,
  });
}
