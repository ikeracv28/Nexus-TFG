# Estado del Proyecto — Hitos

Actualizado: 10/05/2026

## Calendario de entregas

| Hito | Fecha | Estado |
|------|-------|--------|
| 25% | 7 abril | Entregado |
| 50% | 21 abril | Entregado — Memoria + repo + vídeo |
| 75% | 5 mayo | **Entregado — feedback recibido y corregido** |
| 100% | 19 mayo | **En curso — quedan 9 días** |
| Memoria defensa | 26 mayo | Pendiente |
| Defensa tribunal | 2-5 junio | Pendiente |

---

## Hito 3 (75%) — 5 mayo 2026

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
- [x] [FLUTTER] PanelTutorCentroScreen — 4 modos sidebar (Dashboard, Alumnos, Partes, Incidencias, Chat)
- [x] [FLUTTER] PanelTutorCentroScreen Dashboard — 4 stat cards + panel alumnos/carga + incidencias recientes
- [x] [FLUTTER] PanelAdminScreen — 3 modos (usuarios, prácticas, empresas) + mobile navbar con 3 tabs
- [x] [FLUTTER] DashboardScreen alumno — 4 tabs (Inicio, Seguimientos, Incidencias, Chat placeholder)
- [x] [FLUTTER] SeguimientosScreen — lista de partes + FAB "Nuevo parte" → SeguimientoScreen
- [x] [FLUTTER] SeguimientoScreen — formulario completo (fecha sin futuras, horas 1-24, descripción min 10 chars)
- [x] [FLUTTER] IncidenciasScreen — lista + bottom sheet para reportar incidencia (tipo + descripción)
- [x] [INFRA] nginx.conf con Cache-Control correcto para Flutter web (no-store index.html, no-cache main.dart.js)
- [x] [INFRA] Dockerfile frontend multi-stage copia nginx.conf

### Pendiente para Hito 3

- [ ] [BACKEND] WebSocket/STOMP para chat en tiempo real (puede quedar en Hito 4 si no da tiempo)
- [ ] [FLUTTER] ChatScreen funcional con WebSocket (placeholder ya existe en DashboardScreen y TutorCentroScreen)
- [x] [TEST] Test OWASP A01.2: alumno A no puede ver prácticas de alumno B — 8/8 pasan (01/05/2026)
- [x] [TEST] Test OWASP A01.3: alumno sin práctica asignada no puede acceder a práctica ajena — 8/8 pasan (01/05/2026)
- [x] [BUGFIX] @Service("practicaService") en PracticaServiceImpl — bean name correcto para SpEL en @PreAuthorize (01/05/2026)
- [ ] [DOC] Actualizar ARQUITECTURA_API.md con los endpoints ya implementados
- [ ] [DOC] Grabar vídeo demo Hito 3

---

## Hito 4 (100%) — 19 mayo 2026

### Completado (10/05/2026)

- [x] [BACKEND] WebSocket/STOMP chat en tiempo real — WebSocketAuthInterceptor con auth CONNECT + SUBSCRIBE
- [x] [BACKEND] Módulo ausencias: V8 migration + entidad + service + controller (01/05/2026)
- [x] [BACKEND] Chat REST + WebSocket — MensajeController, MensajeService, MensajeRepository
- [x] [BACKEND] Foto de perfil — V12 migration (bytea), UsuarioController POST/GET, validación MIME + 5 MB
- [x] [BACKEND] Sistema notificaciones — NotificacionController + service + repository; hooks en seguimientos y chat
- [x] [BACKEND] Correcciones feedback profesor: enum EstadoValidacionEmpresa (E), V13 pgcrypto (F), SUBSCRIBE auth (B)
- [x] [FLUTTER] ChatScreen real con WebSocket STOMP — stomp_dart_client, reconnect automático
- [x] [FLUTTER] Pantalla ausencias del alumno — AusenciasScreen + AusenciaTile + AusenciaService
- [x] [FLUTTER] Foto de perfil — FotoCache + NexusAvatar widget + PerfilScreen + PerfilProvider global
- [x] [FLUTTER] Sistema notificaciones — NotificacionProvider + NotificacionesScreen + badge en 4 paneles

### Completado (12/05/2026)

- [x] [FLUTTER] Polling notificaciones cada 30s — `NotificacionProvider` con Timer + flag `_cargado`
- [x] [FLUTTER] WebSocket URL dinámica — `ApiClient.wsBaseUrl` derivado de `API_URL` env var
- [x] [INFRA] `application-prod.properties` — HikariCP pool 10/5 + Actuator solo health,info
- [x] [FLUTTER] Paquete `excel: ^4.0.6` añadido para exportación Excel

### Pendiente para Hito 4

- [ ] [BACKEND+FLUTTER] Feature 4: Evaluación final del alumno — V14 migration + EvaluacionFinal entity + controller/service + formulario Flutter tutor centro + vista alumno
- [ ] [FLUTTER] Feature 5: Exportar PDF + Excel desde `ficha_alumno_screen.dart` — paquetes ya instalados, botón PDF ya existe en AppBar con `onPressed: null`
- [ ] [TEST] Subir cobertura JaCoCo del 69% a ≥80% — tests de integración para NotificacionController, UsuarioController, AusenciaController, MensajeController
- [ ] [FLUTTER] Verificar que chat WebSocket cubre caso tutor empresa ↔ tutor centro (requisito tutoría 12/05)
- [ ] [DOC] Manual de usuario por rol con capturas
- [ ] [FLUTTER] Pulido visual final, pruebas cross-device

---

## Estado técnico actual (10/05/2026)

### Lo que funciona end-to-end en Docker

| Flujo | Estado |
|-------|--------|
| Login todos los roles → rutas correctas | ✅ |
| Alumno: dashboard, seguimientos, incidencias, ausencias, chat | ✅ |
| Alumno: foto de perfil — subir y ver | ✅ |
| Alumno: notificaciones cuando se valida/rechaza su parte o llega mensaje | ✅ |
| Tutor empresa: ver partes, validar/rechazar, ver ausencias, chat | ✅ |
| Tutor empresa: notificaciones cuando el alumno le envía mensajes | ✅ |
| Tutor centro: dashboard, alumnos, partes, incidencias, chat | ✅ |
| Tutor centro: notificaciones cuando el alumno le envía mensajes | ✅ |
| Admin: gestión usuarios, prácticas, empresas (CRUD completo) | ✅ |
| Chat WebSocket STOMP en tiempo real — 3 participantes | ✅ |
| Logout server-side con JTI blacklist | ✅ |
| WebSocket SUBSCRIBE con verificación de participante | ✅ |
| Foto de perfil sincronizada entre todos los paneles (FotoCache) | ✅ |

### Problemas conocidos
- (ninguno activo)

---

## Vídeo de demo — qué mostrar

**Hito 3 (5 mayo)**: Flujo completo alumno (seguimientos + incidencias) + tutor empresa (validar/rechazar) + tutor centro (dashboard) + admin (gestión CRUD) + logout funcional.

**Hito 4 (19 mayo)**: Demo completa incluyendo chat en tiempo real y módulo ausencias.
