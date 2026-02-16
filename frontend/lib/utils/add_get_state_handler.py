# -*- coding: utf-8 -*-
import sys

file_path = r'c:\Users\mmmpc\OneDrive\Escritorio\clases libro sapienciales\backend\main.py'

# The GET_STATE handler code to insert (using ASCII safe comments)
get_state_handler = '''
            # ---- SOLICITAR ESTADO ACTUAL ----
            elif action == "GET_STATE":
                # Enviar estado actual
                await websocket.send_text(json.dumps({
                    "type": "STATE_UPDATE",
                    "data": state.to_dict()
                }))
                # Si hay actividad activa, enviarla tambien
                if state.current_activity and state.current_activity.state == ActivityState.ACTIVE:
                    await websocket.send_text(json.dumps({
                        "type": "ACTIVITY_UNLOCKED",
                        "data": state.current_activity.to_student_dict()
                    }))

'''

# Read the file
with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Find the insertion point: before WORD_SEARCH_PROGRESS handler
target = '            elif action == "WORD_SEARCH_PROGRESS":'

if target in content:
    new_content = content.replace(target, get_state_handler + target)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    print("Successfully added GET_STATE handler to backend/main.py")
else:
    print("ERROR: Could not find insertion point")
