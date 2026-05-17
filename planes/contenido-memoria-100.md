# Contenido expandido — Memoria TFG 100%
# Listo para integrar en el documento Word

> Instrucciones: cada bloque indica exactamente dónde va en la memoria.
> Copia el texto tal cual (sin los encabezados de bloque) en la sección indicada.
> Las imágenes [SCREENSHOT X] son recordatorios para insertar la captura correspondiente.

---

## BLOQUE A — Ampliación Capítulo 1: Motivación y contexto del problema

**Sección destino**: Capítulo 1 — "De qué trata mi idea y por qué la propongo"
**Insertar**: Después del párrafo existente sobre la centralización de la gestión

---

La fragmentación no es solo un problema de comodidad. Cuando el seguimiento se hace por correo electrónico, no existe una trazabilidad formal de lo que el alumno ha comunicado y lo que el tutor ha visto. Si al final del periodo de prácticas surge un conflicto sobre las horas realizadas o las tareas asignadas, no hay un registro verificable al que acudir. La plataforma Nexus aborda este problema desde el origen: cualquier comunicación relevante ocurre dentro del sistema, queda registrada con marca temporal y está asociada al participante que la realizó.

Otro aspecto que motivó el proyecto es la asimetría de información entre los distintos actores del proceso. El alumno vive la práctica en primera persona y conoce los detalles de su día a día, pero puede no tener claro cómo comunicar un problema de forma que llegue a la persona adecuada. El tutor del centro supervisa a varios alumnos simultáneamente y a menudo se entera de los problemas tarde o indirectamente. El tutor de empresa, por su parte, interactúa con el alumno a diario pero no tiene visibilidad del marco académico ni de los objetivos formativos del ciclo. Nexus está diseñada para que cada actor vea exactamente la información que necesita, en el momento en que la necesita, sin tener que solicitarla a través de canales informales.

La decisión de limitar el alcance del TFG a la fase de seguimiento —dejando fuera la gestión de ofertas, la asignación de alumnos a empresas y la firma digital de convenios— responde a una razón práctica: el seguimiento es la parte donde más fallos concretos se pueden identificar y donde una herramienta digital tiene un impacto más inmediato en la experiencia del alumno. Resolver primero el problema más urgente y documentar bien las extensiones naturales del sistema es, en mi opinión, una estrategia más honesta que intentar cubrir todo el ciclo de forma superficial.

---

## BLOQUE B — Nueva sección 4.5: Chat en tiempo real con WebSocket y STOMP

**Sección destino**: Capítulo 4 — Nueva subsección "4.5. Chat en tiempo real con WebSocket y protocolo STOMP"
**Insertar**: Después de la sección 4.4 de tests

---

### 4.5. Chat en tiempo real con WebSocket y protocolo STOMP

La comunicación entre los participantes de una práctica era uno de los requisitos funcionales desde el primer análisis del sistema. La solución más sencilla habría sido el polling: el cliente consulta la API periódicamente para comprobar si hay mensajes nuevos. Este enfoque es simple de implementar, pero tiene dos desventajas significativas: genera tráfico constante aunque no haya ningún mensaje nuevo, y la latencia entre el envío y la recepción depende del intervalo de consulta, que no puede ser demasiado corto sin saturar el servidor.

Opté por WebSocket porque es la solución apropiada para comunicación bidireccional en tiempo real. A diferencia de HTTP, donde el cliente siempre inicia la comunicación y el servidor solo responde, WebSocket establece un canal persistente y bidireccional: una vez abierta la conexión, el servidor puede enviar datos al cliente en cualquier momento, sin que el cliente tenga que preguntar. Spring Boot integra WebSocket de forma nativa a través del módulo `spring-websocket`, que se configura en una clase `WebSocketConfig` que anota el endpoint `/ws` y habilita el broker de mensajes STOMP.

Sobre la conexión WebSocket base implementé el protocolo STOMP (Simple Text Oriented Messaging Protocol). STOMP añade una capa de mensajería con semántica de publicación-suscripción: los clientes se suscriben a canales con destinos con formato `/topic/practica/{id}`, y cualquier mensaje publicado en ese destino llega a todos los suscriptores activos. Esta arquitectura de broker es más robusta que gestionar conexiones WebSocket directas, porque Spring se encarga del enrutamiento entre suscriptores.

Para gestionar los dos contextos de comunicación distintos —el alumno hablando con su tutor del centro, y los dos tutores coordinándose entre sí— diseñé un modelo de canal dual. La migración Flyway V16 añadió la columna `canal` a la tabla de mensajes, con dos valores posibles: `ALUMNO` (para la conversación alumno-tutor centro) y `TUTORES` (para la coordinación entre los dos tutores de la práctica). El cliente indica el canal tanto en el destino STOMP como en el endpoint REST de historial mediante el parámetro `?canal=`. Esta separación garantiza que el alumno no puede leer la conversación privada entre sus tutores.

La autenticación en WebSocket fue el aspecto más complejo de la implementación. Las peticiones HTTP convencionales pasan por el filtro JWT de Spring Security antes de llegar al controlador, pero los frames WebSocket siguen un ciclo de vida diferente. Para resolver esto implementé un `ChannelInterceptor` que intercepta dos tipos de frames específicos. En el frame `CONNECT` —el apretón de manos inicial— el interceptor extrae el token JWT de la cabecera STOMP, lo valida con el mismo mecanismo que usa el filtro HTTP, y establece la autenticación en el contexto de seguridad de la sesión. En el frame `SUBSCRIBE` comprueba que el email del usuario autenticado corresponde efectivamente a uno de los tres participantes de la práctica cuyo identificador aparece en el destino solicitado. Si la verificación falla, lanza `AccessDeniedException`, que Spring traduce en el cierre de la conexión STOMP antes de que el cliente pueda escuchar el canal.

Los mensajes se persisten en la base de datos mediante la entidad `Mensaje` con relación a la práctica, al remitente y con marca temporal. Al suscribirse al canal, el cliente también solicita el historial mediante un endpoint REST convencional (`GET /mensajes/practica/{id}?canal=ALUMNO`), de modo que al abrir el chat se cargan los mensajes anteriores aunque el usuario no estuviera conectado en el momento en que se enviaron.

En el cliente Flutter, la pantalla `ChatScreen` establece la conexión STOMP al montarse utilizando el paquete `stomp_dart_client`. La URL del WebSocket se deriva de la misma variable de entorno `API_URL` que usan las peticiones REST, sustituyendo el esquema `https://` por `wss://` o `http://` por `ws://`. Esto garantiza que el mismo build de Flutter funciona en local, en Docker y en cualquier despliegue sin modificar el código. La conexión se cierra en `dispose`, siguiendo el ciclo de vida de Flutter: no hay fugas de conexión aunque el usuario cambie de pestaña.

