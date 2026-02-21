import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Psalm1PrefaceWidget extends StatefulWidget {
  const Psalm1PrefaceWidget({super.key});

  @override
  State<Psalm1PrefaceWidget> createState() => _Psalm1PrefaceWidgetState();
}

class _Psalm1PrefaceWidgetState extends State<Psalm1PrefaceWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildIntroSection(),
          _buildTheJustSection(),
          _buildTheWickedSection(),
          _buildConclusionSection(),
        ],
      ),
    );
  }

  Widget _buildIntroSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background: Ancient Door/Open Book
        Image.network(
          'https://images.unsplash.com/photo-1544377193-33dcf4d68fb5?w=1600', // Ancient book/door vibe
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.6),
          colorBlendMode: BlendMode.darken,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text(
                  'SALMO 1',
                  style: GoogleFonts.cinzel(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                    letterSpacing: 8,
                  ).copyWith(shadows: [const Shadow(color: Colors.black, blurRadius: 20)]),
                ),
                Text(
                  'EL PREFACIO',
                  style: GoogleFonts.monsieurLaDoulaise(
                    fontSize: 60,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  '“El libro de los Salmos no comienza con m?sica…\nComienza con una decisi?n.”',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 32,
                    color: Colors.white,
                    height: 1.5,
                  ).copyWith(shadows: [const Shadow(color: Colors.black, blurRadius: 10)]),
                ),
                const SizedBox(height: 60),
                 const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTheJustSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background: Green Tree by Water
        Image.network(
          'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1600', // Lush tree/water
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.5),
           colorBlendMode: BlendMode.darken,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.green.withOpacity(0.2)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EL CAMINO DEL JUSTO',
                style: GoogleFonts.cinzel(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightGreenAccent,
                ).copyWith(shadows: [const Shadow(color: Colors.black, blurRadius: 15)]),
              ),
              const SizedBox(height: 30),
              _buildBulletPoint('No anda en consejo de malos'),
              _buildBulletPoint('Su delicia est? en la ley de Jehov?'),
              _buildBulletPoint('Medita en ella d?a y noche'),
              const SizedBox(height: 40),
              Text(
                '“Ser? como ?rbol plantado junto a corrientes de aguas...”',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ).copyWith(shadows: [const Shadow(color: Colors.black, blurRadius: 10)]),
              ),
              const SizedBox(height: 20),
              Text(
                'RESULTADO: Estabilidad • Fruto • Prosperidad Espiritual',
                 textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 24,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTheWickedSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background: Dry desert/Wind
        Image.network(
          'https://images.unsplash.com/photo-1516541196182-6bdb0516ed27?w=1600', // Dry/Desert/Wind
          fit: BoxFit.cover,
           color: Colors.black.withOpacity(0.6),
           colorBlendMode: BlendMode.darken,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.orangeAccent.withOpacity(0.1)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EL CAMINO DEL IMP?O',
                style: GoogleFonts.cinzel(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ).copyWith(shadows: [const Shadow(color: Colors.black, blurRadius: 15)]),
              ),
              const SizedBox(height: 30),
               _buildBulletPoint('No as? los malos...'),
              _buildBulletPoint('Como el tamo que arrebata el viento'),
              _buildBulletPoint('No se levantar?n en el juicio'),
              const SizedBox(height: 40),
              Text(
                '“Porque Jehov? conoce el camino de los justos; mas la senda de los malos perecer?.”',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ).copyWith(shadows: [const Shadow(color: Colors.black, blurRadius: 10)]),
              ),
               const SizedBox(height: 20),
               Text(
                'RESULTADO: Inestabilidad • Juicio • Separaci?n',
                 textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 24,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConclusionSection() {
     return Stack(
      fit: StackFit.expand,
      children: [
        // Background: Space/Eternity or Path
        Image.network(
          'https://images.unsplash.com/photo-1470229722913-7ea038629f55?w=1600', 
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
                '?EN QU? CAMINO EST?S?',
                style: GoogleFonts.cinzel(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ).copyWith(shadows: [const Shadow(color: Colors.redAccent, blurRadius: 20)]),
              ),
              const SizedBox(height: 40),
              Text(
                'El Salmo 1 es el filtro.',
                style: GoogleFonts.lato(fontSize: 30, color: Colors.white70),
              ),
               Text(
                'Sin santidad, ninguna m?sica es adoraci?n.',
                style: GoogleFonts.lato(fontSize: 30, color: Colors.white70),
              ),
              const SizedBox(height: 60),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                 decoration: BoxDecoration(
                   border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                   borderRadius: BorderRadius.circular(10),
                 ),
                 child: Text(
                   'DECIDE HOY',
                   style: GoogleFonts.cinzel(
                     fontSize: 40,
                     color: const Color(0xFFD4AF37),
                     fontWeight: FontWeight.bold,
                   ),
                 ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_right, color: Colors.white70, size: 30),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 24,
              color: Colors.white,
            ).copyWith(shadows: [const Shadow(color: Colors.black, blurRadius: 5)]),
          ),
        ],
      ),
    );
  }
}
