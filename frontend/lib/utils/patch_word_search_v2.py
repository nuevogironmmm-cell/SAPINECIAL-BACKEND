
import os

file_path = r"c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart"

try:
    with open(file_path, 'r', encoding='latin-1') as f:
        lines = f.readlines()

    new_lines = []
    i = 0
    patched = False
    
    while i < len(lines):
        line = lines[i]
        
        if "GestureDetector(" in line and not patched:
            # Found the start
            print(f"Found GestureDetector at line {i+1}")
            
            # Keep the GestureDetector line
            new_lines.append(line)
            
            # Start injecting our behavior line
            indent = line.split("GestureDetector")[0] + "  "
            new_lines.append(f"{indent}behavior: HitTestBehavior.opaque,\n")
            
            i += 1
            
            # Now process the callbacks. We need to find onPanStart, onPanUpdate, onPanEnd lines
            # and replicate them for Vertical/Horizontal
            
            # We'll just collect the next few lines until we see 'child:'
            # and if they contain the callbacks, we duplicate them
            
            pan_start_line = ""
            pan_update_line = ""
            pan_end_line = ""
            
            buffer = []
            
            while i < len(lines) and "child:" not in lines[i]:
                current = lines[i]
                buffer.append(current)
                
                if "onPanStart:" in current:
                    pan_start_line = current.strip().replace("onPanStart:", "").strip().rstrip(",")
                if "onPanUpdate:" in current:
                    pan_update_line = current.strip().replace("onPanUpdate:", "").strip().rstrip(",")
                if "onPanEnd:" in current:
                    pan_end_line = current.strip().replace("onPanEnd:", "").strip().rstrip(",")
                
                i += 1
            
            # Add the original lines back
            new_lines.extend(buffer)
            
            # Add the new lines if we found the callbacks
            if pan_start_line and pan_update_line and pan_end_line:
                print("Found all callbacks, injecting duplicates...")
                new_lines.append(f"{indent}onVerticalDragStart: {pan_start_line},\n")
                new_lines.append(f"{indent}onVerticalDragUpdate: {pan_update_line},\n")
                new_lines.append(f"{indent}onVerticalDragEnd: {pan_end_line},\n")
                new_lines.append(f"{indent}onHorizontalDragStart: {pan_start_line},\n")
                new_lines.append(f"{indent}onHorizontalDragUpdate: {pan_update_line},\n")
                new_lines.append(f"{indent}onHorizontalDragEnd: {pan_end_line},\n")
                patched = True
            else:
                 print("WARNING: Did not find all callbacks in the expected block.")
                 print(f"Start: {bool(pan_start_line)}, Update: {bool(pan_update_line)}, End: {bool(pan_end_line)}")
            
        else:
            new_lines.append(line)
            i += 1

    if patched:
        with open(file_path, 'w', encoding='latin-1') as f:
            f.writelines(new_lines)
        print("Successfully patched word_search_widget.dart")
    else:
        print("Failed to patch: GestureDetector not found or already patched?")

except Exception as e:
    print(f"Error: {e}")
