
import sys

file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\backend\main.py'
try:
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            # Look at 960-1000 for action variable and initial message handling
            if 960 <= i + 1 <= 1000:
                print(f"{i+1}: {line}", end='')
                sys.stdout.flush()
except Exception as e:
    print(f"Error: {e}")
