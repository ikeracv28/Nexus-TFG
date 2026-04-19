# HISTORIAL DE CAMBIOS — Nexus TFG
# Complemento al HISTORIAL_CAMBIOS.md del proyecto
# Registra decisiones de rediseño detectadas durante el desarrollo

---

## [18/04/2025] — Rediseño del flujo de validación de seguimientos

### Contexto
Durante la sesión de análisis previo a la implementación del Hito 3 se detectó un error
de lógica en el diseño del módulo de seguimientos.

### Problema
El sistema original tenía un endpoint único `PATCH /seguimientos/{id}/validar` accesible
por cualquier tutor (TUTOR_CENTRO o TUTOR_EMPRESA), con tres estados posibles:
PENDIENTE, VALIDADO, RECHAZADO. Este diseño mezclaba las responsabilidades del tutor
de empresa y del tutor del centro en una misma acción.

### Análisis
En la realidad de las FCT existen dos validaciones distintas:
1. El tutor de empresa firma el parte semanal (valida el trabajo real hecho en la empresa).
2. El tutor del centro da el visto bueno académico (supervisa el proceso formativo).

Son responsabilidades distintas, con información distinta y en momentos distintos.
Permitir que cualquiera de los dos valide directamente al estado final no refleja
el proceso real y elimina la trazabilidad de quién hizo qué.

### Solución
Flujo de doble validación en cascada:
- Cuatro estados: PENDIENTE_EMPRESA, PENDIENTE_CENTRO, COMPLETADO, RECHAZADO
- Dos endpoints separados con @PreAuthorize diferente
- El orden es obligatorio y se valida en el servicio con BusinessRuleException
- El rechazo de empresa genera incidencia automática sin intervención del alumno

### Archivos afectados
- V4__Estados_Seguimiento.sql (nueva migración Flyway)
- SeguimientoServiceImpl.java (separar validar() en dos métodos)
- SeguimientoController.java (dos endpoints nuevos)
- IncidenciaService.java (creación automática en rechazo)
- SeguimientoServiceTest.java (cuatro nuevos casos de negocio)
- ARQUITECTURA_API.md (actualizar contrato)

### Por qué se detectó antes de implementar
La revisión crítica del diseño antes de escribir código es parte del workflow definido
en conductor/workflow.md. El coste de este cambio antes de implementar es bajo.
El mismo cambio tras haber construido el frontend completo habría requerido rehacer
todas las pantallas de validación.

---

## [19/04/2026] — Hito 2: datos de prueba, endpoint /me, dashboard real, SeguimientoScreen

### Contexto
Sesión de preparación de la demo del Hito 2 (entrega 21/04). El backend ya tenía
autenticación JWT, CRUD de prácticas y seguimientos. El dashboard Flutter mostraba
datos reales pero sin datos seed útiles y con la barra de progreso hardcodeada a 0.

### Cambios realizados

**Migración V4__Datos_Prueba_Hito2.sql**
- Nueva empresa EjemploTech S.L. (CIF B12345678)
- Nuevo usuario tutor de empresa: tutorempresa@nexus.edu / 123456 (ROLE_TUTOR_EMPRESA)
- Práctica activa FCT-2025-001 para alumno@nexus.edu, 240 horas, del 02/04 al 01/11/2025
- 3 seguimientos (COMPLETADO 8h, VALIDADO 8h, PENDIENTE 8h) para mostrar el flujo
- 1 incidencia ABIERTA tipo ACCESO vinculada a la práctica

**Endpoint GET /api/v1/practicas/me**
- Nuevo endpoint exclusivo para ROLE_ALUMNO
- El servicio obtiene el email del JWT mediante SecurityContextHolder en lugar de recibir
  el alumnoId como parámetro — el alumno no necesita conocer su propio ID
- Devuelve 404 con mensaje claro si el alumno no tiene práctica activa
- Requirió añadir `findFirstByAlumnoIdAndEstado()` al PracticaRepository

**IncidenciaController y IncidenciaRepository (básico)**
- GET /api/v1/incidencias/practica/{id}: lista de incidencias ordenada por fecha desc
- GET /api/v1/incidencias/{id}: detalle de una incidencia
- El mapeo a IncidenciaResponse se hace inline en el controller (sin MapStruct aún,
  se formalizará en Hito 3 cuando el módulo sea completo)

**Flutter — PracticaProvider refactorizado**
- `cargarPracticas(alumnoId)` sustituido por `cargarDashboard()` sin parámetros
- Las tres llamadas (práctica activa, seguimientos, incidencias) se ejecutan en paralelo
  con `Future.wait()` para minimizar la latencia percibida
- `horasCompletadas`: getter calculado sumando solo seguimientos con estado COMPLETADO
- `agregarSeguimiento()`: actualiza la lista local al registrar sin recargar toda la red

**Flutter — Nuevos modelos y servicios**
- `seguimiento_model.dart`: sincronizado con SeguimientoResponse.java
- `incidencia_model.dart`: sincronizado con IncidenciaResponse.java
- `seguimiento_service.dart`: GET /seguimientos/practica/{id} y POST /seguimientos
- `incidencia_service.dart`: GET /incidencias/practica/{id}
- `practica_service.dart`: nuevo método `getPracticaActiva()` → GET /practicas/me

**Flutter — Dashboard con datos reales**
- Barra de progreso conectada a `provider.horasCompletadas` (ya no hardcodeada a 0)
- Cards de seguimientos e incidencias muestran datos reales de la API (primeros 3 items)
- Color semántico: verde=COMPLETADO, azul=VALIDADO, ámbar=PENDIENTE, rojo=RECHAZADO/ABIERTA

**Flutter — SeguimientoScreen**
- Formulario con 3 campos: DatePicker (fecha ≤ hoy), número de horas (1-24), descripción
- POST /seguimientos y actualización local del provider sin recarga extra
- SnackBar de confirmación en verde al registrar correctamente

**Fix DatePicker (19/04/2026)**
- El DatePicker aparecía en blanco porque se pasaba `locale: Locale('es','ES')` sin tener
  `flutter_localizations` configurado en el MaterialApp
- Solución: añadir `flutter_localizations` al pubspec.yaml y configurar
  `localizationsDelegates` y `supportedLocales` en main.dart

### Tests
- 10/10 tests pasando con Java 21
- NOTA: el JAVA_HOME del sistema apunta a Java 11. Para correr tests desde terminal:
  `JAVA_HOME="C:/Program Files/Eclipse Adoptium/jdk-21.0.10.7-hotspot" ./mvnw test`

---

## [18/04/2025] — Definición del sistema de diseño visual

### Contexto
El frontend tenía un DashboardScreen funcional pero sin sistema de diseño definido.
Los colores estaban hardcodeados directamente en los widgets.

### Decisión
Definir un sistema de diseño centralizado antes de implementar más pantallas:
- Archivo app_theme.dart con NexusColors y NexusSizes
- Color semántico obligatorio (verde=validado, ámbar=pendiente, rojo=incidencia, azul=activo)
- Navegación adaptativa con LayoutBuilder (web: NavigationRail, móvil: BottomNavigationBar)
- Referencia visual documentada en DESIGN_SYSTEM.md

### Por qué ahora y no después
Definir el sistema de diseño con una sola pantalla implementada es el momento óptimo.
Con más pantallas habría que refactorizar todas. Con ninguna no hay referencia visual real.
