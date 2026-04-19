# Registro de Cambios y Avances - TFG Nexus

Este documento registra las implementaciones técnicas realizadas tras la entrega del Hito 1 (25%) para alcanzar los objetivos del Hito 2 (50%).

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
