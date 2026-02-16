
import re
import sys

file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart'

def apply_fix():
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    # 1. Add import
    if "import 'package:flutter/gestures.dart';" not in content:
        content = content.replace("import 'package:flutter/material.dart';", 
                                  "import 'package:flutter/material.dart';\nimport 'package:flutter/gestures.dart';")
        print("Added import.")

    # 2. Add class definition
    eager_class_code = """
class EagerGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => 'EagerGestureRecognizer';
}
"""
    if "class EagerGestureRecognizer" not in content:
        content += "\n" + eager_class_code
        print("Added EagerGestureRecognizer class.")

    # 3. Replace GestureDetector with RawGestureDetector
    # Identify start of GestureDetector
    gd_start_idx = content.find("GestureDetector(")
    
    if gd_start_idx == -1:
        if "RawGestureDetector" in content:
            print("RawGestureDetector already present.")
            # Verify if it's correct? Assuming yes for now if class exists.
        else:
            print("Error: GestureDetector not found and RawGestureDetector not found.")
            # fallback: look for the stack or container
        return

    # Find the matching closing parenthesis for GestureDetector
    balance = 0
    gd_end_idx = -1
    
    # We start counting from the opening paren of GestureDetector'('
    start_paren_idx = content.find("(", gd_start_idx)
    
    for i in range(start_paren_idx, len(content)):
        char = content[i]
        if char == '(':
            balance += 1
        elif char == ')':
            balance -= 1
            if balance == 0:
                gd_end_idx = i + 1 # Include the closing paren
                break
    
    if gd_end_idx == -1:
        print("Error: Could not find matching closing parenthesis for GestureDetector.")
        return

    gesture_detector_block = content[gd_start_idx:gd_end_idx]
    
    # Find 'child:' inside the block
    child_match = re.search(r'\bchild:\s*', gesture_detector_block)
    if not child_match:
        print("Error: Could not find 'child:' inside GestureDetector.")
        return
    
    child_start_in_block = child_match.end()
    # Extract the child widget string (from child_start to end of block - 1 char for closing paren)
    # Actually, we need to be careful. The 'child:' value might end before the GestureDetector closing paren.
    # But usually it's the last argument.
    # Let's assume it's the last argument for now, or use paren counting again for the child? 
    # No, simpler: Recalculate 'child_content' by taking everything from child_start to the end of block minus the last closing paren.
    
    child_content = gesture_detector_block[child_start_in_block:-1].strip()
    
    # Need to handle if child content has a comma at the end (if it wasn't the last arg)
    # But replacing the whole GestureDetector is safer.
    
    # Check if 'child:' is indeed the last argument.
    # If there are arguments after child, we need to locate where child ends.
    # Given the previous reads, child: Container(...) seemed to be the last one or close to it.
    
    # Let's construct the RawGestureDetector string
    # We need 'size' variable context? No, the code string uses 'size' variable which is available in the scope.
    # The callback '_onPanStart', '_onPanUpdate', '_onPanEnd' are available methods.
    
    new_block = f"""RawGestureDetector(
                gestures: {{
                  EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                    (EagerGestureRecognizer instance) {{
                      instance.onStart = (d) => _onPanStart(d, BoxConstraints(maxWidth: size, maxHeight: size));
                      instance.onUpdate = (d) => _onPanUpdate(d, BoxConstraints(maxWidth: size, maxHeight: size));
                      instance.onEnd = (d) => _onPanEnd(d);
                    }},
                  ),
                }},
                behavior: HitTestBehavior.opaque,
                child: {child_content}
              )"""

    # Replace in content
    new_content = content[:gd_start_idx] + new_block + content[gd_end_idx:]
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print("Successfully replaced GestureDetector with RawGestureDetector.")

if __name__ == '__main__':
    apply_fix()
