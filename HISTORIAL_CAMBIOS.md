# Registro de Cambios y Avances - TFG Nexus

Este documento registra las implementaciones técnicas realizadas a lo largo del proyecto.

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
