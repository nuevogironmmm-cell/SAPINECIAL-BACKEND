
import sys

file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\backend\main.py'
try:
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            # student_websocket starts around 950. Let's look at 950-1100
            if 950 <= i + 1 <= 1100:
                print(f"{i+1}: {line}", end='')
                sys.stdout.flush()
except Exception as e:
    print(f"Error: {e}")
