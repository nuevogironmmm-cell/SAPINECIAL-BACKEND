#!/usr/bin/env python3
"""Scan and fix all broken Spanish text in word_search_widget.dart"""

filepath = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart'

with open(filepath, 'r', encoding='utf-8-sig') as f:
    content = f.read()

# Show all lines with '?' that are likely broken text
lines = content.split('\n')
print("=== Lines with potentially broken '?' in strings ===")
for i, line in enumerate(lines):
    s = line.strip()
    if s.startswith('//'):
        continue
    # Look for ? inside quotes that suggest broken encoding
    if ("'?" in s or "?'" in s or '"?' in s or '?"' in s) and '==' not in s and 'null' not in s and '.contains' not in s:
        print(f'{i+1}: {s}')

print("\n=== Now applying fixes ===")

# Map of broken text -> correct text
fixes = [
    # Signs and accents that got corrupted
    ("'?Resultado enviado!'", "'\\u00a1Resultado enviado!'"),
    ("'?? ?ENVIAR RESULTADO!'", "'\\U0001f3c6 \\u00a1ENVIAR RESULTADO!'"),
    ("'?Tu resultado fue enviado al docente!'", "'\\u00a1Tu resultado fue enviado al docente!'"),
    ("'?Felicidades!'", "'\\u00a1Felicidades!'"),
    ("'?Sigue practicando", "'\\u00a1Sigue practicando"),
    ("'?? ?R?CORD DE VELOCIDAD! ??'", "'\\U0001f680 \\u00a1R\\u00c9CORD DE VELOCIDAD! \\U0001f680'"),
    ("'?? El m?s r?pido gana la corona ??'", "'\\U0001f3c6 El m\\u00e1s r\\u00e1pido gana la corona \\U0001f451'"),
    ("'?Completaste todo!", "'\\u00a1Completaste todo!"),
    ("sabidur?a", "sabidur\\u00eda"),
    ("// Bot?n de enviar", "// Bot\\u00f3n de enviar"),
    ("// Mensaje de confirmaci?n", "// Mensaje de confirmaci\\u00f3n"),
    ("// BOT?N DE ENVIAR", "// BOT\\u00d3N DE ENVIAR"),
    ("// RANKING DE GANADORES ORDENADO POR TIEMPO (si est? disponible)", "// RANKING DE GANADORES ORDENADO POR TIEMPO (si est\\u00e1 disponible)"),
    ("// M?ximo 55%", "// M\\u00e1ximo 55%"),
    ("visibilidad m?vil", "visibilidad m\\u00f3vil"),
    ("// La Cuadr?cula", "// La Cuadr\\u00edcula"),
    ("// Calcular tama?o cuadrado", "// Calcular tama\\u00f1o cuadrado"),
    ("// En m?vil (dentro de scroll)", "// En m\\u00f3vil"),
    ("// ?xito o Fracaso", "// \\u00c9xito o Fracaso"),
    ("// Acci?n es critica", "// Acci\\u00f3n es cr\\u00edtica"),
    ("'M?nimo", "'M\\u00ednimo"),
    ("posici?n", "posici\\u00f3n"),
]

count = 0
for old, new in fixes:
    # Decode unicode escapes in the new string
    new_decoded = new.encode().decode('unicode_escape')
    old_check = old
    if old_check in content:
        content = content.replace(old_check, new_decoded)
        print(f"  Fixed: {old} -> {new_decoded}")
        count += 1

print(f"\nTotal fixes applied: {count}")

# Also fix the accent map if it has broken chars
if "'SATAN?S'" in content:
    content = content.replace("'SATAN?S'", "'SATAN\\u00c1S'".encode().decode('unicode_escape'))
    print("Fixed: SATAN?S -> SATAN?S")
    count += 1

if "'SABIDUR?A'" in content:
    content = content.replace("'SABIDUR?A'", "'SABIDUR\\u00cdA'".encode().decode('unicode_escape'))
    print("Fixed: SABIDUR?A -> SABIDUR?A")
    count += 1

if "'PR?LOGO'" in content:
    content = content.replace("'PR?LOGO'", "'PR\\u00d3LOGO'".encode().decode('unicode_escape'))
    print("Fixed: PR?LOGO -> PR?LOGO")
    count += 1

if "'EP?LOGO'" in content:
    content = content.replace("'EP?LOGO'", "'EP\\u00cdLOGO'".encode().decode('unicode_escape'))
    print("Fixed: EP?LOGO -> EP?LOGO")
    count += 1

# Verify
print("\n=== Verification ===")
remaining = 0
for i, line in enumerate(content.split('\n')):
    s = line.strip()
    if s.startswith('//'):
        continue
    if ("'?" in s or "?'" in s) and '==' not in s and 'null' not in s and '.contains' not in s and 'ternary' not in s:
        if 'gridConstraints' not in s and 'maxHeight' not in s and 'seconds' not in s:
            print(f'  REMAINING {i+1}: {s}')
            remaining += 1

if remaining == 0:
    print("  No broken text remaining!")
else:
    print(f"  {remaining} lines still have potential issues")

# Save
with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(content)

print(f"\nFile saved ({len(content)} chars)")
