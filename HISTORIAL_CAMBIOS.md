# Registro de Cambios y Avances - TFG Nexus

Este documento registra las implementaciones técnicas realizadas a lo largo del proyecto.

---

## [17/05/2026] — Rediseño visual completo + Gestión de empresas + Fix zona horaria

### Frontend — Rediseño visual (Design System v2)

- **`app_theme.dart`**: sistema de colores semántico ampliado (`NexusColors.successLight/Text`, `warningLight/Text`, `dangerLight/Text`, `neutralLight/Text`, `inkTertiary`). Función helper `fmtH(num h)` para formatear horas como "4h 30min".
- **Logo Nexus**: wordmark SVG integrado como asset PNG en sidebar de todos los roles.
- **`login_screen.dart`**: rediseño completo — layout 2 columnas (panel izquierdo con gradiente + branding, formulario derecho limpio).
- **`panel_tutor_centro_screen.dart`**: fix crítico F12 (`MediaQuery.sizeOf` en lugar de `constraints.maxWidth` que devolvía 0 en primer frame Flutter web). `_DetailPanel` rediseñado con layout 2 columnas: contenido principal izquierda + sidebar 220px derecha (ficha completa + comunicación). Nuevas `_MiniStatBadge` (horas/partes/incidencias). `_IncidenciaDetailCard` rediseñada como fila compacta clickeable. Modal de gestión de incidencia sustituye `showModalBottomSheet` por `Dialog` centrado con opciones estilizadas por estado. Eliminado ~650 líneas de código muerto nunca conectado al árbol de widgets.
- **`panel_admin_screen.dart`**: `_DashStatCard` con icono en caja de color + subtítulo contextual. `_PracticasEnCurso` con `NexusAvatar` + chip "En curso". Tabs de filtro en vista prácticas sustituyen `FilterChip` por pills animados con contador de cada estado. `_PracticaCard` rediseñada en 3 columnas (código/alumno | empresa/tutor | horas/acción). Botón ojo en práctica finalizada abre el diálogo de edición.

### Backend + Frontend — Gestión de empresas (CRUD completo)

- **`EmpresaRequest.java`**: nuevo DTO con validaciones JSR-380 (`@NotBlank`, `@Email`, `@Size`).
- **`EmpresaMapper`**: métodos `toEntity(EmpresaRequest)` y `updateEntity(EmpresaRequest, @MappingTarget Empresa)` con MapStruct.
- **`EmpresaService` / `EmpresaServiceImpl`**: métodos `create`, `update`, `delete`. Validación CIF único en create (excepción 400 si duplicado) y en update (permite mantener el mismo CIF pero rechaza el de otra empresa). Delete falla con FK constraint si la empresa tiene prácticas asociadas — comportamiento correcto e intencionado.
- **`EmpresaController`**: `POST /api/v1/empresas`, `PUT /api/v1/empresas/{id}`, `DELETE /api/v1/empresas/{id}` con `@PreAuthorize("hasRole('ADMIN')")`.
- **`EmpresaModel`** (Flutter): ampliado con `direccion`, `emailContacto`, `telefonoContacto`.
- **`AdminService`** (Flutter): métodos `crearEmpresa`, `editarEmpresa`, `eliminarEmpresa`.
- **`AdminProvider`** (Flutter): métodos CRUD empresa con gestión de error.
- **`panel_admin_screen.dart`**: nuevo modo `_ModoAdmin.empresas` con tabla buscable, diálogo de creación/edición (`_EmpresaFormDialog`) y confirmación de borrado.

### Infraestructura — Fix zona horaria

- **`docker-compose.yml`**: `TZ=Europe/Madrid` en servicios `db` y `backend`. `JAVA_TOOL_OPTIONS=-Duser.timezone=Europe/Madrid` para la JVM de Spring Boot.
- **`application.properties`**: `spring.jackson.time-zone=Europe/Madrid` + `spring.jackson.serialization.write-dates-as-timestamps=false` — los timestamps se serializan en ISO-8601 con zona horaria correcta (UTC+2 CEST).

---

## [13/05/2026] — Chat dual-canal + Exportar PDF y Excel del expediente FCT

### Backend — Chat con dos canales separados