---

## BLOQUE C — Nueva sección 4.6: Sistema de notificaciones

**Sección destino**: Capítulo 4 — Nueva subsección "4.6. Sistema de notificaciones"

---

### 4.6. Sistema de notificaciones

El sistema de notificaciones informa a los usuarios de eventos relevantes sin que tengan que navegar activamente por la aplicación buscando novedades. Diseñé el sistema siguiendo un modelo REST con polling ligero, en lugar de abrir un segundo canal WebSocket. La razón es que las notificaciones no son eventos de tiempo real estricto —un parte validado o un mensaje recibido pueden esperar treinta segundos sin consecuencias reales—, y añadir un segundo WebSocket habría complicado significativamente la arquitectura del cliente por un beneficio marginal.

La entidad `Notificacion` almacena el identificador del destinatario, el tipo de notificación (`SEGUIMIENTO`, `INCIDENCIA`, `CHAT`, `SISTEMA`), el texto descriptivo del evento, la marca temporal de creación y un booleano `leida`. Los tipos permiten al cliente diferenciar el icono y el color de cada notificación, y abren la posibilidad de filtros futuros sin cambiar el modelo de datos.

Las notificaciones se generan automáticamente en los puntos de transición del sistema. Cuando `SeguimientoServiceImpl` aprueba o rechaza un parte, llama a `NotificacionService.crear()` para notificar al alumno. Cuando `MensajeServiceImpl` persiste un mensaje de chat, genera notificaciones para todos los participantes de la práctica excepto el remitente. Esta integración mediante llamadas directas entre servicios garantiza la consistencia: cualquier evento que modifica el estado del sistema genera automáticamente la notificación correspondiente, sin duplicar lógica en el controlador.

En el cliente, el `NotificacionProvider` arranca junto con la sesión y lanza un `Timer.periodic` que consulta el contador de notificaciones no leídas cada treinta segundos. El polling actualiza únicamente el número —un endpoint ligero que devuelve un entero— sin descargar la lista completa, minimizando el tráfico de red. El badge rojo con el contador aparece en el icono de la campana del `AppBar` en el panel del alumno y en el sidebar de los tres paneles de tutor. Al pulsar la campana se navega a la `NotificacionesScreen`, que muestra la lista con icono diferenciado por tipo. Al tocar una fila se marca como leída; el botón "Leer todas" limpia el badge de un solo toque.

---

## BLOQUE D — Nueva sección 4.7: Foto de perfil y sincronización entre paneles

**Sección destino**: Capítulo 4 — Nueva subsección "4.7. Foto de perfil"

---

### 4.7. Foto de perfil y sincronización visual entre paneles

El módulo de foto de perfil añade identidad visual a la plataforma, especialmente relevante en el contexto del chat, donde un avatar diferencia visualmente al emisor del receptor. La decisión de diseño más relevante fue el lugar de almacenamiento de las imágenes. Las opciones habituales en aplicaciones web son un servicio externo de objeto (S3, Azure Blob Storage), el sistema de ficheros del servidor, o la base de datos. Para un despliegue Docker autocontenido como el de este proyecto, opté por almacenar las imágenes como columna `BYTEA` en la tabla `usuarios`, añadida mediante la migración Flyway V12. Esta decisión elimina la necesidad de configurar buckets externos ni volúmenes de disco con permisos especiales, y las imágenes quedan incluidas de forma automática en cualquier backup de la base de datos.

Un aspecto técnico que requirió investigación fue el comportamiento de la anotación `@Lob` de JPA en Hibernate 6. En versiones anteriores, `@Lob` sobre un campo `byte[]` mapeaba a `bytea` en PostgreSQL. En Hibernate 6, el comportamiento cambió y mapea a OID (Object Identifier), un tipo diferente que requiere permisos especiales en la base de datos y no funciona correctamente con las operaciones JDBC estándar. La solución fue usar `@Column(columnDefinition = "bytea")`, que fuerza el tipo exacto en la DDL generada independientemente de la versión de Hibernate.

El endpoint de subida valida el tipo MIME del fichero recibido (se aceptan `image/jpeg`, `image/png` y `image/webp`) y limita el tamaño a 5 MB antes de persistir los bytes. La respuesta del endpoint `GET /usuarios/{id}` incluye un campo booleano `tieneFoto`, de modo que el cliente sabe si existe una imagen antes de hacer la petición de descarga, evitando una llamada HTTP innecesaria para los usuarios sin foto configurada.

La sincronización de la foto entre todos los paneles fue el reto más interesante en el cliente. Flutter construye la interfaz como un árbol de widgets independientes: el `NexusAvatar` del sidebar del tutor empresa, el del `AppBar` del alumno y el del panel de administración son instancias distintas que no comparten estado directamente. Para que todos se actualicen simultáneamente cuando el usuario sube una foto nueva, implementé `FotoCache`: una clase estática con un `ValueNotifier<int>` cuyo valor se incrementa cada vez que se sube o se elimina una imagen. Cada instancia de `NexusAvatar` escucha este notifier a través de un `ValueListenableBuilder` y se reconstruye automáticamente cuando el valor cambia, forzando una nueva descarga desde el servidor. Este patrón resuelve la sincronización sin necesidad de un provider global ni de pasar callbacks entre widgets distantes en el árbol de widgets.

---

## BLOQUE E — Nueva sección 4.8: Evaluación final del alumno

**Sección destino**: Capítulo 4 — Nueva subsección "4.8. Evaluación final del alumno"

---

### 4.8. Evaluación final del alumno

La evaluación final es el módulo que cierra el ciclo formativo de las prácticas. Al finalizar el periodo, el tutor de empresa emite una valoración estructurada del alumno que queda registrada en el sistema y es visible para el tutor del centro en la ficha del alumno.

El diseño de la entidad `EvaluacionFinal` refleja los criterios reales de evaluación en FCT: una nota global numérica de cero a diez, que es el único campo obligatorio, y cinco criterios optativos: actitud y puntualidad, competencia técnica, iniciativa y autonomía, trabajo en equipo, y cumplimiento de tareas. Los criterios son opcionales porque no todos los tutores de empresa tienen información suficiente sobre todos los aspectos del desempeño del alumno para emitir una valoración justa. Forzar una puntuación para criterios que no se han podido observar habría distorsionado el resultado. La nota global es independiente de la media de los criterios, porque el tutor puede querer ponderar su valoración considerando factores que los criterios no recogen.

