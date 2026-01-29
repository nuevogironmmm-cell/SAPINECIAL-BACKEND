# -*- coding: utf-8 -*-
"""
Backend para Literatura Sapiencial
Servidor WebSocket con autenticación básica
"""
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict
import json
import secrets
import hashlib

app = FastAPI(title="Sapiencial App Backend")

# Configuración de CORS (restringir en producción)
ALLOWED_ORIGINS = [
    "http://localhost:*",
    "http://127.0.0.1:*",
    # Agregar dominios de producción aquí
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: Cambiar a ALLOWED_ORIGINS en producción
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ============================================================
# CONFIGURACIÓN DE SEGURIDAD
# ============================================================

# Token de acceso para profesor (cambiar en producción)
# Generar con: python -c "import secrets; print(secrets.token_urlsafe(32))"
TEACHER_ACCESS_TOKEN = "profesor2026"  # Token simple para desarrollo
TEACHER_TOKEN_HASH = hashlib.sha256(TEACHER_ACCESS_TOKEN.encode()).hexdigest()

# Tokens de sesión activos (en producción usar Redis/DB)
active_sessions: Dict[str, str] = {}  # token -> role

def validate_token(token: str, role: str) -> bool:
    """Valida el token de acceso según el rol"""
    if role == "teacher":
        # Verificar hash del token de profesor
        token_hash = hashlib.sha256(token.encode()).hexdigest()
        return token_hash == TEACHER_TOKEN_HASH
    elif role == "student":
        # Los estudiantes pueden conectarse con cualquier token no vacío
        # En producción, validar contra lista de tokens de sesión
        return len(token) >= 4
    return False

def generate_session_token() -> str:
    """Genera un token de sesión único"""
    return secrets.token_urlsafe(16)

# ============================================================
# MANAGER DE CONEXIONES WEBSOCKET
# ============================================================

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []
        self.user_roles: Dict[WebSocket, str] = {}
        self.connection_count = 0

    async def connect(self, websocket: WebSocket, role: str = "student"):
        await websocket.accept()
        self.active_connections.append(websocket)
        self.user_roles[websocket] = role
        self.connection_count += 1
        # Usar logging en producción en lugar de print
        print(f"[INFO] Cliente conectado como: {role} (Total: {len(self.active_connections)})")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        if websocket in self.user_roles:
            role = self.user_roles.pop(websocket)
            print(f"[INFO] Cliente desconectado: {role} (Total: {len(self.active_connections)})")

    async def broadcast(self, message: dict):
        """Envía mensaje a todos los clientes conectados"""
        json_msg = json.dumps(message, ensure_ascii=False)
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_text(json_msg)
            except Exception as e:
                print(f"[ERROR] Error broadcasting: {e}")
                disconnected.append(connection)
        
        # Limpiar conexiones muertas
        for conn in disconnected:
            self.disconnect(conn)

    async def send_to_role(self, message: dict, target_role: str):
        """Envía mensaje solo a usuarios de un rol específico"""
        json_msg = json.dumps(message, ensure_ascii=False)
        for connection, role in self.user_roles.items():
            if role == target_role:
                try:
                    await connection.send_text(json_msg)
                except Exception:
                    pass

manager = ConnectionManager()

# ============================================================
# ESTADO DE LA CLASE
# ============================================================

class ClassState:
    def __init__(self):
        self.current_state = "LOBBY"
        self.current_slide_index = 0
        self.current_block_index = 0
        self.active_activity_id = None
        self.is_activity_locked = True
        self.student_responses: Dict[str, List[int]] = {}  # slideId -> responses

    def to_dict(self) -> dict:
        return {
            "state": self.current_state,
            "slide": self.current_slide_index,
            "block": self.current_block_index,
            "activity": self.active_activity_id,
            "locked": self.is_activity_locked
        }

state = ClassState()

# ============================================================
# ENDPOINTS HTTP
# ============================================================

@app.get("/")
async def root():
    """Endpoint de verificación de salud"""
    return {
        "status": "ok", 
        "message": "Sapiencial App Server Running",
        "version": "1.1.0",
        "connections": len(manager.active_connections)
    }

@app.get("/state")
async def get_state():
    """Obtiene el estado actual de la clase"""
    return state.to_dict()

@app.post("/auth/teacher")
async def authenticate_teacher(token: str = Query(...)):
    """Autentica al profesor y devuelve token de sesión"""
    if validate_token(token, "teacher"):
        session_token = generate_session_token()
        active_sessions[session_token] = "teacher"
        return {"success": True, "session_token": session_token}
    raise HTTPException(status_code=401, detail="Token inválido")

# ============================================================
# WEBSOCKET CON AUTENTICACIÓN
# ============================================================

@app.websocket("/ws/{role}")
async def websocket_endpoint(
    websocket: WebSocket, 
    role: str,
    token: str = Query(default="")
):
    """
    Endpoint WebSocket con autenticación por rol
    
    Uso:
    - Profesor: ws://localhost:8000/ws/teacher?token=profesor2026
    - Estudiante: ws://localhost:8000/ws/student?token=cualquier_texto
    """
    
    # Validar rol
    if role not in ["teacher", "student"]:
        await websocket.close(code=4001)
        return
    
    # Validar token
    if not validate_token(token, role):
        await websocket.accept()
        await websocket.send_text(json.dumps({
            "type": "ERROR",
            "data": {"message": "Token de acceso inválido", "code": "AUTH_FAILED"}
        }))
        await websocket.close(code=4003)
        return
    
    # Conexión exitosa
    await manager.connect(websocket, role)
    
    try:
        # Enviar estado inicial
        await websocket.send_text(json.dumps({
            "type": "STATE_UPDATE",
            "data": state.to_dict()
        }))

        while True:
            data = await websocket.receive_text()
            
            try:
                message = json.loads(data)
            except json.JSONDecodeError:
                await websocket.send_text(json.dumps({
                    "type": "ERROR",
                    "data": {"message": "JSON inválido"}
                }))
                continue

            # Solo el profesor puede ejecutar acciones de control
            if role == "teacher":
                await handle_teacher_action(message)
            elif role == "student":
                await handle_student_action(websocket, message)

    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception as e:
        print(f"[ERROR] WebSocket error: {e}")
        manager.disconnect(websocket)

async def handle_teacher_action(message: dict):
    """Procesa acciones del profesor"""
    action = message.get("action")
    payload = message.get("payload", {})

    if action == "SET_STATE":
        state.current_state = payload.get("state", state.current_state)
        await manager.broadcast({
            "type": "STATE_UPDATE",
            "data": {"state": state.current_state}
        })

    elif action == "SET_SLIDE":
        state.current_slide_index = payload.get("slide", state.current_slide_index)
        state.current_block_index = payload.get("block", state.current_block_index)
        await manager.broadcast({
            "type": "SLIDE_UPDATE",
            "data": {
                "slide": state.current_slide_index,
                "block": state.current_block_index
            }
        })

    elif action == "UNLOCK_ACTIVITY":
        state.is_activity_locked = False
        state.active_activity_id = payload.get("activityId")
        state.student_responses[state.active_activity_id] = []
        await manager.broadcast({
            "type": "ACTIVITY_STATUS",
            "data": {
                "locked": False, 
                "activityId": state.active_activity_id
            }
        })

    elif action == "LOCK_ACTIVITY":
        state.is_activity_locked = True
        await manager.broadcast({
            "type": "ACTIVITY_STATUS",
            "data": {"locked": True}
        })

    elif action == "REVEAL_ANSWER":
        await manager.broadcast({
            "type": "ANSWER_REVEALED",
            "data": {
                "activityId": payload.get("activityId"),
                "correctIndex": payload.get("correctIndex")
            }
        })

    elif action == "RESET_ACTIVITY":
        activity_id = payload.get("activityId")
        if activity_id in state.student_responses:
            state.student_responses[activity_id] = []
        await manager.broadcast({
            "type": "ACTIVITY_RESET",
            "data": {"activityId": activity_id}
        })

async def handle_student_action(websocket: WebSocket, message: dict):
    """Procesa acciones del estudiante"""
    action = message.get("action")
    payload = message.get("payload", {})

    if action == "SUBMIT_ANSWER":
        if state.is_activity_locked:
            await websocket.send_text(json.dumps({
                "type": "ERROR",
                "data": {"message": "La actividad está bloqueada"}
            }))
            return

        activity_id = payload.get("activityId")
        option_index = payload.get("optionIndex")
        
        if activity_id and option_index is not None:
            if activity_id not in state.student_responses:
                state.student_responses[activity_id] = []
            state.student_responses[activity_id].append(option_index)
            
            # Notificar a todos sobre la nueva respuesta
            await manager.broadcast({
                "type": "STUDENT_RESPONSE",
                "data": {
                    "activityId": activity_id,
                    "responses": state.student_responses[activity_id]
                }
            })

# ============================================================
# ENDPOINT LEGACY (sin token - solo para desarrollo)
# ============================================================

@app.websocket("/ws-dev/{role}")
async def websocket_dev_endpoint(websocket: WebSocket, role: str):
    """
    Endpoint de desarrollo SIN autenticación
    ⚠️ NO USAR EN PRODUCCIÓN
    """
    await manager.connect(websocket, role)
    try:
        await websocket.send_text(json.dumps({
            "type": "STATE_UPDATE",
            "data": state.to_dict()
        }))

        while True:
            data = await websocket.receive_text()
            message = json.loads(data)

            if role == "teacher":
                await handle_teacher_action(message)

    except WebSocketDisconnect:
        manager.disconnect(websocket)
