
import sys

file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\backend\main.py'
try:
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            # After SUBMIT_ANSWER handler completes, look for the end of that block
            if 1100 <= i + 1 <= 1150:
                print(f"{i+1}: {line}", end='')
                sys.stdout.flush()
except Exception as e:
    print(f"Error: {e}")
