import asyncio
import websockets
import json
import random
import time

# URL de producci?n (cambiar si es necesario)
WS_URL = "wss://sapinecial-backend.onrender.com/ws/student"
# WS_URL = "ws://localhost:8000/ws/student"

NUM_STUDENTS = 50
DURATION_SECONDS = 30

async def student_client(student_id):
    uri = WS_URL
    student_name = f"TestStudent_{student_id}"
    
    try:
        async with websockets.connect(uri) as websocket:
            # 1. Registrarse
            register_msg = {
                "action": "REGISTER",
                "payload": {"name": student_name}
            }
            await websocket.send(json.dumps(register_msg))
            print(f"[Student {student_id}] Conectado y enviando registro...")

            # 2. Mantener conexi?n y escuchar
            start_time = time.time()
            while time.time() - start_time < DURATION_SECONDS:
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=5.0)
                    data = json.loads(message)
                    # print(f"[Student {student_id}] Recibi?: {data.get('type')}")
                    
                    # Responder a ping o actividad si fuera necesario (simulado)
                    if data.get('type') == 'REGISTRATION_SUCCESS':
                        # print(f"[Student {student_id}] Registrado exitosamente.")
                        pass
                        
                except asyncio.TimeoutError:
                    # Enviar un ping para mantener viva la conexi?n
                    # await websocket.send(json.dumps({"action": "PING"}))
                    pass
            
            print(f"[Student {student_id}] Finaliz? prueba exitosamente.")
            return True

    except Exception as e:
        print(f"[Student {student_id}] Error: {e}")
        return False

async def main():
    print(f"Iniciando prueba de carga con {NUM_STUDENTS} estudiantes hacia {WS_URL}...")
    print(f"Duraci?n: {DURATION_SECONDS} segundos")
    
    tasks = []
    for i in range(NUM_STUDENTS):
        tasks.append(student_client(i))
        # Peque?o delay para no saturar el inicio instant?neo
        await asyncio.sleep(0.05)
    
    results = await asyncio.gather(*tasks)
    
    success_count = results.count(True)
    fail_count = results.count(False)
    
    print("\n" + "="*30)
    print("RESUMEN DE PRUEBA")
    print("="*30)
    print(f"Total Estudiantes: {NUM_STUDENTS}")
    print(f"Conexiones Exitosas: {success_count}")
    print(f"Fallos: {fail_count}")
    print("="*30)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nPrueba detenida manualmente.")
