# Estado del Proyecto — Hitos

Actualizado: 01/05/2026

## Calendario de entregas

| Hito | Fecha | Estado |
|------|-------|--------|
| 25% | 7 abril | Entregado |
| 50% | 21 abril | Entregado — Memoria + repo + vídeo |
| 75% | 5 mayo | **En curso — queda 4 días** |
| 100% | 19 mayo | Pendiente |
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

- [ ] [BACKEND] WebSocket/STOMP chat entre alumno, tutor centro y tutor empresa
- [ ] [BACKEND] Módulo ausencias: tabla separada con anexo en bytea (subir fichero justificante)
- [ ] [FLUTTER] ChatScreen real — mensajes en tiempo real
- [ ] [FLUTTER] Pantalla ausencias del alumno
- [ ] [FLUTTER] Pulido visual final, pruebas cross-device

---

## Estado técnico actual (01/05/2026)

### Lo que funciona end-to-end en Docker

| Flujo | Estado |
|-------|--------|
| Login todos los roles → rutas correctas | ✅ |
| Alumno: ver dashboard, registrar parte, ver incidencias, reportar incidencia | ✅ |
| Tutor empresa: ver partes, validar/rechazar, incidencia automática al rechazar | ✅ |
| Tutor centro: dashboard con stats, lista alumnos, incidencias recientes | ✅ |
| Admin: gestión usuarios, prácticas, empresas (CRUD completo) | ✅ |
| Logout server-side con JTI blacklist | ✅ |
| Cache-Control Nginx correcto | ✅ |

### Problemas conocidos
- (ninguno activo)

---

## Vídeo de demo — qué mostrar

**Hito 3 (5 mayo)**: Flujo completo alumno (seguimientos + incidencias) + tutor empresa (validar/rechazar) + tutor centro (dashboard) + admin (gestión CRUD) + logout funcional.

**Hito 4 (19 mayo)**: Demo completa incluyendo chat en tiempo real y módulo ausencias.
