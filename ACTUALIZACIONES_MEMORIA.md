# Actualizaciones para la Memoria TFG — Nexus
> Cada bloque indica exactamente **dónde colocarlo** y si es texto nuevo o sustituye a algo existente.

---

## BLOQUE 1 — Sección 3.1: Requisitos Funcionales
**Acción:** Añadir a continuación del RF-07 existente. Son requisitos nuevos, no reemplaza nada.

---

- **RF-08 (Gestión de Ausencias):** El alumno puede registrar ausencias con fecha y motivo, y adjuntar un fichero justificante (PDF, JPG o PNG de hasta 5 MB). El tutor de empresa revisa cada ausencia y la clasifica como justificada o injustificada. El sistema valida que no exista ya una ausencia para la misma práctica y fecha, evitando duplicados.

- **RF-09 (Chat en tiempo real):** Cada práctica dispone de un canal de chat privado entre el alumno y sus tutores. Los mensajes nuevos se reciben en tiempo real mediante WebSocket sin necesidad de recargar la pantalla. Al abrir el chat se carga el historial completo a través de REST y los mensajes posteriores llegan por suscripción al canal correspondiente.

- **RF-10 (Sistema de auditoría):** El sistema registra automáticamente todas las operaciones relevantes —creación, modificación y validación de prácticas, seguimientos, ausencias e incidencias, así como inicios y cierres de sesión— en una tabla centralizada. El administrador puede consultarlas filtrando por módulo, con el email del actor y una descripción de la acción ejecutada.

- **RF-11 (Gestión de incidencias):** El alumno puede reportar cualquier problema durante la práctica mediante un formulario categorizado. Si el tutor de empresa rechaza un parte de seguimiento, el sistema crea automáticamente una incidencia visible para el tutor del centro, sin que el alumno tenga que hacer nada adicional.

- **RF-12 (Restauración de sesión):** Cuando el usuario reabre la aplicación, esta comprueba si el token JWT almacenado de forma segura sigue siendo válido mediante una llamada a `GET /auth/me`. Si el token es válido, el usuario accede directamente a su panel sin necesidad de volver a introducir sus credenciales. Si el token ha expirado o ha sido revocado, el almacenamiento se limpia y se muestra la pantalla de login.

---

## BLOQUE 2 — Sección 3.2: Requisitos No Funcionales
**Acción:** Sustituir completamente la sección 3.2 existente (que solo tiene RNF-01 y RNF-02) por este bloque.

---

- **RNF-01 (Seguridad):** Cifrado BCrypt para contraseñas, autenticación stateless mediante JWT con claim `jti` único por token, blacklist en servidor para invalidación inmediata en logout y limpieza automática de entradas expiradas. Rate limiting de diez peticiones por IP y minuto en los endpoints de autenticación.

- **RNF-02 (Integridad referencial):** PostgreSQL garantiza la integridad de las relaciones entre entidades. Flyway gestiona el historial de cambios del esquema mediante migraciones versionadas y secuenciales, lo que hace el estado de la base de datos reproducible en cualquier entorno.

- **RNF-03 (Usabilidad y adaptabilidad):** La interfaz se adapta automáticamente al tamaño de pantalla usando `LayoutBuilder`: en dispositivos anchos (más de 600 px) se muestra un sidebar de navegación lateral; en móvil se sustituye por una barra de navegación inferior. La misma base de código Flutter genera ambas variantes sin duplicar lógica.

- **RNF-04 (Portabilidad):** El frontend se distribuye como aplicación web estática compilada. Un Dockerfile multi-stage construye la app con el SDK de Flutter y transfiere únicamente los ficheros estáticos resultantes a una imagen Nginx Alpine, eliminando todas las herramientas de compilación del artefacto final. Esto reduce el tamaño de imagen y la superficie de ataque en producción.

- **RNF-05 (Mantenibilidad):** La arquitectura en capas estricta —Controller, Service, Repository— separa las responsabilidades y facilita la extensión del sistema. Cada módulo funcional tiene su propio servicio, su propio controlador y sus propios tests. Añadir un nuevo módulo no requiere modificar los existentes.

- **RNF-06 (Trazabilidad):** El sistema de auditoría registra cada operación en una transacción independiente mediante `Propagation.REQUIRES_NEW`, de forma que incluso si la operación principal falla y su transacción hace rollback, el intento queda almacenado. Esto garantiza un historial completo e inalterable de lo que ha ocurrido en el sistema.

- **RNF-07 (Confidencialidad del token en cliente):** El token JWT se almacena en el dispositivo usando `flutter_secure_storage`, que utiliza el almacenamiento cifrado del sistema operativo (Keychain en iOS, EncryptedSharedPreferences en Android, credenciales del sistema en web). Nunca se guarda en memoria no cifrada ni en localStorage.

