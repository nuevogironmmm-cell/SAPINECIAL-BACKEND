# -*- coding: utf-8 -*-
"""
Backend para Literatura Sapiencial
Servidor WebSocket con sistema completo de estudiantes
Versión 2.1 - Con persistencia de progreso y soporte para 50+ usuarios
"""
import os
import asyncio
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Optional, Any
from datetime import datetime
from enum import Enum
import json
import hashlib
import uuid

# Archivo para persistencia de progreso
PROGRESS_FILE = "student_progress.json"

app = FastAPI(title="Sapiencial App Backend")

# Configuración de CORS (permite conexiones desde Netlify)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar el dominio de Netlify
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Endpoint de health check para Render
@app.get("/")
def health_check():
    return {"status": "ok", "service": "sapiencial-backend"}

@app.get("/health")
def health():
    return {"status": "healthy"}

# ============================================================
# ENUMERACIONES
# ============================================================

class StudentConnectionStatus(str, Enum):
    CONNECTED = "connected"
    RESPONDED = "responded"
    NOT_RESPONDED = "notResponded"
    DISCONNECTED = "disconnected"

class ActivityState(str, Enum):
    LOCKED = "locked"
    ACTIVE = "active"
    CLOSED = "closed"

class StudentActivityType(str, Enum):
    MULTIPLE_CHOICE = "multipleChoice"
    TRUE_FALSE = "trueFalse"
    SHORT_ANSWER = "shortAnswer"

class StudentClassification(str, Enum):
    WINNER = "winner"
    EXCELLENT = "excellent"
    VERY_GOOD = "veryGood"
    APPROVED = "approved"
    BASIC = "basic"
    FAILED = "failed"

# ============================================================
# FUNCIONES DE CLASIFICACIÓN
# ============================================================

def get_classification(percentage: float) -> StudentClassification:
    """Obtiene CLASIFICACIÓN según porcentaje"""
    if percentage >= 100:
        return StudentClassification.WINNER
    elif percentage >= 90:
        return StudentClassification.EXCELLENT
    elif percentage >= 80:
        return StudentClassification.VERY_GOOD
    elif percentage >= 70:
        return StudentClassification.APPROVED
    elif percentage >= 60:
        return StudentClassification.BASIC
    return StudentClassification.FAILED

def get_classification_icon(classification: StudentClassification) -> str:
    """Obtiene ícono de CLASIFICACIÓN"""
    icons = {
        StudentClassification.WINNER: "🏆",
        StudentClassification.EXCELLENT: "⭐",
        StudentClassification.VERY_GOOD: "👍",
        StudentClassification.APPROVED: "✅",
        StudentClassification.BASIC: "📚",
        StudentClassification.FAILED: "💪",
    }
    return icons.get(classification, "")

def get_motivational_message(percentage: float) -> str:
    """Obtiene mensaje motivacional para estudiante"""
    if percentage >= 100:
        return "¡Excelente! Dominaste el tema 👏"
    elif percentage >= 90:
        return "Muy buen trabajo, casi perfecto 💪"
    elif percentage >= 80:
        return "Vas muy bien, sigue así 🔥"
    elif percentage >= 70:
        return "Buen avance, puedes mejorar 👍"
    elif percentage >= 60:
        return "Buen intento, sigue practicando 📘"
    return "¡Ánimo, cada clase es una nueva oportunidad! 🌱"

# ============================================================
# Configuración DE SEGURIDAD
# ============================================================

TEACHER_ACCESS_TOKEN = "profesor2026"
TEACHER_TOKEN_HASH = hashlib.sha256(TEACHER_ACCESS_TOKEN.encode()).hexdigest()

def validate_token(token: str, role: str) -> bool:
    """Valida el token de acceso según el rol"""
    if role == "teacher":
        token_hash = hashlib.sha256(token.encode()).hexdigest()
        return token_hash == TEACHER_TOKEN_HASH
    elif role == "student":
        return True  # Estudiantes no requieren token
    return False

def generate_session_id() -> str:
    """Genera un ID de sesión único"""
    return str(uuid.uuid4())[:8]

# ============================================================
# PERSISTENCIA DE PROGRESO
# ============================================================

