
file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\backend\main.py'
try:
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if 800 <= i + 1 <= 1300:
                print(f"{i+1}: {line}", end='')
except Exception as e:
    print(f"Error: {e}")