- **RNF-08 (Disponibilidad del entorno):** El orquestador Docker Compose configura un healthcheck sobre la base de datos PostgreSQL antes de permitir que el backend arranque, evitando errores de conexión durante el inicio en frío. Los tres servicios —base de datos, API y frontend— se despliegan y se detienen de forma coordinada con un único comando.

---

## BLOQUE 3 — Sección 4: Arquitectura y Tecnologías
**Acción:** Añadir a continuación del párrafo de Frontend existente, antes del apartado 4.1. Es contenido nuevo que no reemplaza nada.

### Título a insertar: "Arquitectura del frontend en detalle"

---

La arquitectura del frontend sigue el patrón de tres capas propio de Flutter. La capa de datos contiene los modelos —clases Dart que mapean directamente los JSON de la API— y los servicios, que encapsulan cada llamada HTTP usando Dio. Un interceptor global inyecta el token JWT en la cabecera `Authorization` de cada petición y detecta respuestas 401 para redirigir al login sin intervención del desarrollador.

La capa de presentación se organiza en providers —uno por módulo funcional— que extienden `ChangeNotifier`. Cada provider carga sus datos, gestiona el estado de carga y error, y notifica a los widgets cuando algo cambia. Esta separación hace que los widgets sean puramente visuales: reciben datos del provider y delegan las acciones de vuelta a él, sin lógica de negocio incrustada.

La navegación se implementa con `go_router`, que permite definir rutas con guards: si el usuario no está autenticado y navega a una ruta protegida, el router lo redirige automáticamente al login. Al arrancar la aplicación, antes de mostrar ninguna pantalla, se ejecuta `AuthProvider.init()`, que llama a `GET /auth/me` con el token almacenado. Si el servidor confirma que el token sigue siendo válido, el usuario accede directamente a su panel; si devuelve un 401, el almacenamiento se limpia y se muestra el login. Esto elimina la necesidad de que el usuario se autentique en cada sesión mientras su token esté vigente.

---

## BLOQUE 4 — Sección 4: Infraestructura y despliegue
**Acción:** Insertar justo antes del apartado 4.1 (después del bloque anterior). Es contenido nuevo.

### Título a insertar: "Infraestructura y despliegue con Docker"

---

Todo el sistema se despliega mediante Docker Compose, que orquesta tres servicios en una red privada: la base de datos PostgreSQL, la API Spring Boot y el frontend Flutter servido por Nginx.

El Dockerfile del backend es un build multi-stage: la primera etapa usa la imagen oficial de Maven con Java 21 para compilar el proyecto; la segunda etapa copia únicamente el JAR resultante sobre una imagen Alpine mínima. El artefacto final no contiene el código fuente ni las herramientas de compilación.

El Dockerfile del frontend sigue el mismo patrón pero con una particularidad relevante: la URL del backend se inyecta en tiempo de compilación mediante el parámetro `--dart-define=API_URL`. Esto evita que la URL quede grabada en el código fuente y permite configurarla por entorno sin recompilar. El valor se lee en Dart con `String.fromEnvironment('API_URL')` y Docker Compose lo pasa como argumento de build desde el fichero `.env`.

El `docker-compose.yml` configura un healthcheck sobre la base de datos —`pg_isready`— antes de permitir que el backend arranque. Esto evita errores de conexión durante el inicio en frío, donde PostgreSQL puede tardar unos segundos en estar listo para aceptar conexiones. La variable `JWT_SECRET` está declarada con la sintaxis `${JWT_SECRET:?mensaje}`, de modo que Docker Compose falla de forma explícita si no está definida en el entorno, impidiendo arrancar con un secreto vacío o por defecto.

---

## BLOQUE 5 — Sección 4.3: Seguridad OWASP
**Acción:** Añadir este párrafo al final de la sección 4.3, después del apartado de "Rate limiting y cabeceras". Es contenido nuevo.

---

**Control de acceso a nivel de objeto (A01 — IDOR).** Durante la revisión final del proyecto detecté que los servicios de seguimiento y ausencias verificaban el rol del usuario —TUTOR_EMPRESA o TUTOR_CENTRO— pero no comprobaban que el usuario autenticado fuera el tutor asignado específicamente a la práctica sobre la que estaba actuando. Cualquier tutor de empresa con sesión activa podía validar partes de prácticas que no le correspondían. La corrección añade una verificación explícita antes de cualquier modificación de estado: `practica.getTutorEmpresa().getEmail().equals(emailAutenticado)`. Si la comprobación falla, el servicio lanza `AccessDeniedException` antes de ejecutar nada. Es la diferencia entre "¿tienes el rol correcto?" —control por tipo de usuario— y "¿tienes permiso sobre este recurso concreto?" —control por pertenencia—, que OWASP A01 denomina Broken Object Level Authorization. El mismo patrón se aplica al listado de seguimientos y ausencias por práctica: aunque el endpoint sea de solo lectura, un usuario sin relación con esa práctica recibe un 403 en lugar de los datos.