def load_progress() -> Dict:
    """Carga el progreso guardado de estudiantes"""
    try:
        if os.path.exists(PROGRESS_FILE):
            with open(PROGRESS_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
    except Exception as e:
        print(f"[WARN] Error cargando progreso: {e}")
    return {"students": {}, "last_updated": None}

def save_progress(students_data: Dict):
    """Guarda el progreso de estudiantes"""
    try:
        data = {
            "students": students_data,
            "last_updated": datetime.now().isoformat()
        }
        with open(PROGRESS_FILE, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"[INFO] Progreso guardado: {len(students_data)} estudiantes")
    except Exception as e:
        print(f"[ERROR] Error guardando progreso: {e}")

# Variable global para progreso persistente
_saved_progress = load_progress()

# ============================================================
# MODELOS DE DATOS - ESTUDIANTE
# ============================================================

class StudentData:
    """Datos del estudiante"""
    def __init__(self, session_id: str, name: str, from_saved: Dict = None):
        self.session_id = session_id
        self.name = name
        self.status = StudentConnectionStatus.CONNECTED
        self.connected_at = datetime.now()
        self.last_activity_at: Optional[datetime] = None
        self.websocket: Optional[WebSocket] = None
        
        # Cargar datos guardados si existen
        if from_saved:
            self.accumulated_percentage = from_saved.get('accumulated_percentage', 0.0)
            self.responses = from_saved.get('responses', {})
            self.reflections = from_saved.get('reflections', [])
        else:
            self.accumulated_percentage = 0.0
            self.responses: Dict[str, Dict] = {}  # activity_id -> response
            self.reflections: List[Dict] = []
    
    @property
    def classification(self) -> StudentClassification:
        return get_classification(self.accumulated_percentage)
    
    @property
    def classification_icon(self) -> str:
        return get_classification_icon(self.classification)
    
    @property
    def motivational_message(self) -> str:
        return get_motivational_message(self.accumulated_percentage)
    
    def has_responded(self, activity_id: str) -> bool:
        return activity_id in self.responses
    
    def add_response(self, activity_id: str, answer: Any, is_correct: bool, 
                     percentage_value: float, response_time_ms: Optional[int] = None):
        """Agrega respuesta y recalcula porcentaje"""
        self.responses[activity_id] = {
            "activity_id": activity_id,
            "answer": answer,
            "is_correct": is_correct,
            "percentage_value": percentage_value,
            "answered_at": datetime.now().isoformat(),
            "response_time_ms": response_time_ms,
        }
        self.last_activity_at = datetime.now()
        
        if is_correct:
            self.accumulated_percentage += percentage_value
            if self.accumulated_percentage > 100:
                self.accumulated_percentage = 100
        
        self.status = StudentConnectionStatus.RESPONDED
    
    def to_saveable(self) -> Dict:
        """Convierte a diccionario para guardar en archivo"""
        return {
            "name": self.name,
            "accumulated_percentage": self.accumulated_percentage,
            "responses": self.responses,
            "reflections": self.reflections,
        }
    
    def add_reflection(self, topic: str, content: str):
        """Agrega reflexión"""
        reflection = {
            "id": generate_session_id(),
            "student_session_id": self.session_id,
            "student_name": self.name,
            "topic": topic,
            "content": content,
            "created_at": datetime.now().isoformat(),
        }
        self.reflections.append(reflection)
        self.last_activity_at = datetime.now()
        return reflection
    
    def reset_for_new_activity(self):
        """Resetea estado para nueva actividad"""
        self.status = StudentConnectionStatus.NOT_RESPONDED
    
    def to_dict(self) -> Dict:
        """Convierte a diccionario para JSON"""
        return {
            "sessionId": self.session_id,
            "name": self.name,
            "status": self.status.value,
            "accumulatedPercentage": self.accumulated_percentage,
            "connectedAt": self.connected_at.isoformat(),
            "lastActivityAt": self.last_activity_at.isoformat() if self.last_activity_at else None,
            "classification": self.classification.value,
            "classificationIcon": self.classification_icon,
            "motivationalMessage": self.motivational_message,
        }
    
    def to_summary(self) -> Dict:
        """Versión resumida para dashboard"""
        return {
            "sessionId": self.session_id,
            "name": self.name,
            "status": self.status.value,
            "accumulatedPercentage": self.accumulated_percentage,
            "classification": self.classification.value,
            "classificationIcon": self.classification_icon,
        }

# ============================================================
# MODELO: ACTIVIDAD
# ============================================================

class ActivityData:
    """Datos de actividad para estudiantes"""
    def __init__(self, activity_id: str, question: str, options: List[str],
                 correct_index: int, percentage_value: float,
                 activity_type: StudentActivityType = StudentActivityType.MULTIPLE_CHOICE,
                 time_limit_seconds: Optional[int] = None,
                 title: Optional[str] = None,
                 slide_content: Optional[str] = None,
                 biblical_reference: Optional[str] = None):
        self.id = activity_id
        self.question = question
        self.options = options
        self.correct_index = correct_index
        self.percentage_value = percentage_value
        self.activity_type = activity_type
        self.state = ActivityState.LOCKED
        self.time_limit_seconds = time_limit_seconds
        self.title = title  # Título de la diapositiva/actividad
        self.slide_content = slide_content  # Contenido extra (ej: la cita bíblica)
        self.biblical_reference = biblical_reference  # Referencia bíblica (ej: "Eclesiastés 1:2")
    
    def to_student_dict(self) -> Dict:
        """Versión para estudiante (sin respuesta correcta)"""
        return {
            "id": self.id,
            "type": self.activity_type.value,
            "question": self.question,
            "options": self.options,
            "percentageValue": self.percentage_value,
            "state": self.state.value,
            "timeLimitSeconds": self.time_limit_seconds,
            "title": self.title,
            "slideContent": self.slide_content,
            "biblicalReference": self.biblical_reference,
        }
    
    def to_dict(self) -> Dict:
        """Versión completa para docente"""
        data = self.to_student_dict()
        data["correctIndex"] = self.correct_index
        return data

# ============================================================
# MANAGER DE ESTUDIANTES
# ============================================================

class StudentManager:
    """Gestiona estudiantes conectados - Soporta hasta 100 conexiones simultáneas"""
    def __init__(self):
        self.students: Dict[str, StudentData] = {}  # session_id -> StudentData
        self.names_in_use: set = set()  # Nombres activos (evita duplicados)
        self.websocket_to_student: Dict[WebSocket, str] = {}  # websocket -> session_id
        self._load_saved_students()
    
    def _load_saved_students(self):
        """Carga estudiantes con progreso guardado (sin WebSocket activo)"""
        global _saved_progress
        saved_students = _saved_progress.get("students", {})
        for name, data in saved_students.items():
            # No crear conexión, solo guardar datos para reconexión
            print(f"[INFO] Progreso cargado: {name} - {data.get('accumulated_percentage', 0)}%")
    
    def _get_saved_data(self, name: str) -> Optional[Dict]:
        """Obtiene datos guardados de un estudiante por nombre"""
        global _saved_progress
        name_lower = name.lower()
        for saved_name, data in _saved_progress.get("students", {}).items():
            if saved_name.lower() == name_lower:
                return data
        return None
    
    def _save_all_progress(self):
        """Guarda el progreso de todos los estudiantes"""
        global _saved_progress
        students_data = {}
        for student in self.students.values():
            students_data[student.name] = student.to_saveable()
        save_progress(students_data)
        _saved_progress = load_progress()
    
    def _find_student_by_name(self, name: str) -> Optional[StudentData]:
        """Busca estudiante por nombre (ignorando mayúsculas)"""
        name_lower = name.strip().lower()
        for student in self.students.values():
            if student.name.lower() == name_lower:
                return student
        return None
    
    def validate_name(self, name: str, allow_reconnect: bool = True) -> tuple[bool, str]:
        """Valida nombre de estudiante"""
        name = name.strip()
        
        if len(name) < 3:
            return False, "El nombre debe tener al menos 3 caracteres"
        
        if len(name) > 50:
            return False, "El nombre no puede exceder 50 caracteres"
        
        # Verificar si existe un estudiante con este nombre
        existing = self._find_student_by_name(name)
        if existing:
            # Si está desconectado, permitir reconexión
            if allow_reconnect and existing.status == StudentConnectionStatus.DISCONNECTED:
                return True, "RECONNECT"
            # Si está conectado, rechazar
            if existing.status != StudentConnectionStatus.DISCONNECTED:
                return False, "Este nombre ya está en uso en la clase"
        
        # Verificar si hay datos guardados (estudiante anterior que se reconecta)
        if self._get_saved_data(name):
            return True, "RESTORE"
        
        return True, "OK"
    
    def register_student(self, name: str, websocket: WebSocket) -> tuple[Optional[StudentData], str]:
        """Registra un nuevo estudiante o reconecta uno existente"""
        name = name.strip()
        
        # Validar nombre
        is_valid, message = self.validate_name(name)
        if not is_valid:
            return None, message
        
        # Si el mensaje es RECONNECT, reconectar al estudiante existente
        if message == "RECONNECT":
            return self.reconnect_student(name, websocket)
        
        # Generar ID de sesión
        session_id = generate_session_id()
        
        # Verificar si hay datos guardados para restaurar
        saved_data = self._get_saved_data(name)
        
        # Crear estudiante (con datos guardados si existen)
        student = StudentData(session_id, name, from_saved=saved_data)
        student.websocket = websocket
        
        # Registrar
        self.students[session_id] = student
        self.names_in_use.add(name)
        self.websocket_to_student[websocket] = session_id
        
        print(f"[INFO] Estudiante registrado: {name} (ID: {session_id})")
        return student, "OK"
    
    def reconnect_student(self, name: str, websocket: WebSocket) -> tuple[Optional[StudentData], str]:
        """Intenta reconectar un estudiante existente"""
        student = self._find_student_by_name(name)
        
        if student:
            # Estudiante encontrado, reconectar
            student.websocket = websocket
            student.status = StudentConnectionStatus.CONNECTED
            self.websocket_to_student[websocket] = student.session_id
            print(f"[INFO] Estudiante reconectado: {student.name}")
            return student, "Reconectado exitosamente"
        
        return None, "No se encontró sesión previa"
    
    def disconnect_student(self, websocket: WebSocket):
        """Desconecta un estudiante y guarda su progreso"""
        session_id = self.websocket_to_student.pop(websocket, None)
        if session_id and session_id in self.students:
            student = self.students[session_id]
            student.status = StudentConnectionStatus.DISCONNECTED
            student.websocket = None
            print(f"[INFO] Estudiante desconectado: {student.name}")
            # Guardar progreso al desconectar
            self._save_all_progress()
    
    def get_student_by_websocket(self, websocket: WebSocket) -> Optional[StudentData]:
        """Obtiene estudiante por websocket"""
        session_id = self.websocket_to_student.get(websocket)
        return self.students.get(session_id) if session_id else None
    
    def get_student_by_session(self, session_id: str) -> Optional[StudentData]:
        """Obtiene estudiante por ID de sesión"""
        return self.students.get(session_id)
    
    def get_connected_students(self) -> List[StudentData]:
        """Obtiene lista de estudiantes conectados"""
        return [s for s in self.students.values() 
                if s.status != StudentConnectionStatus.DISCONNECTED]
    
    def get_dashboard_summary(self, current_activity_id: Optional[str] = None) -> Dict:
        """Obtiene resumen para dashboard del docente"""
        connected = self.get_connected_students()
        responded = [s for s in connected if s.status == StudentConnectionStatus.RESPONDED]
        not_responded = [s for s in connected if s.status == StudentConnectionStatus.NOT_RESPONDED]
        
        return {
            "students": [s.to_summary() for s in connected],
            "totalStudents": len(connected),
            "respondedCount": len(responded),
            "notRespondedCount": len(not_responded),
            "currentActivityId": current_activity_id,
            "responseRate": (len(responded) / len(connected) * 100) if connected else 0,
        }
    
    def reset_all_for_new_activity(self):
        """Resetea todos los estudiantes para nueva actividad"""
        for student in self.get_connected_students():
            student.reset_for_new_activity()
    
    async def broadcast_to_students(self, message: Dict):
        """Envía mensaje a todos los estudiantes conectados"""
        json_msg = json.dumps(message, ensure_ascii=False)
        disconnected = []
        
        for _, student in self.students.items():
            if student.websocket and student.status != StudentConnectionStatus.DISCONNECTED:
                try:
                    await student.websocket.send_text(json_msg)
                except (ConnectionError, RuntimeError) as e:
                    print(f"[ERROR] Error enviando a {student.name}: {e}")
                    disconnected.append(student.websocket)
        
        for ws in disconnected:
            self.disconnect_student(ws)
    
    async def send_to_student(self, session_id: str, message: Dict):
        """Envía mensaje a un estudiante específico"""
        student = self.students.get(session_id)
        if student and student.websocket:
            try:
                await student.websocket.send_text(
                    json.dumps(message, ensure_ascii=False)
                )
            except (ConnectionError, RuntimeError) as e:
                print(f"[ERROR] Error enviando a {student.name}: {e}")

student_manager = StudentManager()

# ============================================================
# MANAGER DE CONEXIONES (DOCENTE)
# ============================================================

class TeacherConnectionManager:
    """Gestiona conexiones de docentes"""
    def __init__(self):
        self.teacher_connections: List[WebSocket] = []
    
    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.teacher_connections.append(websocket)
        print(f"[INFO] Docente conectado (Total: {len(self.teacher_connections)})")
    
    def disconnect(self, websocket: WebSocket):
        if websocket in self.teacher_connections:
            self.teacher_connections.remove(websocket)
            print("[INFO] Docente desconectado")
    
    async def broadcast_to_teachers(self, message: Dict):
        """Envía mensaje a todos los docentes"""
        json_msg = json.dumps(message, ensure_ascii=False)
        disconnected = []
        
        for ws in self.teacher_connections:
            try:
                await ws.send_text(json_msg)
            except (ConnectionError, RuntimeError):
                disconnected.append(ws)
        
        for ws in disconnected:
            self.disconnect(ws)

teacher_manager = TeacherConnectionManager()

# ============================================================
# ESTADO DE LA CLASE
# ============================================================

class ClassState:
    """Estado global de la clase"""
    def __init__(self):
        self.current_state = "LOBBY"
        self.current_slide_index = 0
        self.current_block_index = 0
        self.current_activity: Optional[ActivityData] = None
        self.activities: Dict[str, ActivityData] = {}  # activity_id -> ActivityData
        self.reflections: List[Dict] = []  # Todas las reflexiones recibidas
    
    def register_activity(self, activity_id: str, question: str, options: List[str],
                         correct_index: int, percentage_value: float,
                         activity_type: str = "multipleChoice",
                         time_limit: Optional[int] = None,
                         title: Optional[str] = None,
                         slide_content: Optional[str] = None,
                         biblical_reference: Optional[str] = None):
        """Registra una actividad"""
        act_type = StudentActivityType(activity_type) if activity_type else StudentActivityType.MULTIPLE_CHOICE
        activity = ActivityData(
            activity_id=activity_id,
            question=question,
            options=options,
            correct_index=correct_index,
            percentage_value=percentage_value,
            activity_type=act_type,
            time_limit_seconds=time_limit,
            title=title,
            slide_content=slide_content,
            biblical_reference=biblical_reference
        )
        self.activities[activity_id] = activity
        return activity
    
    def get_activity(self, activity_id: str) -> Optional[ActivityData]:
        return self.activities.get(activity_id)
    
    def to_dict(self) -> Dict:
        return {
            "state": self.current_state,
            "slide": self.current_slide_index,
            "block": self.current_block_index,
            "currentActivity": self.current_activity.to_student_dict() if self.current_activity else None,
        }

state = ClassState()

# ============================================================
# ENDPOINTS HTTP
# ============================================================

@app.get("/")
async def root():
    """Endpoint de verificación"""
    connected_students = student_manager.get_connected_students()
    return {
        "status": "ok",
        "message": "Sapiencial App Server Running",
        "version": "2.0.0",
        "connectedStudents": len(connected_students),
        "connectedTeachers": len(teacher_manager.teacher_connections),
    }

@app.get("/state")
async def get_state():
    """Obtiene el estado actual de la clase"""
    return state.to_dict()

@app.get("/students")
async def get_students():
    """Obtiene lista de estudiantes (para debug)"""
    return student_manager.get_dashboard_summary(
        state.current_activity.id if state.current_activity else None
    )

@app.post("/validate-name")
async def validate_student_name(name: str = Query(...)):
    """Valida si un nombre est? disponible"""
    is_valid, message = student_manager.validate_name(name)
    return {"valid": is_valid, "message": message}

# ============================================================
# WEBSOCKET - DOCENTE
# ============================================================

@app.websocket("/ws/teacher")
async def teacher_websocket(
    websocket: WebSocket,
    token: str = Query(default="")
):
    """WebSocket para docente"""
    if not validate_token(token, "teacher"):
        await websocket.accept()
        await websocket.send_text(json.dumps({
            "type": "ERROR",
            "data": {"message": "Token inválido", "code": "AUTH_FAILED"}
        }))
        await websocket.close(code=4003)
        return
    
    await teacher_manager.connect(websocket)
    
    try:
        # Enviar estado inicial
        await websocket.send_text(json.dumps({
            "type": "STATE_UPDATE",
            "data": state.to_dict()
        }))
        
        # Enviar resumen de estudiantes
        await websocket.send_text(json.dumps({
            "type": "DASHBOARD_UPDATE",
            "data": student_manager.get_dashboard_summary(
                state.current_activity.id if state.current_activity else None
            )
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
            
            await handle_teacher_action(websocket, message)
    
    except WebSocketDisconnect:
        teacher_manager.disconnect(websocket)
    except (ConnectionError, RuntimeError, json.JSONDecodeError) as e:
        print(f"[ERROR] Teacher WebSocket: {e}")
        teacher_manager.disconnect(websocket)

async def handle_teacher_action(websocket: WebSocket, message: Dict):
    """Procesa acciones del docente"""
    action = message.get("action")
    payload = message.get("payload", {})
    
    if action == "SET_STATE":
        state.current_state = payload.get("state", state.current_state)
        await broadcast_all({
            "type": "STATE_UPDATE",
            "data": {"state": state.current_state}
        })
    
    elif action == "SET_SLIDE":
        state.current_slide_index = payload.get("slide", state.current_slide_index)
        state.current_block_index = payload.get("block", state.current_block_index)
        await broadcast_all({
            "type": "SLIDE_UPDATE",
            "data": {
                "slide": state.current_slide_index,
                "block": state.current_block_index
            }
        })
    
    elif action == "REGISTER_ACTIVITY":
        # Registrar actividad antes de habilitarla
        activity = state.register_activity(
            activity_id=payload.get("activityId"),
            question=payload.get("question", ""),
            options=payload.get("options", []),
            correct_index=payload.get("correctIndex", 0),
            percentage_value=payload.get("percentageValue", 10.0),
            activity_type=payload.get("activityType", "multipleChoice"),
            time_limit=payload.get("timeLimitSeconds"),
            title=payload.get("title"),
            slide_content=payload.get("slideContent"),
            biblical_reference=payload.get("biblicalReference")
        )
        await websocket.send_text(json.dumps({
            "type": "ACTIVITY_REGISTERED",
            "data": activity.to_dict()
        }))
    
    elif action == "UNLOCK_ACTIVITY":
        activity_id = payload.get("activityId")
        activity = state.get_activity(activity_id)
        
        if activity:
            activity.state = ActivityState.ACTIVE
            state.current_activity = activity
            student_manager.reset_all_for_new_activity()
            
            # Enviar a estudiantes (sin respuesta correcta)
            await student_manager.broadcast_to_students({
                "type": "ACTIVITY_UNLOCKED",
                "data": activity.to_student_dict()
            })
            
            # Actualizar dashboard
            await teacher_manager.broadcast_to_teachers({
                "type": "DASHBOARD_UPDATE",
                "data": student_manager.get_dashboard_summary(activity_id)
            })
    
    elif action == "LOCK_ACTIVITY":
        if state.current_activity:
            state.current_activity.state = ActivityState.CLOSED
        
        await student_manager.broadcast_to_students({
            "type": "ACTIVITY_LOCKED",
            "data": {}
        })
        
        await teacher_manager.broadcast_to_teachers({
            "type": "DASHBOARD_UPDATE",
            "data": student_manager.get_dashboard_summary()
        })
    
    elif action == "LOCK_ALL_ACTIVITIES":
        # Cerrar TODAS las actividades activas de una vez
        closed_count = 0
        for activity in state.activities.values():
            if activity.state == ActivityState.ACTIVE:
                activity.state = ActivityState.CLOSED
                closed_count += 1
        
        state.current_activity = None
        
        # Notificar a todos los estudiantes
        await student_manager.broadcast_to_students({
            "type": "ALL_ACTIVITIES_LOCKED",
            "data": {"closedCount": closed_count}
        })
        
        # Actualizar dashboard
        await teacher_manager.broadcast_to_teachers({
            "type": "DASHBOARD_UPDATE",
            "data": student_manager.get_dashboard_summary()
        })
        
        print(f"[INFO] {closed_count} actividades cerradas")
    
    elif action == "REVEAL_ANSWER":
        activity_id = payload.get("activityId")
        activity = state.get_activity(activity_id)
        
        if activity:
            await broadcast_all({
                "type": "ANSWER_REVEALED",
                "data": {
                    "activityId": activity_id,
                    "correctIndex": activity.correct_index
                }
            })
    
    elif action == "GET_REFLECTIONS":
        # Enviar todas las reflexiones al docente
        all_reflections = []
        for student in student_manager.students.values():
            all_reflections.extend(student.reflections)
        
        await websocket.send_text(json.dumps({
            "type": "REFLECTIONS_LIST",
            "data": {"reflections": all_reflections}
        }))
    
    elif action == "REQUEST_DASHBOARD":
        # Docente solicita actualización del dashboard
        await websocket.send_text(json.dumps({
            "type": "DASHBOARD_UPDATE",
            "data": student_manager.get_dashboard_summary(
                state.current_activity.id if state.current_activity else None
            )
        }))

async def broadcast_all(message: Dict):
    """Envía mensaje a docentes y estudiantes"""
    await teacher_manager.broadcast_to_teachers(message)
    await student_manager.broadcast_to_students(message)

# ============================================================
# WEBSOCKET - ESTUDIANTE
# ============================================================

@app.websocket("/ws/student")
async def student_websocket(websocket: WebSocket):
    """WebSocket para estudiante"""
    await websocket.accept()
    student: Optional[StudentData] = None
    
    try:
        # Esperar registro del estudiante
        await websocket.send_text(json.dumps({
            "type": "REGISTRATION_REQUIRED",
            "data": {"message": "Por favor, ingresa tu nombre"}
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
            
            action = message.get("action")
            payload = message.get("payload", {})
            
            # ---- REGISTRO DE ESTUDIANTE ----
            if action == "REGISTER":
                name = payload.get("name", "").strip()
                reconnect = payload.get("reconnect", False)
                
                if reconnect:
                    # Intentar reconexión
                    student, msg = student_manager.reconnect_student(name, websocket)
                    if student:
                        await websocket.send_text(json.dumps({
                            "type": "REGISTRATION_SUCCESS",
                            "data": {
                                **student.to_dict(),
                                "reconnected": True
                            }
                        }))
                    else:
                        # No encontrado, registrar como nuevo
                        student, msg = student_manager.register_student(name, websocket)
                        if student:
                            await websocket.send_text(json.dumps({
                                "type": "REGISTRATION_SUCCESS",
                                "data": student.to_dict()
                            }))
                        else:
                            await websocket.send_text(json.dumps({
                                "type": "REGISTRATION_ERROR",
                                "data": {"message": msg}
                            }))
                            continue
                else:
                    # Nuevo registro
                    student, msg = student_manager.register_student(name, websocket)
                    if student:
                        await websocket.send_text(json.dumps({
                            "type": "REGISTRATION_SUCCESS",
                            "data": student.to_dict()
                        }))
                    else:
                        await websocket.send_text(json.dumps({
                            "type": "REGISTRATION_ERROR",
                            "data": {"message": msg}
                        }))
                        continue
                
                # Enviar estado actual
                await websocket.send_text(json.dumps({
                    "type": "STATE_UPDATE",
                    "data": state.to_dict()
                }))
                
                # IMPORTANTE: Si hay actividad activa, enviarla explícitamente
                if state.current_activity and state.current_activity.state == ActivityState.ACTIVE:
                    await websocket.send_text(json.dumps({
                        "type": "ACTIVITY_UNLOCKED",
                        "data": state.current_activity.to_student_dict()
                    }))
                    print(f"[INFO] Actividad activa enviada a {student.name}: {state.current_activity.id}")
                
                # Notificar al docente
                await teacher_manager.broadcast_to_teachers({
                    "type": "STUDENT_JOINED",
                    "data": student.to_summary()
                })
                await teacher_manager.broadcast_to_teachers({
                    "type": "DASHBOARD_UPDATE",
                    "data": student_manager.get_dashboard_summary(
                        state.current_activity.id if state.current_activity else None
                    )
                })
            
            # ---- ENVIAR RESPUESTA ----
            elif action == "SUBMIT_ANSWER":
                if not student:
                    await websocket.send_text(json.dumps({
                        "type": "ERROR",
                        "data": {"message": "Debes registrarte primero"}
                    }))
                    continue
                
                activity_id = payload.get("activityId")
                answer = payload.get("answer")
                response_time_ms = payload.get("responseTimeMs")
                
                # Verificar actividad
                activity = state.get_activity(activity_id)
                if not activity:
                    await websocket.send_text(json.dumps({
                        "type": "ERROR",
                        "data": {"message": "Actividad no encontrada"}
                    }))
                    continue
                
                if activity.state != ActivityState.ACTIVE:
                    await websocket.send_text(json.dumps({
                        "type": "ERROR",
                        "data": {"message": "La actividad no est? activa"}
                    }))
                    continue
                
                if student.has_responded(activity_id):
                    await websocket.send_text(json.dumps({
                        "type": "ERROR",
                        "data": {"message": "Ya has respondido esta actividad"}
                    }))
                    continue
                
                # Evaluar respuesta
                is_correct = (answer == activity.correct_index)
                
                # Registrar respuesta
                student.add_response(
                    activity_id=activity_id,
                    answer=answer,
                    is_correct=is_correct,
                    percentage_value=activity.percentage_value,
                    response_time_ms=response_time_ms
                )
                
                # Confirmar al estudiante (sin revelar si es correcta)
                await websocket.send_text(json.dumps({
                    "type": "ANSWER_RECEIVED",
                    "data": {
                        "activityId": activity_id,
                        "accumulatedPercentage": student.accumulated_percentage,
                        "motivationalMessage": student.motivational_message,
                    }
                }))
                
                # Notificar al docente
                await teacher_manager.broadcast_to_teachers({
                    "type": "STUDENT_RESPONDED",
                    "data": {
                        "studentSessionId": student.session_id,
                        "studentName": student.name,
                        "activityId": activity_id,
                        "answer": answer,
                        "isCorrect": is_correct,
                        "accumulatedPercentage": student.accumulated_percentage,
                    }
                })
                
                # Actualizar dashboard
                await teacher_manager.broadcast_to_teachers({
                    "type": "DASHBOARD_UPDATE",
                    "data": student_manager.get_dashboard_summary(activity_id)
                })
                
                # Guardar progreso después de cada respuesta
                student_manager._save_all_progress()
            
            # ---- ENVIAR reflexión ----
            elif action == "SUBMIT_REFLECTION":
                if not student:
                    await websocket.send_text(json.dumps({
                        "type": "ERROR",
                        "data": {"message": "Debes registrarte primero"}
                    }))
                    continue
                
                topic = payload.get("topic", "General")
                content = payload.get("content", "").strip()
                
                if len(content) < 10:
                    await websocket.send_text(json.dumps({
                        "type": "ERROR",
                        "data": {"message": "La reflexión debe tener al menos 10 caracteres"}
                    }))
                    continue
                
                # Registrar reflexión
                reflection = student.add_reflection(topic, content)
                
                # Confirmar al estudiante
                await websocket.send_text(json.dumps({
                    "type": "REFLECTION_RECEIVED",
                    "data": {"message": "reflexión enviada correctamente"}
                }))
                
                # Notificar al docente
                await teacher_manager.broadcast_to_teachers({
                    "type": "NEW_REFLECTION",
                    "data": reflection
                })
            
            # ---- SOLICITAR ESTADO ----
            elif action == "GET_STATE":
                await websocket.send_text(json.dumps({
                    "type": "STATE_UPDATE",
                    "data": state.to_dict()
                }))
                
                if student:
                    await websocket.send_text(json.dumps({
                        "type": "STUDENT_UPDATE",
                        "data": student.to_dict()
                    }))
    
    except WebSocketDisconnect:
        if student:
            student_manager.disconnect_student(websocket)
            # Notificar al docente
            await teacher_manager.broadcast_to_teachers({
                "type": "STUDENT_LEFT",
                "data": {"sessionId": student.session_id, "name": student.name}
            })
            await teacher_manager.broadcast_to_teachers({
                "type": "DASHBOARD_UPDATE",
                "data": student_manager.get_dashboard_summary(
                    state.current_activity.id if state.current_activity else None
                )
            })
    except (ConnectionError, RuntimeError, json.JSONDecodeError) as e:
        print(f"[ERROR] Student WebSocket: {e}")
        if student:
            student_manager.disconnect_student(websocket)

# ============================================================
# ENDPOINT LEGACY (desarrollo)
# ============================================================

@app.websocket("/ws-dev/{role}")
async def websocket_dev_endpoint(websocket: WebSocket, role: str):
    """Endpoint de desarrollo SIN autenticación"""
    if role == "teacher":
        await teacher_manager.connect(websocket)
        try:
            await websocket.send_text(json.dumps({
                "type": "STATE_UPDATE",
                "data": state.to_dict()
            }))
            while True:
                data = await websocket.receive_text()
                message = json.loads(data)
                await handle_teacher_action(websocket, message)
        except WebSocketDisconnect:
            teacher_manager.disconnect(websocket)
    elif role == "student":
        # Redirigir a endpoint de estudiante
        await student_websocket(websocket)