- **V16 migration** (`V16__Canal_Chat.sql`): `ALTER TABLE mensajes ADD COLUMN canal VARCHAR(20) NOT NULL DEFAULT 'ALUMNO'` + índice compuesto `idx_mensajes_practica_canal(practica_id, canal)`.
- **`Mensaje` entity**: campo `canal` (`@Column nullable=false, length=20`, default "ALUMNO").
- **`MensajeRequest` / `MensajeResponse`**: añadido campo `canal` (8º campo del record MensajeResponse).
- **`MensajeRepository`**: nuevo método `findByPracticaIdAndCanalOrderByFechaEnvioAsc(Long, String)`.
- **`MensajeService` / `MensajeServiceImpl`**: firmas actualizadas `guardar(..., String canal)` y `listarPorPractica(Long, String canal)`. Lógica `validarAccesoCanal`: canal ALUMNO → alumno + tutor centro; canal TUTORES → tutor empresa + tutor centro.
- **`MensajeController`**: GET acepta `@RequestParam(defaultValue="ALUMNO") canal`; `@MessageMapping("/chat/{id}")` envía a `/topic/practica/{id}`; `@MessageMapping("/chat/{id}/tutores")` envía a `/topic/practica/{id}/tutores`.
- **`WebSocketAuthInterceptor`**: SUBSCRIBE separado con `TOPIC_ALUMNO = ^/topic/practica/(\\d+)$` y `TOPIC_TUTORES = ^/topic/practica/(\\d+)/tutores$`. Cada canal valida que el email del principal sea uno de los participantes autorizados.

### Tests actualizados

- **`MensajeControllerTest`**: `mensajeMock()` actualizado con 8 args; stubs `listarPorPractica(1L, "ALUMNO")`; tests `tutor_empresa_puede_ver_historial_tutores` y `sin_parametro_canal_usa_alumno_por_defecto` añadidos.
- **`MensajeServiceTest`**: tests de separación de canales (`tutor_empresa_no_puede_usar_canal_alumno`, `alumno_no_puede_usar_canal_tutores`, `mensajes_canales_no_se_mezclan`).

### Frontend — Chat dual-canal

- **`mensaje_service.dart`**: `getHistorial(id, {canal})`, `conectar({canal})`, `enviarMensaje({canal})` — topic y destination cambian según canal.
- **`chat_provider.dart`**: `iniciar(id, {canal})` guarda `_canal` y lo pasa al servicio.
- **`chat_placeholder_screen.dart`**: parámetro `final String canal`; instancia **local** de `ChatProvider` por widget (evita conflicto entre los dos chats simultáneos); UI canal TUTORES diferenciada (color verde, icono supervisor_account).
- **`panel_tutor_centro_screen.dart`**: `enum _Mode` añade `chatTutores`; sidebar + mobile navbar con nuevo botón "Chat con tutor empresa".
- **`panel_tutor_empresa_screen.dart`**: Tab 2 = `ChatPlaceholderScreen(canal: 'TUTORES')`.

### Feature 5: Exportar expediente FCT

- **`ficha_alumno_screen.dart`**: botón PDF (rojo) + botón Excel (verde) en AppBar. `_exportarPdf()` genera un PDF A4 multipágina con cabecera/pie, datos de práctica, seguimientos en tabla, incidencias, ausencias y evaluación final; usa `pdf: ^3.10.8` + `printing: ^5.12.0` (`Printing.sharePdf()`). `_exportarExcel()` crea un libro `.xlsx` con hojas Información/Seguimientos/Incidencias/Ausencias/Evaluación; usa `excel: ^4.0.6` + `dart:html` `Blob`/`AnchorElement` para la descarga web.

---

## [10/05/2026] — Correcciones feedback profesor (75%) + Foto de perfil + Notificaciones

### Correcciones OWASP — Feedback del profesor

- **[E] enum EstadoValidacionEmpresa — A04/OWASP**: El endpoint `PATCH /seguimientos/{id}/validar-empresa` aceptaba un `String` libre como `nuevoEstado`, lo que permitía enviar valores arbitrarios. Se crea el enum `EstadoValidacionEmpresa { PENDIENTE_CENTRO, RECHAZADO }` y se cambia el `@RequestParam` del controller a este tipo. Spring convierte el String al enum antes de llegar al método; si el valor no es válido, el nuevo `MethodArgumentTypeMismatchException` handler devuelve 400 con la lista de valores aceptados.
- **[F] V13__Pgcrypto_Extension.sql**: La extensión `pgcrypto` (usada en V6 y V7 para `crypt()` y `gen_salt()`) se cargaba implícitamente porque PostgreSQL la tenía activa por defecto, pero no estaba declarada en Flyway. Si la BD no tuviera la extensión, las migraciones V6/V7 fallarían silenciosamente. Se añade `CREATE EXTENSION IF NOT EXISTS pgcrypto` como V13 idempotente.
- **[B] WebSocket SUBSCRIBE sin autorización**: El `WebSocketAuthInterceptor` solo validaba el frame `CONNECT` (autenticación JWT). Cualquier usuario autenticado podía suscribirse a `/topic/practica/{id}` de una práctica ajena. Se añade manejo de `StompCommand.SUBSCRIBE`: se extrae el `practicaId` con regex `^/topic/practica/(\\d+)$`, se busca la práctica en BD y se verifica que el email del principal es alumno, tutor centro o tutor empresa de esa práctica. Si no, `AccessDeniedException`. Los admins se omiten del check.
- **[A, C]**: Confirmados como ya correctos en el codebase actual — no requirieron cambios.

