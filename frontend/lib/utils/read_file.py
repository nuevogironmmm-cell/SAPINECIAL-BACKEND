
import os

file_path = r"c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart"

try:
    with open(file_path, 'r', encoding='latin-1') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if "GestureDetector" in line:
                print(f"Line {i+1}: {line.strip()}")
                # Print context
                for j in range(max(0, i-5), min(len(lines), i+30)):
                    print(f"{j+1}: {lines[j].rstrip()}")
except Exception as e:
    print(f"Error: {e}")
