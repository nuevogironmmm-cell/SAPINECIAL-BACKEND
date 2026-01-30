# -*- coding: utf-8 -*-
"""
Script de Prueba de Carga - 50 Usuarios Simult?neos
==================================================
Simula 50 estudiantes conect?ndose simult?neamente al servidor WebSocket
para verificar la estabilidad del sistema.

Uso: python load_test.py [URL_DEL_SERVIDOR]
Por defecto usa localhost:8000

Autor: Sistema de Pruebas Sapiencial App
"""

import asyncio
import websockets
import json
import time
import random
import statistics
from datetime import datetime
from typing import List, Dict, Tuple
import argparse
import sys

# Configuraci?n de la prueba
NUM_STUDENTS = 50
CONNECTION_DELAY_MS = 50  # Delay entre conexiones para simular llegada gradual
TEST_DURATION_SECONDS = 30  # Duraci?n total de la prueba
ACTIVITY_RESPONSE_DELAY_MS = (500, 3000)  # Rango de tiempo de respuesta simulado

# Nombres de prueba
NOMBRES_PRUEBA = [
    "Mar?a Garc?a", "Juan Pérez", "Ana Mart?nez", "Carlos L?pez", "Laura S?nchez",
    "Pedro Rodr?guez", "Sof?a Hern?ndez", "Miguel Gonz?lez", "Carmen D?az", "José Ruiz",
    "Isabel Moreno", "David Mu?oz", "Elena ?lvarez", "Francisco Romero", "Luc?a Torres",
    "Antonio Navarro", "Paula Dom?nguez", "Manuel V?zquez", "Sara Ramos", "Javier Gil",
    "Raquel Serrano", "Alberto Blanco", "Marta Molina", "Fernando Castro", "Beatriz Ortega",
    "Sergio Delgado", "Cristina Rubio", "Diego Mar?n", "Andrea Sanz", "Pablo Iglesias",
    "M?nica Medina", "Alejandro Reyes", "Clara Jiménez", "Rubén Garrido", "Patricia Vargas",
    "Daniel Flores", "Nuria Pascual", "Adri?n Herrero", "Eva Montero", "?scar Cano",
    "Silvia Le?n", "Iv?n Prieto", "Teresa Cabrera", "Roberto Campos", "Inés Vega",
    "V?ctor Nieto", "Rosa Carrasco", "Guillermo Santos", "Julia Fuentes", "Emilio Guerrero"
]

# Estad?sticas globales
stats = {
    "connections_attempted": 0,
    "connections_successful": 0,
    "connections_failed": 0,
    "registrations_successful": 0,
    "registrations_failed": 0,
    "responses_sent": 0,
    "responses_confirmed": 0,
    "errors": [],
    "connection_times": [],
    "registration_times": [],
    "response_times": [],
    "start_time": None,
    "end_time": None,
}