---

## BLOQUE 6 — Sección 4.4: Tests automatizados
**Acción:** Sustituir todas las menciones a "ciento siete tests" y "107 tests" por "ciento veintiún tests" / "121 tests". Además, añadir este párrafo al final de la sección 4.4.

---

Al cierre del proyecto, la batería cuenta con **ciento veintiún tests** organizados en catorce clases. Los catorce nuevos casos incorporados en el hito final cubren el módulo de chat: `MensajeServiceTest` verifica el almacenamiento y recuperación de mensajes con su práctica y remitente asociados, y `MensajeControllerTest` comprueba el comportamiento de seguridad por roles —que un alumno solo puede enviar mensajes a prácticas en las que participa, y que un usuario sin autenticación recibe un 401 antes de llegar al controlador—. La cobertura global se mantiene en el 69,5% de instrucciones medido con JaCoCo.

---

## BLOQUE 7 — Sección 5.3: Panel del Tutor Centro / Administrador
**Acción:** Eliminar el bullet duplicado "Lista de Alumnos" que aparece dos veces en esta sección. Dejar solo la segunda versión, que es la más completa.

**Borrar esta línea:**
> ● Lista de Alumnos : El tutor puede saltar de un alumno a otro para ver cómo van.

**Conservar esta (que ya existe más abajo):**
> ● Lista de Alumnos: El tutor puede saltar de un alumno a otro para ver su progreso FCT, los partes pendientes de su validación final y las incidencias abiertas.

---

## BLOQUE 8 — Sección 5.4: Panel del Tutor de Empresa
**Acción:** Sustituir completamente el texto actual de la sección 5.4 por este.

---

Al añadir la doble validación, necesité diseñar una pantalla específica para el tutor de empresa. He decidido mantenerla deliberadamente simple porque el tutor de empresa no necesita ver el historial académico del alumno, ni las incidencias del centro, ni el detalle del chat. Si le meto todo eso en una pantalla se vuelve confusa y deja de parecerse al proceso que ya conoce: revisar el parte de la semana y firmarlo.

El panel se organiza en dos pestañas accesibles desde la barra lateral.

La primera pestaña, **Partes pendientes**, muestra tres indicadores en la cabecera: el número de partes que esperan firma, las horas que el tutor ya ha validado en el convenio activo, y las horas que le quedan al alumno hasta completarlo. Debajo aparecen los partes ordenados por fecha, con la descripción que escribió el alumno y los botones de validar o rechazar. Cuando rechaza un parte tiene que escribir el motivo obligatoriamente, de modo que queda registrado y el tutor del centro sabe exactamente qué ocurrió.

La segunda pestaña, **Progreso del alumno**, está pensada para los momentos en que el tutor quiere tener una visión global sin entrar en el detalle de cada parte. Muestra una tarjeta por práctica con el nombre del alumno, el código del convenio, las fechas de inicio y fin, y una barra de progreso visual que representa las horas validadas frente al total comprometido. Bajo la barra aparece el desglose numérico: horas registradas por el alumno, horas ya validadas por la empresa, y horas que aún quedan para completar el convenio. Los indicadores de la primera pestaña se calculan únicamente sobre prácticas en estado activo, evitando que convenios ya finalizados distorsionen los totales.

---

## BLOQUE 9 — Sección 6: Modelo de la Base de Datos
**Acción:** Añadir después del párrafo sobre el ERD, antes del texto sobre las entidades JPA. Es contenido nuevo.

---

Varias decisiones de diseño del esquema merecen una explicación más detallada.

El justificante de ausencia se almacena como `bytea` directamente en PostgreSQL, vinculado al registro de la ausencia. Esta decisión evita la complejidad de gestionar un sistema de ficheros externo —con rutas, permisos y sincronización— para el alcance del proyecto. La respuesta JSON expone únicamente un campo booleano `tieneJustificante`, de modo que el cliente sabe si existe un fichero sin descargarlo hasta que el usuario lo solicita explícitamente. El endpoint de descarga verifica antes de devolver los bytes que quien hace la petición sea participante de la práctica vinculada, aplicando el mismo control de acceso a nivel de objeto que en el resto de módulos.

