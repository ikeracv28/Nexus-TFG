# Estado del Proyecto — Hitos

Actualizado: 17/05/2026

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

### Completado (12/05/2026) — sesión tarde

- [x] [BACKEND+FLUTTER] Evaluación final del alumno — V14 migration + EvaluacionFinal entity + EvaluacionFinalRepository + EvaluacionService + EvaluacionFinalController (5 endpoints) + formulario slider tutor empresa + vista lectura en ficha alumno tutor centro
- [x] [TEST] Cobertura JaCoCo: 69% → 80% — 254 tests, 0 fallos (13 ficheros de test nuevos: 8 @WebMvcTest + 5 @SpringBootTest)
- [x] [FLUTTER] Rediseño diálogo evaluación — _EvaluarDialog con Slider por criterio (color rojo/ámbar/verde), Switch enable/disable, nota global slider 0-10; elimina TextFormField numérico anterior
- [x] [BUGFIX] FichaAlumnoScreen → StatefulWidget + initState cargarEvaluacionDe() — corrige "pendiente por evaluar" al abrir ficha aunque ya exista evaluación

### Completado (13/05/2026)

- [x] [BACKEND] V16 migration: columna `canal VARCHAR(20)` en `mensajes` + índice compuesto (practica_id, canal)
- [x] [BACKEND] Chat dual-canal: MensajeController (2 @MessageMapping + GET con ?canal=), MensajeService refactorizado; canal ALUMNO (alumno ↔ tutor centro), canal TUTORES (tutor empresa ↔ tutor centro)
- [x] [BACKEND] WebSocketAuthInterceptor: validación SUBSCRIBE con TOPIC_ALUMNO + TOPIC_TUTORES (regex separados)
- [x] [TEST] MensajeServiceTest + MensajeControllerTest actualizados con nuevas firmas; 2 nuevos tests de separación de canales
- [x] [FLUTTER] ChatPlaceholderScreen con parámetro `canal`, instancia local de ChatProvider por pantalla
- [x] [FLUTTER] PanelTutorCentroScreen: modo `chatTutores` en sidebar + mobile navbar; canal TUTORES con icono supervisor_account
- [x] [FLUTTER] PanelTutorEmpresaScreen: Tab 2 = chat canal TUTORES
- [x] [FLUTTER] Feature 5: Exportar PDF + Excel desde `ficha_alumno_screen.dart` — botón PDF (rojo) + botón Excel (verde) en AppBar; `pdf`, `printing`, `excel` packages

### Completado (17/05/2026)

- [x] [FLUTTER] Rediseño visual completo — Design System v2 (NexusColors semánticos, logo wordmark)
- [x] [FLUTTER] Login rediseñado — layout 2 columnas, panel branding + formulario
- [x] [BUGFIX] Fix F12 en panel tutor centro — MediaQuery.sizeOf en lugar de constraints.maxWidth
- [x] [FLUTTER] Panel tutor centro — DetailPanel 2 columnas, MiniStatBadge, modal incidencia como Dialog
- [x] [FLUTTER] Panel admin — DashStatCard con iconos, tabs pill con contadores, PracticaCard 3 columnas
- [x] [BACKEND+FLUTTER] Gestión empresas CRUD completo — EmpresaRequest DTO, POST/PUT/DELETE admin-only, UI tabla+formulario en panel admin
- [x] [INFRA] Fix zona horaria — TZ=Europe/Madrid en Docker + spring.jackson.time-zone

### Pendiente para Hito 4

- [ ] [DOC] Manual de usuario por rol con capturas
- [ ] [DOC] Grabar vídeo demo final Hito 4

---

## Estado técnico actual (17/05/2026)

### Lo que funciona end-to-end en Docker

| Flujo | Estado |
|-------|--------|
| Login todos los roles → rutas correctas | ✅ |
| Alumno: dashboard, seguimientos, incidencias, ausencias, chat | ✅ |
| Alumno: foto de perfil — subir y ver | ✅ |
| Alumno: notificaciones cuando se valida/rechaza su parte o llega mensaje | ✅ |
| Tutor empresa: ver partes, validar/rechazar, ver ausencias, chat tutores, evaluar alumno | ✅ |
| Tutor empresa: notificaciones cuando llega mensaje en canal TUTORES | ✅ |
| Tutor centro: dashboard, alumnos, partes, incidencias, chat alumno, chat tutores | ✅ |
| Tutor centro: exportar expediente alumno en PDF y Excel | ✅ |
| Tutor centro: notificaciones cuando el alumno le envía mensajes | ✅ |
| Admin: gestión usuarios, prácticas, empresas (CRUD completo) | ✅ |
| Admin: gestión empresas colaboradoras (CRUD completo) | ✅ |
| Zona horaria Europe/Madrid correcta en todos los registros | ✅ |
| Chat WebSocket STOMP — canal ALUMNO (alumno ↔ tutor centro) | ✅ |
| Chat WebSocket STOMP — canal TUTORES (tutor empresa ↔ tutor centro) | ✅ |
| Logout server-side con JTI blacklist | ✅ |
| WebSocket SUBSCRIBE con verificación de canal por participante | ✅ |
| Foto de perfil sincronizada entre todos los paneles (FotoCache) | ✅ |

### Problemas conocidos
- (ninguno activo)

---

## Vídeo de demo — qué mostrar

**Hito 3 (5 mayo)**: Flujo completo alumno (seguimientos + incidencias) + tutor empresa (validar/rechazar) + tutor centro (dashboard) + admin (gestión CRUD) + logout funcional.

**Hito 4 (19 mayo)**: Demo completa incluyendo chat en tiempo real y módulo ausencias.
