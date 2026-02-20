import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PsalmsAuthorsWidget extends StatefulWidget {
  const PsalmsAuthorsWidget({super.key});

  @override
  State<PsalmsAuthorsWidget> createState() => _PsalmsAuthorsWidgetState();
}

class _PsalmsAuthorsWidgetState extends State<PsalmsAuthorsWidget> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<AuthorData> _authors = [
    AuthorData(
      name: 'David',
      title: '“Bien amado”',
      // Cinematic: Man silhouette in desert/nature or harp concept
      image: 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=1600', 
      bio: 'Segundo rey de Israel, pastor y músico. Vencedor de Goliat y varón conforme al corazón de Dios.',
      details: [
        'Pastor de ovejas en su juventud.',
        'Músico experto (arpa) y Poeta.',
        'Guerrero que venció a Goliat.',
        'Sufrió persecución bajo Saúl.',
        'Pecado con Betsabé y arrepentimiento (Salmo 51).'
      ],
      legacy: 'Estableció la adoración en Jerusalén. ~74 salmos atribuidos.',
      verse: '“Crea en mí, oh Dios, un corazón limpio...” (Salmo 51:10)',
    ),
    AuthorData(
      name: 'Moisés',
      title: 'Libertador de Israel',
      // Cinematic: Desert mountains/Sinai vibe
      image: 'https://images.unsplash.com/photo-1508609594689-5c742c31c77f?w=1600', 
      bio: 'Legislador, profeta y líder del Éxodo. Habló cara a cara con Dios.',
      details: [
        '40 años en el desierto.',
        'Autor del Salmo 90 (el más antiguo).',
        'Intercesor incansable por Israel.'
      ],
      legacy: 'Fundamento de la fe. Su salmo contrasta la eternidad de Dios con la fragilidad humana.',
      verse: '“Señor, tú has sido nuestro refugio...” (Salmo 90:1)',
    ),
    AuthorData(
      name: 'Salomón',
      title: '“Pacífico”',
      // Cinematic: Ancient architecture/Gold
      image: 'https://images.unsplash.com/photo-1575883209867-270830421e4d?w=1600', 
      bio: 'Tercer rey de Israel. Constructor del Templo. Sabiduría extraordinaria.',
      details: [
        'Construyó el Primer Templo.',
        'Escribió Proverbios y Cantares.',
        'Prosperidad sin precedentes.'
      ],
      legacy: 'Llevó a Israel a su apogeo. Salmos 72 y 127.',
      verse: '“Si Jehová no edificare la casa...” (Salmo 127:1)',
    ),
    AuthorData(
      name: 'Asaf',
      title: '“Recolector”',
      // Cinematic: Ancient music/Levites concept (Light entering dark space)
      image: 'https://images.unsplash.com/photo-1470229722913-7ea038629f55?w=1600', 
      bio: 'Levita, director del coro en tiempos de David. "Vidente".',
      details: [
        'Descendiente de Gersón.',
        'Líder de adoración en el Templo.',
        'Enfocado en la justicia de Dios.'
      ],
      legacy: 'Fundó un gremio de cantores. Salmos 50, 73-83.',
      verse: '“¿A quién tengo yo en los cielos sino a ti?...” (Salmo 73:25)',
    ),
    AuthorData(
      name: 'Hijos de Coré',
      title: 'Levitas Fieles',
      // Cinematic: Water/Nature (Psalm 42)
      image: 'https://images.unsplash.com/photo-1518176258769-f227c798150e?w=1600', 
      bio: 'Músicos del templo. Eligieron la fidelidad sobre la rebelión de su padre.',
      details: [
        'Porteros y cantores.',
        'No murieron en la rebelión de Coré.',
        'Salmos profundos y nostálgicos.'
      ],
      legacy: 'Salmos 42, 44-49, 84-87. Anhelo por Dios.',
      verse: '“Como el ciervo brama por las aguas...” (Salmo 42:1)',
    ),
    AuthorData(
      name: 'Hemán',
      title: 'El Ezranita',
      // Cinematic: Dark/Sorrowful but hopeful (Psalm 88)
      image: 'https://images.unsplash.com/photo-1516541196182-6bdb0516ed27?w=1600', 
      bio: 'Sabio y cantor levita. Nieto de Samuel. Hombre de oración en aflicción.',
      details: [
        'Líder de cantores coatitas.',
        'Autor del Salmo 88 (el más oscuro).',
        'Oración constante.'
      ],
      legacy: 'Fe en medio de la oscuridad absoluta.',
      verse: '“Oh Jehová... día y noche clamo delante de ti.” (Salmo 88:1)',
    ),
    AuthorData(
      name: 'Etán',
      title: 'El Ezranita',
      // Cinematic: Wisdom/Light
      image: 'https://images.unsplash.com/photo-1444703686981-a3abbc4d4fe3?w=1600', 
      bio: 'Levita y director musical. Sabiduría comparable a Salomón.',
      details: [
        'Mencionado por su sabiduría (1 Reyes 4:31).',
        'Cantor con címbalos.',
        'Autor del Salmo 89.'
      ],
      legacy: 'Canta sobre el pacto y la fidelidad de Dios.',
      verse: '“Las misericordias de Jehová cantaré perpetuamente.” (Salmo 89:1)',
    ),
    AuthorData(
      name: 'La Restauración',
      title: 'Hageo, Zacarías, Esdras',
      // Cinematic: Ruins/Rebuilding/Stones
      image: 'https://images.unsplash.com/photo-1590625327299-add664d42df7?w=1600', 
      bio: 'Líderes post-exílicos. Restauraron el Templo y la Ley.',
      details: [
        'Hageo: Profeta de la reconstrucción.',
        'Zacarías: Levita, músico y profeta.',
        'Esdras: Sacerdote, enseñó la Ley.'
      ],
      legacy: 'Aseguraron la alabanza tras el exilio.',
      verse: '“Esdras había preparado su corazón...” (Esdras 7:10)',
    ),
    AuthorData(
      name: 'Ezequías',
      title: '“Jehová fortalece”',
      // Cinematic: King/Scroll/Reform
      image: 'https://images.unsplash.com/photo-1507842217121-fe83214c7764?w=1600', 
      bio: 'Rey reformador. Restauró la adoración verdadera.',
      details: [
        'Destruyó los ídolos.',
        'Restauró la pascua.',
        'Recopiló escritos sagrados.'
      ],
      legacy: 'Preservó el Salterio para el culto.',
      verse: '“Lo hizo de todo corazón, y fue prosperado.” (2 Cró 31:21)',
    ),
    AuthorData(
      name: 'Jedutún',
      title: '“Elogiador”',
      // Cinematic: Worship/Hands/Dark background
      image: 'https://images.unsplash.com/photo-1502471602540-79a838e55e51?w=1600', 
      bio: 'Director musical principal de David (con Asaf y Hemán).',
      details: [
        'Dirigía con címbalos.',
        'Mencionado en Salmos 39, 62, 77.',
        'Familia de porteros.'
      ],
      legacy: 'Su estilo perduró generaciones.',
      verse: '“En Dios solamente está callada mi alma...” (Salmo 62:1)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image with Transitions and Dark Overlay
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              key: ValueKey(_currentIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_authors[_currentIndex].image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.black.withOpacity(0.5), // Center lighter
                      Colors.black.withOpacity(0.9), // Edges darker
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _authors.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final author = _authors[index];
              return Center( // CENTERING CONTENT
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center, // CENTER ALIGNMENT
                      children: [
                        // Header Section
                        Text(
                          author.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: 90,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE6C200),
                            letterSpacing: 5,
                          ).copyWith(
                            shadows: [
                              const Shadow(color: Colors.black, blurRadius: 15, offset: Offset(0, 5)),
                            ],
                          ),
                        ),
                        Text(
                          author.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 58,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300,
                          ).copyWith(
                             shadows: [
                              const Shadow(color: Colors.black, blurRadius: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Divider
                        Container(
                          width: 150,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6C200),
                            boxShadow: [BoxShadow(color: Color(0xFFE6C200), blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Bio
                        Text(
                          author.bio,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 40,
                            color: Colors.white,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ).copyWith(
                            shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Details (Centered List)
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: author.details.map((detail) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "• $detail",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 34,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            )).toList(),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Legacy & Verse
                        Text(
                          "LEGADO: ${author.legacy}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cinzel(
                            fontSize: 32,
                            color: const Color(0xFFE6C200),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          author.verse,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 38,
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Navigation Indicators
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_authors.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? const Color(0xFFD4AF37) : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          
          // Navigation Arrows
          Positioned(
            right: 20,
            bottom: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white54),
              onPressed: () {
                if (_currentIndex < _authors.length - 1) {
                  _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                }
              },
            ),
          ),
           Positioned(
            left: 20,
            bottom: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
              onPressed: () {
                if (_currentIndex > 0) {
                  _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AuthorData {
  final String name;
  final String title;
  final String image;
  final String bio;
  final List<String> details;
  final String legacy;
  final String verse;

  AuthorData({
    required this.name,
    required this.title,
    required this.image,
    required this.bio,
    required this.details,
    required this.legacy,
    required this.verse,
  });
}