El sistema impone una única evaluación por práctica. Si el tutor intenta enviar una segunda valoración, el servicio detecta el registro existente y lo actualiza en lugar de crear uno nuevo. Esta decisión simplifica el contrato de la API desde el punto de vista del cliente, que no necesita distinguir entre crear y modificar. La unicidad se garantiza a nivel de base de datos mediante una restricción `UNIQUE` sobre el par `(practica_id, tutor_empresa_id)` en la migración Flyway V14, de modo que ningún error en la lógica de la aplicación puede generar evaluaciones duplicadas.

El diseño del formulario de evaluación requirió varias iteraciones. La primera versión usaba campos de texto numérico para introducir las notas, pero este enfoque es propenso a errores de formato (comas en lugar de puntos, valores fuera de rango) y resulta menos expresivo que una interfaz visual. La versión final usa controles deslizantes (`Slider`) para cada criterio y para la nota global. El color del slider cambia en tiempo real según el valor: rojo para notas inferiores a cinco, ámbar entre cinco y siete, y verde para siete o superior. Este código de color es coherente con el sistema de diseño del resto de la aplicación y transmite de forma inmediata si la valoración es insuficiente, suficiente o notable. Cada criterio tiene un interruptor para habilitarlo o deshabilitarlo, reflejando el carácter opcional del modelo de datos.

En la pantalla del tutor del centro, la evaluación se presenta en modo solo lectura dentro de la ficha del alumno. Para garantizar que la versión más reciente se muestra siempre, la pantalla es un `StatefulWidget` y solicita los datos al servidor en `initState`, evitando que se muestre información obsoleta en caché.

---

## BLOQUE F — Nueva sección 4.9: Gestión CRUD de empresas colaboradoras

**Sección destino**: Capítulo 4 — Nueva subsección "4.9. Gestión de empresas colaboradoras"

---

### 4.9. Gestión de empresas colaboradoras

La entidad `Empresa` existía desde el diseño inicial del modelo de datos y era consultable mediante `GET /api/v1/empresas` para poblar los formularios de creación de prácticas. Sin embargo, no disponía de endpoints de escritura: se asumía que las empresas eran datos de referencia introducidos directamente en la base de datos. Esta limitación resultó inadecuada para un sistema de gestión real, donde el administrador debe poder registrar nuevas empresas colaboradoras sin acceso directo a la base de datos.

Se implementó el CRUD completo con tres nuevos endpoints, todos protegidos con `@PreAuthorize("hasRole('ADMIN')")`. El endpoint `POST /api/v1/empresas` crea una nueva empresa validando que el CIF no esté ya registrado —el campo es único en el esquema— y lanzando `IllegalArgumentException` (400 Bad Request) si existe duplicado. El endpoint `PUT /api/v1/empresas/{id}` permite actualizar cualquier campo, con la misma validación de CIF único pero excluyendo la propia empresa del check para permitir guardar sin cambiar el identificador fiscal. El endpoint `DELETE /api/v1/empresas/{id}` elimina el registro; si la empresa tiene prácticas asociadas, la restricción de clave foránea de PostgreSQL lanza una excepción de integridad referencial que el handler global convierte en una respuesta 409 Conflict informativa.

El DTO de entrada `EmpresaRequest` define los cinco campos del modelo (nombre, CIF, dirección, email de contacto y teléfono) con validaciones de Bean Validation: `@NotBlank` y `@Size` para los obligatorios, `@Email` para el correo electrónico. Estas anotaciones son verificadas por Spring antes de que la petición llegue al servicio, gracias a `@Valid` en el parámetro del controlador. El mapper MapStruct se amplió con dos métodos: `toEntity(EmpresaRequest)` para la creación y `updateEntity(EmpresaRequest, @MappingTarget Empresa)` para la actualización in-place de una entidad existente, que es la forma correcta de hacer actualizaciones parciales con MapStruct sin crear un objeto nuevo y sin desconectar la entidad del contexto de persistencia de Hibernate.

En el panel de administración se añadió un modo "Empresas" accesible desde el sidebar en web y desde la barra de navegación inferior en móvil. La vista muestra la lista de empresas en formato tabla con búsqueda en tiempo real por nombre o CIF, filtrada en cliente sin peticiones adicionales al servidor. Los formularios de creación y edición se presentan como diálogos centrados con validación en cliente antes de enviar la petición. Si el servidor rechaza la operación, el mensaje de error aparece dentro del diálogo sin cerrarlo, permitiendo corregir el valor sin tener que volver a abrir el formulario.

---

## BLOQUE G — Actualización sección 4.4: Tests (reemplazar texto existente)

**Sección destino**: Capítulo 4.4 — Reemplazar el contenido completo de la sección

---

### 4.4. Tests automatizados y cobertura de código

Desde el inicio del proyecto traté los tests de integración como parte del desarrollo, no como una fase separada posterior. La arquitectura en capas facilita esta filosofía: los servicios encapsulan toda la lógica de negocio de forma independiente al protocolo HTTP, lo que permite testearlos directamente con un contexto Spring completo sobre una base de datos H2 en memoria sin necesidad de arrancar un servidor HTTP. Al cierre del proyecto, la batería cuenta con **254 tests automatizados**, todos pasando sin fallos, con una **cobertura de instrucciones del 80 %** medida por JaCoCo.

Los tests se organizan en dos tipos con tecnologías distintas. Los **tests de integración de servicio** (`@SpringBootTest + @Transactional + @ActiveProfiles("test")`) cargan el contexto completo de Spring con una base de datos H2 en modo compatibilidad PostgreSQL, ejecutan las operaciones reales contra la base de datos y revierten los cambios al terminar cada caso mediante la anotación `@Transactional`. Este enfoque detecta problemas que los mocks no pueden revelar: inconsistencias entre la entidad JPA y el esquema Flyway, comportamiento inesperado de las consultas JPQL, y violaciones de restricciones de integridad referencial. Los **tests de controlador** (`@WebMvcTest + @MockBean`) cargan únicamente la capa web del contexto de Spring, sustituyen los servicios por mocks de Mockito y verifican la seguridad por roles, el mapeo de rutas, la serialización JSON y los códigos de respuesta HTTP.

Los módulos cubiertos con tests de servicio incluyen: `PracticaService` (19 tests: ciclo de vida completo, transiciones de estado, validaciones de rol), `UsuarioService` (11 tests: perfil, foto de perfil con tipos MIME y límites de tamaño), `EvaluacionFinalService` (9 tests: crear, actualizar, consultar por práctica), `NotificacionService` (10 tests: creación, marcado como leída, contador), `MensajeService` y `SeguimientoService` (15 tests combinados: almacenamiento, separación por canal, flujo de doble validación) y `EmpresaService` (4 tests: validación CIF único, actualización in-place).

