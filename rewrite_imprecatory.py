# -*- coding: utf-8 -*-
import os

# UTF-8 character helpers
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

content = f"""import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =============================================================================
/// SALMOS IMPRECATORIOS {chr(0x2014)} DISE{N_}O 3D MODERNO PARA PROYECCI{O_}N
/// Navegaci{o_}n con botones SIGUIENTE/ANTERIOR (sin scroll inestable)
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
    with SingleTickerProviderStateMixin {{
  int _currentPage = 0;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Datos de los salmos imprecatorios principales
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
      'context': 'Uno de los m{a_}s citados en el Nuevo Testamento. Profec{i_}a mesi{a_}nica del sufrimiento de Cristo. Clamor desde la profundidad del dolor.',
      'image': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=3840',
    }},
    {{
      'number': '83',
      'title': 'Contra las naciones enemigas',
      'author': 'Asaf',
      'verse': '{lq}Oh Dios, no guardes silencio; no calles, oh Dios, ni te est{e_}s quieto.{rq}',
      'reference': 'Salmo 83:1',
      'context': 'Oraci{o_}n colectiva contra una coalici{o_}n de naciones que buscan destruir a Israel. Apela a las victorias divinas del pasado.',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=3840',
    }},
    {{
      'number': '109',
      'title': 'El m{a_}s intenso {chr(0x2014)} Contra el traidor',
      'author': 'David',
      'verse': '{lq}Oh Dios de mi alabanza, no calles; porque boca de imp{i_}o y boca de enga{n_}ador se han abierto contra m{i_}.{rq}',
      'reference': 'Salmo 109:1-2',
      'context': 'Considerado el salmo imprecatorio m{a_}s intenso. David clama contra quien lo traicion{o_}. Pedro lo aplica a Judas en Hechos 1:20.',
      'image': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=3840',
    }},
    {{
      'number': '137',
      'title': 'Lamento del exilio en Babilonia',
      'author': 'An{o_}nimo (ex{i_}lico)',
      'verse': '{lq}Junto a los r{i_}os de Babilonia, all{i_} nos sent{a_}bamos, y aun llor{a_}bamos, acord{a_}ndonos de Sion.{rq}',
      'reference': 'Salmo 137:1',
      'context': 'El dolor del pueblo exiliado. Rechazan cantar los c{a_}nticos de Dios para entretenimiento de sus captores. Claman justicia contra Babilonia.',
      'image': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=3840',
    }},
  ];

  // Datos de la actividad clasificatoria
  final List<Map<String, dynamic>> _activityItems = [
    {{
      'text': '{lq}Lev{a_}ntate, oh Se{n_}or; defi{e_}ndeme; pelea contra los que me combaten.{rq}',
      'answer': 'IMPRECATORIO',
      'color': Colors.redAccent,
      'reference': 'Salmo 35',
    }},
    {{
      'text': '{lq}Ten misericordia de m{i_}, oh Dios, porque en ti ha confiado mi alma.{rq}',
      'answer': 'LAMENTO',
      'color': Colors.blueAccent,
      'reference': 'Salmo 57',
    }},
    {{
      'text': '{lq}Alabad al Se{n_}or porque {e_}l es bueno; porque para siempre es su misericordia.{rq}',
      'answer': 'ALABANZA',
      'color': Colors.greenAccent,
      'reference': 'Salmo 136',
    }},
    {{
      'text': '{lq}Sean avergonzados y turbados todos los que se alegran de mi mal.{rq}',
      'answer': 'IMPRECATORIO',
      'color': Colors.redAccent,
      'reference': 'Salmo 40',
    }},
    {{
      'text': '{lq}{qm}Hasta cu{a_}ndo, Se{n_}or, me olvidar{a_}s para siempre?{rq}',
      'answer': 'LAMENTO',
      'color': Colors.blueAccent,
      'reference': 'Salmo 13',
    }},
  ];

  @override
  void initState() {{
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }}

  @override
  void dispose() {{
    _glowController.dispose();
    super.dispose();
  }}

  // Total de p{a_}ginas: t{i_}tulo + definici{o_}n + 6 salmos + nota David + intro actividad + 5 ejercicios = 15
  int get _totalPages => 2 + _psalms.length + 1 + 1 + _activityItems.length;

  void _nextPage() {{
    if (_currentPage < _totalPages - 1) {{
      setState(() => _currentPage++);
    }}
  }}

  void _prevPage() {{
    if (_currentPage > 0) {{
      setState(() => _currentPage--);
    }}
  }}

  @override
  Widget build(BuildContext context) {{
    return Scaffold(
      backgroundColor: const Color(0xFF0A0000),
      body: Stack(
        children: [
          // Contenido de la p{a_}gina actual con animaci{o_}n
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {{
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
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

          // Barra de navegaci{o_}n inferior
          _buildNavigationBar(),

          // Indicador de p{a_}gina lateral
          _buildPageIndicator(),
        ],
      ),
    );
  }}

  Widget _buildCurrentPage() {{
    if (_currentPage == 0) return _buildTitlePage();
    if (_currentPage == 1) return _buildDefinitionPage();
    if (_currentPage >= 2 && _currentPage < 2 + _psalms.length) {{
      return _buildPsalmPage(_psalms[_currentPage - 2]);
    }}
    if (_currentPage == 2 + _psalms.length) return _buildDavidNotePage();
    if (_currentPage == 3 + _psalms.length) return _buildActivityIntro();
    final actIdx = _currentPage - 4 - _psalms.length;
    if (actIdx >= 0 && actIdx < _activityItems.length) {{
      return _buildActivityItem(actIdx, _activityItems[actIdx]);
    }}
    return const SizedBox.shrink();
  }}

  // ==========================================================================
  // BARRA DE NAVEGACI{O_}N INFERIOR (ANTERIOR / SIGUIENTE)
  // ==========================================================================
  Widget _buildNavigationBar() {{
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.95),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bot{o_}n ANTERIOR
            _currentPage > 0
                ? _buildNavButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'ANTERIOR',
                    onTap: _prevPage,
                    isBack: true,
                  )
                : const SizedBox(width: 200),

            // Contador de p{a_}ginas
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
                  fontSize: 22,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Bot{o_}n SIGUIENTE
            _currentPage < _totalPages - 1
                ? _buildNavButton(
                    icon: Icons.arrow_forward_rounded,
                    label: 'SIGUIENTE',
                    onTap: _nextPage,
                    isBack: false,
                  )
                : const SizedBox(width: 200),
          ],
        ),
      ),
    );
  }}

  Widget _buildNavButton({{
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isBack,
  }}) {{
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
              colors: [
                color.withOpacity(0.25),
                color.withOpacity(0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBack) Icon(icon, color: color, size: 30),
              if (isBack) const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
              if (!isBack) const SizedBox(width: 10),
              if (!isBack) Icon(icon, color: color, size: 30),
            ],
          ),
        ),
      ),
    );
  }}

  // ==========================================================================
  // INDICADOR DE P{A_}GINA LATERAL
  // ==========================================================================
  Widget _buildPageIndicator() {{
    return Positioned(
      right: 20,
      top: 0,
      bottom: 80,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_totalPages, (index) {{
            final isActive = _currentPage == index;
            return GestureDetector(
              onTap: () => setState(() => _currentPage = index),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                width: isActive ? 16 : 10,
                height: isActive ? 16 : 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.redAccent : Colors.white24,
                  boxShadow: isActive
                      ? [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 10)]
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
  // P{A_}GINA DE T{I_}TULO
  // ==========================================================================
  Widget _buildTitlePage() {{
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1533613220915-609f661a6fe1?w=3840',
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.75),
          colorBlendMode: BlendMode.darken,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A0505)),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // {I_}cono con efecto de resplandor 3D
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {{
                  return Container(
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.redAccent.withOpacity(_glowAnimation.value * 0.3),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 70,
                          spreadRadius: 25,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.gavel, size: 120, color: Colors.redAccent),
                  );
                }},
              ),
              const SizedBox(height: 45),
              Text(
                'SALMOS\\nIMPRECATORIOS',
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  fontSize: 90,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 6,
                  height: 1.1,
                ).copyWith(
                  shadows: [
                    const Shadow(color: Colors.redAccent, blurRadius: 30),
                    const Shadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 5)),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              Container(
                width: 220,
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
                  color: Colors.white54,
                  letterSpacing: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }}

  // ==========================================================================
  // P{A_}GINA DE DEFINICI{O_}N
  // ==========================================================================
  Widget _buildDefinitionPage() {{
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0505), Color(0xFF0A0000), Color(0xFF150000)],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tarjeta 3D con elevaci{o_}n
                Container(
                  padding: const EdgeInsets.all(55),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2A0A0A), Color(0xFF1A0505)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.15),
                        blurRadius: 40, spreadRadius: 5, offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 30, offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '{qm}QU{E_} SON?',
                        style: GoogleFonts.cinzel(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 45),
                      Text(
                        'Los Salmos Imprecatorios son oraciones donde '
                        'el salmista clama a Dios pidiendo juicio y '
                        'justicia contra sus enemigos y opresores.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 40,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 45),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          'NO SON VENGANZA PERSONAL.\\n'
                          'SON APELACIONES A LA JUSTICIA DIVINA.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.oswald(
                            fontSize: 36,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
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
                    fontSize: 30,
                    color: Colors.white38,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }}

  // ==========================================================================
  // P{A_}GINA INDIVIDUAL DE SALMO
  // ==========================================================================
  Widget _buildPsalmPage(Map<String, String> psalm) {{
    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen de fondo b{i_}blica
        Image.network(
          psalm['image']!,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.78),
          colorBlendMode: BlendMode.darken,
          errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1A0505)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // N{u_}mero del salmo con efecto 3D
                Container(
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.redAccent.withOpacity(0.2),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.3),
                        blurRadius: 40, spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    psalm['number']!,
                    style: GoogleFonts.cinzel(
                      fontSize: 110,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ).copyWith(
                      shadows: [
                        const Shadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'SALMO ${{psalm['number']}}',
                  style: GoogleFonts.cinzel(
                    fontSize: 40,
                    color: Colors.white54,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  psalm['title']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 46,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ).copyWith(
                    shadows: [const Shadow(color: Colors.black, blurRadius: 15)],
                  ),
                ),
                const SizedBox(height: 35),

                // Tarjeta del vers{i_}culo con efecto 3D
                Container(
                  padding: const EdgeInsets.all(45),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30, offset: const Offset(0, 15),
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
                          fontSize: 40,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '{chr(0x2014)} ${{psalm['reference']}}',
                        style: GoogleFonts.cinzel(
                          fontSize: 26,
                          color: Colors.redAccent.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Contexto hist{o_}rico
                Text(
                  psalm['context']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 34,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Insignia del autor
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    'Autor: ${{psalm['author']}}',
                    style: GoogleFonts.lato(
                      fontSize: 26,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }}

  // ==========================================================================
  // NOTA SOBRE DAVID
  // ==========================================================================
  Widget _buildDavidNotePage() {{
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A00), Color(0xFF0A0000)],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline, size: 90, color: Color(0xFFD4AF37)),
                const SizedBox(height: 35),
                Text(
                  'NOTA IMPORTANTE',
                  style: GoogleFonts.cinzel(
                    fontSize: 54,
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
                        const Color(0xFF2A1A00).withOpacity(0.6),
                        const Color(0xFF1A0A00).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        blurRadius: 40, spreadRadius: 5, offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'David es el autor principal de los salmos '
                        'imprecatorios. Como rey ungido por Dios, '
                        'sus oraciones no eran venganza personal, '
                        'sino apelaciones al Juez supremo pidiendo '
                        'que se cumpliera la justicia divina.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 38,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 35),
                      Container(
                        width: 160,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.transparent, Color(0xFFD4AF37), Colors.transparent],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 35),
                      Text(
                        '{lq}M{i_}a es la venganza, yo pagar{e_}, dice el Se{n_}or.{rq}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 36,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '{chr(0x2014)} Romanos 12:19',
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
      ],
    );
  }}

  // ==========================================================================
  // INTRODUCCI{O_}N DE ACTIVIDAD
  // ==========================================================================
  Widget _buildActivityIntro() {{
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0000), Color(0xFF000000)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orangeAccent.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.3),
                    blurRadius: 50, spreadRadius: 15,
                  ),
                ],
              ),
              child: const Icon(Icons.touch_app, size: 110, color: Colors.orangeAccent),
            ),
            const SizedBox(height: 45),
            Text(
              'ACTIVIDAD',
              style: GoogleFonts.cinzel(
                fontSize: 68,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'CLASIFICA EL TEXTO',
              style: GoogleFonts.oswald(
                fontSize: 44,
                color: Colors.orangeAccent,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 55),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryBadge('IMPRECATORIO', Colors.redAccent),
                const SizedBox(width: 30),
                _buildCategoryBadge('LAMENTO', Colors.blueAccent),
                const SizedBox(width: 30),
                _buildCategoryBadge('ALABANZA', Colors.greenAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }}

  Widget _buildCategoryBadge(String text, Color color) {{
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 28,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }}

  // ==========================================================================
  // EJERCICIO INDIVIDUAL
  // ==========================================================================
  Widget _buildActivityItem(int index, Map<String, dynamic> item) {{
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF101010), Color(0xFF050505)],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EJERCICIO ${{index + 1}}',
                  style: GoogleFonts.oswald(
                    fontSize: 34,
                    color: Colors.white24,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 50),

                // Tarjeta de cita con efecto 3D
                Container(
                  padding: const EdgeInsets.all(55),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30, offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.format_quote, color: Colors.white24, size: 40),
                      const SizedBox(height: 24),
                      Text(
                        item['text'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 46,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                if (!widget.revealAnswers)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'Esperando orden del docente para revelar',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 30,
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 26),
                        decoration: BoxDecoration(
                          color: item['color'] as Color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (item['color'] as Color).withOpacity(0.6),
                              blurRadius: 40, spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          item['answer'],
                          style: GoogleFonts.oswald(
                            fontSize: 62,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Pertenece al ${{item['reference']}}',
                        style: GoogleFonts.lato(
                          fontSize: 32,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }}
}}
"""

filepath = os.path.join(
    r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales',
    'frontend', 'lib', 'widgets', 'imprecatory_psalms_widget.dart'
)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

# Verify
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"Written: {{len(lines)}} lines")
# Check some accented content
for i, line in enumerate(lines):
    if any(w in line for w in ['Jehov', 'DISE', 'venganza', 'Mois', 'naci']):
        print(f"  L{{i+1}}: {{line.rstrip()[:100]}}")
        if i > 25: break
