
file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart'
try:
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if 560 <= i + 1 <= 610:
                print(f"{i+1}: {line}", end='')
except Exception as e:
    print(f"Error: {e}")
