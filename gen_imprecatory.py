# -*- coding: utf-8 -*-
import os

a_ = chr(0xE1)
e_ = chr(0xE9)
i_ = chr(0xED)
o_ = chr(0xF3)
u_ = chr(0xFA)
n_ = chr(0xF1)
A_ = chr(0xC1)
E_ = chr(0xC9)
I_ = chr(0xCD)
O_ = chr(0xD3)
U_ = chr(0xDA)
N_ = chr(0xD1)
qm = chr(0xBF)
ex = chr(0xA1)
lq = chr(0xAB)
rq = chr(0xBB)
em = chr(0x2014)

content = f"""import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =============================================================================
/// SALMOS IMPRECATORIOS {em} WIDGET 3D INTERACTIVO PARA PROYECCI{O_}N
/// Instituto B{i_}blico Elim Internacional
/// =============================================================================
class ImprecatoryPsalmsWidget extends StatefulWidget {{
  final bool revealAnswers;

  const ImprecatoryPsalmsWidget({{
    super.key,
    this.revealAnswers = false,
  }});

  @override
  State<ImprecatoryPsalmsWidget> createState() =>
      _ImprecatoryPsalmsWidgetState();
}}

class _ImprecatoryPsalmsWidgetState extends State<ImprecatoryPsalmsWidget>
    with TickerProviderStateMixin {{
  int _currentPage = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _rotateController;

  // Datos de los 6 salmos imprecatorios principales
  final List<Map<String, String>> _psalms = [
    {{
      'number': '35',
      'title': 'Contra los enemigos injustos',
      'author': 'David',
      'verse': '{lq}Pelea, oh Jehov{a_}, contra los que me combaten; combate a los que me guerrean.{rq}',
      'reference': 'Salmo 35:1',
      'context': 'David enfrenta acusadores falsos que le pagan mal por bien. Clama a Dios como guerrero y defensor de la justicia.',
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=3840',
    }},
    {{
      'number': '58',
      'title': 'Contra los jueces corruptos',
      'author': 'David',
      'verse': '{lq}{qm}Es verdad que pronunci{a_}is justicia, oh congregaci{o_}n? {qm}Juzg{a_}is rectamente, hijos de los hombres?{rq}',
      'reference': 'Salmo 58:1',
      'context': 'Denuncia contra gobernantes y jueces que pervierten la justicia. Pide a Dios que intervenga contra la corrupci{o_}n.',
      'image': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=3840',
    }},
    {{
      'number': '69',
      'title': 'Clamor de angustia profunda',
      'author': 'David',
      'verse': '{lq}S{a_}lvame, oh Dios, porque las aguas han entrado hasta el alma.{rq}',
      'reference': 'Salmo 69:1',
      'context': 'Uno de los m{a_}s citados en el Nuevo Testamento. Profec{i_}a mesi{a_}nica del sufrimiento de Cristo.',
      'image': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=3840',
    }},
    {{
      'number': '83',
      'title': 'Contra las naciones enemigas',
      'author': 'Asaf',
      'verse': '{lq}Oh Dios, no guardes silencio; no calles, oh Dios, ni te est{e_}s quieto.{rq}',
      'reference': 'Salmo 83:1',
      'context': 'Oraci{o_}n colectiva contra una coalici{o_}n de naciones que buscan destruir a Israel.',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=3840',
    }},
    {{
      'number': '109',
      'title': 'El m{a_}s intenso {em} Contra el traidor',
      'author': 'David',
      'verse': '{lq}Oh Dios de mi alabanza, no calles; porque boca de imp{i_}o y boca de enga{n_}ador se han abierto contra m{i_}.{rq}',
      'reference': 'Salmo 109:1-2',
      'context': 'Considerado el m{a_}s intenso. Pedro lo aplica a Judas en Hechos 1:20.',
      'image': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=3840',
    }},
    {{
      'number': '137',
      'title': 'Lamento del exilio en Babilonia',
      'author': 'An{o_}nimo (ex{i_}lico)',
      'verse': '{lq}Junto a los r{i_}os de Babilonia, all{i_} nos sent{a_}bamos, y aun llor{a_}bamos, acord{a_}ndonos de Sion.{rq}',
      'reference': 'Salmo 137:1',
      'context': 'El dolor del pueblo exiliado. Claman justicia contra Babilonia y sus captores.',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=3840',
    }},
  ];

  @override
  void initState() {{
    super.initState();

    // Brillo pulsante
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Flotaci{o_}n 3D
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Rotaci{o_}n lenta para efecto 3D
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }}

  @override
  void dispose() {{
    _glowController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }}

  // P{a_}ginas: T{i_}tulo + Definici{o_}n + 6 Salmos + Nota David = 9
  int get _totalPages => 9;

  void _nextPage() {{
    if (_currentPage < _totalPages - 1) setState(() => _currentPage++);
  }}

  void _prevPage() {{
    if (_currentPage > 0) setState(() => _currentPage--);
  }}

  @override
  Widget build(BuildContext context) {{
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Scaffold(
          backgroundColor: const Color(0xFF080005),
          body: Stack(
            children: [
              // Fondo animado 3D con part{i_}culas
              _build3DBackground(),

              // Contenido de la p{a_}gina actual
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {{
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                }},
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentPage),
                  child: _buildCurrentPage(),
                ),
              ),

              // Navegaci{o_}n inferior
              _buildNavigationBar(),

              // Indicador lateral
              _buildPageIndicator(),
            ],
          ),
        ),
      ),
    );
  }}

  // ==========================================================================
  // FONDO 3D ANIMADO CON PART{I_}CULAS Y GRADIENT
  // ==========================================================================
  Widget _build3DBackground() {{
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {{
        return Stack(
          children: [
            // Gradiente base
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.3, -0.5),
                  radius: 1.8,
                  colors: [
                    Color(0xFF1A0008),
                    Color(0xFF080005),
                    Color(0xFF050002),
                  ],
                ),
              ),
            ),
            // Orbe luminoso flotante 3D
            Positioned(
              right: -80,
              top: -80,
              child: Transform.rotate(
                angle: _rotateController.value * 2 * pi,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.redAccent.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Segundo orbe
            Positioned(
              left: -100,
              bottom: -100,
              child: Transform.rotate(
                angle: -_rotateController.value * 2 * pi * 0.7,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFD4AF37).withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }},
    );
  }}

  Widget _buildCurrentPage() {{
    if (_currentPage == 0) return _buildTitlePage();
    if (_currentPage == 1) return _buildDefinitionPage();
    if (_currentPage >= 2 && _currentPage <= 7) {{
      return _buildPsalmPage(_psalms[_currentPage - 2]);
    }}
    return _buildDavidNotePage();
  }}

  // ==========================================================================
  // BARRA DE NAVEGACI{O_}N
  // ==========================================================================
  Widget _buildNavigationBar() {{
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.85),
              Colors.black.withOpacity(0.98),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _currentPage > 0
                ? _buildNavBtn(Icons.arrow_back_rounded, 'ANTERIOR', _prevPage, true)
                : const SizedBox(width: 200),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                '${{_currentPage + 1}} / $_totalPages',
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _currentPage < _totalPages - 1
                ? _buildNavBtn(Icons.arrow_forward_rounded, 'SIGUIENTE', _nextPage, false)
                : const SizedBox(width: 200),
          ],
        ),
      ),
    );
  }}

  Widget _buildNavBtn(IconData icon, String label, VoidCallback onTap, bool isBack) {{
    final color = isBack ? const Color(0xFFBFA67A) : Colors.redAccent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.25), color.withOpacity(0.10)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, spreadRadius: 2),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBack) Icon(icon, color: color, size: 30),
              if (isBack) const SizedBox(width: 10),
              Text(label, style: GoogleFonts.cinzel(
                fontSize: 20, fontWeight: FontWeight.bold, color: color, letterSpacing: 2,
              )),
              if (!isBack) const SizedBox(width: 10),
              if (!isBack) Icon(icon, color: color, size: 30),
            ],
          ),
        ),
      ),
    );
  }}

  Widget _buildPageIndicator() {{
    return Positioned(
      right: 20, top: 0, bottom: 80,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_totalPages, (i) {{
            final isActive = _currentPage == i;
            return GestureDetector(
              onTap: () => setState(() => _currentPage = i),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                width: isActive ? 16 : 10,
                height: isActive ? 16 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.redAccent : Colors.white24,
                  boxShadow: isActive
                      ? [BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 12)]
                      : null,
                ),
              ),
            );
          }}),
        ),
      ),
    );
  }}

  // ==========================================================================
  // P{A_}GINA 1: T{I_}TULO CON EFECTO 3D FLOTANTE
  // ==========================================================================
  Widget _buildTitlePage() {{
    return Center(
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {{
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value),
            child: child,
          );
        }},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // {I_}cono 3D con doble resplandor
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {{
                return Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.redAccent.withOpacity(_glowAnimation.value * 0.25),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(_glowAnimation.value * 0.4),
                        blurRadius: 80,
                        spreadRadius: 30,
                      ),
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(_glowAnimation.value * 0.15),
                        blurRadius: 120,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.gavel, size: 130, color: Colors.redAccent),
                );
              }},
            ),
            const SizedBox(height: 50),

            // T{i_}tulo con sombra 3D
            Text(
              'SALMOS\\nIMPRECATORIOS',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 88,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 5,
                height: 1.1,
              ).copyWith(shadows: [
                Shadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 40),
                const Shadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 6)),
                Shadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 80, offset: const Offset(0, 0)),
              ]),
            ),
            const SizedBox(height: 35),

            // L{i_}nea decorativa
            Container(
              width: 250,
              height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.transparent, Colors.redAccent, Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 35),

            Text(
              'JUSTICIA DIVINA EN EL SALTERIO',
              style: GoogleFonts.oswald(
                fontSize: 38,
                color: Colors.white38,
                letterSpacing: 10,
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Actividad Interactiva',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 30,
                color: Colors.redAccent.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }}

  // ==========================================================================
  // P{A_}GINA 2: DEFINICI{O_}N CON TARJETA 3D
  // ==========================================================================
  Widget _buildDefinitionPage() {{
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {{
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_floatAnimation.value * 0.003),
              alignment: Alignment.center,
              child: child,
            );
          }},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de libro
              const Icon(Icons.menu_book, size: 70, color: Colors.redAccent),
              const SizedBox(height: 30),

              Text(
                '{qm}QU{E_} SON?',
                style: GoogleFonts.cinzel(
                  fontSize: 62,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 45),

              // Tarjeta principal 3D
              Container(
                padding: const EdgeInsets.all(55),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF200808), Color(0xFF120404)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.25), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.12),
                      blurRadius: 40, spreadRadius: 5, offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 30, offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Los Salmos Imprecatorios son aquellos donde '
                      'el salmista clama a Dios pidiendo juicio, '
                      'justicia o castigo contra sus enemigos.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 40,
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 45),

                    // Caja destacada
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'No son deseos personales de venganza...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: 34,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'SON ORACIONES QUE ENTREGAN\\nLA JUSTICIA EN MANOS DE DIOS.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.oswald(
                              fontSize: 38,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              Text(
                'PRINCIPALES: SALMOS 35, 58, 69, 83, 109, 137',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: Colors.white30,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}

  // ==========================================================================
  // P{A_}GINAS 3-8: SALMOS INDIVIDUALES CON PERSPECTIVA 3D
  // ==========================================================================
  Widget _buildPsalmPage(Map<String, String> psalm) {{
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen de fondo
        Image.network(
          psalm['image']!,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.80),
          colorBlendMode: BlendMode.darken,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF120404)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 40),
            child: AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {{
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0008)
                    ..rotateY(_floatAnimation.value * 0.002),
                  alignment: Alignment.center,
                  child: child,
                );
              }},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // N{u_}mero gigante con resplandor 3D
                  AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {{
                      return Container(
                        padding: const EdgeInsets.all(35),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.redAccent.withOpacity(_glowAnimation.value * 0.15),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(_glowAnimation.value * 0.25),
                              blurRadius: 50, spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: Text(
                          psalm['number']!,
                          style: GoogleFonts.cinzel(
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ).copyWith(shadows: [
                            const Shadow(color: Colors.black, blurRadius: 25, offset: Offset(0, 8)),
                          ]),
                        ),
                      );
                    }},
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'SALMO ${{psalm['number']}}',
                    style: GoogleFonts.cinzel(
                      fontSize: 42,
                      color: Colors.white54,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    psalm['title']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 48,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ).copyWith(shadows: [
                      const Shadow(color: Colors.black, blurRadius: 15),
                    ]),
                  ),
                  const SizedBox(height: 35),

                  // Tarjeta del vers{i_}culo con cristal 3D
                  Container(
                    padding: const EdgeInsets.all(45),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.07),
                          Colors.white.withOpacity(0.02),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30, offset: const Offset(0, 18),
                        ),
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.05),
                          blurRadius: 40, spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.format_quote, color: Colors.redAccent, size: 44),
                        const SizedBox(height: 20),
                        Text(
                          psalm['verse']!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '{em} ${{psalm['reference']}}',
                          style: GoogleFonts.cinzel(
                            fontSize: 26,
                            color: Colors.redAccent.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Contexto
                  Text(
                    psalm['context']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 34,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Insignia autor
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, color: Colors.white38, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Autor: ${{psalm['author']}}',
                          style: GoogleFonts.lato(
                            fontSize: 26,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }}

  // ==========================================================================
  // P{A_}GINA 9: NOTA SOBRE DAVID
  // ==========================================================================
  Widget _buildDavidNotePage() {{
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) {{
            return Transform.translate(
              offset: Offset(0, _floatAnimation.value * 0.5),
              child: child,
            );
          }},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // {I_}cono con resplandor dorado
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {{
                  return Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: 50,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lightbulb_outline,
                        size: 90, color: Color(0xFFD4AF37)),
                  );
                }},
              ),
              const SizedBox(height: 35),

              Text(
                'NOTA IMPORTANTE',
                style: GoogleFonts.cinzel(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 45),

              Container(
                padding: const EdgeInsets.all(55),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2A1A00).withOpacity(0.5),
                      const Color(0xFF1A0A00).withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.25), width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.08),
                      blurRadius: 40, spreadRadius: 5, offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30, offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Muchos de los salmos imprecatorios fueron '
                      'escritos por David, quien sufri{o_} persecuci{o_}n '
                      'y traici{o_}n. Como rey ungido por Dios, sus '
                      'oraciones no eran venganza personal, sino '
                      'apelaciones al Juez supremo.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 38,
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: 160, height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.transparent, Color(0xFFD4AF37), Colors.transparent],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '{lq}M{i_}a es la venganza, yo pagar{e_}, dice el Se{n_}or.{rq}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 38,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '{em} Romanos 12:19',
                      style: GoogleFonts.cinzel(
                        fontSize: 24,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }}
}}
"""

filepath = os.path.join(
    r'c:\\Users\\mmmpc\\OneDrive\\Escritorio\\clases libro sapienciales',
    'frontend', 'lib', 'widgets', 'imprecatory_psalms_widget.dart'
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Written: {{len(lines)}} lines")
for i, line in enumerate(lines):
    if any(w in line for w in ['Jehov', 'IMPRECATORIO', 'venganza', 'SIGUIENTE', 'fontSize: 88', 'fontSize: 12']):
        print(f"  L{{i+1}}: {{line.rstrip()[:95]}}")
        if i > 50: break