Los módulos cubiertos con tests de controlador incluyen todos los controladores REST: `PracticaController` (10 tests), `SeguimientoController` (13 tests), `IncidenciaController` (10 tests), `AusenciaController` (13 tests), `EvaluacionFinalController` (12 tests), `NotificacionController` (10 tests), `UsuarioController` (7 tests), `MensajeController` (8 tests) y `EmpresaController` junto a `CentroController` (6 tests en total). Los 13 ficheros de test se organizan en paquetes por módulo, de modo que cualquier test que falla puede localizarse inmediatamente.

Los tests de control de acceso merecen mención especial. La clase `A01AccessControlTest` verifica que un alumno no puede acceder a los recursos de otro alumno, que un tutor de empresa no puede actuar sobre prácticas que no supervisa, y que los intentos de escalada de privilegios devuelven exactamente el código HTTP 403, no 404 ni 500. Esta distinción es importante: devolver 404 cuando el recurso existe pero el usuario no tiene permiso oculta la denegación de acceso y puede enmascarar problemas de autorización en los logs de producción.

La cobertura se mide ejecutando `./mvnw verify`, que corre todos los tests y genera el informe en `target/site/jacoco/index.html`. El objetivo del 80 % se estableció de forma deliberada: los módulos principales —seguimientos, ausencias, evaluación, notificaciones— superan ese umbral, mientras que algunos adaptadores de infraestructura (DTOs simples, configuraciones de Spring) quedan por debajo por su baja densidad de lógica.

Durante la escritura de los tests detecté varios errores que habían pasado desapercibidos en la ejecución normal. El más representativo: la implementación de seguimientos accedía a `SecurityContextHolder.getContext().getAuthentication().getName()` sin verificar si la autenticación era nula. En producción ese código nunca se llama sin autenticación activa, pero en los tests de servicio que no configuran el contexto de seguridad lanzaba `NullPointerException`. La corrección fue un método privado `currentUserEmail()` que devuelve `"system"` cuando no hay autenticación. Es un ejemplo de cómo los tests no solo verifican funcionalidad, sino que obligan a revisar el código desde un ángulo diferente y afloran bugs que la ejecución normal no ejercita.

---

## BLOQUE H — Nueva sección 4.10: Infraestructura y despliegue en contenedores

**Sección destino**: Capítulo 4 — Nueva subsección "4.10. Infraestructura y despliegue en contenedores"
**Nota**: Este contenido complementa lo que ya existe en el capítulo 4 sobre Docker. Fusionar con el texto existente.

---

### 4.10. Infraestructura y despliegue en contenedores

El sistema completo se despliega mediante Docker Compose con tres servicios que forman una red privada aislada. El contenedor `nexus-db` ejecuta PostgreSQL 16 Alpine con un volumen persistente para garantizar que los datos sobreviven a los reinicios, y un `healthcheck` con `pg_isready` que verifica la disponibilidad del servidor antes de permitir que los dependientes arranquen. El contenedor `nexus-api` contiene el backend Spring Boot construido mediante un Dockerfile multi-stage: la primera etapa descarga las dependencias Maven y compila el JAR con `./mvnw package -DskipTests`; la segunda etapa copia únicamente el JAR resultante a una imagen base `eclipse-temurin:21-jre-alpine`, que no incluye el JDK completo ni el código fuente. El contenedor `nexus-web` sirve el bundle compilado de Flutter mediante Nginx Alpine.

El frontend también usa un build multi-stage: la primera etapa instala el SDK de Flutter y compila la aplicación web con `flutter build web --release --dart-define=API_URL=...`; la segunda etapa copia los archivos estáticos al contenedor Nginx. Esta arquitectura multi-stage garantiza que los artefactos finales en producción no contienen herramientas de compilación ni código fuente, reduciendo tanto el tamaño de imagen como la superficie de ataque.

La configuración de Nginx aplica tres políticas de caché diferentes. El fichero `index.html` se sirve con `Cache-Control: no-store` para garantizar que el navegador siempre obtiene el punto de entrada más reciente tras un despliegue. El bundle principal `main.dart.js` usa validación de ETag. Los assets con hash en el nombre de fichero (imágenes, fuentes), que Flutter genera automáticamente durante la compilación, se sirven con un año de caché inmutable, porque el hash cambia en cada build cuando el contenido cambia.

Durante las pruebas de aceptación detecté que todas las marcas temporales del sistema se mostraban con dos horas de diferencia respecto a la hora real de España en verano. La causa es que los contenedores Docker se ejecutan por defecto en la zona horaria UTC, mientras que España peninsular opera en `Europe/Madrid` (UTC+2 durante el horario de verano CEST). La corrección se aplicó en tres niveles: la variable de entorno `TZ=Europe/Madrid` en los servicios `db` y `backend` de Docker Compose, que es respetada por el sistema operativo Alpine y por la JVM; `JAVA_TOOL_OPTIONS=-Duser.timezone=Europe/Madrid` para garantizar que la propiedad de zona horaria de la JVM se establece antes de que Spring Boot inicialice su contexto; y las propiedades `spring.jackson.time-zone=Europe/Madrid` junto a `spring.jackson.serialization.write-dates-as-timestamps=false` en `application.properties`, que instruyen a Jackson para serializar los objetos `LocalDateTime` en formato ISO-8601 con la zona horaria de Madrid.

El perfil de producción `application-prod.properties` configura adicionalmente el pool de conexiones HikariCP con un máximo de diez conexiones y un mínimo de cinco, y restringe los endpoints de Spring Actuator a solo `health` e `info`, ocultando métricas internas que no deben ser accesibles desde el exterior.

Las credenciales de la base de datos y el secreto JWT se externalizan mediante un fichero `.env` que no se versiona en el repositorio de código. La variable `JWT_SECRET` se declara con la sintaxis `${JWT_SECRET:?Este valor es obligatorio}`, de modo que Docker Compose falla de forma explícita e informativa si la variable no está definida, impidiendo arrancar el sistema con un secreto vacío o por defecto.

---

## BLOQUE I — Ampliación Capítulo 5: Panel del Alumno (reemplazar bullet points)

**Sección destino**: Capítulo 5.1 — Reemplazar los bullet points actuales con este texto

---

El panel del alumno es la pantalla principal que el estudiante ve desde el primer día de prácticas hasta el último. Está diseñada para que cualquier acción relevante —registrar una tarea, reportar un problema, enviar un mensaje— se pueda hacer en menos de tres pasos desde la pantalla inicial.

