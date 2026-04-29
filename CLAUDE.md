## Memory
You have access to Engram persistent memory via MCP tools (mem_save, mem_search, mem_session_summary, etc.).
Save proactively after significant work — don't wait to be asked.
After any compaction or context reset, call mem_context to recover session state before continuing.

# Nexus TFG — Claude Code

**Autor**: Iker Acevedo Donate | **Institución**: CampusFP | **Entrega final**: 19 mayo 2026
**Propósito**: Plataforma centralizada para gestión del ciclo de prácticas académicas (FCT).

---

## Stack

| Capa | Tecnología |
|------|-----------|
| Backend | Java 21 + Spring Boot 3.4.1 |
| Seguridad | Spring Security + JWT (jjwt 0.12.5) |
| Persistencia | PostgreSQL + Hibernate (JPA) + Flyway |
| Mapeo | MapStruct 1.6.3 + Lombok |
| Frontend | Flutter (Dart) SDK ^3.11.4 + Provider + Dio + go_router |
| Infraestructura | Docker Compose (db + backend + frontend/Nginx) |

---

## Archivos de referencia

| Archivo | Cuándo leer |
|---------|-------------|
| `planes/roles-y-validacion.md` | Antes de tocar seguimientos, incidencias o permisos |
| `planes/estado-hitos.md` | Para saber qué está hecho y qué queda pendiente |
| `planes/patrones-codigo.md` | Checklist al crear endpoint nuevo o pantalla Flutter |
| `planes/decisiones-tecnicas.md` | Antes de proponer alternativas de arquitectura |
| `planes/repositorios-y-entregas.md` | Al sincronizar el repo de entrega al profesor |
| `PLAN_SEGURIDAD_OWASP.md` | Antes de implementar cualquier feature nueva |
| `ARQUITECTURA_API.md` | Contrato REST completo — documentar endpoint antes de implementarlo |
| `DESIGN_SYSTEM.md` | Antes de implementar cualquier pantalla Flutter |
| `HISTORIAL_CAMBIOS.md` | Bitácora técnica — registrar cada sesión de cambios |
| `MEMORIA_ACTUALIZACIONES.md` | Bloques para copiar en la memoria Word del TFG |

---

## Skills disponibles

Invocar con `/nombre-skill`. Ejecutar SIEMPRE `/owasp-security` al final de cualquier sesión de código.

| Skill | Cuándo invocar |
|-------|---------------|
| `/owasp-security` | Al terminar cualquier tarea de código. Obligatorio antes de commit. |
| `/java-springboot` | Al diseñar endpoints, configurar Spring Security, Flyway, JPA. |
| `/java-expert` | Patrones avanzados Java 21 (records, sealed classes, streams). |
| `/java-junit` | Al escribir tests de integración o tests de seguridad. |
| `/frontend-design` | Al diseñar o mejorar pantallas Flutter (consultar también DESIGN_SYSTEM.md). |
| `/mermaid-diagram-specialist` | Al crear diagramas de flujo, ER, secuencia para la memoria del TFG. |
| `/documentation-writer` | Al redactar bloques para MEMORIA_ACTUALIZACIONES.md. |
| `/docker-compose-orchestration` | Al modificar docker-compose.yml o configurar redes/volúmenes. |
| `/multi-stage-dockerfile` | Al modificar los Dockerfiles de backend o frontend. |
| `/gitignore-gen` | Si se añaden nuevas herramientas al proyecto. |
| `/agents-md-creator` | Si hay que regenerar este CLAUDE.md desde cero. |

---

## Engram — Memoria persistente

Engram da memoria entre sesiones a Claude Code vía MCP (SQLite local).
**Binario instalado** en `C:\Users\ikera\go\bin\engram.exe` pero aún no configurado como plugin.



Una vez configurado, engram recordará contexto entre sesiones sin necesidad de releer todos los archivos.

---

## Comandos críticos

### Rebuild tras cualquier cambio de código

> Este problema ha ocurrido varias veces. Seguir siempre este orden.

```bash
# 1. Reconstruir sin caché
docker-compose build --no-cache backend frontend

# 2. Reemplazar contenedores
docker rm -f nexus-db nexus-api nexus-web
docker-compose up -d
```

Después: **Ctrl+Shift+R** en Chrome (el browser cachea el JS de Flutter independientemente del contenedor).

Si solo cambia el backend: `docker-compose build --no-cache backend` + `docker rm -f nexus-api` + `docker-compose up -d backend`.

### Usuarios de prueba

| Email | Contraseña | Rol |
|-------|-----------|-----|
| admin@nexus.edu | Admin@Nexus2026 | ADMIN |
| tutor@nexus.edu | Tutor@Nexus2026 | TUTOR_CENTRO |
| alumno@nexus.edu | Alumno@Nexus2026 | ALUMNO |
| tutorempresa@nexus.edu | Empresa@Nexus2026 | TUTOR_EMPRESA |

### Comandos habituales

```bash
# Backend (desde backend/tfg-nexus-api/)
./mvnw test                     # Ejecutar todos los tests
./mvnw flyway:info              # Ver estado de migraciones

# Frontend (desde frontend/)
flutter pub get && flutter run -d chrome

# Docker
docker-compose logs -f backend  # Logs en tiempo real
```

---

## Reglas de Oro

**Backend**: Flyway para todo cambio de esquema. DTOs en controllers (nunca entidades JPA). MapStruct para mapeos. Validar transiciones de estado en el servicio. Documentar endpoint en ARQUITECTURA_API.md antes de implementarlo.

**Flutter**: Todos los colores de `NexusColors`. Adaptativo con `LayoutBuilder` (>600px = sidebar). Validar en cliente Y en backend independientemente.

**Seguridad**: Sin `@CrossOrigin(origins = "*")`. `@PreAuthorize` explícito en cada endpoint. Parámetros de estado siempre enums o conjuntos cerrados. Logs sin datos personales. `/owasp-security` antes de cada commit.

**Git**: Commits por bloque funcional completo. Mensajes en español explicando el por qué. Push antes de terminar sesión.

**Memoria del TFG**: Cada feature completada → bloque en `MEMORIA_ACTUALIZACIONES.md`. Tono académico en primera persona, cada decisión justificada.

**Comunicación**: Español técnico. Actitud crítica. Explicar el concepto antes del código (Iker no tiene experiencia previa con Flutter).
