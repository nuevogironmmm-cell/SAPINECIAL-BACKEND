
import sys

file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\backend\main.py'
try:
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            # Look at 1000-1060 for the action handling switch/if
            if 1000 <= i + 1 <= 1060:
                print(f"{i+1}: {line}", end='')
                sys.stdout.flush()
except Exception as e:
    print(f"Error: {e}")