La pestaña de inicio muestra el resumen del estado actual de la práctica: el nombre de la empresa y el tutor asignado, la barra de progreso de horas que indica cuántas se han contabilizado como completadas del total acordado en el convenio, y los seguimientos más recientes con su estado actual. La barra de progreso computa únicamente los partes en estado `COMPLETADO`, es decir, aquellos que han pasado por las dos validaciones requeridas. Mostrar partes en estado `PENDIENTE_EMPRESA` como si ya contaran habría engañado al alumno sobre su avance real.

La pestaña de seguimientos presenta la lista completa de partes registrados, ordenada por fecha descendente. Cada parte muestra las horas, la fecha, la descripción abreviada y un indicador visual del estado: ámbar para pendiente de empresa, azul para pendiente del centro, verde para completado y rojo para rechazado. Un botón flotante en la esquina inferior derecha abre el formulario de nuevo parte. El formulario valida en cliente que la fecha no sea futura, que las horas estén entre 1 y 24, y que la descripción tenga al menos diez caracteres, reflejando en tiempo real cualquier error de forma antes de enviar la petición al servidor.

La pestaña de incidencias permite al alumno reportar formalmente cualquier problema durante la práctica. El formulario incluye un selector de categoría (acceso, ausencia, comportamiento, accidente u otros) y un campo de texto libre. La categoría permite al tutor del centro clasificar las incidencias y detectar patrones, como varias incidencias de tipo acceso en la misma empresa. Si el tutor de empresa rechaza un parte de seguimiento, el sistema genera automáticamente una incidencia visible para el tutor del centro, sin que el alumno tenga que hacer nada adicional.

La pestaña de ausencias permite registrar faltas de asistencia con fecha, motivo y un fichero justificante opcional. El calendario nativo de Flutter limita la selección a fechas pasadas o presentes, alineando la validación del cliente con la restricción `@PastOrPresent` del backend. El sistema verifica que no existe ya una ausencia registrada para la misma práctica y la misma fecha, evitando duplicados. El estado de cada ausencia se refleja mediante el código de color del sistema de diseño: ámbar para pendiente de revisión, verde para justificada y rojo para injustificada.

El chat ocupa la quinta pestaña y se conecta automáticamente al canal `ALUMNO` de la práctica activa al abrirse. El historial completo se carga mediante REST y los mensajes nuevos llegan en tiempo real por WebSocket. Los avatares de los participantes diferencian visualmente al emisor del receptor, algo especialmente relevante en conversaciones con el tutor del centro donde el contexto de quién dijo qué importa.

La pantalla de perfil, accesible desde el avatar en el AppBar, permite al alumno actualizar su foto de perfil. El cambio se refleja inmediatamente en todos los elementos de la interfaz que muestran el avatar, gracias al mecanismo de sincronización `FotoCache`.

[SCREENSHOT: Panel alumno — dashboard inicial con barra progreso y seguimientos recientes]
[SCREENSHOT: Panel alumno — formulario nuevo seguimiento]
[SCREENSHOT: Panel alumno — pestaña ausencias]
[SCREENSHOT: Panel alumno — chat activo]

---

## BLOQUE J — Ampliación Capítulo 5: Panel del Tutor del Centro (reemplazar bullet points)

**Sección destino**: Capítulo 5.2 — Reemplazar los bullet points actuales con este texto

---

El panel del tutor del centro es el más complejo del sistema por la naturaleza multidimensional del rol: supervisar a varios alumnos simultáneamente, gestionar incidencias, validar partes y coordinar con los tutores de empresa. La arquitectura de la pantalla responde a esta complejidad con un layout de tres columnas en web: barra de navegación funcional a la izquierda, lista de alumnos en el centro, y panel de detalle del alumno seleccionado a la derecha.

La barra de navegación lateral tiene cinco modos. El **modo Dashboard** muestra el resumen global: cuatro tarjetas de estadísticas (alumnos activos, partes pendientes de su validación, incidencias abiertas y ausencias injustificadas), un panel de alumnos con sus indicadores de carga, y las incidencias más recientes que requieren atención. Este modo está diseñado para la revisión diaria rápida: el tutor puede ver de un vistazo qué alumnos necesitan atención sin abrir ninguna ficha.

El **modo Alumnos** activa el panel de detalle individual. Al seleccionar un alumno de la lista, el panel derecho muestra su información completa: nombre, empresa, fechas de la práctica, barra de progreso de horas FCT, seguimientos pendientes de su validación final, incidencias abiertas y ausencias injustificadas. El layout del panel de detalle usa dos columnas cuando el espacio disponible supera los 650 píxeles: la columna principal contiene las secciones que requieren acción, y la columna secundaria da acceso rápido a la ficha completa y al chat con el alumno y el tutor de empresa.

La **ficha completa del alumno** abre todos los datos históricos: el informe de ausencias con columnas de estado, justificante y quién las revisó; el historial de seguimientos con fechas, horas y comentarios de validación; y la evaluación final emitida por el tutor de empresa, en modo solo lectura. La ficha incluye botones para exportar el expediente completo en PDF y en Excel, generados directamente en el cliente Flutter sin necesidad de endpoints adicionales en el servidor.

El **modo Partes** muestra la vista global de todos los seguimientos pendientes de la validación final del centro, sin necesidad de entrar en cada alumno. Cada parte muestra el nombre del alumno, la empresa, las horas declaradas y la descripción. El tutor puede validar o rechazar directamente desde esta vista.

El **modo Incidencias** agrupa todas las incidencias activas con indicación del estado (`ABIERTA`, `EN_GESTIÓN`, `RESUELTA`). Al pulsar una incidencia se abre un diálogo centrado para cambiar su estado y añadir un comentario de resolución. El diseño usa un diálogo modal en lugar del `BottomSheet` habitual en móvil, porque en web un panel que aparece desde abajo rompe la sensación de aplicación de escritorio.

Los modos de chat (`ALUMNO` y `TUTORES`) conectan al tutor del centro con el alumno de la práctica seleccionada y con el tutor de empresa, respectivamente. La separación de canales garantiza que el alumno no puede leer la coordinación entre los dos tutores.

En móvil, los cinco modos se presentan como pestañas en la barra inferior, manteniendo todas las funcionalidades pero adaptando la navegación al patrón táctil.

[SCREENSHOT: Panel tutor centro — dashboard inicial con stats y alumnos]
[SCREENSHOT: Panel tutor centro — detalle alumno seleccionado con dos columnas]
[SCREENSHOT: Panel tutor centro — ficha completa con historial de ausencias]
[SCREENSHOT: Panel tutor centro — diálogo de gestión de incidencia]

---

## BLOQUE K — Ampliación Capítulo 5: Panel de Administración (reemplazar bullet points)

