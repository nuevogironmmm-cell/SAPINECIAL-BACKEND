# ?? Gu?a de Despliegue - Literatura Sapiencial

## Arquitectura de Despliegue

```
???????????????????         ???????????????????
?    NETLIFY      ?         ?     RENDER      ?
?   (Frontend)    ? ??WSS????   (Backend)     ?
?  Flutter Web    ?         ?  FastAPI/Python ?
???????????????????         ???????????????????
```

## PASO 1: Desplegar Backend en Render

### 1.1 Crear cuenta en Render
1. Ve a https://render.com
2. Reg?strate con tu cuenta de GitHub

### 1.2 Crear nuevo servicio Web
1. Click en **"New +"** ? **"Web Service"**
2. Conecta tu repositorio de GitHub o sube manualmente
3. Configura:
   - **Name**: `sapiencial-backend`
   - **Region**: Oregon (US West)
   - **Branch**: main
   - **Root Directory**: `backend`
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### 1.3 Variables de Entorno (opcional)
No se requieren variables de entorno adicionales por ahora.

### 1.4 Obtener la URL
Una vez desplegado, Render te dar? una URL como:
```
https://sapiencial-backend.onrender.com
```

**?? IMPORTANTE**: Copia esta URL, la necesitar?s para el frontend.

---

## PASO 2: Actualizar URL del Frontend

### 2.1 Editar app_config.dart
Abre `frontend/lib/config/app_config.dart` y actualiza la URL:

```dart
static const String _productionBackendUrl = 'wss://TU-URL-DE-RENDER.onrender.com';
```

### 2.2 Reconstruir el frontend
```bash
cd frontend
flutter build web --release
```

---

## PASO 3: Desplegar Frontend en Netlify

### 3.1 Opci?n A: Arrastrar y soltar (m?s f?cil)
1. Ve a https://app.netlify.com
2. Arrastra la carpeta `frontend/build/web` al ?rea de deploy
3. ?Listo! Netlify te dar? una URL

### 3.2 Opci?n B: Conectar con GitHub
1. En Netlify, click **"Add new site"** ? **"Import an existing project"**
2. Conecta tu repositorio de GitHub
3. Configura:
   - **Base directory**: `frontend`
   - **Build command**: (dejar vac?o - subimos build manual)
   - **Publish directory**: `frontend/build/web`

### 3.3 Configurar dominio personalizado (opcional)
En **Site settings** ? **Domain management** puedes:
- Usar el subdominio de Netlify: `tu-app.netlify.app`
- Agregar un dominio personalizado

---

## PASO 4: Verificar el despliegue

### 4.1 Probar el backend
Visita: `https://tu-backend.onrender.com/health`
Debe responder: `{"status": "healthy"}`

### 4.2 Probar la aplicaci?n
1. Abre la URL de Netlify en una ventana (Docente)
2. Abre en otra ventana/inc?gnito (Estudiante)
3. Ingresa como docente con contrase?a: `1234`
4. Ingresa como estudiante con cualquier nombre

---

## ?? Soluci?n de Problemas

### "No se puede conectar al servidor"
- Verifica que el backend en Render esté corriendo (puede tardar en despertar si es plan gratuito)
- El plan gratuito de Render duerme después de 15 min de inactividad
- Soluci?n: Visitar `/health` para despertar el servidor

### WebSocket no conecta
- Verifica que la URL en `app_config.dart` use `wss://` (con SSL)
- Render provee SSL autom?ticamente

### CORS errors
- El backend ya tiene CORS configurado para aceptar todas las origins
- Si persiste, verifica la consola del navegador

---

## ?? Estructura de archivos importantes

```
proyecto/
??? backend/
?   ??? main.py              # Servidor FastAPI
?   ??? requirements.txt     # Dependencias Python
?   ??? render.yaml          # Config de Render
?
??? frontend/
?   ??? lib/
?   ?   ??? config/
?   ?       ??? app_config.dart  # ? Configurar URL aqu?
?   ??? build/
?   ?   ??? web/             # ? Subir esta carpeta a Netlify
?   ??? netlify.toml         # Config de Netlify
```

---

## ?? Tips

1. **Plan gratuito de Render**: El servidor duerme después de 15 min. Primera conexi?n puede tardar ~30 seg.

2. **Para desarrollo local**: La app autom?ticamente usa `localhost:8000` cuando no est? en modo release.

3. **Hot reload no funciona en web**: Usa `flutter run -d chrome` para desarrollo.

---

?Disfruta tu app desplegada! ??
