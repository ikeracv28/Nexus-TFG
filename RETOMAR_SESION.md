# Retomar sesión — Nexus TFG

> Leer este archivo al inicio de cada sesión para recuperar el contexto completo.
> Actualizado: 01/05/2026

---

## Dónde estamos

Proyecto: plataforma de gestión de prácticas FCT (TFG de Iker Acevedo).
Entrega Hito 3 (75%): **5 mayo 2026 — quedan 4 días**.
Entrega final: 19 mayo 2026.

El código está en GitHub: `https://github.com/ikeracv28/Nexus-TFG.git`, rama `main`.
Docker Compose levanta tres contenedores: `nexus-db` (Postgres), `nexus-api` (Spring Boot), `nexus-web` (Flutter/Nginx en puerto 3000).

---

## Qué está implementado y funciona

| Módulo | Estado |
|--------|--------|
| Auth JWT + logout server-side (JTI blacklist) | ✅ |
| Rutas por rol con go_router (admin/tutor-centro/tutor-empresa/alumno) | ✅ |
| OWASP Bloque 1 y 2 completos (CORS, RateLimit, headers, logout, passwords) | ✅ |
| DashboardScreen alumno — 4 tabs (Inicio, Seguimientos, Incidencias, Chat placeholder) | ✅ |
| SeguimientosScreen — lista de partes + FAB → formulario → POST /seguimientos | ✅ |
| IncidenciasScreen — lista + bottom sheet para reportar incidencia | ✅ |
| PanelTutorEmpresaScreen — lista partes, validar/rechazar | ✅ |
| PanelTutorCentroScreen — 5 modos sidebar (Dashboard, Alumnos, Partes, Incidencias, Chat) | ✅ |
| PanelTutorCentroScreen Dashboard — 4 stat cards + secciones carga/incidencias | ✅ (con bug, ver abajo) |
| PanelAdminScreen — 3 modos (usuarios, prácticas, empresas) + mobile navbar | ✅ |
| nginx.conf con Cache-Control correcto para Flutter web | ✅ |

---

## Bug conocido pendiente (SIGUIENTE TAREA)

**Dashboard tutor centro**: Los paneles `_AlumnosYCarga` e `_IncidenciasRecientes` no se ven.
- Las 4 stat cards y las horas sí aparecen.
- El backend devuelve datos correctamente (confirmado con curl y DB).
- **Causa probable**: `LayoutBuilder` dentro de `SingleChildScrollView` recibe `maxHeight = infinity`, colapsando la altura de los widgets inferiores.
- **Archivo**: `frontend/lib/presentation/screens/panel_tutor_centro_screen.dart`
- **Fix**: quitar el `LayoutBuilder` o reestructurar para que `_AlumnosYCarga` e `_IncidenciasRecientes` tengan altura intrínseca sin depender de constraints del padre.

---

## Tareas pendientes por orden de prioridad

1. **Fix dashboard tutor centro** — bug LayoutBuilder (~30 min)
2. **Tests OWASP A01.2 y A01.3** — alumno A no puede ver prácticas de alumno B; alumno sin práctica no accede a ajena (~1h, en `backend/tfg-nexus-api/src/test/`)
3. **Actualizar ARQUITECTURA_API.md** — documentar todos los endpoints ya implementados (~30 min)
4. **Grabar vídeo demo Hito 3** — flujo completo todos los roles (tú lo grabas, yo no)
5. (Opcional Hito 3 / Seguro Hito 4) **WebSocket/STOMP chat** — placeholder ya existe en ambas pantallas

---

## Arrancar el entorno en el curro

```bash
# Si es la primera vez en este equipo, clonar primero:
git clone https://github.com/ikeracv28/Nexus-TFG.git
cd Nexus-TFG

# Si ya está clonado, actualizar:
git pull origin main

# Levantar todo:
docker-compose build --no-cache backend frontend
docker rm -f nexus-db nexus-api nexus-web
docker-compose up -d
```

Después abrir `http://localhost:3000` y hacer **Ctrl+Shift+R** para vaciar caché Flutter.

---

## Usuarios de prueba

| Email | Contraseña | Rol |
|-------|-----------|-----|
| admin@nexus.edu | Admin@Nexus2026 | ADMIN |
| tutor@nexus.edu | Tutor@Nexus2026 | TUTOR_CENTRO |
| alumno@nexus.edu | Alumno@Nexus2026 | ALUMNO |
| tutorempresa@nexus.edu | Empresa@Nexus2026 | TUTOR_EMPRESA |

---

## Archivos clave si hay que revisar código

| Qué | Dónde |
|-----|-------|
| Pantalla tutor centro (bug) | `frontend/lib/presentation/screens/panel_tutor_centro_screen.dart` |
| Provider tutor centro | `frontend/lib/presentation/providers/tutor_centro_provider.dart` |
| Pantalla alumno dashboard | `frontend/lib/presentation/screens/dashboard_screen.dart` |
| Pantalla admin | `frontend/lib/presentation/screens/panel_admin_screen.dart` |
| Tests backend | `backend/tfg-nexus-api/src/test/java/` |
| Hitos y estado | `planes/estado-hitos.md` |
| Historial técnico | `HISTORIAL_CAMBIOS.md` |
| Contrato API REST | `ARQUITECTURA_API.md` |