async def simulate_student(student_id: int, ws_url: str, activity_id: str = None):
    """Simula un estudiante individual"""
    name = NOMBRES_PRUEBA[student_id] if student_id < len(NOMBRES_PRUEBA) else f"Estudiante_{student_id}"
    session_id = None
    
    try:
        # Conexi?n
        stats["connections_attempted"] += 1
        connect_start = time.perf_counter()
        
        async with websockets.connect(ws_url, ping_interval=20, ping_timeout=10) as ws:
            connect_time = (time.perf_counter() - connect_start) * 1000
            stats["connection_times"].append(connect_time)
            stats["connections_successful"] += 1
            print(f"? [{student_id:02d}] {name} conectado ({connect_time:.1f}ms)")
            
            # Registro
            reg_start = time.perf_counter()
            await ws.send(json.dumps({
                "action": "REGISTER",
                "payload": {"name": name, "reconnect": False}
            }))
            
            # Esperar respuesta de registro
            try:
                response = await asyncio.wait_for(ws.recv(), timeout=10.0)
                response_data = json.loads(response)
                reg_time = (time.perf_counter() - reg_start) * 1000
                stats["registration_times"].append(reg_time)
                
                if response_data.get("type") == "REGISTRATION_SUCCESS":
                    session_id = response_data.get("data", {}).get("sessionId")
                    stats["registrations_successful"] += 1
                    print(f"  ? [{student_id:02d}] Registrado: {session_id} ({reg_time:.1f}ms)")
                elif response_data.get("type") == "REGISTRATION_ERROR":
                    stats["registrations_failed"] += 1
                    error_msg = response_data.get("data", {}).get("message", "Unknown")
                    print(f"  ? [{student_id:02d}] Error registro: {error_msg}")
                    return
                else:
                    # Mensaje inesperado, continuar escuchando
                    pass
                    
            except asyncio.TimeoutError:
                stats["registrations_failed"] += 1
                print(f"  ? [{student_id:02d}] Timeout en registro")
                return
            
            # Mantener conexi?n activa y responder a actividades
            remaining_time = TEST_DURATION_SECONDS
            while remaining_time > 0:
                try:
                    message = await asyncio.wait_for(ws.recv(), timeout=5.0)
                    data = json.loads(message)
                    msg_type = data.get("type")
                    
                    if msg_type == "ACTIVITY_UNLOCKED":
                        # Simular respuesta con delay aleatorio
                        activity = data.get("data", {})
                        act_id = activity.get("id")
                        options_count = len(activity.get("options", []))
                        
                        # Delay aleatorio para simular pensamiento
                        delay = random.randint(*ACTIVITY_RESPONSE_DELAY_MS) / 1000
                        await asyncio.sleep(delay)
                        
                        # Enviar respuesta
                        answer = random.randint(0, max(0, options_count - 1))
                        resp_start = time.perf_counter()
                        
                        await ws.send(json.dumps({
                            "action": "SUBMIT_ANSWER",
                            "payload": {
                                "activityId": act_id,
                                "answer": answer,
                                "responseTimeMs": int(delay * 1000)
                            }
                        }))
                        stats["responses_sent"] += 1
                        
                        # Esperar confirmaci?n
                        try:
                            confirm = await asyncio.wait_for(ws.recv(), timeout=5.0)
                            confirm_data = json.loads(confirm)
                            if confirm_data.get("type") == "ANSWER_RECEIVED":
                                resp_time = (time.perf_counter() - resp_start) * 1000
                                stats["response_times"].append(resp_time)
                                stats["responses_confirmed"] += 1
                                print(f"  ?? [{student_id:02d}] Respuesta enviada ({resp_time:.1f}ms)")
                        except asyncio.TimeoutError:
                            pass
                    
                    elif msg_type == "STATE_UPDATE" or msg_type == "SLIDE_UPDATE":
                        # Actualizaci?n de estado, ignorar
                        pass
                    
                except asyncio.TimeoutError:
                    # Sin mensajes, continuar
                    remaining_time -= 5
                    continue
                except websockets.ConnectionClosed:
                    print(f"  ? [{student_id:02d}] Conexi?n cerrada")
                    break
                    
    except websockets.exceptions.InvalidStatusCode as e:
        stats["connections_failed"] += 1
        stats["errors"].append(f"[{student_id}] HTTP Error: {e}")
        print(f"? [{student_id:02d}] {name} - Error HTTP: {e}")
    except ConnectionRefusedError:
        stats["connections_failed"] += 1
        stats["errors"].append(f"[{student_id}] Conexi?n rechazada")
        print(f"? [{student_id:02d}] {name} - Conexi?n rechazada")
    except Exception as e:
        stats["connections_failed"] += 1
        stats["errors"].append(f"[{student_id}] {type(e).__name__}: {str(e)}")
        print(f"? [{student_id:02d}] {name} - Error: {e}")


async def run_load_test(ws_url: str, num_students: int = NUM_STUDENTS):
    """Ejecuta la prueba de carga completa"""
    print("=" * 60)
    print("?? PRUEBA DE CARGA - Sistema Sapiencial App")
    print("=" * 60)
    print(f"?? Configuraci?n:")
    print(f"   • Estudiantes: {num_students}")
    print(f"   • URL: {ws_url}")
    print(f"   • Duraci?n: {TEST_DURATION_SECONDS}s")
    print(f"   • Delay entre conexiones: {CONNECTION_DELAY_MS}ms")
    print("=" * 60)
    print()
    
    stats["start_time"] = datetime.now()
    
    # Crear tareas para todos los estudiantes
    tasks = []
    for i in range(num_students):
        task = asyncio.create_task(simulate_student(i, ws_url))
        tasks.append(task)
        # Delay gradual entre conexiones
        await asyncio.sleep(CONNECTION_DELAY_MS / 1000)
    
    # Esperar que todas las tareas terminen
    await asyncio.gather(*tasks, return_exceptions=True)
    
    stats["end_time"] = datetime.now()
    
    # Mostrar resultados
    print_results()