La tabla `audit_logs` almacena todas las operaciones relevantes del sistema con cuatro campos clave: el módulo afectado, la acción ejecutada, el identificador del recurso y el email del actor. El servicio de auditoría utiliza `Propagation.REQUIRES_NEW` para escribir en una transacción independiente de la operación principal. Si la operación falla y hace rollback, el intento queda igualmente registrado en el log —que es exactamente el comportamiento necesario en un sistema de trazabilidad.

La tabla de mensajes del chat vincula cada mensaje a una práctica concreta y a su remitente. Al cargar la pantalla del chat se recupera el historial completo mediante REST; los mensajes posteriores se reciben en tiempo real por suscripción al topic `/topic/practica/{id}` de STOMP. Solo los participantes de esa práctica están suscritos a ese topic, garantizando que los mensajes no se cruzan entre prácticas distintas.

---

## BLOQUE 10 — Sección 7: Estado actual Hito 4
**Acción:** Sustituir el párrafo del Hito 4 existente (que está en futuro) por este.

---

**Estado Actual (Hito 4 — completado):** El cuarto hito cierra el ciclo de comunicación que era el objetivo central del proyecto desde su definición inicial. Se implementó el chat en tiempo real mediante WebSocket con el protocolo STOMP: el backend expone el endpoint `/ws`, la autenticación se resuelve pasando el token JWT en las cabeceras del frame STOMP CONNECT, y un interceptor de canal lo valida antes de registrar la conexión. Los mensajes se publican en topics por práctica —`/topic/practica/{id}`— de modo que solo los participantes de cada práctica reciben los mensajes de su canal. El historial se carga al abrir la pantalla mediante REST y los mensajes nuevos llegan por WebSocket sin necesidad de polling.

Junto al chat, este hito incorporó varias mejoras de seguridad y calidad detectadas durante la revisión final. Se corrigió una vulnerabilidad IDOR en los servicios de seguimiento y ausencias: el sistema verificaba el rol del usuario pero no que fuera el participante asignado a esa práctica concreta. Se implementó la restauración de sesión en Flutter —`GET /auth/me` al arrancar la app— para que el usuario no tenga que autenticarse de nuevo si su token sigue siendo válido. La blacklist de tokens y el mapa de rate limiting recibieron una limpieza periódica automática mediante `@Scheduled`, evitando el crecimiento indefinido de esas estructuras en memoria. La batería de tests creció hasta ciento veintiún casos con la incorporación de los tests del módulo de chat.

---

## BLOQUE 11 — Sección 8: Conclusión
**Acción:** Sustituir el primer párrafo de la conclusión por este, que recoge el estado final real del proyecto.

---

Este proyecto demuestra que se puede mejorar significativamente la experiencia de las prácticas si se centraliza en un único entorno digital lo que antes estaba disperso entre correos, llamadas y hojas de cálculo. La plataforma Nexus cubre el ciclo completo del seguimiento: el registro semanal de actividades con validación en dos pasos por figuras con responsabilidades distintas, la gestión de incidencias y ausencias con justificante adjunto, la comunicación directa en tiempo real entre los participantes de cada práctica, y un sistema de auditoría que registra todo lo que ocurre en el sistema. Al cierre del proyecto, el backend cuenta con ciento veintiún tests de integración y una cobertura del 69,5% medida con JaCoCo, cubriendo tanto los flujos correctos como los intentos de acceso no autorizado.

---

## Resumen de cambios por sección

| Sección | Acción | Prioridad |
|---|---|---|
| 3.1 RF | Añadir RF-08 a RF-12 al final de la lista | 🔴 Alta |
| 3.2 RNF | Sustituir los 2 RNF por los 8 del Bloque 2 | 🔴 Alta |
| 4 (nuevo) | Insertar bloque de arquitectura frontend detallada | 🟡 Media |
| 4 (nuevo) | Insertar bloque de infraestructura Docker | 🟡 Media |
| 4.3 OWASP | Añadir párrafo de IDOR al final de la sección | 🔴 Alta |
| 4.4 Tests | Actualizar "107" → "121" y añadir párrafo final | 🔴 Alta |
| 5.3 Panel Tutor Centro | Eliminar bullet "Lista de Alumnos" duplicado | 🟡 Media |
| 5.4 Panel Tutor Empresa | Sustituir texto completo | 🟡 Media |
| 6 Base de datos | Añadir párrafos de bytea, audit_logs y mensajes | 🟡 Media |
| 7 Hito 4 | Sustituir párrafo en futuro por pasado completado | 🔴 Alta |
| 8 Conclusión | Sustituir primer párrafo | 🟡 Media |