**Sección destino**: Capítulo 5.3 — Reemplazar los bullet points actuales con este texto

---

El panel de administración es la herramienta de gestión del sistema para el personal del centro educativo responsable de la coordinación general de las prácticas. A diferencia de los paneles de tutor, que están centrados en el seguimiento de alumnos concretos, el panel de administración opera sobre las entidades maestras del sistema: usuarios, prácticas y empresas colaboradoras.

El **dashboard inicial** presenta cuatro tarjetas de estadísticas con iconos y subtítulos contextuales calculados con datos reales. El contador de prácticas activas muestra además cuántas están en borrador y cuántas finalizadas, para que el administrador tenga el contexto completo en un vistazo. La sección de prácticas en curso lista las cinco más recientes con el avatar del alumno, el nombre de la empresa y la barra de progreso de horas, ofreciendo una vista rápida del estado general.

La **gestión de usuarios** permite crear cuentas de cualquier rol (alumno, tutor del centro, tutor de empresa, administrador), editarlas y activarlas o desactivarlas sin eliminar el registro. La capacidad de desactivación —en lugar de borrado— responde a una decisión de diseño consciente: eliminar un usuario destruiría su historial de partes, incidencias y mensajes. La desactivación conserva toda la trazabilidad histórica mientras impide el acceso al sistema. Los formularios validan el formato del email, el DNI y la fortaleza de la contraseña en cliente antes de enviar la petición.

La **gestión de prácticas** permite crear y modificar convenios activos. Los campos incluyen el alumno asignado, el tutor del centro, el tutor de empresa, la empresa, las fechas de inicio y fin, y las horas totales del convenio. La posibilidad de editar prácticas existentes fue una adición razonada: durante el despliegue es frecuente asignar por error a un alumno a la práctica equivocada o escribir mal un email; corregirlo sin borrar y recrear el registro evita perder el historial de partes ya registrados. La vista de prácticas se filtra por estado (Todas, Activas, Borradores, Finalizadas) mediante tabs animadas con el contador de prácticas en cada estado. Las prácticas finalizadas muestran un icono de ojo que abre la ficha en modo solo lectura.

La **gestión de empresas** es la funcionalidad añadida en el cuarto hito. La vista presenta la lista de empresas colaboradoras en formato tabla con búsqueda en tiempo real. Las acciones de crear, editar y eliminar se gestionan mediante diálogos centrados. La eliminación incluye un aviso explícito de que fallará si la empresa tiene prácticas asociadas, previniendo que el administrador intente borrar una empresa en uso sin entender por qué la operación falla.

La **auditoría** ofrece un historial completo de todas las operaciones del sistema —creación de usuarios, validaciones de partes, cambios de estado de incidencias, inicio y cierre de sesión— filtrable por módulo. Cada registro incluye el email del actor, la descripción de la acción y la marca temporal. El administrador puede detectar actividad inusual o reconstruir la secuencia de eventos ante cualquier incidencia.

[SCREENSHOT: Panel admin — dashboard con stat cards e iconos]
[SCREENSHOT: Panel admin — gestión prácticas con tabs filtro]
[SCREENSHOT: Panel admin — gestión empresas con tabla y búsqueda]

---

## BLOQUE L — Ampliación Capítulo 5: Panel del Tutor de Empresa (reemplazar bullet points)

**Sección destino**: Capítulo 5.4 — Reemplazar los bullet points actuales con este texto

---

El panel del tutor de empresa responde a un principio de diseño minimalista: este actor tiene una función muy específica en el sistema —firmar partes, revisar ausencias, evaluar al alumno— y la interfaz no debe distraerle con información que no le corresponde gestionar.

La primera pestaña muestra la lista de **partes de seguimiento pendientes** de su validación. Cada parte presenta el nombre del alumno, la semana a la que corresponde, las horas declaradas y la descripción completa de las tareas, formateada como cita para diferenciarla visualmente del resto de la tarjeta. Los botones de validar y rechazar están diferenciados en color: verde para la aprobación y rojo para el rechazo. Al rechazar se exige introducir un motivo antes de confirmar, porque el motivo queda registrado y es visible para el alumno y el tutor del centro.

La segunda pestaña gestiona las **ausencias**. Cada tarjeta muestra el alumno, la fecha, el motivo declarado y un indicador visual si existe justificante adjunto. Al pulsar el indicador de justificante, la aplicación descarga los bytes mediante una petición autenticada y abre el fichero en una nueva pestaña del navegador, sin exponer el token JWT en la URL. Las acciones permiten marcar la ausencia como justificada o injustificada, con confirmación previa.

La tercera pestaña da acceso al **chat del canal TUTORES**, la conversación privada entre el tutor de empresa y el tutor del centro para coordinar aspectos de la práctica que no son apropiados para el chat del alumno: gestión de conflictos, decisiones sobre ausencias injustificadas, evaluación final.

La cuarta pestaña presenta el **formulario de evaluación final** cuando la práctica está en curso o finalizada. El formulario con sliders de color dinámico permite al tutor completar la evaluación en pocos minutos, sin confusión sobre el rango de valores o el formato esperado. Una vez enviada, la evaluación queda disponible en la ficha del alumno para el tutor del centro.

La cabecera del panel muestra tres métricas globales: partes pendientes de firma, partes ya procesados y horas acumuladas por el alumno en partes completados. Estas cifras permiten al tutor de empresa calibrar rápidamente el estado general de la práctica antes de entrar en el detalle de cada parte.

[SCREENSHOT: Panel tutor empresa — lista de partes pendientes con acciones validar/rechazar]
[SCREENSHOT: Panel tutor empresa — formulario evaluación con sliders de color]

---

## BLOQUE M — Nueva sección 5.5: Sistema de diseño y coherencia visual

**Sección destino**: Capítulo 5 — Nueva subsección "5.5. Sistema de diseño y coherencia visual (Design System v2)"

---

### 5.5. Sistema de diseño y coherencia visual

Una de las decisiones transversales más importantes del proyecto fue definir un sistema de diseño centralizado antes de construir las pantallas. Sin este sistema, cada pantalla hubiera acumulado variaciones visuales menores que, sumadas, producen la sensación de inconsistencia que caracteriza a las aplicaciones construidas sin un lenguaje visual común.

El sistema de diseño de Nexus parte de una filosofía de claridad funcional: el color comunica estado, no decora. Cada elemento visual tiene un significado concreto que el usuario aprende una vez y reconoce en toda la aplicación. El **azul** identifica acciones principales y elementos activos. El **verde** señala que algo ha sido validado o completado correctamente. El **ámbar** advierte de elementos pendientes de atención. El **rojo** alerta sobre incidencias abiertas, rechazos o acciones destructivas. Esta semántica de color es consistente en todos los paneles y roles: el mismo ámbar que indica un parte pendiente en el panel del alumno indica una incidencia sin resolver en el panel del tutor.