def print_results():
    """Imprime los resultados de la prueba"""
    duration = (stats["end_time"] - stats["start_time"]).total_seconds()
    
    print()
    print("=" * 60)
    print("?? RESULTADOS DE LA PRUEBA DE CARGA")
    print("=" * 60)
    print()
    
    # Conexiones
    print("?? CONEXIONES:")
    print(f"   • Intentadas:  {stats['connections_attempted']}")
    print(f"   • Exitosas:    {stats['connections_successful']} ({100*stats['connections_successful']/max(1,stats['connections_attempted']):.1f}%)")
    print(f"   • Fallidas:    {stats['connections_failed']}")
    print()
    
    # Registros
    print("?? REGISTROS:")
    print(f"   • Exitosos:    {stats['registrations_successful']} ({100*stats['registrations_successful']/max(1,stats['connections_successful']):.1f}%)")
    print(f"   • Fallidos:    {stats['registrations_failed']}")
    print()
    
    # Respuestas
    print("?? RESPUESTAS:")
    print(f"   • Enviadas:    {stats['responses_sent']}")
    print(f"   • Confirmadas: {stats['responses_confirmed']}")
    print()
    
    # Tiempos
    print("??  TIEMPOS DE RESPUESTA:")
    if stats["connection_times"]:
        print(f"   • Conexi?n promedio:   {statistics.mean(stats['connection_times']):.1f}ms")
        print(f"   • Conexi?n m?xima:     {max(stats['connection_times']):.1f}ms")
        print(f"   • Conexi?n m?nima:     {min(stats['connection_times']):.1f}ms")
    if stats["registration_times"]:
        print(f"   • Registro promedio:   {statistics.mean(stats['registration_times']):.1f}ms")
    if stats["response_times"]:
        print(f"   • Respuesta promedio:  {statistics.mean(stats['response_times']):.1f}ms")
    print()
    
    # Rendimiento
    print("?? RENDIMIENTO:")
    print(f"   • Duraci?n total:      {duration:.1f}s")
    print(f"   • Conexiones/segundo:  {stats['connections_successful']/duration:.1f}")
    print()
    
    # Veredicto
    success_rate = stats['connections_successful'] / max(1, stats['connections_attempted']) * 100
    
    print("=" * 60)
    if success_rate >= 95 and stats['connections_failed'] < 3:
        print("? RESULTADO: EXCELENTE")
        print("   El sistema soporta 50 usuarios simult?neos sin problemas.")
    elif success_rate >= 80:
        print("??  RESULTADO: ACEPTABLE")
        print("   El sistema funciona pero hay margen de mejora.")
    else:
        print("? RESULTADO: NECESITA MEJORAS")
        print("   El sistema tiene problemas de escalabilidad.")
    print("=" * 60)
    
    # Errores detallados
    if stats["errors"]:
        print()
        print("?? ERRORES DETECTADOS:")
        for error in stats["errors"][:10]:  # Mostrar m?ximo 10
            print(f"   • {error}")
        if len(stats["errors"]) > 10:
            print(f"   ... y {len(stats['errors'])-10} errores m?s")


def main():
    parser = argparse.ArgumentParser(description="Prueba de carga para Sapiencial App")
    parser.add_argument(
        "url",
        nargs="?",
        default="ws://localhost:8000/ws/student",
        help="URL del WebSocket (default: ws://localhost:8000/ws/student)"
    )
    parser.add_argument(
        "-n", "--num-students",
        type=int,
        default=NUM_STUDENTS,
        help=f"N?mero de estudiantes a simular (default: {NUM_STUDENTS})"
    )
    parser.add_argument(
        "-d", "--duration",
        type=int,
        default=TEST_DURATION_SECONDS,
        help=f"Duraci?n de la prueba en segundos (default: {TEST_DURATION_SECONDS})"
    )
    
    args = parser.parse_args()
    
    # Actualizar configuraci?n global
    global TEST_DURATION_SECONDS
    TEST_DURATION_SECONDS = args.duration
    
    try:
        asyncio.run(run_load_test(args.url, args.num_students))
    except KeyboardInterrupt:
        print("\n\n??  Prueba interrumpida por el usuario")
        print_results()
        sys.exit(1)


if __name__ == "__main__":
    main()
