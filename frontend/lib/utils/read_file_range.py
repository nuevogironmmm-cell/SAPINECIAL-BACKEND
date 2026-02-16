
import os

file_path = r"c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart"

try:
    with open(file_path, 'r', encoding='latin-1') as f:
        lines = f.readlines()
        for i in range(570, 595):
            if i < len(lines):
                print(f"{i+1}:{lines[i].rstrip()}")
except Exception as e:
    print(f"Error: {e}")