Los colores se definen en tres variantes por cada estado semántico. Por ejemplo, para el estado de éxito: `NexusColors.success` (verde para iconos y texto), `NexusColors.successLight` (verde muy claro para fondos de badges) y `NexusColors.successText` (verde oscuro para texto sobre fondo claro, garantizando contraste suficiente). Esta estructura triple permite componer cualquier badge de estado sin calcular colores manualmente en cada pantalla. Todos los valores se centralizan en `app_theme.dart`; ninguna pantalla usa valores de color literales.

El rediseño visual del cuarto hito actualizó la pantalla de login con un layout de dos columnas: el panel izquierdo presenta el logo y la identidad visual de Nexus sobre un fondo con gradiente; el panel derecho contiene el formulario de autenticación con el mínimo de elementos necesarios. En pantallas estrechas el panel izquierdo desaparece y el formulario ocupa todo el ancho, manteniendo la funcionalidad en dispositivos móviles sin sacrificar la identidad visual en escritorio.

Durante el rediseño del panel del tutor del centro encontré un bug específico de Flutter Web: la propiedad `constraints.maxWidth` dentro de un `LayoutBuilder` devuelve cero durante el primer frame de renderizado en el navegador, antes de que el motor de layout del DOM haya calculado las dimensiones reales del contenedor. Esto provocaba que el panel de detalle no se renderizara hasta que el usuario interactuaba con la página. La solución fue sustituir `constraints.maxWidth > 600` por `MediaQuery.sizeOf(context).width > 600`, que consulta el tamaño de la ventana directamente del contexto de Flutter y devuelve el valor correcto desde el primer frame.

El widget `NexusAvatar` es un componente transversal que encapsula la lógica de mostrar la foto de perfil o, en su ausencia, las iniciales del usuario sobre un fondo de color. Se usa en las cabeceras de panel, en las listas de alumnos, en el historial del chat y en las tarjetas de seguimientos. Centralizar esta lógica en un único widget garantiza que la foto se muestra de forma consistente en toda la aplicación y que el mecanismo de invalidación de caché (`FotoCache`) funciona correctamente en todos los puntos donde aparece el avatar.

---

## BLOQUE N — Actualización Capítulo 7: Estado Actual Hito 4

**Sección destino**: Capítulo 7 — Añadir después del párrafo de "Estado Actual (Hito 4 — en desarrollo)"
**Nota**: Reemplazar el párrafo existente sobre el Hito 4 con este texto

---

**Estado Actual (Cierre Hito 4 — 100%):** El cuarto hito completó el ciclo funcional del sistema y cerró los módulos planificados desde el inicio del proyecto. El módulo de chat se implementó en su forma definitiva con dos canales independientes: el canal `ALUMNO` para la comunicación entre el estudiante y el tutor del centro, y el canal `TUTORES` para la coordinación privada entre el tutor del centro y el tutor de empresa. La separación de canales garantiza que el alumno no puede acceder a conversaciones que no le corresponden, y que los tutores tienen un espacio de coordinación reservado.

El sistema de notificaciones se integró de forma transversal con los módulos existentes: cualquier validación de parte, rechazo o mensaje nuevo genera automáticamente la notificación correspondiente al destinatario. El polling ligero cada treinta segundos en el cliente mantiene el indicador del badge actualizado sin generar tráfico excesivo.

La evaluación final del alumno completó el ciclo de supervisión: el tutor de empresa puede emitir una valoración con criterios opcionales y nota global, visible en la ficha del alumno para el tutor del centro. El formulario con controles deslizantes y código de color por rango de nota es el resultado de dos iteraciones de diseño, partiendo de campos de texto numérico hasta llegar a una interfaz que comunica la valoración de forma visual e inmediata.

La gestión de empresas colaboradoras añadió el CRUD completo al panel de administración, cerrando la funcionalidad necesaria para que un centro educativo pueda incorporar nuevas empresas al sistema sin acceso directo a la base de datos.

El rediseño visual del sistema completo estableció un lenguaje visual coherente en todos los paneles, con un sistema de diseño documentado en `app_theme.dart` que garantiza consistencia en cualquier extensión futura de la aplicación.

La batería de tests alcanzó los 254 casos con una cobertura del 80 % de instrucciones. Esta cifra supera en más de diez puntos el objetivo inicial del 69,5 % del tercer hito, resultado de escribir sistemáticamente tests para cada módulo nuevo incorporado en el cuarto hito.

---

## BLOQUE O — Ampliación Capítulo 6: Modelo de base de datos

**Sección destino**: Capítulo 6 — Añadir después del diagrama ER existente

---

El esquema final de la base de datos está gestionado por dieciséis migraciones Flyway secuenciales, desde la estructura inicial (V1) hasta la última modificación del cuarto hito (V16). Esta gestión versionada garantiza que cualquier entorno —desarrollo local, Docker Compose, producción— puede alcanzar exactamente el mismo estado del esquema ejecutando `./mvnw flyway:migrate`.

Las decisiones de diseño más relevantes del esquema final son las siguientes.

La tabla `seguimientos` usa un enum PostgreSQL para el campo `estado`, con cuatro valores: `PENDIENTE_EMPRESA`, `PENDIENTE_CENTRO`, `COMPLETADO` y `RECHAZADO`. Esta decisión limita los valores posibles a nivel de base de datos, añadiendo una capa de validación independiente del código Java que impide la inserción de estados incoherentes incluso mediante acceso directo a la base de datos.

La tabla `mensajes` incluye una columna `canal VARCHAR(20)` con un índice compuesto sobre `(practica_id, canal)`. El índice compuesto hace que las consultas de historial —que siempre filtran por práctica y canal simultáneamente— sean eficientes independientemente del volumen de mensajes acumulados.

La tabla `evaluaciones_finales` tiene una restricción `UNIQUE` sobre el par `(practica_id, tutor_empresa_id)`, garantizando una única evaluación por práctica y tutor. La restricción actúa como salvaguarda de integridad referencial que ningún error en la lógica de la aplicación puede eludir.

La tabla `usuarios` almacena la foto de perfil en dos columnas: `foto` de tipo `bytea` y `foto_content_type VARCHAR(20)`. Almacenar el tipo MIME junto a los bytes evita tener que detectar el formato en cada petición de descarga y permite devolver la cabecera `Content-Type` correcta directamente desde el valor almacenado.

