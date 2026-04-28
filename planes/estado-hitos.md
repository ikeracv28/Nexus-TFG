# Estado del Proyecto — Hitos

Actualizado: 28/04/2026

## Calendario de entregas

| Hito | Fecha | Estado |
|------|-------|--------|
| 25% | 7 abril | Entregado |
| 50% | 21 abril | Entregado — Memoria + repo + vídeo |
| 75% | 5 mayo | En curso |
| 100% | 19 mayo | Pendiente |
| Memoria defensa | 26 mayo | Pendiente |
| Defensa tribunal | 2-5 junio | Pendiente |

---

## Hito 3 (75%) — 5 mayo

### Completado

- [x] [BACKEND] Migración V5: estados PENDIENTE_EMPRESA / PENDIENTE_CENTRO / COMPLETADO / RECHAZADO
- [x] [BACKEND] Seed tutor empresa (V4: tutorempresa@nexus.edu)
- [x] [BACKEND] IncidenciaController + IncidenciaService (CRUD + cambio de estado)
- [x] [BACKEND] SeguimientoServiceImpl: validarEmpresa() + validarCentro() + incidencia automática al rechazar
- [x] [BACKEND] 5 tests de integración del flujo de doble validación — todos pasan
- [x] [BACKEND] OWASP Bloque 1: CORS, SpEL, JWT Base64, RateLimitFilter, headers HTTP, account enumeration, logs
- [x] [BACKEND] OWASP Bloque 2: logout server-side (JTI blacklist), validación estados, passwords V6, dependency-check
- [x] [FLUTTER] app_theme.dart con NexusColors y NexusSizes
- [x] [FLUTTER] go_router con rutas por rol y guards de autenticación
- [x] [FLUTTER] Navegación adaptativa: sidebar 52px en web, BottomNavigationBar en móvil
- [x] [FLUTTER] PanelTutorEmpresaScreen — sidebar verde, stats, lista partes con validar/rechazar
- [x] [FLUTTER] PanelTutorCentroScreen — 3 columnas, 4 modos sidebar, barra progreso FCT

### Pendiente

- [ ] [BACKEND] WebSocket/STOMP para chat en tiempo real
- [ ] [FLUTTER] Pantalla de registro de seguimiento del alumno (FAB → formulario → POST /seguimientos)
- [ ] [FLUTTER] Verificar endpoints getMisPracticasComoTutorCentro y getMisPracticasComoTutorEmpresa
- [ ] [FLUTTER] Pantalla de incidencias del alumno (lista básica → gestión de estado)
- [ ] [FLUTTER] Pantalla de chat (WebSocket — placeholder listo, funcionalidad real en Hito 4)

---

## Vídeo de demo — qué mostrar

**Hito 3 (5 mayo)**: Todo lo del Hito 2 + pantallas Flutter funcionales (seguimientos, incidencias, paneles tutor empresa y centro), flujo de doble validación completo.

**Hito 4 (19 mayo)**: Demo completa de la app, todos los roles, chat en tiempo real.
