
import os
import re

file_path = r"c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\frontend\lib\widgets\word_search_widget.dart"

try:
    with open(file_path, 'r', encoding='latin-1') as f:
        content = f.read()

    # Find the GestureDetector block
    # We look for onPanStart, onPanUpdate, onPanEnd and their arguments
    
    # Regex to capture the arguments of the callbacks
    # onPanStart: (d) => _onPanStart(d, SOME_ARGS),
    pattern = r"onPanStart:\s*\((.*?)\)\s*=>\s*_onPanStart\s*\((.*?)\),\s*onPanUpdate:\s*\((.*?)\)\s*=>\s*_onPanUpdate\s*\((.*?)\),\s*onPanEnd:\s*\((.*?)\)\s*=>\s*_onPanEnd\s*\((.*?)\),"
    
    match = re.search(pattern, content, re.DOTALL)
    
    if match:
        print("Match found!")
        start_arg = match.group(1) # d
        start_call_args = match.group(2) # d, constraints
        
        update_arg = match.group(3) # d
        update_call_args = match.group(4) # d, constraints
        
        end_arg = match.group(5) # d
        end_call_args = match.group(6) # d
        
        # Construct the new block
        new_block = f"""behavior: HitTestBehavior.opaque,
                onPanStart: ({start_arg}) => _onPanStart({start_call_args}),
                onPanUpdate: ({update_arg}) => _onPanUpdate({update_call_args}),
                onPanEnd: ({end_arg}) => _onPanEnd({end_call_args}),
                onVerticalDragStart: ({start_arg}) => _onPanStart({start_call_args}),
                onVerticalDragUpdate: ({update_arg}) => _onPanUpdate({update_call_args}),
                onVerticalDragEnd: ({end_arg}) => _onPanEnd({end_call_args}),
                onHorizontalDragStart: ({start_arg}) => _onPanStart({start_call_args}),
                onHorizontalDragUpdate: ({update_arg}) => _onPanUpdate({update_call_args}),
                onHorizontalDragEnd: ({end_arg}) => _onPanEnd({end_call_args}),"""
                
        # Replace the old block with the new one
        new_content = content.replace(match.group(0), new_block)
        
        with open(file_path, 'w', encoding='latin-1') as f:
            f.write(new_content)
        
        print("Successfully patched word_search_widget.dart")
        
    else:
        print("Could not find the GestureDetector pattern.")
        # Print a snippet to debug
        start_idx = content.find("GestureDetector")
        if start_idx != -1:
            print(f"Context around GestureDetector:\n{content[start_idx:start_idx+300]}")

except Exception as e:
    print(f"Error: {e}")
