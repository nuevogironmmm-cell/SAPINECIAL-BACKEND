# -*- coding: utf-8 -*-
# Adds 2 new pages to proverbs_widget.dart:
#   Page 7: Forma Literaria y Caracteristicas
#   Page 8: Temas Ampliados
import os

widget_path = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    'frontend', 'lib', 'widgets', 'proverbs_widget.dart'
)

with open(widget_path, 'r', encoding='utf-8') as f:
    code = f.read()

# 1) Change _totalPages = 7 to 9
code = code.replace('final int _totalPages = 7;', 'final int _totalPages = 9;')

# 2) Add cases 7 and 8 to switch
code = code.replace(
    "      case 6: return _buildMujerVirtuosa();\n      default: return _buildPortada();",
    "      case 6: return _buildMujerVirtuosa();\n"
    "      case 7: return _buildFormaLiteraria();\n"
    "      case 8: return _buildTemasAmpliados();\n"
    "      default: return _buildPortada();"
)

# 3) Build the two new methods
lines = []
def w(s=''):
    lines.append(s)

# ===================================================================
# PAGE 7: FORMA LITERARIA Y CARACTERISTICAS
# ===================================================================
w()
w("  Widget _buildFormaLiteraria() {")
w("    return SingleChildScrollView(")
w("      key: const ValueKey('p7'),")
w("      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),")
w("      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w(f"        _buildSectionHeader('6', 'FORMA LITERARIA', Icons.format_quote_rounded),")
w("        const SizedBox(height: 30),")
# Intro card
w("        Container(")
w("          width: double.infinity,")
w("          padding: const EdgeInsets.all(30),")
w("          decoration: BoxDecoration(")
w("            gradient: LinearGradient(colors: [")
w("              const Color(0xFF1A237E).withValues(alpha: 0.5),")
w("              const Color(0xFF283593).withValues(alpha: 0.2),")
w("            ]),")
w("            borderRadius: BorderRadius.circular(24),")
w("            border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4), width: 2),")
w("            boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.3), blurRadius: 30)],")
w("          ),")
w("          child: Row(children: [")
w("            const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFD54F), size: 56),")
w("            const SizedBox(width: 24),")
w("            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w(f"              Text('El libro se presenta en forma po{chr(233)}tica.',")
w(f"                style: GoogleFonts.playfairDisplay(fontSize: 32, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5)),")
w("              const SizedBox(height: 10),")
w(f"              Text('Su contenido no admite un an{chr(225)}lisis ordenado.',")
w(f"                style: GoogleFonts.lato(fontSize: 26, color: Colors.white70, height: 1.4)),")
w("            ])),")
w("          ]),")
w("        ),")
w("        const SizedBox(height: 36),")
# 5 classes title
w(f"        Text('Cinco clases de caracter{chr(237)}sticas:', style: GoogleFonts.cinzel(fontSize: 36, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),")
w("        const SizedBox(height: 20),")
# The 5 classes
classes_data = [
    (f'Hist{chr(243)}ricas', 'Icons.history_edu_rounded', '0xFF1E88E5', f'Proverbios basados en hechos y experiencias del pueblo de Israel.'),
    (f'Metaf{chr(243)}ricas', 'Icons.compare_arrows_rounded', '0xFF43A047', f'Uso de im{chr(225)}genes y figuras para transmitir verdades espirituales.'),
    ('Enigmas', 'Icons.help_outline_rounded', '0xFFFF8F00', f'Dichos misteriosos que requieren reflexi{chr(243)}n profunda para comprenderlos.'),
    (f'Parab{chr(243)}licas', 'Icons.auto_awesome_rounded', '0xFF7B1FA2', f'Ense{chr(241)}anzas narradas como breves historias o comparaciones.'),
    (f'Did{chr(225)}cticas', 'Icons.school_rounded', '0xFFE53935', f'Instrucci{chr(243)}n directa con fines educativos y morales.'),
]
for i, (name, icon, color, desc) in enumerate(classes_data, 1):
    w(f"        _buildClassItem({i}, '{name}', {icon}, Color({color}), '{desc}'),")
    w("        const SizedBox(height: 12),")
w("        const SizedBox(height: 24),")
# Other literary characteristics
w(f"        Text('Otras caracter{chr(237)}sticas literarias:', style: GoogleFonts.cinzel(fontSize: 32, color: Color(0xFFFFD54F), fontWeight: FontWeight.bold)),")
w("        const SizedBox(height: 20),")
w("        Wrap(spacing: 16, runSpacing: 14, alignment: WrapAlignment.center, children: [")
lit_chars = ['Poemas', f'Par{chr(225)}bolas', 'Preguntas directas', 'Verbos pareados',
             f'Ant{chr(237)}tesis', f'Comparaci{chr(243)}n', f'Personificaci{chr(243)}n']
for ch in lit_chars:
    w(f"          _buildLiteraryChip('{ch}'),")
w("        ]),")
w("      ]),")
w("    );")
w("  }")
w()

# Helper: _buildClassItem
w("  Widget _buildClassItem(int number, String title, IconData icon, Color accent, String description) {")
w("    return Container(")
w("      width: double.infinity,")
w("      padding: const EdgeInsets.all(22),")
w("      decoration: BoxDecoration(")
w("        gradient: LinearGradient(colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)]),")
w("        borderRadius: BorderRadius.circular(20),")
w("        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),")
w("      ),")
w("      child: Row(children: [")
# Number circle
w("        Container(")
w("          width: 52, height: 52,")
w("          decoration: BoxDecoration(")
w("            shape: BoxShape.circle,")
w("            color: accent.withValues(alpha: 0.2),")
w("            border: Border.all(color: accent, width: 2),")
w("          ),")
w("          child: Center(child: Text('$number', style: GoogleFonts.orbitron(fontSize: 24, color: accent, fontWeight: FontWeight.bold))),")
w("        ),")
w("        const SizedBox(width: 20),")
w("        Icon(icon, color: accent, size: 36),")
w("        const SizedBox(width: 16),")
w("        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w("          Text(title, style: GoogleFonts.cinzel(fontSize: 28, color: accent, fontWeight: FontWeight.bold)),")
w("          const SizedBox(height: 4),")
w("          Text(description, style: GoogleFonts.lato(fontSize: 22, color: Colors.white70, height: 1.3)),")
w("        ])),")
w("      ]),")
w("    );")
w("  }")
w()

# Helper: _buildLiteraryChip
w("  Widget _buildLiteraryChip(String text) {")
w("    return AnimatedBuilder(")
w("      animation: _pulseAnimation,")
w("      builder: (_, __) => Transform.scale(")
w("        scale: _pulseAnimation.value,")
w("        child: Container(")
w("          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),")
w("          decoration: BoxDecoration(")
w("            gradient: LinearGradient(colors: [")
w("              const Color(0xFF00BCD4).withValues(alpha: 0.25),")
w("              const Color(0xFF0097A7).withValues(alpha: 0.12),")
w("            ]),")
w("            borderRadius: BorderRadius.circular(30),")
w("            border: Border.all(color: const Color(0xFF00BCD4).withValues(alpha: 0.5), width: 2),")
w("            boxShadow: [BoxShadow(color: const Color(0xFF00BCD4).withValues(alpha: 0.12), blurRadius: 12)],")
w("          ),")
w("          child: Row(mainAxisSize: MainAxisSize.min, children: [")
w("            const Icon(Icons.edit_note_rounded, color: Color(0xFF00BCD4), size: 24),")
w("            const SizedBox(width: 8),")
w("            Text(text, style: GoogleFonts.lato(fontSize: 24, color: Color(0xFF00BCD4), fontWeight: FontWeight.bold)),")
w("          ]),")
w("        ),")
w("      ),")
w("    );")
w("  }")

# ===================================================================
# PAGE 8: TEMAS AMPLIADOS
# ===================================================================
w()
w("  Widget _buildTemasAmpliados() {")
w("    return SingleChildScrollView(")
w("      key: const ValueKey('p8'),")
w("      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),")
w("      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w(f"        _buildSectionHeader('7', 'TEMAS DEL LIBRO', Icons.library_books_rounded),")
w("        const SizedBox(height: 30),")
# Themes grid - all topics with references
themes_amp = [
    (f'Juventud y disciplina', 'Pr. 15:32; 20:11; 29:15', 'Icons.escalator_warning_rounded', '0xFF1E88E5'),
    ('Vida familiar', 'Pr. 13:1; 20:20', 'Icons.family_restroom_rounded', '0xFFE91E63'),
    ('Dominio propio', 'Pr. 21:23', 'Icons.self_improvement_rounded', '0xFF43A047'),
    (f'Resistencia a la tentaci{chr(243)}n', 'Pr. 20:19; 22:3', 'Icons.shield_rounded', '0xFFFF8F00'),
    ('Asuntos de negocios', 'Pr. 31:18', 'Icons.store_rounded', '0xFF7B1FA2'),
    ('Palabras y lenguas', 'Pr. 15:24', 'Icons.record_voice_over_rounded', '0xFF00BCD4'),
    ('Conocimiento de Dios', 'Pr. 9:10', 'Icons.church_rounded', '0xFFFFD54F'),
    ('Matrimonio', 'Pr. 18:22', 'Icons.favorite_rounded', '0xFFE53935'),
    (f'B{chr(250)}squeda de la verdad', 'Pr. 8:7', 'Icons.search_rounded', '0xFF26A69A'),
    ('Riqueza y pobreza', 'Pr. 8:18', 'Icons.account_balance_rounded', '0xFFFF7043'),
    ('Inmoralidad', 'Pr. 6:12-15', 'Icons.warning_rounded', '0xFFAB47BC'),
    (f'Sabidur{chr(237)}a', 'Pr. 3:13; 4:7', 'Icons.psychology_alt_rounded', '0xFF42A5F5'),
]
w("        Wrap(spacing: 18, runSpacing: 18, alignment: WrapAlignment.center, children: [")
for title, ref, icon, color in themes_amp:
    w(f"          _buildAmpThemeCard('{title}', '{ref}', {icon}, Color({color})),")
w("        ]),")
w("      ]),")
w("    );")
w("  }")
w()

# Helper: _buildAmpThemeCard
w("  Widget _buildAmpThemeCard(String title, String reference, IconData icon, Color accent) {")
w("    return Container(")
w("      width: 360,")
w("      padding: const EdgeInsets.all(22),")
w("      decoration: BoxDecoration(")
w("        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,")
w("          colors: [accent.withValues(alpha: 0.2), accent.withValues(alpha: 0.06)]),")
w("        borderRadius: BorderRadius.circular(22),")
w("        border: Border.all(color: accent.withValues(alpha: 0.45), width: 2),")
w("        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.12), blurRadius: 16)],")
w("      ),")
w("      child: Row(children: [")
w("        Container(")
w("          width: 52, height: 52,")
w("          decoration: BoxDecoration(")
w("            shape: BoxShape.circle,")
w("            color: accent.withValues(alpha: 0.2),")
w("            border: Border.all(color: accent, width: 2),")
w("          ),")
w("          child: Icon(icon, color: accent, size: 28),")
w("        ),")
w("        const SizedBox(width: 16),")
w("        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [")
w("          Text(title, style: GoogleFonts.cinzel(fontSize: 24, color: accent, fontWeight: FontWeight.bold)),")
w("          const SizedBox(height: 4),")
w("          Container(")
w("            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),")
w("            decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),")
w("            child: Text(reference, style: GoogleFonts.orbitron(fontSize: 14, color: accent)),")
w("          ),")
w("        ])),")
w("      ]),")
w("    );")
w("  }")

new_methods = '\n'.join(lines) + '\n'

# Insert before _buildSectionHeader
marker = '  Widget _buildSectionHeader(String number, String title, IconData icon) {'
code = code.replace(marker, new_methods + '\n' + marker)

with open(widget_path, 'w', encoding='utf-8') as f:
    f.write(code)

total_lines = code.count('\n') + 1
print(f'Patched: {widget_path}')
print(f'Total lines: {total_lines}')
print('Added: Page 7 (Forma Literaria) + Page 8 (Temas Ampliados)')