### Feature: Foto de perfil (Hito 5)

- **Backend**: Migración V12 añade columnas `foto_perfil BYTEA` y `foto_content_type VARCHAR(50)` a la tabla `usuarios`. `UsuarioController` expone `POST /me/foto` (multipart, validación MIME + 5 MB) y `GET /{id}/foto` (devuelve bytes con Content-Type original). `UsuarioResponse` incorpora campo `tieneFoto: boolean`. Corrección clave: `@Column(columnDefinition = "bytea")` en lugar de `@Lob` — Hibernate 6 mapea `@Lob` a OID en PostgreSQL, no a bytea.
- **Flutter**: `FotoCache` estático con `ValueNotifier<int>` para sincronización global. `NexusAvatar` widget escucha el notifier y se reconstruye cuando la foto cambia. `PerfilScreen` con selector de imagen y subida. `PerfilProvider` global registrado con `ChangeNotifierProxyProvider` en `main.dart` — se auto-carga al autenticarse.

### Feature: Sistema de notificaciones completo (Hito D del feedback)

- **Backend**:
  - `NotificacionRepository`: queries `findByUsuarioIdOrderByFechaCreacionDesc`, `countByUsuarioIdAndLeidaFalse`, `@Modifying marcarLeida`, `marcarTodasLeidas`.
  - `NotificacionService` / `NotificacionServiceImpl`: `crear(usuarioId, tipo, mensaje)`, `listarParaUsuario()`, `contarNoLeidas()`, `marcarLeida(id)`, `marcarTodasLeidas()`. Usa `SecurityContextHolder` para resolver el usuario autenticado.
  - `NotificacionController`: 4 endpoints REST (`GET /me`, `GET /me/no-leidas`, `PATCH /{id}/leer`, `PATCH /me/leer-todas`).
  - **Hooks automáticos**: `SeguimientoServiceImpl.validarEmpresa()` crea notificación al alumno al aprobar o rechazar su parte; `validarCentro()` notifica al completar. `MensajeServiceImpl.guardar()` notifica a los otros 2 participantes (no al remitente) cuando se envía un mensaje de chat.
- **Flutter**:
  - `NotificacionService` (data layer): llama a los 4 endpoints REST.
  - `NotificacionProvider`: lista, badge counter, `marcarLeida`, `marcarTodasLeidas`. Se registra con `ChangeNotifierProxyProvider` en `main.dart` — llama `cargar()` al autenticarse.
  - `NotificacionesScreen`: lista con iconos por tipo (CHAT=azul, SEGUIMIENTO=verde, INCIDENCIA=ámbar), marca como leída al tocar, botón "Leer todas", estado vacío.
  - **Badge en todos los paneles**: campana `Icons.notifications_none_outlined` con `Badge` (contador rojo) en el AppBar del dashboard del alumno y en el sidebar de los paneles de tutor empresa, tutor centro y admin.

---

## [29/04/2026] — Dashboard Tutor Centro + Mobile Nav Admin + Nginx Cache Fix

### Frontend (Flutter)

- **PanelTutorCentroScreen — modo Dashboard**: Se añade `dashboard` al enum `_Mode` como vista inicial por defecto. La vista `_VistaDashboard` muestra 4 tarjetas de estadísticas (prácticas activas, convenios/empresas, incidencias abiertas, partes por validar) calculadas desde `TutorCentroProvider`, un panel `_AlumnosYCarga` con barra de progreso por alumno y un panel `_IncidenciasRecientes` con las 4 últimas incidencias y badge de estado coloreado. Layout de dos columnas en pantallas >600px mediante `LayoutBuilder`. Iconos actualizados en sidebar y bottom nav.
- **PanelAdminScreen — navbar móvil**: El método `build()` bifurca en dos Scaffolds según `constraints.maxWidth < 600`. En móvil se construye un `Scaffold` con `AppBar` (fondo `NexusColors.ink`, título dinámico por modo) y `BottomNavigationBar` personalizado (`_MobileBottomNavAdmin`) con 3 tabs: Inicio, Alumnos/Prácticas, Empresas. Sin esta corrección la versión móvil mostraba el contenido sin forma de cambiar de sección.

### Infraestructura (Nginx + Docker)

- **nginx.conf — Cache-Control para Flutter web**: Nuevo archivo de configuración Nginx con tres políticas de caché: `no-store, no-cache, must-revalidate` para `index.html`, `flutter_service_worker.js` y `flutter_bootstrap.js`; `no-cache` (ETag) para `main.dart.js`; `max-age=1y, immutable` para assets con hash en el nombre. Soluciona el problema recurrente de que el browser servía el bundle JS antiguo después de rebuilds Docker.
- **Dockerfile frontend**: Se añade `COPY nginx.conf /etc/nginx/conf.d/default.conf` en la etapa Nginx (etapa 2) para que la política de caché se aplique automáticamente en cada despliegue.