La tabla `audit_logs` almacena el `jti` (JWT ID) del token activo en cada operación registrada, permitiendo correlacionar eventos de auditoría con sesiones específicas en caso de investigación forense. Junto al email del actor, el módulo, la acción y la marca temporal, el sistema proporciona una trazabilidad completa que cumple con los requisitos mínimos de auditoría de sistemas de información académica.

---

## BLOQUE P — Ampliación Capítulo 8: Conclusión completa

**Sección destino**: Capítulo 8 — Reemplazar el párrafo existente con este texto completo

---

Este proyecto demuestra que es posible mejorar significativamente la experiencia de las prácticas de Formación Profesional cuando se centraliza en un único entorno digital lo que antes estaba disperso entre correos electrónicos, llamadas y hojas de cálculo. La plataforma Nexus cubre el ciclo completo del seguimiento: el registro semanal de actividad por parte del alumno, la doble validación por tutor de empresa y tutor del centro, la gestión de ausencias con justificantes, la comunicación en tiempo real mediante chat con dos canales independientes, y la evaluación final del alumno. Todo ello con un sistema de auditoría que garantiza la trazabilidad de cada operación y con controles de seguridad que siguen las recomendaciones del estándar OWASP Top 10.

Uno de los aprendizajes más importantes del proyecto ha sido comprobar que las decisiones con mayor impacto no son las tecnológicas sino las de lógica de negocio. Detectar que el flujo de validación necesitaba dos pasos diferenciados —uno por la empresa y otro por el centro— antes de construir ninguna pantalla fue un hallazgo que habría costado mucho más corregir a posteriori. Del mismo modo, la decisión de diseñar una tabla independiente para las ausencias en lugar de reutilizar la de seguimientos evitó columnas siempre nulas según el tipo de registro, que son una señal clara de normalización incorrecta. Estos no son errores de código, sino de diseño conceptual, y solo se detectan cuando se cuestiona críticamente el modelo antes de implementarlo.

Otro aprendizaje relevante ha sido la importancia de integrar la seguridad como parte del proceso de desarrollo, no como una fase posterior. La revisión sistemática OWASP que realicé durante el tercer hito encontró vulnerabilidades reales —un fallo criptográfico en la generación de tokens JWT, un vector de enumeración de cuentas en el endpoint de registro, y ausencia de control de acceso a nivel de objeto en los servicios de seguimiento— que no habrían sido detectadas por los tests funcionales normales. Aplicarlas sobre el código existente tuvo un coste bajo. Haber esperado al final del proyecto para revisar la seguridad habría requerido un esfuerzo mucho mayor y posiblemente cambios de arquitectura.

La batería de 254 tests automatizados con una cobertura del 80 % ha sido la red de seguridad que ha permitido refactorizar, ampliar módulos y corregir bugs sin romper funcionalidades existentes. En más de una ocasión, la escritura de un test nuevo para un módulo recién implementado reveló un comportamiento inesperado en un módulo anterior que la ejecución normal no ejercitaba. Esta interdependencia entre tests y correcciones es el argumento más convincente que he encontrado en la práctica para tratar los tests como parte del desarrollo, no como documentación opcional.

Desde el punto de vista tecnológico, combinar Java con Spring Boot en el backend y Flutter en el frontend ha sido una elección que ha funcionado bien. Spring Boot proporciona un ecosistema maduro para la gestión de seguridad, la validación de entradas y la persistencia con JPA, con abstracciones que reducen el código necesario sin ocultar lo que ocurre por debajo. Flutter permite construir una interfaz adaptativa —web, Android, iOS desde una única base de código— con un sistema de estado (Provider) que, una vez comprendido su modelo reactivo, simplifica la gestión de la interfaz. El reto principal de Flutter ha sido aprender a pensar en términos de árbol de widgets y ciclo de vida, que son conceptos sin equivalente directo en el desarrollo web tradicional.

En cuanto a las extensiones naturales del sistema, hay dos líneas claras de trabajo. A corto plazo, la firma digital de convenios mediante certificado o mediante una firma simple en pantalla táctil eliminaría el único paso que sigue requiriendo papel en el proceso actual. A medio plazo, la gestión del proceso previo a las prácticas —publicación de perfiles por parte de las empresas, preferencias de los alumnos y asignación por el centro— completaría el ciclo completo que Nexus aspira a digitalizar. La arquitectura modular del sistema, donde cada funcionalidad tiene su propio servicio, controlador y repositorio, está diseñada precisamente para facilitar estas extensiones sin modificar lo que ya existe.

Este TFG ha sido la primera vez que he desarrollado un sistema completo de principio a fin, tomando decisiones de arquitectura reales con consecuencias reales. La diferencia entre lo que sabía al empezar y lo que sé al terminar no se mide en tecnologías aprendidas, sino en criterio para tomar decisiones técnicas justificadas.

---

## RESUMEN DE INTEGRACIÓN

| Bloque | Sección destino | Páginas estimadas |
|--------|----------------|-------------------|
| A | Cap. 1 — Motivación ampliada | +1 pág |
| B | Cap. 4.5 — Chat WebSocket | +2.5 pág |
| C | Cap. 4.6 — Notificaciones | +1 pág |
| D | Cap. 4.7 — Foto de perfil | +1.5 pág |
| E | Cap. 4.8 — Evaluación final | +1.5 pág |
| F | Cap. 4.9 — Gestión empresas | +1.5 pág |
| G | Cap. 4.4 — Tests (reemplazar) | +1.5 pág |
| H | Cap. 4.10 — Infraestructura Docker | +1.5 pág |
| I | Cap. 5.1 — Panel Alumno | +2.5 pág |
| J | Cap. 5.2 — Panel Tutor Centro | +2.5 pág |
| K | Cap. 5.3 — Panel Admin | +2 pág |
| L | Cap. 5.4 — Panel Tutor Empresa | +1.5 pág |
| M | Cap. 5.5 — Design System v2 (nuevo) | +2 pág |
| N | Cap. 7 — Estado Hito 4 | +1 pág |
| O | Cap. 6 — BD ampliada | +1.5 pág |
| P | Cap. 8 — Conclusión completa | +1.5 pág |
| **TOTAL** | | **~26 págs nuevas** |

**Estimación post-integración**: 23 páginas actuales + 26 nuevas ≈ **~49 páginas**.

Para llegar a ~80 páginas quedarán por añadir principalmente:
- Capturas de pantalla en alta resolución (cada captura en página completa suman rápido)
- Diagramas adicionales (UML de secuencia chat WebSocket, diagrama de estados seguimientos)
- Sección de manual de usuario por rol (pendiente de redactar)
- Posibles anexos: tabla de endpoints API, glosario de términos FCT, registro de decisiones técnicas
