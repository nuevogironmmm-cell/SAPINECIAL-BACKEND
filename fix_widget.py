#!/usr/bin/env python3
"""Script to fix word_search_widget.dart - remove Listener and fix spelling"""
import re

filepath = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart'

with open(filepath, 'r', encoding='utf-8-sig') as f:
    lines = f.readlines()

print(f"Read {len(lines)} lines")

# Find the Listener block and remove it
new_lines = []
skip_mode = False
listener_depth = 0

i = 0
while i < len(lines):
    line = lines[i]
    stripped = line.strip()
    
    # Detect start of Listener block
    if 'Listener(' in stripped and 'onPointerDown' not in stripped:
        # Check if next line has onPointerDown
        if i + 1 < len(lines) and 'onPointerDown' in lines[i + 1]:
            # Skip the Listener( line and onPointerDown handler
            # Find "child: RawGestureDetector(" and keep from there
            print(f"Found Listener at line {i+1}")
            j = i
            while j < len(lines):
                if 'child: RawGestureDetector(' in lines[j]:
                    print(f"Found RawGestureDetector at line {j+1}")
                    # Replace with just RawGestureDetector (reduce indent by removing "child: ")
                    indent = '              '
                    new_lines.append(f'{indent}// Cuadr\u00edcula con gestos de selecci\u00f3n\n')
                    new_lines.append(f'{indent}RawGestureDetector(\n')
                    i = j + 1
                    break
                j += 1
            continue
    
    new_lines.append(line)
    i += 1

# Now remove the extra closing parenthesis from Listener
# Find the pattern: "            ),\n\n              // Overlay"
content = ''.join(new_lines)

# The Listener had an extra closing ")," that we need to remove
# Look for the closing bracket sequence before "// Overlay de Inicio"
# Pattern: ...),\r\n              ),\r\n\r\n              // Overlay
# Should become: ...),\r\n\r\n              // Overlay
content = content.replace(
    '            ),\r\n\r\n              // Overlay',
    '\r\n              // Overlay'
)
content = content.replace(
    '            ),\n\n              // Overlay',
    '\n              // Overlay'
)

# Fix remaining spelling/encoding issues
replacements = {
    '\u00bfFelicidades!': '\u00a1Felicidades!',
    'sabidur\u00eda': 'sabidur\u00eda',  # Already correct
    'Se acab\u00f3 el tiempo. \u00bfSigue': 'Se acab\u00f3 el tiempo. \u00a1Sigue',
    '\u00bfResultado enviado!': '\u00a1Resultado enviado!',
    '\u00bfCompletaste todo!': '\u00a1Completaste todo!',
    'Env\u00eda tu resultado': 'Env\u00eda tu resultado',  # Already correct
    '\u00bfTu resultado fue enviado': '\u00a1Tu resultado fue enviado',
    '\u00bfENVIAR RESULTADO!': '\u00a1ENVIAR RESULTADO!',
    '\u00bfR\u00c9CORD DE VELOCIDAD!': '\u00a1R\u00c9CORD DE VELOCIDAD!',
    'El m\u00e1s r\u00e1pido': 'El m\u00e1s r\u00e1pido',  # Already correct
    'posici\u00f3n': 'posici\u00f3n',  # Already correct
}

for old, new in replacements.items():
    if old in content:
        content = content.replace(old, new)
        print(f"Replaced: {old} -> {new}")

# Verify
print(f"\nVerification:")
print(f"Has Scrollable.of: {'Scrollable.of' in content}")
print(f"Has Listener(: {'Listener(' in content}")
print(f"Has BouncingScrollPhysics: {'BouncingScrollPhysics' in content}")
print(f"Has timeLimitSeconds = 600: {'timeLimitSeconds = 600' in content}")

# Write with UTF-8 BOM
with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(content)

print(f"\nFile saved successfully ({len(content)} chars)")