---

## [28/04/2026] — Seguridad OWASP Bloque 2: A03 + A07 logout + A02 passwords + A06 audit

### Backend (Spring Boot)

- **[A03] Validación de estado en PracticaServiceImpl**: `cambiarEstado()` valida el parámetro `nuevoEstado` contra un `Set.of("BORRADOR","ACTIVA","FINALIZADA")` antes de persistir. Antes se aceptaba cualquier String libre. Lanza `BusinessRuleException` con listado explícito de valores permitidos.
- **[A07] Logout server-side con blacklist JTI**: `JwtUtils.generateToken()` incluye `.id(UUID.randomUUID().toString())` en cada token (claim `jti`). Nuevo `TokenBlacklistService` con `ConcurrentHashMap<String, Boolean>` que almacena los JTIs revocados. `JwtAuthenticationFilter` verifica la blacklist antes de autenticar. `AuthController` expone `POST /auth/logout` (`@PreAuthorize("isAuthenticated()")`), que extrae el JTI del header Bearer y lo invalida en el servidor. El logout era antes solo local (delete del storage Flutter).
- **[A02] Contraseñas de usuarios de prueba OWASP-compliant**: Migración Flyway V6 actualiza los hashes BCrypt de los 4 usuarios de prueba. Contraseñas nuevas: `Admin@Nexus2026`, `Tutor@Nexus2026`, `Alumno@Nexus2026`, `Empresa@Nexus2026` (12+ chars, mayúscula + minúscula + número + símbolo). No se modificó V3 (Flyway checksum). Los hashes se generaron registrando usuarios temporales en el backend en ejecución y consultando la BD; V6 los aplica y elimina los temporales.
- **[A06] OWASP Dependency-Check**: Plugin `dependency-check-maven:10.0.3` añadido al `pom.xml`. `failBuildOnCVSS=7` detiene el build si hay CVE de severidad alta o crítica. Genera reportes HTML+JSON en `target/dependency-check/`.

### Frontend (Flutter)

- **[A07] Logout invoca backend antes de limpiar storage**: `AuthService.logout()` lee el token local, llama `POST /api/v1/auth/logout` con el header Bearer para revocar el JTI en servidor, y solo entonces elimina el storage local. Si el backend falla (red caída, token ya expirado), el bloque `finally` garantiza la limpieza local igualmente.

### Tests nuevos

- `JwtUtilsOwaspTest`: 2 tests añadidos — `generated_token_contains_non_null_jti` y `two_tokens_have_different_jtis`. Verifican que el JTI está presente y es único por token (necesario para que la blacklist funcione).
- `AuthControllerTest`: test `should_logout_and_return_204` con `@WithMockUser`. Se añade `@MockBean TokenBlacklistService` para que el contexto `@WebMvcTest` arranque con el nuevo filtro.

---

## [28/04/2026] — Seguridad OWASP Bloque 1 + fixes Flutter storage/dashboard

### Backend (Spring Boot)

