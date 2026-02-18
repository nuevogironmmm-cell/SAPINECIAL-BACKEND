import sys
filepath = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart'
with open(filepath, 'r', encoding='utf-8-sig') as f:
    content = f.read()

# Fix medal emojis
content = content.replace("return '??'; // Primer lugar", "return '\U0001f451'; // Primer lugar")
content = content.replace("return '??'; // Segundo lugar", "return '\U0001f948'; // Segundo lugar")
content = content.replace("return '??'; // Tercer lugar", "return '\U0001f949'; // Tercer lugar")
content = content.replace("default: return '?';", "default: return '\u2B50';")
content = content.replace("Text('??', style: TextStyle(fontSize: 28))", "Text('\U0001f3c6', style: TextStyle(fontSize: 28))")
content = content.replace("seg?n posici", "seg\u00fan posici")

with open(filepath, 'w', encoding='utf-8-sig') as f:
    f.write(content)
print('Done')
