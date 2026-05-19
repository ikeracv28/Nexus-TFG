# Prompt de limpieza — Repositorio de entrega TFG

Copia y pega esto en el chat de Claude del repositorio de entrega.

---

## PROMPT

Eres Claude Code trabajando en el repositorio de entrega de un TFG de desarrollo de software. Este repositorio es el que verá el profesor evaluador y debe estar completamente limpio y profesional. El repositorio de desarrollo (privado) contiene archivos de configuración de herramientas de IA que NO deben aparecer aquí.

Tu tarea es hacer una limpieza completa y dejar el repositorio en estado profesional.

---

### FASE 1 — Eliminar archivos de herramientas IA y trabajo interno

Elimina todos estos archivos y carpetas del repositorio (git rm + commit):

**Carpetas enteras:**
- `planes/` — planes de trabajo internos con IA
- `conductor/` — configuración de agente IA (Conductor)
- `.agents/` — configuración de agentes IA

**Archivos de configuración IA en raíz:**
- `CLAUDE.md` — instrucciones para Claude Code
- `GEMINI.md` — instrucciones para Gemini
- `skills-lock.json` — lock de skills de Claude Code
- `DESIGN_SYSTEM.md` — referencia interna del design system
- `HISTORIAL_CAMBIOS.md` — bitácora de sesiones de IA
- `RETOMAR_SESION.md` — contexto para retomar sesión con IA
- `PLAN_SEGURIDAD_OWASP.md` — checklist interno de seguridad
- `contexto_proyecto.md` — contexto interno del proyecto
- `ACTUALIZACIONES_MEMORIA.md` — notas internas de memoria
- `MEMORIA_ACTUALIZACIONES.md` — bloques de memoria para la memoria Word
- `MEMORIA_NUEVA_CONTENIDO.md` — borradores de memoria
- `Feedback.md` — feedback de tutorías (notas internas)

**Archivos de configuración IA en subcarpetas:**
- `backend/GEMINI.md`
- `backend/contexto_proyecto.md`
- `backend/ARQUITECTURA_API.md` (duplicado del de raíz)
- `backend/MEMORIA_SEGUIMIENTO_ENTREGA_1.md`
- `frontend/GEMINI.md`
- `frontend/contexto_proyecto.md`
- `frontend/ARQUITECTURA_API.md` (duplicado del de raíz)

**Borradores de memoria/documentación:**
- `memoria75%.md`
- `MemoriaEnMd.md`
- `Memoria TFG Iker-Acevedo 75% (1).md`
- `Memoria TFG Iker-Acevedo 75% (2).md`
- `Captura de pantalla 2026-04-29 202731.md`

---

### FASE 2 — Revisar y pulir el README.md

El README.md debe ser profesional y útil para el evaluador. Estructura sugerida:

```markdown
# Nexus — Plataforma de Gestión de Prácticas FCT

Breve descripción del proyecto (2-3 líneas).

## Stack tecnológico
[tabla con Backend/Frontend/Base de datos/Infraestructura]

## Requisitos previos
- Docker Desktop
- Git

## Arranque rápido
[comandos docker-compose para levantar el proyecto]

## Acceso a la aplicación
[URL y usuarios de prueba de cada rol]

## Estructura del proyecto
[árbol de carpetas explicado brevemente]

## Documentación
[links a ARQUITECTURA_API.md, MANUAL_USUARIO.md, ERD_DATABASE.md]
```

Elimina del README cualquier mención a:
- Claude Code, Gemini, IA, herramientas de agentes
- Archivos internos que ya habrás borrado
- Rutas de archivos que ya no existen

---

### FASE 3 — Revisar el .gitignore

Añade al `.gitignore` para que nunca aparezcan en este repo:
```
# Archivos de herramientas IA
CLAUDE.md
GEMINI.md
skills-lock.json
.agents/
conductor/
planes/
DESIGN_SYSTEM.md
HISTORIAL_CAMBIOS.md
RETOMAR_SESION.md
PLAN_SEGURIDAD_OWASP.md
contexto_proyecto.md
ACTUALIZACIONES_MEMORIA.md
MEMORIA_ACTUALIZACIONES.md
```

---

### FASE 4 — Verificar que solo queda lo valioso

Tras la limpieza, en raíz solo deben quedar:

| Archivo | Por qué se mantiene |
|---------|-------------------|
| `README.md` | Punto de entrada para el evaluador |
| `ARQUITECTURA_API.md` | Documentación técnica del contrato REST |
| `MANUAL_USUARIO.md` | Manual de uso por roles |
| `USUARIOS_PRUEBA.md` | Credenciales para probar el sistema |
| `ANEXO 8_ACEVEDO DONATE, IKER.md` | Documento oficial del TFG |
| `ERD_DATABASE.md` | Diagrama entidad-relación |
| `UML_CLASS_DIAGRAM.md` | Diagramas de clases |
| `docker-compose.yml` | Para levantar el sistema |
| `backend/` | Código fuente backend |
| `frontend/` | Código fuente frontend |

---

### FASE 5 — Commit final

Haz un único commit limpio con todo lo eliminado:

```
git rm -r --cached planes/ conductor/ .agents/ 2>/dev/null || true
git rm --cached CLAUDE.md GEMINI.md skills-lock.json DESIGN_SYSTEM.md \
  HISTORIAL_CAMBIOS.md RETOMAR_SESION.md PLAN_SEGURIDAD_OWASP.md \
  contexto_proyecto.md ACTUALIZACIONES_MEMORIA.md MEMORIA_ACTUALIZACIONES.md \
  MEMORIA_NUEVA_CONTENIDO.md Feedback.md memoria75%.md MemoriaEnMd.md \
  "Memoria TFG Iker-Acevedo 75% (1).md" "Memoria TFG Iker-Acevedo 75% (2).md" \
  "Captura de pantalla 2026-04-29 202731.md" 2>/dev/null || true
git rm --cached backend/GEMINI.md backend/contexto_proyecto.md \
  "backend/ARQUITECTURA_API.md" backend/MEMORIA_SEGUIMIENTO_ENTREGA_1.md \
  frontend/GEMINI.md frontend/contexto_proyecto.md \
  "frontend/ARQUITECTURA_API.md" 2>/dev/null || true
```

Mensaje del commit:
```
chore: limpieza repositorio de entrega — eliminar archivos de trabajo interno
```

Luego `git push`.

---

### NOTAS FINALES

- **No toques el código fuente** (backend/src/, frontend/lib/). Solo documentación y configuración.
- Si algún archivo de la lista no existe en este repo, ignóralo (puede que nunca se sincronizara).
- Después de la limpieza, haz `git log --oneline -5` y `git status` para confirmar que el working tree está limpio.
- El repositorio de entrega es: https://github.com/ikeracv28/TFG-Seguimiento