- **[A01] CORS sin wildcard**: `SecurityConfig` reemplaza `@CrossOrigin(origins = "*")` en todos los controllers por una configuración centralizada con orígenes explícitos (`http://localhost:3000`, `http://localhost:8080`). Se añade `setAllowCredentials(true)` y se expone solo el header `Authorization`. El wildcard se elimina de `AuthController`, `PracticaController`, `SeguimientoController` e `IncidenciaController`.
- **[A01] SpEL roto en PracticaController**: Los dos `@PreAuthorize` que usaban `.principal.id` (inválido sobre `UserDetails`) se reescriben para delegar en métodos de servicio: `@practicaService.esParticipante(#id, authentication.name)` y `@practicaService.perteneceAlAlumnoAutenticado(#alumnoId, authentication.name)`. Se añaden ambos métodos a `PracticaService` e `PracticaServiceImpl` con `@Transactional(readOnly = true)`.
- **[A02] JWT con Decoders.BASE64**: `JwtUtils.getSigningKey()` cambia de `secret.getBytes()` (inseguro) a `Decoders.BASE64.decode(secret)` (correcto). El algoritmo resultante pasa de HS512 a HS256 porque la clave real son 40 bytes (320 bits). Todos los tokens anteriores quedan invalidados al reconstruir.
- **[A04] RateLimitFilter**: Nuevo filtro `@Component @Order(1)` que limita a 10 peticiones/minuto por IP en endpoints `/api/v1/auth/`. Implementado con `ConcurrentHashMap<String, long[]>` (ventana deslizante) sin dependencias externas. Devuelve HTTP 429 con body JSON.
- **[A05] Cabeceras HTTP de seguridad**: `SecurityConfig` añade `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `X-XSS-Protection` y `HSTS` en todas las respuestas.
- **[A07] Account enumeration eliminada**: `AuthServiceImpl.validarUnicidad()` comprueba email y DNI con una sola expresión y lanza siempre el mismo mensaje genérico. El login lanza `BadCredentialsException` genérica en lugar de revelar si el email existe.
- **[A09] Logs de seguridad**: `AuthServiceImpl`, `GlobalExceptionHandler` y `SeguimientoServiceImpl` loguean eventos de seguridad (login fallido, acceso denegado, cambios de estado) con nivel WARN/INFO. Sin datos personales en los logs — solo IDs y roles.
- **Tests**: 35 tests, todos pasan. Nuevas clases: `JwtUtilsOwaspTest` (5), `RateLimitFilterTest` (6), `AuthServiceOwaspTest` (5), `PracticaOwnershipTest` (10), `SecurityHeadersAndCorsTest` (9).

### Frontend (Flutter)

- **ApiClient — storage resistente**: El interceptor envuelve `_storage.read()` en try/catch. Si Web Crypto no puede descifrar (datos corruptos tras rebuild Docker), limpia el storage y trata al usuario como no autenticado. Sin este fix el error se propagaba como `"invalid argument (index): 'message'"` bloqueando incluso el login.
- **isAuthenticated resistente**: Mismo try/catch en `AuthService.isAuthenticated()`.
- **Dashboard — _ErrorCard**: Cuando `practica.errorMessage != null` se muestra una tarjeta de error con mensaje y botón "Reintentar", en lugar del estado vacío "Sin práctica asignada" que ocultaba el problema real.

### Causa raíz de fallos recurrentes — documentado para no repetirlo

Los fallos de "la app no refleja los cambios" se producen por dos motivos acumulados:
1. **Contenedores Docker con código antiguo**: siempre usar `docker-compose build --no-cache backend frontend` tras cambios de código, luego `docker-compose up -d`.
2. **Caché del browser**: el browser cachea el JS de Flutter y sirve el build antiguo aunque el contenedor haya cambiado. Solución obligatoria tras cualquier rebuild: **Ctrl+Shift+R** en Chrome.

Ver procedimiento completo en la sección "Workflow de actualización" de `CLAUDE.md`.

---

## [26/04/2026] - Hito 3: Doble Validación y Paneles de Tutor

### Backend (Spring Boot)
- **Migración V5**: Renombrado de estados en tabla `seguimientos`. `PENDIENTE` → `PENDIENTE_EMPRESA`, `VALIDADO` → `PENDIENTE_CENTRO`. Los registros existentes se reclasifican automáticamente. Los estados `COMPLETADO` y `RECHAZADO` no cambian.
- **Flujo de doble validación completo**: `SeguimientoServiceImpl` refactorizado con dos métodos de negocio separados:
  - `validarEmpresa()`: solo actúa sobre `PENDIENTE_EMPRESA`. Puede aprobar (`PENDIENTE_CENTRO`) o rechazar (`RECHAZADO`). Al rechazar, crea automáticamente una `Incidencia` de tipo `RECHAZO_PARTE` vinculada a la práctica — el alumno no necesita reportarla manualmente.
  - `validarCentro()`: solo actúa sobre `PENDIENTE_CENTRO`. Marca el parte como `COMPLETADO`, sumando las horas al progreso del alumno.
- **Endpoints nuevos**: `PATCH /api/v1/seguimientos/{id}/validar-empresa` (TUTOR_EMPRESA) y `PATCH /api/v1/seguimientos/{id}/validar-centro` (TUTOR_CENTRO).
- **IncidenciaService completo**: CRUD de incidencias con transición de estados `ABIERTA → EN_PROCESO → RESUELTA → CERRADA`. Solo el tutor del centro puede avanzar el estado. `IncidenciaController` expone `POST /incidencias`, `GET /incidencias/practica/{id}`, `PATCH /incidencias/{id}/estado`.
- **Tests**: 5 tests de integración en `SeguimientoDoubleValidationTest` — todos pasan. Cubren los 4 casos de negocio obligatorios (registro, validación empresa, rechazo empresa con incidencia automática, intento de saltar el orden) más el flujo completo empresa→centro→COMPLETADO.

### Frontend (Flutter)
- **Sistema de diseño**: `app_theme.dart` con `NexusColors`, `NexusSizes` y `NexusText`. Todos los colores son semánticos (verde=validado, ámbar=pendiente, rojo=rechazado/incidencia, azul=activo). Cero hardcoding de colores en pantallas.
- **Routing por rol**: `go_router` con guards de autenticación. Cada rol redirige a su pantalla propia al hacer login (alumno→dashboard, tutor empresa→panel empresa, tutor centro→panel centro).
- **PanelTutorEmpresaScreen**: Sidebar verde 52px + contenido. Stats con borde izquierdo semántico (pendientes/procesados/horas). Parte-cards con cabecera, cita de descripción y acciones validar/rechazar. Modal de rechazo con motivo obligatorio.
- **PanelTutorCentroScreen**: Layout 3 columnas (sidebar 52px + lista alumnos 220px + panel detalle). Sidebar con 4 iconos funcionales: Alumnos (lista+detalle), Partes (todos los pendientes), Incidencias (agrupadas por estado), Chat (placeholder). Lista de alumnos con selección sólida azul y badges de estado. Panel detalle: barra de progreso FCT con gradiente y porcentaje, partes pendientes con validación inline, incidencias abiertas con gestión de estado. Adaptativo: bottom nav en móvil.
- **Providers actualizados**: `TutorEmpresaProvider` con stats calculados (totalPartes, totalHoras, totalValidados). `TutorCentroProvider` con selección de alumno, seguimientos y incidencias por práctica, horas completadas.
- **Correcciones de sesión**: JWT expirado no provoca crash (catch en `JwtAuthenticationFilter`). Token localStorage persiste correctamente entre sesiones. go_router gestiona redirecciones sin conflicto con Navigator.

### Decisiones Técnicas
- **Incidencia automática al rechazar**: La crea el servicio de seguimientos, no el controller. El tutor de empresa no necesita conocer la existencia de la entidad Incidencia para generar una.
- **Sidebar 52px en lugar de AppBar**: Libera espacio vertical. El logout como icono propio separado del avatar mejora la discoverabilidad.
- **Modo de vistas en sidebar tutor centro**: En lugar de navegar entre pantallas, los iconos cambian el modo del panel derecho. Evita recargas y mantiene la lista de alumnos siempre visible.

---

## [26/04/2026] — Bloque 3: go_router + pantalla tutor empresa + endpoints /me por rol

### Backend
- **GET /practicas/tutor-empresa/me**: nuevo endpoint para que el tutor de empresa obtenga sus prácticas asignadas. Sigue el patrón de `/practicas/me` del alumno.
- **GET /practicas/tutor-centro/me**: ídem para el tutor del centro.

### Flutter
- **go_router configurado**: `_AppWithRouter` crea el router una vez con la referencia al `AuthProvider`. El `refreshListenable` hace que el router reevalúe el guard en cada cambio de sesión.
- **Guards por rol**: tras login, el router redirige automáticamente a `/dashboard` (ALUMNO), `/tutor-empresa` (TUTOR_EMPRESA) o `/tutor-centro` (TUTOR_CENTRO).
- **PanelTutorEmpresaScreen**: pantalla minimalista de firma de partes. Carga los partes en PENDIENTE_EMPRESA, permite validar con confirmación y rechazar con motivo obligatorio via modal. El rechazo genera incidencia automática en el backend.
- **PanelTutorCentroScreen**: placeholder listo para el Bloque 4.
- **TutorEmpresaProvider**: gestiona la carga y validación de partes pendientes.
- **SeguimientoService**: añadidos `validarEmpresa()` y `validarCentro()`.
- **IncidenciaService**: añadido `actualizarEstado()`.
- **Corrección**: fallback de estado en `seguimiento_model.dart` corregido a `PENDIENTE_EMPRESA`.

## [26/04/2026] — Verificación de correcciones del Hito 2 + arranque Hito 3

### Correcciones verificadas (Bloque 1)
- **FIX-1 JWT Secret**: `.env` contiene clave aleatoria de 64 caracteres base64. `JwtUtils.java` usa `@Value("${JWT_SECRET:CAMBIAR_EN_PRODUCCION}")` — el fallback nunca se activa en entornos reales. Docker Compose inyecta la variable correctamente.
- **FIX-2 Rol.java**: Ya usa `@Getter + @Setter + @EqualsAndHashCode(of = "id")`. Corregido el Javadoc que describía incorrectamente `@Data`.
- **FIX-3 RuntimeException**: `PracticaServiceImpl` ya usa `BusinessRuleException` y `ResourceNotFoundException` en todos los puntos de fallo. Sin `RuntimeException` genérica.
- **FIX-4 BBDD-TFG.sql**: Cabecera de referencia histórica ya presente desde commits anteriores.
- **FIX-5 Perfiles Spring**: `application-dev.properties` y `application-prod.properties` existen con configuración de logs por entorno.
- **FIX-6 Paginación**: `PracticaController.listarTodas()` ya retorna `Page<PracticaResponse>` con `@PageableDefault(size = 20)`.

---

## [19/04/2026] — Hito 2: datos de prueba, endpoint /me, dashboard real, SeguimientoScreen

### Backend

- **Migración V4__Datos_Prueba_Hito2.sql**: nueva empresa EjemploTech S.L., usuario `tutorempresa@nexus.edu`, práctica activa FCT-2025-001 para el alumno (240h, 02/04-01/11/2025), 3 seguimientos con estados distintos y 1 incidencia abierta — suficiente para mostrar el flujo completo en la demo.
- **GET /api/v1/practicas/me**: nuevo endpoint exclusivo para ROLE_ALUMNO. El servicio obtiene el email del JWT mediante `SecurityContextHolder` en lugar de recibir `alumnoId` como parámetro. Añadido `findFirstByAlumnoIdAndEstado()` al `PracticaRepository`.
- **IncidenciaController básico**: `GET /incidencias/practica/{id}` y `GET /incidencias/{id}`. El mapeo se hace inline sin MapStruct (se formaliza en Hito 3 cuando el módulo esté completo).

### Flutter

- **PracticaProvider refactorizado**: `cargarPracticas(alumnoId)` sustituido por `cargarDashboard()` sin parámetros. Las tres llamadas (práctica activa, seguimientos, incidencias) se ejecutan en paralelo con `Future.wait()` para minimizar la latencia percibida.
- **Modelos y servicios nuevos**: `seguimiento_model.dart`, `incidencia_model.dart`, `seguimiento_service.dart`, `incidencia_service.dart`, `practica_service.dart` con `getPracticaActiva()`.
- **Dashboard con datos reales**: barra de progreso conectada a `horasCompletadas` (solo seguimientos COMPLETADO). Cards de seguimientos e incidencias muestran los primeros 3 items reales con color semántico.
- **SeguimientoScreen**: formulario con DatePicker (fecha ≤ hoy), horas (1-24), descripción. POST /seguimientos y actualización local del provider. SnackBar de confirmación.
- **Fix DatePicker**: el picker aparecía en blanco por pasar `locale: Locale('es','ES')` sin `flutter_localizations` configurado. Solución: añadir `flutter_localizations` al `pubspec.yaml` y configurar `localizationsDelegates` y `supportedLocales` en `main.dart`.
- **Tests**: 10/10 pasando. NOTA: `JAVA_HOME` del sistema apunta a Java 11 — para correr tests desde terminal: `JAVA_HOME="C:/Program Files/Eclipse Adoptium/jdk-21.0.10.7-hotspot" ./mvnw test`.

---

## [19/04/2026] — Navegación funcional del Dashboard + POST incidencias

### Backend (Spring Boot)
- **IncidenciaRequest DTO**: Nuevo record con campos `tipo` y `descripcion` validados con Bean Validation (`@NotBlank`, `@Size`).
- **POST /api/v1/incidencias**: Nuevo endpoint en `IncidenciaController` que permite reportar una incidencia vinculada a la práctica activa del usuario autenticado. El backend resuelve el ID de la práctica desde el JWT (via `SecurityContextHolder`), sin requerir que el cliente lo envíe. La incidencia se crea con estado `ABIERTA` de forma automática.
- **Tests**: Los 10 tests existentes siguen pasando tras los cambios.

### Frontend (Flutter)
- **Arquitectura de navegación**: `DashboardScreen` refactorizado para usar `IndexedStack` con 4 hijos. El `NavigationRail` (web) y el `BottomNavigationBar` (móvil) ahora cambian el contenido real de la pantalla al pulsar, en lugar de solo marcar el item seleccionado.
- **SeguimientosScreen**: Nueva pantalla con la lista completa de partes del alumno, barra de progreso de horas completadas vs totales, y FAB para registrar un nuevo seguimiento. Al volver del formulario, recarga los datos automáticamente.
- **IncidenciasScreen**: Nueva pantalla con listado de incidencias y botón outline "Reportar incidencia" que abre un `ModalBottomSheet`. El sheet contiene un dropdown de tipo y un textarea de descripción. Al enviar, llama al nuevo `POST /incidencias` y recarga la lista.
- **ChatPlaceholderScreen**: Pantalla placeholder estilo Nexus con icono, texto "Chat en tiempo real" y badge "Próximo — Hito 3".
- **Widgets compartidos**: `SeguimientoTile` e `IncidenciaTile` extraídos a `presentation/widgets/` para ser reutilizados desde el tab de inicio y desde sus respectivas pantallas completas.
- **Callbacks conectados**: Los botones "Ver todos" y "Reportar" del tab de inicio ahora navegan a sus respectivos tabs via callbacks al `IndexedStack`.

---

## [15/04/2026] - Integración Visual y Sincronización de Identidad

### Backend (Spring Boot)
- **Seguridad y DTOs**: Se ha modificado el record `AuthResponse` y el `UsuarioMapper` para incluir el `id` del usuario en la respuesta de autenticación. Esta mejora es crítica para que el cliente móvil realice peticiones dependientes del contexto del usuario (como listar sus propias prácticas) de forma eficiente sin decodificar manualmente el JWT.
- **Mapeo Automatizado**: MapStruct ahora gestiona la sincronización del ID de la entidad `Usuario` al DTO de respuesta, garantizando integridad en el flujo de login.
- **Módulo de Seguimientos (Tarea 5)**: Implementación completa de la lógica de partes diarios:
  - **Persistencia**: Creado `SeguimientoRepository` con filtrado por práctica y estado.
  - **DTOs y Mappers**: Definidos `SeguimientoRequest/Response` y su integración con MapStruct para proteger las entidades JPA.
  - **Servicios**: Implementado `SeguimientoService` con validación de estados (protección de registros ya procesados) y captura automática de la identidad del tutor desde el contexto de seguridad.
  - **Controlador REST**: Expuestos endpoints para registro (ALUMNO), consulta (TODOS) y validación (TUTORES) bajo `@PreAuthorize`.
  - **Calidad**: Añadido `SeguimientoServiceTest` y configurado perfil de test con H2 para validaciones independientes.

### Frontend (Flutter)
- **Modelos de Negocio**: Creación de la entidad `Practica` sincronizada 1:1 con el contrato del backend (`PracticaResponse`).
- **Comunicaciones**: Implementación del `PracticaService` para el consumo de endpoints protegidos y el `PracticaProvider` para la gestión del estado global de las prácticas académicas.
- **UI/UX (Dashboard)**:
  - Diseño e implementación de la pantalla **Dashboard**, siguiendo las directrices de diseño (Cards con elevación, estados visuales mediante colores semánticos).
  - Integración de saludo dinámico y resumen de formación práctica (Empresa, Código, Tutores).
- **Navegación**: Refactorización del flujo de arranque en `main.dart`. La aplicación ahora detecta reactivamente el estado de autenticación mediante `Consumer<AuthProvider>`, redirigiendo automáticamente entre el Login y el Dashboard sin gestión manual de rutas.

### Documentación y Seguimiento
- **Memoria de Seguimiento**: Actualización del plan operativo en `conductor/` marcando la Tarea 4 (Gestión de Prácticas) como completada.
- **Bitácora**: Unificación de registros en este documento (`HISTORIAL_CAMBIOS.md`) para simplificar la futura redacción de la memoria del TFG.

---

## [18/04/2026] — Decisión: sistema de diseño visual centralizado

Antes de implementar más pantallas Flutter se definió un sistema de diseño centralizado en `app_theme.dart`. Los colores estaban hardcodeados directamente en los widgets, lo que hacía imposible mantener coherencia visual a medida que creciera la app. El momento óptimo para definirlo es con una sola pantalla implementada: con ninguna no hay referencia real, con más habría que refactorizar todo.

**Decisiones**: `NexusColors` (semántico: azul=activo, verde=validado, ámbar=pendiente, rojo=incidencia/rechazado) y `NexusSizes` (espaciados y radios consistentes). Navegación adaptativa con `LayoutBuilder` — `NavigationRail` en web, `BottomNavigationBar` en móvil. Referencia completa en `DESIGN_SYSTEM.md`.

---

## [14/04/2026] - Preparación Hito 2 (50%)

### Backend (Spring Boot)
- **Seguridad**: Activada la seguridad por métodos (`@EnableMethodSecurity`) para garantizar que las restricciones `@PreAuthorize` se apliquen en todos los niveles.
- **Entidades**: Implementación de las entidades JPA restantes para sincronización total con la BD: `Incidencia`, `Mensaje` y `Notificacion`.
- **Lógica de Negocio**: Implementación del CRUD completo de **Prácticas**, incluyendo:
  - Repositorio con consultas personalizadas por alumno/tutor.
  - Servicio con validación de estados (protección de convenios activos).
  - Controlador REST protegido por roles (ADMIN crea, TUTORES supervisan, ALUMNOS consultan).
- **Manejo de Errores**: Refactorización del `GlobalExceptionHandler` para capturar `AccessDeniedException` y devolver códigos HTTP 403 (Forbidden) profesionales.
- **Calidad**: Implementación de batería de tests de integración para el módulo de Prácticas y Autenticación (8 tests totales superados).

### Frontend (Flutter)
- **Arranque de Proyecto**: Transformación del boilerplate inicial en una arquitectura profesional organizada por capas (`core`, `data`, `presentation`).
- **Comunicaciones**: Configuración de `Dio` como cliente de red con interceptores para la gestión automática de tokens JWT.
- **Persistencia**: Integración de `flutter_secure_storage` para el almacenamiento encriptado de credenciales en el dispositivo.
- **Gestión de Estado**: Implementación de `Provider` para el manejo global de la autenticación del usuario.
- **UI/UX**: Creación de la pantalla de **Login** funcional, conectada en tiempo real con la API del Backend.

### Arquitectura y DevOps
- **Consolidación**: Unificación del control del proyecto en la raíz (`TFG/`) y centralización de planes de desarrollo en `conductor/`.
- **Docker**: Corrección de rutas de build y eliminación de redundancias en la inicialización de la base de datos para evitar conflictos con Flyway.
