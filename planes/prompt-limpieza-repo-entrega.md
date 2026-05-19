# Prompt de limpieza — Repositorio de entrega TFG

Copia y pega esto en el chat de Claude del repositorio de entrega.

---

## CONTEXTO

Este es el repositorio de entrega del TFG (https://github.com/ikeracv28/TFG-Seguimiento).
El repositorio de desarrollo (privado) contiene archivos de configuración de herramientas de IA
que NO deben aparecer aquí, pero hay documentación técnica valiosa que el profesor evaluador
ha valorado explícitamente en el feedback del 75% y que DEBE mantenerse o mejorarse.

Feedback del profesor (hito 75%): valoración EXCELENTE. Destacó expresamente:
- PLAN_SEGURIDAD_OWASP.md: "inusual en un TFG de DAM, nivel de rigor profesional"
- USUARIOS_PRUEBA.md: "con cuentas demo y prácticas de demostración"
- decisiones_tecnicas.md: "bitácora interna de calidad"
- ERD_DATABASE.md, UML_CLASS_DIAGRAM.md: "Diagramas enlazados"
- "Documentación abundante (10 ficheros raíz + bitácora interna)"

---

## FASE 1 — Eliminar archivos de herramientas IA (sí o sí)

Estos archivos son configuración interna de herramientas de IA y NO aportan valor académico.
Elimínalos con `git rm`:

**Archivos de configuración IA en raíz:**
- `CLAUDE.md` — instrucciones para Claude Code
- `GEMINI.md` — instrucciones para Gemini
- `skills-lock.json` — lock de skills de Claude Code
- `RETOMAR_SESION.md` — contexto de sesión con IA
- `contexto_proyecto.md` — contexto interno del proyecto para IA

**Carpetas de configuración IA:**
- `.agents/` — configuración de agentes IA
- `conductor/` — configuración de agente Conductor (IA)

**Archivos de configuración IA en subcarpetas:**
- `backend/GEMINI.md`
- `backend/contexto_proyecto.md`
- `frontend/GEMINI.md`
- `frontend/contexto_proyecto.md`

**Carpeta `planes/` — eliminar casi toda, pero EXTRAER antes lo valioso:**

Antes de borrar `planes/`, copia estos archivos a la raíz del proyecto con nombre en mayúsculas:
- `planes/decisiones-tecnicas.md` → `DECISIONES_TECNICAS.md` (el profesor lo valoró)

Luego elimina la carpeta `planes/` completa.

---

## FASE 2 — Eliminar borradores de documentación

Archivos de trabajo en progreso que no deben aparecer en el repo de entrega:

- `HISTORIAL_CAMBIOS.md` — bitácora de sesiones de IA (no es documentación académica)
- `ACTUALIZACIONES_MEMORIA.md` — notas internas de memoria IA
- `MEMORIA_ACTUALIZACIONES.md` — bloques de memoria para Word
- `MEMORIA_NUEVA_CONTENIDO.md` — borradores de la memoria TFG
- `DESIGN_SYSTEM.md` — referencia interna del design system para IA
- `Feedback.md` — notas privadas de tutoría
- `memoria75%.md` — borrador de la memoria
- `MemoriaEnMd.md` — borrador de la memoria
- `"Memoria TFG Iker-Acevedo 75% (1).md"` — borrador
- `"Memoria TFG Iker-Acevedo 75% (2).md"` — borrador
- `"Captura de pantalla 2026-04-29 202731.md"` — archivo suelto

**Duplicados de ARQUITECTURA_API.md en subcarpetas** (el raíz es el definitivo):
- `backend/ARQUITECTURA_API.md`
- `frontend/ARQUITECTURA_API.md`
- `backend/MEMORIA_SEGUIMIENTO_ENTREGA_1.md`

---

## FASE 3 — Lo que hay que MANTENER (no tocar)

El profesor valoró expresamente estos archivos. Deben estar en el repo de entrega:

| Archivo | Por qué se mantiene |
|---------|-------------------|
| `README.md` | Punto de entrada — revisar en Fase 4 |
| `ARQUITECTURA_API.md` | Contrato REST completo — documentación técnica |
| `MANUAL_USUARIO.md` | Manual por roles con capturas — el profesor lo pidió |
| `USUARIOS_PRUEBA.md` | Credenciales demo — el profesor lo valoró |
| `PLAN_SEGURIDAD_OWASP.md` | **El profesor lo destacó especialmente** — no tocar |
| `ERD_DATABASE.md` | Diagrama E-R — mencionado positivamente |
| `UML_CLASS_DIAGRAM.md` | Diagramas de clases — mencionado positivamente |
| `DECISIONES_TECNICAS.md` | (recién movido de planes/) — el profesor lo valoró |
| `ANEXO 8_ACEVEDO DONATE, IKER.md` | Documento oficial del TFG |
| `docker-compose.yml` | Para levantar el sistema |
| `backend/` | Código fuente backend — no tocar |
| `frontend/` | Código fuente frontend — no tocar |

---

## FASE 4 — Revisar y mejorar el README.md

El README debe ser profesional. Estructura ideal para la entrega final:

```markdown
# Nexus — Plataforma de Gestión de Prácticas FCT

[Descripción breve del sistema: qué es, para qué sirve, a quién va dirigido]

## Stack tecnológico
| Capa | Tecnología |
|------|-----------|
| Backend | Java 21 + Spring Boot 3.4.1 |
| Seguridad | Spring Security + JWT |
| Persistencia | PostgreSQL + Hibernate (JPA) + Flyway |
| Frontend | Flutter (Dart) + Provider + Dio + go_router |
| Infraestructura | Docker Compose |

## Requisitos previos
- Docker Desktop instalado y arrancado
- Git

## Arranque rápido
```bash
git clone https://github.com/ikeracv28/TFG-Seguimiento.git
cd TFG-Seguimiento
docker-compose up -d
```
La primera vez tarda ~3 minutos (descarga imágenes + aplica migraciones Flyway).

Acceso: http://localhost (Flutter web compilado)
API: http://localhost:8080

## Usuarios de prueba
Ver USUARIOS_PRUEBA.md para credenciales y escenarios de demostración.

## Documentación técnica
- ARQUITECTURA_API.md — Contrato REST completo
- PLAN_SEGURIDAD_OWASP.md — Plan de seguridad con trazabilidad OWASP Top 10
- ERD_DATABASE.md — Diagrama entidad-relación
- UML_CLASS_DIAGRAM.md — Diagramas de clases
- DECISIONES_TECNICAS.md — Decisiones de arquitectura justificadas
- MANUAL_USUARIO.md — Manual de uso por rol

## Tests
| Área | Clases | Tests |
|------|--------|-------|
| Seguridad OWASP | 6 | ~60 |
| Controllers | 10 | ~130 |
| Servicios | 2 | ~30 |
| **Total** | **~18** | **~258** |

Cobertura JaCoCo disponible tras: `./mvnw test`
```

Elimina del README cualquier mención a herramientas de IA, archivos internos que ya no existen,
o rutas que hayan cambiado.

---

## FASE 5 — Verificar secretos y actualizar .gitignore

**Primero — verificar que `.env` NO está trackeado:**
```bash
git ls-files .env
```
Si devuelve el nombre del archivo, quitarlo del tracking antes de cualquier otra cosa:
```bash
git rm --cached .env
git commit -m "fix: eliminar .env del tracking de git"
```
El `.env` contiene `DB_PASSWORD`, `JWT_SECRET` y otras variables sensibles que nunca deben estar en un repo público.

**Nota sobre `USUARIOS_PRUEBA.md`:** las contraseñas en texto plano que contiene (`Admin@Nexus2026`, etc.) son **credenciales de demostración intencionales** — el evaluador las necesita para probar el sistema. El profesor las valoró positivamente. No eliminar este archivo.

**Nota sobre `V6__Passwords_Seguros_Usuarios_Prueba.sql`:** solo contiene hashes BCrypt irreversibles (`$2a$10$...`). Es seguro y necesario para que Flyway inicialice la BD.

Añade al `.gitignore` para prevenir filtraciones en futuras sincronizaciones:

```gitignore
# Secretos — NUNCA subir
.env
.env.local
.env.*.local
*.pem
*.key
*.p12
*.jks

# Herramientas IA
CLAUDE.md
GEMINI.md
skills-lock.json
.agents/
conductor/
planes/
RETOMAR_SESION.md
contexto_proyecto.md
DESIGN_SYSTEM.md
HISTORIAL_CAMBIOS.md
ACTUALIZACIONES_MEMORIA.md
MEMORIA_ACTUALIZACIONES.md

# Borradores
memoria75%.md
MemoriaEnMd.md
Feedback.md
```

---

## FASE 6 — Commit final

```bash
git add -A
git commit -m "chore: limpieza repo entrega — eliminar archivos IA, extraer decisiones-tecnicas"
git push
```

Tras el push, verifica con `git log --oneline -3` y `git status` que el working tree está limpio.

---

## RESULTADO ESPERADO

Raíz del repo de entrega tras la limpieza:
```
├── README.md                    ← punto de entrada profesional
├── ARQUITECTURA_API.md          ← contrato REST
├── PLAN_SEGURIDAD_OWASP.md      ← destacado por el profesor
├── MANUAL_USUARIO.md            ← manual por roles
├── USUARIOS_PRUEBA.md           ← credenciales demo
├── DECISIONES_TECNICAS.md       ← movido de planes/
├── ERD_DATABASE.md              ← diagrama E-R
├── UML_CLASS_DIAGRAM.md         ← diagramas de clases
├── ANEXO 8_ACEVEDO DONATE...md  ← documento oficial
├── docker-compose.yml           ← infraestructura
├── backend/                     ← código fuente
└── frontend/                    ← código fuente
```

12 archivos en raíz — limpio, profesional y coherente con el feedback del profesor.
