import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImprecatoryPsalmsWidget extends StatefulWidget {
  final bool revealAnswers;

  const ImprecatoryPsalmsWidget({
    super.key,
    this.revealAnswers = false,
  });

  @override
  State<ImprecatoryPsalmsWidget> createState() => _ImprecatoryPsalmsWidgetState();
}

class _ImprecatoryPsalmsWidgetState extends State<ImprecatoryPsalmsWidget> {
  final PageController _pageController = PageController();
  
  // Data for the activity
  final List<Map<String, dynamic>> _activityItems = [
    {
      'text': '“Lev?ntate, oh Se?or; defiéndeme; pelea contra los que me combaten.”',
      'answer': 'IMPRECATORIO',
      'color': Colors.redAccent,
      'reference': 'Salmo 35',
    },
    {
      'text': '“Ten misericordia de m?, oh Dios, porque en ti ha confiado mi alma.”',
      'answer': 'LAMENTO',
      'color': Colors.blueAccent,
      'reference': 'Salmo 57',
    },
    {
      'text': '“Alabad al Se?or porque él es bueno; porque para siempre es su misericordia.”',
      'answer': 'ALABANZA',
      'color': Colors.greenAccent,
      'reference': 'Salmo 136',
    },
    {
      'text': '“Sean avergonzados y turbados todos los que se alegran de mi mal.”',
      'answer': 'IMPRECATORIO',
      'color': Colors.redAccent,
      'reference': 'Salmo 40',
    },
    {
      'text': '“?Hasta cu?ndo, Se?or, me olvidar?s para siempre?”',
      'answer': 'LAMENTO',
      'color': Colors.blueAccent,
      'reference': 'Salmo 13',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505), // Dark reddish black vibe
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: [
          _buildDefinitionSection(),
          _buildActivityIntro(),
          ..._activityItems.asMap().entries.map((entry) => _buildActivityItem(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildDefinitionSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1533613220915-609f661a6fe1?w=1600', // Stormy/Justice vibe
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.7),
          colorBlendMode: BlendMode.darken,
        ),
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LOS SALMOS IMPRECATORIOS',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ).copyWith(shadows: [const Shadow(color: Colors.black, blurRadius: 20)]),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '?QU? SON?',
                      style: GoogleFonts.oswald(fontSize: 30, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Son oraciones donde el salmista clama a Dios pidiendo juicio y justicia contra sus enemigos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(fontSize: 28, color: Colors.white, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'NO SON VENGANZA PERSONAL.\nSON JUSTICIA DIVINA.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(fontSize: 26, color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'PRINCIPALES: SALMOS 35, 58, 69, 83, 109, 137',
                style: GoogleFonts.cinzel(fontSize: 24, color: Colors.white54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityIntro() {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, size: 100, color: Colors.orangeAccent),
          const SizedBox(height: 30),
          Text(
            'ACTIVIDAD 2 – CLASIFICA EL TEXTO',
            style: GoogleFonts.oswald(fontSize: 50, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Clasifica el Texto',
            style: GoogleFonts.cinzel(fontSize: 40, color: Colors.orangeAccent),
          ),
          const SizedBox(height: 40),
          Text(
            '?? IMPRECATORIO  |  ?? LAMENTO  |  ?? ALABANZA',
            style: GoogleFonts.lato(fontSize: 24, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white24, size: 50),
        ],
      ),
    );
  }

  Widget _buildActivityItem(int index, Map<String, dynamic> item) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF101010)), // Dark background
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'EJERCICIO ${index + 1}',
                      style: GoogleFonts.oswald(fontSize: 24, color: Colors.white24),
                    ),
                    const SizedBox(height: 40),
                    
                    // Quote Card
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        item['text'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 40,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 60),

                    if (!widget.revealAnswers)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          'Esperando orden del docente para revelar',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 22,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                            decoration: BoxDecoration(
                              color: item['color'],
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(color: item['color'].withOpacity(0.6), blurRadius: 30, spreadRadius: 5)
                              ],
                            ),
                            child: Text(
                              item['answer'],
                              style: GoogleFonts.oswald(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Pertenece al ${item['reference']}",
                            style: GoogleFonts.lato(fontSize: 24, color: Colors.white70),
                          ),
                        ],
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
}
