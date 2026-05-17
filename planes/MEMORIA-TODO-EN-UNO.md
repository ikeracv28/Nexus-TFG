# MEMORIA TFG — TODO EL CONTENIDO NUEVO EN UN SOLO ARCHIVO
# Ordenado por capítulo. Copia cada bloque exactamente donde indica.

> CÓMO USAR ESTE ARCHIVO:
> - Cada sección indica si hay que [REEMPLAZAR] el texto existente o [AÑADIR A CONTINUACIÓN]
> - Los textos entre corchetes tipo [SCREENSHOT: ...] son recordatorios para insertar la captura
> - Sigue el orden de arriba a abajo: empieza por el Capítulo 1 y termina por el 8

---

═══════════════════════════════════════════════════════════════
## ⚠ CORRECCIONES URGENTES — Párrafos que faltan en la versión actual
═══════════════════════════════════════════════════════════════

### CORRECCIÓN 1 — Capítulo 8: párrafo de apertura que falta
**ACCIÓN: En el Word, ve al inicio del Capítulo 8. Pega este párrafo ANTES de "Uno de los aprendizajes..."**

---

Este proyecto demuestra que es posible mejorar significativamente la experiencia de las prácticas de Formación Profesional cuando se centraliza en un único entorno digital lo que antes estaba disperso entre correos electrónicos, llamadas y hojas de cálculo. La plataforma Nexus cubre el ciclo completo del seguimiento: el registro semanal de actividad por parte del alumno, la doble validación por tutor de empresa y tutor del centro, la gestión de ausencias con justificantes adjuntos, la comunicación en tiempo real mediante chat con dos canales independientes, el sistema de notificaciones, la foto de perfil sincronizada entre paneles, y la evaluación final del alumno. Todo ello con un sistema de auditoría que garantiza la trazabilidad de cada operación y con controles de seguridad que siguen las recomendaciones del estándar OWASP Top 10.

---

### CORRECCIÓN 2 — Capítulo 8: párrafo de futuro que falta
**ACCIÓN: En el Word, ve al FINAL del Capítulo 8. Pega este párrafo después del último párrafo que hay ("La diferencia entre lo que sabía al empezar...")**

---

La arquitectura modular del sistema, donde cada módulo funcional tiene su propio servicio, controlador y repositorio, está diseñada para facilitar las extensiones naturales. A corto plazo, la firma digital de convenios mediante certificado o firma simple en pantalla táctil eliminaría el único paso que sigue requiriendo papel en el proceso actual. A medio plazo, la gestión del proceso previo a las prácticas —publicación de perfiles por parte de las empresas, preferencias de los alumnos y asignación por el centro— completaría el ciclo completo que Nexus aspira a digitalizar. A largo plazo, notificaciones push en dispositivo móvil y análisis de datos sobre las tendencias de validación y ausencias completarían una plataforma de gestión académica competitiva con las soluciones comerciales existentes.

---

### CORRECCIÓN 3 — Capítulo 7: estados Hito 2 y Hito 3 que faltan
**ACCIÓN: En el Word, busca la frase "Habría sido mucho más costoso descubrirlo al final." en el Capítulo 7. Pega este texto JUSTO DESPUÉS de esa frase, antes de "Estado Actual (Hito 4...")**

---

**Estado Actual (Entrega Hito 2 — 50%):** Se alcanzó el ecuador del proyecto. El backend contaba con la lógica core completa: CRUD de prácticas con control de estados, sistema de seguimientos con validación en dos pasos por tutor de empresa y tutor del centro, seguridad real basada en roles con @PreAuthorize en cada endpoint, y los primeros tests de integración. El frontend presentaba el Dashboard funcional del alumno con las cuatro pestañas —inicio, seguimientos, incidencias y chat placeholder— y el sistema de navegación adaptativa web/móvil completamente operativo.

**Estado Actual (Entrega Hito 3 — 75%):** El tercer hito concentró el mayor volumen de trabajo del proyecto. Se completaron cuatro bloques funcionales independientes: el módulo de ausencias con su flujo de revisión y gestión de justificantes adjuntos, el panel de administración con edición completa de usuarios y prácticas, el sistema de auditoría centralizado, y una revisión sistemática de seguridad OWASP que resultó en correcciones concretas sobre CORS, firma JWT, política de contraseñas, gestión de sesiones y rate limiting. La batería de tests creció hasta ciento siete casos con cobertura del 69,5% medida con JaCoCo. Dos aspectos merecen mención especial: el error UnsupportedOperationException causado por Set.of() inmutable en la edición de usuarios —un bug que solo se manifiesta en runtime cuando Hibernate intenta modificar la colección— y la transacción independiente del servicio de auditoría con Propagation.REQUIRES_NEW, que garantiza que los intentos fallidos también quedan registrados.

---

═══════════════════════════════════════════════════════════════
## CAPÍTULO 2 — Objetivos del proyecto
═══════════════════════════════════════════════════════════════

**ACCIÓN: REEMPLAZAR los 4 bullet points actuales con este texto**

---

El objetivo general del proyecto es construir una plataforma centralizada que digitalice el ciclo completo de seguimiento de las prácticas de Formación Profesional, eliminando la dependencia de correos electrónicos, llamadas telefónicas y hojas de cálculo como canales de comunicación y registro. A continuación se detallan los objetivos específicos que guiaron el desarrollo:

**Seguimiento real y verificable.** El alumno registra semanalmente las tareas realizadas, las horas trabajadas y una descripción de las actividades. El sistema acumula automáticamente las horas validadas frente al total acordado en el convenio, ofreciendo a todos los participantes una visión exacta del progreso en cada momento. El registro es inmutable una vez validado, lo que lo convierte en un documento verificable ante cualquier discrepancia.

**Validación en dos pasos que refleja la realidad del proceso.** Los partes de seguimiento pasan primero por el tutor de empresa, que certifica que el trabajo descrito es real y se ha realizado correctamente, y después por el tutor del centro, que confirma que el proceso formativo avanza adecuadamente. Este flujo replica digitalmente el proceso en papel de firma semanal, con la diferencia de que el estado de cada parte es visible para todos los participantes en todo momento.

**Gestión de incidencias y ausencias.** El alumno puede reportar cualquier problema durante la práctica mediante un formulario categorizado. Las ausencias se registran con fecha, motivo y justificante adjunto opcional, y son revisadas por el tutor de empresa. Si la empresa rechaza un parte de seguimiento, el sistema genera automáticamente una incidencia visible para el tutor del centro, sin que el alumno tenga que comunicarlo por separado.

**Comunicación interna vinculada a la práctica.** Cada práctica dispone de dos canales de chat en tiempo real: uno entre el alumno y el tutor del centro, y otro exclusivo entre los dos tutores para su coordinación. Los mensajes quedan registrados con marca temporal, lo que elimina la ambigüedad de las comunicaciones por correo y proporciona un historial consultable.

**Supervisión global y gestión administrativa.** El tutor del centro dispone de una vista consolidada del estado de todos sus alumnos: progreso de horas, partes pendientes de validación, incidencias abiertas y ausencias injustificadas. El administrador del centro puede gestionar usuarios de todos los roles, crear y modificar prácticas y mantener el catálogo de empresas colaboradoras, todo desde un único panel sin necesidad de acceso directo a la base de datos.

**Evaluación final estructurada.** El tutor de empresa emite al final del periodo una valoración del alumno mediante criterios optativos y una nota global, que queda registrada en el sistema y disponible para el tutor del centro en la ficha del alumno.

**Sistema de notificaciones y trazabilidad completa.** Los usuarios reciben notificaciones cuando ocurren eventos relevantes: validación o rechazo de un parte, nuevos mensajes de chat. El sistema registra todas las operaciones en una tabla de auditoría con el actor, la acción y la marca temporal, accesible solo para el administrador.

---

═══════════════════════════════════════════════════════════════
## CAPÍTULO 3 — Análisis de Requisitos
═══════════════════════════════════════════════════════════════

**ACCIÓN 1: REEMPLAZAR la frase introductoria** que dice "Para complementar los objetivos anteriores, he definido los requisitos técnicos que debe cumplir el sistema en **esta primera fase**:" por:

> Para complementar los objetivos anteriores, he definido los requisitos técnicos que debe cumplir el sistema:

**ACCIÓN 2: AÑADIR estos tres requisitos funcionales** al final de la lista RF, después de RF-12

---

* **RF-13 (Foto de perfil):** Cada usuario puede subir una imagen de perfil en formato JPEG, PNG o WebP con un tamaño máximo de 5 MB. La foto se muestra de forma sincronizada en todos los paneles y en el historial del chat. Si el usuario no ha configurado foto, el sistema muestra sus iniciales sobre un fondo de color generado de forma determinística a partir de su nombre.

* **RF-14 (Notificaciones):** El sistema genera notificaciones automáticas cuando ocurren eventos relevantes: validación o rechazo de un parte de seguimiento, nuevos mensajes de chat y cambios de estado de incidencias. Cada usuario dispone de un indicador visual del número de notificaciones no leídas accesible desde cualquier pantalla. La lista completa de notificaciones puede marcarse como leída de forma individual o en bloque.

* **RF-15 (Evaluación final):** Al finalizar el periodo de prácticas, el tutor de empresa puede emitir una evaluación estructurada del alumno con una nota global de cero a diez y hasta cinco criterios optativos valorados individualmente. El sistema permite una única evaluación por práctica, actualizable hasta que la práctica se cierre. La evaluación es visible en modo solo lectura para el tutor del centro en la ficha del alumno.

---

═══════════════════════════════════════════════════════════════
## CAPÍTULO 1 — De qué trata mi idea y por qué la propongo
═══════════════════════════════════════════════════════════════

**ACCIÓN: AÑADIR A CONTINUACIÓN del segundo párrafo existente ("Mi aplicación busca centralizar...")**

---

La fragmentación no es solo un problema de comodidad. Cuando el seguimiento se hace por correo electrónico no existe una trazabilidad formal de lo que el alumno ha comunicado y lo que el tutor ha visto. Si al final del periodo de prácticas surge un conflicto sobre las horas realizadas o las tareas asignadas, no hay un registro verificable al que acudir. La plataforma Nexus aborda este problema desde el origen: cualquier comunicación relevante ocurre dentro del sistema, queda registrada con marca temporal y está asociada al participante que la realizó.

Otro aspecto que motivó el proyecto es la asimetría de información entre los distintos actores del proceso. El alumno vive la práctica en primera persona y conoce los detalles de su día a día, pero puede no tener claro cómo comunicar un problema de forma que llegue a la persona adecuada. El tutor del centro supervisa a varios alumnos simultáneamente y a menudo se entera de los problemas tarde o indirectamente. El tutor de empresa, por su parte, interactúa con el alumno a diario pero no tiene visibilidad del marco académico ni de los objetivos formativos del ciclo. Nexus está diseñada para que cada actor vea exactamente la información que necesita, en el momento en que la necesita, sin tener que solicitarla a través de canales informales.

La decisión de limitar el alcance del TFG a la fase de seguimiento —dejando fuera la gestión de ofertas, la asignación de alumnos a empresas y la firma digital de convenios— responde a una razón práctica: el seguimiento es la parte donde más fallos concretos se pueden identificar y donde una herramienta digital tiene un impacto más inmediato en la experiencia del alumno. Resolver primero el problema más urgente y documentar bien las extensiones naturales del sistema es, en mi opinión, una estrategia más honesta que intentar cubrir todo el ciclo de forma superficial.

---

═══════════════════════════════════════════════════════════════
## CAPÍTULO 4 — Arquitectura y Tecnologías
═══════════════════════════════════════════════════════════════

### 4.1 — AÑADIR al final de la sección "Diseño de la Lógica (Backend)"
**ACCIÓN: AÑADIR A CONTINUACIÓN del último párrafo de 4.1 (después del apartado sobre auditoría)**

---

**Módulo de chat dual-canal**

La entidad Mensaje vincula cada mensaje a una práctica, a su remitente y a un canal. La columna canal añadida en la migración V16 tiene dos valores posibles: ALUMNO, para la conversación entre el estudiante y el tutor del centro, y TUTORES, para la coordinación privada entre los dos tutores de la práctica. Esta separación de canales garantiza que el alumno no puede acceder a la coordinación entre sus tutores, y que cada participante solo recibe los mensajes del canal en el que participa.

**Módulo de foto de perfil**

El módulo de foto de perfil almacena las imágenes como columna BYTEA en la tabla usuarios, añadida mediante la migración Flyway V12. Esta decisión evita la necesidad de configurar servicios de almacenamiento externo para el alcance del proyecto: las imágenes forman parte del backup natural de la base de datos. Un aspecto técnico relevante fue el comportamiento de la anotación @Lob de JPA en Hibernate 6: en versiones anteriores mapeaba a bytea en PostgreSQL, pero en Hibernate 6 mapea a OID, un tipo diferente que requiere permisos especiales. La solución fue usar @Column(columnDefinition = "bytea"), que fuerza el tipo exacto independientemente de la versión de Hibernate.

**Módulo de notificaciones**

El sistema de notificaciones usa un modelo REST con polling ligero en el cliente en lugar de un segundo canal WebSocket. Las notificaciones no son eventos de tiempo real estricto —un parte validado puede esperar treinta segundos sin consecuencias reales— y añadir un segundo WebSocket habría complicado la arquitectura por un beneficio marginal. La entidad Notificacion almacena el destinatario, el tipo (SEGUIMIENTO, INCIDENCIA, CHAT, SISTEMA), el texto del evento, la marca temporal y un booleano leida. Las notificaciones se generan automáticamente mediante llamadas directas entre servicios: cuando SeguimientoServiceImpl aprueba o rechaza un parte notifica al alumno; cuando MensajeServiceImpl persiste un mensaje notifica a todos los participantes excepto al remitente.

**Módulo de evaluación final**

La entidad EvaluacionFinal refleja los criterios reales de evaluación en FCT: una nota global obligatoria de cero a diez y cinco criterios optativos (actitud y puntualidad, competencia técnica, iniciativa y autonomía, trabajo en equipo, y cumplimiento de tareas). Los criterios son opcionales porque no todos los tutores de empresa tienen información suficiente sobre todos los aspectos del desempeño del alumno. El sistema impone una única evaluación por práctica mediante una restricción UNIQUE sobre el par (practica_id, tutor_empresa_id) en la migración V14. Si el tutor envía una segunda evaluación, el servicio detecta el registro existente y lo actualiza en lugar de crear uno nuevo, simplificando el contrato de la API.

**Gestión CRUD de empresas colaboradoras**

La entidad Empresa existía desde el diseño inicial del esquema y era consultable para poblar los formularios de creación de prácticas, pero no disponía de endpoints de escritura. Se implementó el CRUD completo con tres nuevos endpoints protegidos con @PreAuthorize("hasRole('ADMIN')"): POST /api/v1/empresas (crea validando unicidad del CIF), PUT /api/v1/empresas/{id} (actualiza con la misma validación excluyendo la propia empresa del check) y DELETE /api/v1/empresas/{id} (elimina, con FK constraint que impide borrar empresas con prácticas asociadas). El mapper MapStruct se amplió con updateEntity(@MappingTarget Empresa) para la actualización in-place sin desconectar la entidad del contexto de persistencia de Hibernate.

---

### 4.1 — TAMBIÉN AÑADIR: bloque Hito 2 (lógica de negocio central)
**ACCIÓN: AÑADIR justo después del párrafo sobre @PreAuthorize en 4.1 (donde habla de "seguridad real basada en roles")**

---

En el segundo hito se implementó la lógica de negocio central del sistema. La entidad Practica actúa como pivote del modelo de datos: relaciona a un alumno con su tutor del centro, su tutor de empresa y la empresa donde realiza la formación. Esta decisión de diseño refleja la realidad de las prácticas de FP, donde el seguimiento académico y el profesional son responsabilidades independientes.

Para proteger la integridad del ciclo de vida de una práctica, se implementaron tres estados: BORRADOR (recién creada, solo visible por administradores), ACTIVA (en curso, el alumno puede registrar seguimientos) y FINALIZADA (cerrada). Las transiciones entre estados se validan en la capa de servicio, no en el controlador, siguiendo el principio de que la lógica de negocio no debe depender del protocolo de transporte.

Para garantizar que los datos de las entidades JPA nunca se exponen directamente en la API, se utilizó MapStruct: una librería que genera automáticamente el código de mapeo entre entidades y DTOs en tiempo de compilación, sin reflection y sin coste en runtime. Un aspecto que merece mención es el diseño del endpoint GET /api/v1/practicas/me. En lugar de que el cliente tenga que conocer el identificador del alumno, este endpoint extrae la identidad del usuario directamente del token JWT mediante el SecurityContextHolder de Spring Security. Esto simplifica el cliente y elimina la necesidad de almacenar el ID del usuario de forma separada al token, reduciendo la superficie de posibles inconsistencias.

---

### 4.3 — AMPLIAR la sección de Seguridad OWASP existente
**ACCIÓN: AÑADIR A CONTINUACIÓN del último párrafo de la sección 4.3 actual**
**NOTA: La sección ya tiene contenido sobre OWASP. Este texto añade lo que no está cubierto.**

---

**Segunda iteración de seguridad — gestión de sesiones y dependencias**

En una segunda revisión de seguridad apliqué cuatro mejoras complementarias a las anteriores.

La primera afectó a la validación de entradas (A03). El método cambiarEstado() de PracticaServiceImpl aceptaba cualquier cadena como nuevo estado, sin verificar que perteneciera al conjunto cerrado de valores válidos. Aunque los estados son un concepto acotado del dominio, no existía ninguna comprobación que impidiese valores arbitrarios. La corrección fue introducir un Set.of() inmutable con los valores permitidos y lanzar BusinessRuleException si el valor recibido no pertenece al conjunto.

La segunda mejora cierra un hueco en la gestión de sesiones (A07). El logout era hasta ese punto puramente local: eliminar el token del dispositivo. Sin embargo, un token robado seguía siendo válido hasta su expiración natural. Para invalidación inmediata implementé una blacklist de identificadores en el servidor: cada JWT incluye ahora un claim jti (JWT ID) con un UUID único, y al hacer logout ese identificador se registra en un ConcurrentHashMap en memoria. El filtro de autenticación verifica la blacklist antes de aceptar cualquier token. La desventaja conocida y aceptada para este contexto es que la blacklist no persiste entre reinicios del servidor; en producción se sustituiría por Redis con TTL.

La tercera mejora reforzó la política de contraseñas (A02). Los usuarios de prueba iniciales tenían contraseñas débiles de seis caracteres. Dado que Flyway no permite modificar migraciones ya aplicadas, apliqué la corrección en una nueva migración V6 que actualiza los hashes BCrypt directamente. Las nuevas contraseñas cumplen la política de doce caracteres mínimo con mayúscula, minúscula, número y símbolo especial.

La cuarta mejora incorporó el plugin dependency-check-maven de OWASP (A06), que analiza las dependencias del proyecto en busca de vulnerabilidades conocidas (CVE). La configuración falla el build si detecta alguna con puntuación CVSS mayor o igual a 7, equivalente a severidad alta o crítica.

**Tercera iteración de seguridad — hardening final antes de entrega**

En una tercera y última iteración apliqué las mejoras restantes del plan de seguridad.

El validador @Pattern sobre el campo password del DTO de registro impone que toda contraseña nueva cumpla cuatro requisitos simultáneamente: al menos una letra mayúscula, una minúscula, un dígito y un carácter especial, con mínimo diez caracteres. Este patrón actúa en la capa de entrada antes de que la contraseña llegue al servicio o sea procesada por BCrypt.

El servicio de seguimientos comprueba ahora si ya existe un parte del alumno en estado PENDIENTE_EMPRESA para la misma semana ISO (de lunes a domingo) antes de permitir el registro de uno nuevo. Esta restricción replica la lógica del proceso real: un alumno entrega un único parte semanal. Sin este control un alumno podría acumular múltiples partes pendientes en la misma semana, sobrecargando a los tutores con validaciones redundantes.

Las cabeceras de seguridad HTTP que faltaban en el servidor Nginx del frontend se completaron: X-Frame-Options: DENY, X-Content-Type-Options: nosniff, Referrer-Policy: strict-origin-when-cross-origin y una Content-Security-Policy restrictiva. Estas cabeceras complementan las ya configuradas en Spring Security para las respuestas de la API, cerrando la cobertura tanto en peticiones a la API como en la carga de la aplicación web.

---

### 4.4 — REEMPLAZAR completamente la sección de Tests
**ACCIÓN: REEMPLAZAR todo el texto de la sección 4.4 con este texto**

---

Desde el inicio del proyecto traté los tests de integración como parte del desarrollo, no como una fase separada. La arquitectura en capas facilita esta filosofía: los servicios encapsulan toda la lógica de negocio de forma independiente al protocolo HTTP, lo que permite testearlos directamente con un contexto Spring completo sobre una base de datos H2 en memoria. Al cierre del proyecto, la batería cuenta con **254 tests automatizados**, todos pasando sin fallos, con una **cobertura de instrucciones del 80%** medida por JaCoCo. Esta cifra supera en más de diez puntos el 69,5% del tercer hito, resultado de escribir sistemáticamente tests para cada módulo nuevo del cuarto hito.

Los tests se organizan en dos tipos con tecnologías distintas. Los **tests de integración de servicio** (@SpringBootTest + @Transactional + @ActiveProfiles("test")) cargan el contexto completo de Spring con una base de datos H2 en modo compatibilidad PostgreSQL, ejecutan las operaciones reales contra la base de datos y revierten los cambios al terminar cada caso. Este enfoque detecta problemas que los mocks no pueden revelar: inconsistencias entre la entidad JPA y el esquema Flyway, comportamiento inesperado de las consultas JPQL, y violaciones de restricciones de integridad referencial. Los **tests de controlador** (@WebMvcTest + @MockBean) cargan únicamente la capa web, sustituyen los servicios por mocks de Mockito y verifican la seguridad por roles, el mapeo de rutas, la serialización JSON y los códigos de respuesta HTTP.

Los módulos cubiertos con tests de servicio incluyen: PracticaService (19 tests: ciclo de vida completo, transiciones de estado, validaciones de rol), UsuarioService (11 tests: perfil, foto de perfil con tipos MIME y tamaños), EvaluacionFinalService (9 tests: crear, actualizar, consultar), NotificacionService (10 tests: creación, lectura, marcado), MensajeService y SeguimientoService (15 tests: almacenamiento, separación por canal, flujo de doble validación) y EmpresaService (4 tests: validación de CIF único, actualización in-place).

Los módulos cubiertos con tests de controlador incluyen todos los controladores REST: PracticaController (10), SeguimientoController (13), IncidenciaController (10), AusenciaController (13), EvaluacionFinalController (12), NotificacionController (10), UsuarioController (7), MensajeController (8), EmpresaController y CentroController (6 en total).

Los tests de control de acceso merecen mención especial. La clase A01AccessControlTest verifica que un alumno no puede acceder a los recursos de otro alumno, que un tutor de empresa no puede actuar sobre prácticas que no supervisa, y que los intentos de escalada de privilegios devuelven exactamente HTTP 403 —no 404 ni 500—. Esta distinción es importante: devolver 404 cuando el recurso existe pero el usuario no tiene permiso oculta la denegación y puede enmascarar problemas de autorización en los logs de producción.

La cobertura se mide ejecutando ./mvnw verify, que corre todos los tests y genera el informe en target/site/jacoco/index.html. Durante la escritura de los tests detecté varios errores que habían pasado desapercibidos en la ejecución normal. El más representativo: el servicio de seguimientos accedía a SecurityContextHolder.getContext().getAuthentication().getName() sin verificar si la autenticación era nula. En producción ese código nunca se llama sin autenticación activa, pero en tests de servicio sin contexto de seguridad lanzaba NullPointerException. La corrección fue un método privado currentUserEmail() que devuelve "system" cuando no hay autenticación. Es un ejemplo de cómo los tests no solo verifican funcionalidad, sino que afloran bugs que la ejecución normal no ejercita.

---

### 4.5 — NUEVA SECCIÓN (añadir después de 4.4)
**ACCIÓN: CREAR nueva subsección "4.5. Chat en tiempo real con WebSocket y protocolo STOMP"**

---

La comunicación entre los participantes de una práctica era uno de los requisitos funcionales desde el primer análisis del sistema. La solución más sencilla habría sido el polling: el cliente consulta la API periódicamente para comprobar si hay mensajes nuevos. Este enfoque es simple de implementar, pero genera tráfico constante aunque no haya ningún mensaje nuevo, y la latencia entre el envío y la recepción depende del intervalo de consulta. Opté por WebSocket porque establece un canal persistente y bidireccional: una vez abierta la conexión, el servidor puede enviar datos al cliente en cualquier momento sin que el cliente tenga que preguntar.

Sobre la conexión WebSocket base implementé el protocolo STOMP (Simple Text Oriented Messaging Protocol). STOMP añade una capa de mensajería con semántica de publicación-suscripción: los clientes se suscriben a canales con destinos con formato /topic/practica/{id}, y cualquier mensaje publicado en ese destino llega a todos los suscriptores activos. Spring Boot integra WebSocket de forma nativa a través del módulo spring-websocket, configurado en WebSocketConfig que anota el endpoint /ws y habilita el broker de mensajes STOMP.

El sistema implementa dos canales independientes por práctica. La migración Flyway V16 añadió la columna canal a la tabla de mensajes, con dos valores posibles: ALUMNO (para la conversación entre el estudiante y el tutor del centro) y TUTORES (para la coordinación privada entre el tutor de empresa y el tutor del centro). El cliente indica el canal tanto en el destino STOMP como en el endpoint REST de historial mediante el parámetro ?canal=. Esta separación garantiza que el alumno no puede leer la conversación privada entre sus tutores.

La autenticación en WebSocket fue el aspecto más complejo de la implementación. Las peticiones HTTP convencionales pasan por el filtro JWT de Spring Security, pero los frames WebSocket siguen un ciclo de vida diferente. Para resolverlo implementé un ChannelInterceptor que intercepta dos tipos de frames. En el frame CONNECT —el apretón de manos inicial— el interceptor extrae el token JWT de la cabecera STOMP, lo valida y establece la autenticación en el contexto de seguridad de la sesión. En el frame SUBSCRIBE comprueba que el email del usuario autenticado corresponde a uno de los tres participantes de la práctica cuyo identificador aparece en el destino solicitado. Si la verificación falla, lanza AccessDeniedException, que Spring traduce en el cierre de la conexión STOMP antes de que el cliente pueda escuchar el canal.

Los mensajes se persisten en la base de datos con relación a la práctica, al remitente y con marca temporal. Al suscribirse al canal, el cliente solicita el historial mediante un endpoint REST convencional (GET /mensajes/practica/{id}?canal=ALUMNO), de modo que al abrir el chat se cargan los mensajes anteriores aunque el usuario no estuviera conectado cuando se enviaron.

En el cliente Flutter, la pantalla ChatScreen establece la conexión STOMP al montarse utilizando el paquete stomp_dart_client. La URL del WebSocket se deriva de la misma variable de entorno API_URL que usan las peticiones REST, sustituyendo el esquema https:// por wss:// o http:// por ws://. Esto garantiza que el mismo build de Flutter funciona en local, en Docker y en cualquier despliegue sin modificar el código. La conexión se cierra en dispose, siguiendo el ciclo de vida de Flutter: no hay fugas de conexión aunque el usuario cambie de pestaña.

---

### 4.6 — NUEVA SECCIÓN
**ACCIÓN: CREAR nueva subsección "4.6. Sistema de notificaciones"**

---

El sistema de notificaciones informa a los usuarios de eventos relevantes sin que tengan que navegar activamente por la aplicación buscando novedades. Diseñé el sistema con un modelo REST con polling ligero en el cliente, en lugar de un segundo canal WebSocket. La razón es que las notificaciones no son eventos de tiempo real estricto: un parte validado o un mensaje recibido pueden esperar treinta segundos sin consecuencias reales. Añadir un segundo WebSocket habría complicado la arquitectura por un beneficio marginal.

La entidad Notificacion almacena el identificador del destinatario, el tipo (SEGUIMIENTO, INCIDENCIA, CHAT, SISTEMA), el texto descriptivo del evento, la marca temporal y un booleano leida. Los tipos permiten al cliente diferencia el icono y el color de cada notificación y abren la posibilidad de filtros futuros sin cambiar el modelo de datos.

Las notificaciones se generan automáticamente en los puntos de transición del sistema. Cuando SeguimientoServiceImpl aprueba o rechaza un parte, llama a NotificacionService.crear() para notificar al alumno. Cuando MensajeServiceImpl persiste un mensaje, genera notificaciones para todos los participantes de la práctica excepto el remitente. Esta integración garantiza que cualquier evento que modifica el estado del sistema genera la notificación correspondiente sin duplicar lógica en el controlador.

En el cliente, el NotificacionProvider arranca junto con la sesión y lanza un Timer.periodic que consulta el contador de notificaciones no leídas cada treinta segundos. El polling actualiza únicamente el número —un endpoint ligero que devuelve un entero— sin descargar la lista completa, minimizando el tráfico de red. El badge rojo con el contador aparece en el icono de la campana del AppBar en el panel del alumno y en el sidebar de los tres paneles de tutor.

---

### 4.7 — NUEVA SECCIÓN
**ACCIÓN: CREAR nueva subsección "4.7. Foto de perfil y sincronización entre paneles"**

---

El módulo de foto de perfil añade identidad visual a la plataforma, especialmente relevante en el chat donde un avatar diferencia visualmente al emisor del receptor. La decisión más relevante fue el lugar de almacenamiento. Para un despliegue Docker autocontenido como el de este proyecto, opté por almacenar las imágenes como columna BYTEA en la tabla usuarios mediante la migración Flyway V12. Esta decisión elimina la necesidad de configurar buckets externos o volúmenes de disco con permisos especiales: las imágenes quedan incluidas de forma automática en cualquier backup de la base de datos.

Un aspecto técnico que requirió investigación fue el comportamiento de @Lob de JPA en Hibernate 6. En versiones anteriores, @Lob sobre un campo byte[] mapeaba a bytea en PostgreSQL. En Hibernate 6, el comportamiento cambió y mapea a OID, un tipo diferente que requiere permisos especiales. La solución fue usar @Column(columnDefinition = "bytea"), que fuerza el tipo exacto en la DDL independientemente de la versión de Hibernate.

El endpoint de subida valida el tipo MIME del fichero recibido (se aceptan image/jpeg, image/png e image/webp) y limita el tamaño a 5 MB. La respuesta del endpoint GET /usuarios/{id} incluye un campo booleano tieneFoto: el cliente sabe si existe foto antes de hacer la petición de descarga, evitando una llamada HTTP innecesaria para los usuarios sin foto configurada.

La sincronización de la foto entre todos los paneles fue el reto más interesante en el cliente. Flutter construye la interfaz como un árbol de widgets independientes: el NexusAvatar del sidebar del tutor empresa, el del AppBar del alumno y el del panel de administración son instancias distintas que no comparten estado directamente. Para que todos se actualicen simultáneamente cuando el usuario sube una foto nueva, implementé FotoCache: una clase estática con un ValueNotifier<int> cuyo valor se incrementa al subir o eliminar una imagen. Cada instancia de NexusAvatar escucha este notifier a través de un ValueListenableBuilder y se reconstruye automáticamente cuando el valor cambia, forzando una nueva descarga desde el servidor. Este patrón resuelve la sincronización sin necesidad de un provider global ni de pasar callbacks entre widgets distantes en el árbol.

---

### 4.8 — NUEVA SECCIÓN
**ACCIÓN: CREAR nueva subsección "4.8. Evaluación final del alumno"**

---

La evaluación final es el módulo que cierra el ciclo formativo de las prácticas. Al finalizar el periodo, el tutor de empresa emite una valoración estructurada del alumno que queda registrada en el sistema y es visible para el tutor del centro en la ficha del alumno.

El diseño de la entidad EvaluacionFinal refleja los criterios reales de evaluación en FCT: una nota global numérica de cero a diez —el único campo obligatorio— y cinco criterios optativos: actitud y puntualidad, competencia técnica, iniciativa y autonomía, trabajo en equipo, y cumplimiento de tareas. Los criterios son opcionales porque no todos los tutores de empresa tienen información suficiente sobre todos los aspectos del desempeño del alumno para emitir una valoración justa. Forzar una puntuación para criterios no observados habría distorsionado el resultado. La nota global es independiente de la media de los criterios, porque el tutor puede ponderar su valoración considerando factores que los criterios no recogen.

El sistema impone una única evaluación por práctica. Si el tutor envía una segunda valoración, el servicio detecta el registro existente y lo actualiza en lugar de crear uno nuevo, simplificando el contrato de la API. La unicidad se garantiza a nivel de base de datos mediante una restricción UNIQUE sobre el par (practica_id, tutor_empresa_id) en la migración Flyway V14.

El diseño del formulario de evaluación requirió varias iteraciones. La primera versión usaba campos de texto numérico para introducir las notas, pero este enfoque es propenso a errores de formato y resulta menos expresivo que una interfaz visual. La versión final usa controles deslizantes (Slider) para cada criterio y para la nota global. El color del slider cambia en tiempo real: rojo para notas inferiores a cinco, ámbar entre cinco y siete, y verde para siete o superior. Este código de color es coherente con el sistema de diseño del resto de la aplicación. Cada criterio tiene un interruptor para habilitarlo o deshabilitarlo, reflejando el carácter opcional del modelo de datos.

---

### 4.9 — NUEVA SECCIÓN
**ACCIÓN: CREAR nueva subsección "4.9. Gestión de empresas colaboradoras"**

---

La entidad Empresa existía desde el diseño inicial y era consultable para poblar los formularios de creación de prácticas, pero no disponía de endpoints de escritura. El sistema asumía que las empresas eran datos de referencia gestionados fuera de la aplicación. Esta limitación resultó inadecuada para un sistema de gestión real, donde el administrador debe poder registrar nuevas empresas sin acceso directo a la base de datos.

Se implementó el CRUD completo con tres nuevos endpoints protegidos con @PreAuthorize("hasRole('ADMIN')"): POST /api/v1/empresas (crea validando que el CIF no esté ya registrado), PUT /api/v1/empresas/{id} (actualiza con la misma validación de CIF único pero excluyendo la propia empresa del check) y DELETE /api/v1/empresas/{id} (elimina; si tiene prácticas asociadas, la restricción de clave foránea de PostgreSQL provoca una respuesta 409 informativa).

El DTO de entrada EmpresaRequest define los cinco campos del modelo con validaciones de Bean Validation: @NotBlank y @Size para los obligatorios, @Email para el correo electrónico. Estas anotaciones son verificadas por Spring antes de que la petición llegue al servicio, gracias a @Valid en el parámetro del controlador. El mapper MapStruct se amplió con dos métodos: toEntity(EmpresaRequest) para la creación y updateEntity(EmpresaRequest, @MappingTarget Empresa) para la actualización in-place de una entidad existente, que es la forma correcta de hacer actualizaciones parciales con MapStruct sin crear un objeto nuevo ni desconectar la entidad del contexto de persistencia.

---

### 4.10 — NUEVA SECCIÓN
**ACCIÓN: CREAR nueva subsección "4.10. Infraestructura y despliegue en contenedores"**
**NOTA: El capítulo 4 ya menciona Docker en el párrafo inicial. Esta sección expande ese contenido con los detalles técnicos.**

---

El sistema completo se despliega mediante Docker Compose con tres servicios que forman una red privada aislada. El contenedor nexus-db ejecuta PostgreSQL 16 Alpine con un volumen persistente y un healthcheck con pg_isready que verifica la disponibilidad del servidor antes de permitir que los dependientes arranquen, evitando errores de conexión durante el inicio en frío donde PostgreSQL puede tardar unos segundos en estar listo.

El contenedor nexus-api contiene el backend Spring Boot construido mediante un Dockerfile multi-stage: la primera etapa descarga las dependencias Maven y compila el JAR con ./mvnw package -DskipTests; la segunda etapa copia únicamente el JAR resultante a una imagen base eclipse-temurin:21-jre-alpine, que no incluye el JDK completo ni el código fuente. El contenedor nexus-web sirve el bundle compilado de Flutter mediante Nginx Alpine con el mismo patrón multi-stage: la primera etapa instala el SDK de Flutter y compila la aplicación con flutter build web --release --dart-define=API_URL=...; la segunda etapa copia solo los archivos estáticos al contenedor Nginx.

La configuración de Nginx aplica tres políticas de caché diferentes. El fichero index.html se sirve con Cache-Control: no-store para garantizar que el navegador siempre obtiene el punto de entrada más reciente tras un despliegue. El bundle principal main.dart.js usa validación de ETag. Los assets con hash en el nombre de fichero (imágenes, fuentes), que Flutter genera automáticamente durante la compilación, se sirven con un año de caché inmutable.

Durante las pruebas de aceptación detecté que todas las marcas temporales del sistema se mostraban con dos horas de diferencia respecto a la hora real. La causa es que los contenedores Docker se ejecutan por defecto en la zona horaria UTC, mientras que España peninsular opera en Europe/Madrid (UTC+2 durante el horario de verano CEST). La corrección se aplicó en tres niveles: la variable de entorno TZ=Europe/Madrid en los servicios db y backend de Docker Compose; JAVA_TOOL_OPTIONS=-Duser.timezone=Europe/Madrid para garantizar que la propiedad de zona horaria de la JVM se establece antes de que Spring Boot inicialice su contexto; y las propiedades spring.jackson.time-zone=Europe/Madrid junto a spring.jackson.serialization.write-dates-as-timestamps=false en application.properties, que instruyen a Jackson para serializar los objetos LocalDateTime en formato ISO-8601 con la zona horaria de Madrid.

Las credenciales de la base de datos y el secreto JWT se externalizan mediante un fichero .env que no se versiona en el repositorio. La variable JWT_SECRET se declara con la sintaxis ${JWT_SECRET:?mensaje}, de modo que Docker Compose falla de forma explícita si la variable no está definida, impidiendo arrancar con un secreto vacío o por defecto. El perfil de producción application-prod.properties configura adicionalmente el pool de conexiones HikariCP con máximo diez conexiones y mínimo cinco, y restringe los endpoints de Spring Actuator a solo health e info.

---

═══════════════════════════════════════════════════════════════
## CAPÍTULO 5 — Diseño de la Interfaz por Roles
═══════════════════════════════════════════════════════════════

**ACCIÓN: Añadir este párrafo introductorio al principio de la sección, antes de 5.1**

---

Cada panel de la aplicación está diseñado para un actor concreto con necesidades diferentes. La filosofía de diseño común a todos es la claridad funcional: el color comunica estado, no decora. El azul identifica acciones principales y elementos activos. El verde señala que algo ha sido validado correctamente. El ámbar advierte de elementos pendientes de atención. El rojo alerta sobre incidencias, rechazos o acciones destructivas. Esta semántica de color es consistente en todos los paneles: el mismo ámbar que indica un parte pendiente en el panel del alumno indica una incidencia sin resolver en el panel del tutor del centro.

---

### 5.1 — REEMPLAZAR los bullet points del Panel del Alumno
**ACCIÓN: REEMPLAZAR los bullet points existentes de la sección 5.1 con este texto**

---

El panel del alumno es la pantalla que el estudiante usa desde el primer día de prácticas hasta el último. Está diseñada para que cualquier acción relevante —registrar una tarea, reportar un problema, enviar un mensaje— se pueda completar en menos de tres pasos desde la pantalla inicial.

La arquitectura del panel se basa en el patrón Provider de Flutter. Al hacer login, el AuthProvider almacena los datos de la sesión en memoria y notifica automáticamente a todos los widgets que dependen de esa información. La comunicación con la API se centraliza en un cliente Dio configurado con un interceptor JWT: antes de enviar cualquier petición, el interceptor recupera el token del almacenamiento seguro del dispositivo y lo añade a la cabecera de la petición. Ninguna pantalla necesita gestionar la autenticación; el interceptor lo hace de forma transparente.

La pestaña de **inicio** muestra el resumen del estado actual de la práctica: nombre de la empresa y tutor asignado, barra de progreso de horas que indica cuántas se han contabilizado del total acordado en el convenio, y los seguimientos más recientes con su estado visual. La barra de progreso computa únicamente los partes en estado COMPLETADO, es decir, los que han pasado por las dos validaciones requeridas. Mostrar partes pendientes como si ya contaran habría engañado al alumno sobre su avance real. El Dashboard carga los datos de práctica, seguimientos e incidencias en paralelo mediante Future.wait() de Dart, reduciendo el tiempo de carga percibido frente a ejecutarlas de forma secuencial.

La pestaña de **seguimientos** presenta la lista completa de partes registrados, ordenada por fecha descendente. Cada parte muestra las horas, la fecha, la descripción abreviada y un indicador visual del estado mediante el código de color del sistema de diseño. El botón flotante en la esquina inferior derecha abre el formulario de nuevo parte. El formulario valida en cliente que la fecha no sea futura, que las horas estén entre 1 y 24, y que la descripción tenga al menos diez caracteres. Al enviar correctamente, el nuevo parte se añade a la lista local del provider sin necesidad de recargar toda la información desde la red, lo que proporciona una respuesta inmediata.

La pestaña de **incidencias** permite al alumno reportar formalmente cualquier problema durante la práctica. El formulario incluye un selector de categoría (acceso, ausencia, comportamiento, accidente u otros) y un campo de texto libre. Si el tutor de empresa rechaza un parte de seguimiento, el sistema genera automáticamente una incidencia visible para el tutor del centro sin que el alumno tenga que hacer nada adicional. Esta automatización protege al alumno en situaciones donde la empresa puede estar actuando incorrectamente.

La pestaña de **ausencias** permite registrar faltas de asistencia con fecha, motivo y un fichero justificante opcional (PDF, JPG o PNG hasta 5 MB). El calendario nativo de Flutter limita la selección a fechas pasadas o presentes, alineando la validación del cliente con la restricción del backend. El sistema verifica que no existe ya una ausencia para la misma práctica y la misma fecha, evitando duplicados. El estado de cada ausencia se refleja mediante el código de color: ámbar para pendiente, verde para justificada y rojo para injustificada.

La pestaña de **chat** se conecta automáticamente al canal ALUMNO de la práctica activa al abrirse. El historial completo se carga mediante REST y los mensajes nuevos llegan en tiempo real por WebSocket sin recargar la pantalla. Los avatares de los participantes diferencian visualmente al emisor del receptor.

La navegación entre pestañas se implementa con IndexedStack, que mantiene todos los hijos montados en memoria aunque no estén visibles. Esto preserva el estado de scroll y evita recargar datos al cambiar de pestaña. En pantallas anchas (web, tablet, más de 600 píxeles) la navegación se presenta como un NavigationRail lateral; en móvil se sustituye por una BottomNavigationBar inferior. Esta adaptación se gestiona con un único LayoutBuilder que evalúa el ancho disponible sin duplicar lógica.

[SCREENSHOT: Panel alumno — dashboard inicial con barra de progreso]
[SCREENSHOT: Panel alumno — formulario nuevo seguimiento]
[SCREENSHOT: Panel alumno — pestaña ausencias con lista y estados]
[SCREENSHOT: Panel alumno — chat activo con mensajes]

---

### 5.2 — REEMPLAZAR los bullet points del Panel del Tutor del Centro
**ACCIÓN: REEMPLAZAR los bullet points existentes de la sección 5.2 con este texto**

---

El panel del tutor del centro es el más complejo del sistema por la naturaleza multidimensional del rol: supervisar a varios alumnos simultáneamente, gestionar incidencias, validar partes y coordinar con los tutores de empresa. La arquitectura de la pantalla responde a esta complejidad con un layout de tres columnas en web: barra de navegación funcional a la izquierda, lista de alumnos en el centro, y panel de detalle del alumno seleccionado a la derecha.

El **modo Dashboard** muestra el resumen global: cuatro tarjetas de estadísticas (alumnos activos, partes pendientes de validación final, incidencias abiertas y ausencias injustificadas), un panel de alumnos con indicadores de carga, y las incidencias más recientes que requieren atención. Este modo está diseñado para la revisión diaria rápida: el tutor puede ver de un vistazo qué alumnos necesitan atención sin abrir ninguna ficha individual.

El **modo Alumnos** activa el panel de detalle individual. Al seleccionar un alumno de la lista, el panel derecho muestra su información completa: nombre, empresa, fechas de la práctica, barra de progreso de horas FCT, seguimientos pendientes de validación final, incidencias abiertas y ausencias injustificadas. El layout del panel de detalle usa dos columnas cuando el espacio disponible supera los 650 píxeles: la columna principal contiene las secciones que requieren acción, y la columna secundaria da acceso rápido a la ficha completa y al chat. La barra de progreso FCT computa únicamente los partes en estado COMPLETADO, permitiendo al tutor detectar retrasos antes de que se conviertan en un problema.

La **ficha completa del alumno** abre todos los datos históricos: el informe de ausencias con columnas de estado, justificante y quién las revisó; el historial completo de seguimientos con fechas, horas y comentarios de validación; y la evaluación final emitida por el tutor de empresa en modo solo lectura. La ficha incluye botones para exportar el expediente completo en PDF y en Excel, generados directamente en el cliente Flutter con los paquetes pdf y excel.

El **modo Partes** muestra la vista global de todos los seguimientos pendientes de la validación final del centro, sin necesidad de entrar en la ficha de cada alumno. Cada parte muestra el nombre del alumno, la empresa, las horas declaradas y la descripción completa.

El **modo Incidencias** agrupa todas las incidencias activas por estado (ABIERTA, EN_GESTIÓN, RESUELTA). Al pulsar una incidencia se abre un diálogo centrado —no un BottomSheet— para cambiar su estado y añadir un comentario de resolución. El diseño usa un diálogo modal porque en web un panel emergente desde abajo rompe la sensación de aplicación de escritorio.

Los **modos de chat** (canal ALUMNO y canal TUTORES) permiten al tutor del centro conversar con el alumno de la práctica seleccionada y con el tutor de empresa, respectivamente, sin que el alumno pueda leer la coordinación entre tutores.

La lista de alumnos muestra un badge numérico rojo que suma las incidencias abiertas y las ausencias injustificadas de cada alumno, permitiendo detectar los casos que requieren atención sin revisar ficha por ficha.

En móvil, los cinco modos se presentan como pestañas en la barra inferior, manteniendo todas las funcionalidades con el patrón de navegación táctil.

[SCREENSHOT: Panel tutor centro — dashboard con stats y lista de alumnos]
[SCREENSHOT: Panel tutor centro — detalle alumno con layout dos columnas]
[SCREENSHOT: Panel tutor centro — ficha completa con historial]
[SCREENSHOT: Panel tutor centro — diálogo gestión de incidencia]

---

### 5.3 — REEMPLAZAR los bullet points del Panel Admin
**ACCIÓN: REEMPLAZAR los bullet points existentes de la sección 5.3 con este texto**

---

El panel de administración es la herramienta de gestión del sistema para el personal del centro educativo responsable de la coordinación general de las prácticas. Opera sobre las entidades maestras del sistema: usuarios, prácticas y empresas colaboradoras.

El **dashboard inicial** presenta cuatro tarjetas de estadísticas con iconos y subtítulos contextuales calculados con datos reales. El contador de prácticas activas muestra además cuántas están en borrador y cuántas finalizadas, para que el administrador tenga el contexto completo en un vistazo. La sección de prácticas en curso lista las cinco más recientes con el avatar del alumno, el nombre de la empresa y la barra de progreso de horas.

La **gestión de usuarios** permite crear cuentas de cualquier rol, editarlas y activarlas o desactivarlas sin eliminar el registro. La desactivación —en lugar del borrado— conserva el historial completo de partes, incidencias y mensajes mientras impide el acceso al sistema. Los formularios validan el formato del email, el DNI y la fortaleza de la contraseña en cliente antes de enviar la petición.

La **gestión de prácticas** permite crear y modificar convenios activos. La posibilidad de editar prácticas existentes fue una adición razonada: durante el despliegue es frecuente asignar por error a un alumno a la práctica equivocada; corregirlo sin borrar y recrear el registro evita perder el historial de partes ya registrados. La vista de prácticas se filtra por estado (Todas, Activas, Borradores, Finalizadas) mediante tabs animadas con el contador de prácticas en cada estado. Las prácticas finalizadas muestran un icono de ojo que abre la ficha en modo solo lectura.

La **gestión de empresas** es la funcionalidad añadida en el cuarto hito. La vista presenta la lista de empresas colaboradoras en formato tabla con búsqueda en tiempo real por nombre o CIF. Las acciones de crear, editar y eliminar se gestionan mediante diálogos centrados con validación en cliente. La eliminación incluye un aviso explícito de que fallará si la empresa tiene prácticas asociadas, previniendo que el administrador intente borrar una empresa en uso sin entender por qué falla.

La **auditoría** ofrece el historial completo de todas las operaciones del sistema filtrable por módulo, con el email del actor, la descripción de la acción y la marca temporal. El administrador puede detectar actividad inusual o reconstruir la secuencia de eventos ante cualquier incidencia.

[SCREENSHOT: Panel admin — dashboard con tarjetas de stats e iconos]
[SCREENSHOT: Panel admin — gestión prácticas con tabs de filtro animadas]
[SCREENSHOT: Panel admin — gestión empresas con tabla y búsqueda]

---

### 5.4 — REEMPLAZAR los bullet points del Panel del Tutor de Empresa
**ACCIÓN: REEMPLAZAR los bullet points existentes de la sección 5.4 con este texto**

---

El panel del tutor de empresa responde a un principio de diseño minimalista: este actor tiene una función específica en el sistema —firmar partes, revisar ausencias, coordinar con el tutor del centro y evaluar al alumno— y la interfaz no debe distraerle con información que no le corresponde gestionar.

La cabecera del panel muestra tres métricas globales: partes pendientes de firma, partes ya procesados y horas acumuladas por el alumno en partes completados. Estas cifras permiten al tutor calibrar rápidamente el estado general de la práctica antes de entrar en el detalle.

La primera pestaña muestra la lista de **partes de seguimiento pendientes** de su validación. Cada parte presenta el nombre del alumno, la semana, las horas declaradas y la descripción completa de las tareas formateada como cita. Los botones de validar y rechazar están diferenciados en color. Al rechazar se exige introducir un motivo antes de confirmar, porque el motivo queda registrado y es visible para el alumno y el tutor del centro.

La segunda pestaña gestiona las **ausencias**. Cada tarjeta muestra el alumno, la fecha, el motivo declarado y un indicador visual si existe justificante adjunto. Al pulsar el indicador de justificante, la aplicación descarga los bytes mediante una petición autenticada y abre el fichero en una nueva pestaña del navegador, sin exponer el token JWT en la URL. Las acciones permiten marcar la ausencia como justificada o injustificada con confirmación previa.

La tercera pestaña da acceso al **chat del canal TUTORES**, la conversación privada con el tutor del centro para coordinar aspectos de la práctica que no son apropiados para el canal del alumno: gestión de conflictos, decisiones sobre ausencias injustificadas, coordinación antes de la evaluación final.

La cuarta pestaña presenta el **formulario de evaluación final**. Los controles deslizantes con código de color dinámico permiten completar la evaluación en pocos minutos, sin confusión sobre el rango de valores. Una vez enviada, la evaluación queda disponible en la ficha del alumno para el tutor del centro.

[SCREENSHOT: Panel tutor empresa — lista de partes pendientes con acciones]
[SCREENSHOT: Panel tutor empresa — formulario evaluación con sliders de color]

---

### 5.5 — NUEVA SECCIÓN (después de 5.4, antes de la sección de móvil)
**ACCIÓN: CREAR nueva subsección "5.5. Sistema de diseño y coherencia visual"**

---

Una de las decisiones transversales más importantes del proyecto fue definir un sistema de diseño centralizado antes de construir las pantallas. Sin este sistema, cada pantalla hubiera acumulado variaciones visuales menores que, sumadas, producen la sensación de inconsistencia que caracteriza a las aplicaciones construidas sin un lenguaje visual común.

El sistema de diseño de Nexus parte de una filosofía de claridad funcional: el color comunica estado, no decora. Cada elemento visual tiene un significado concreto que el usuario aprende una vez y reconoce en toda la aplicación. Esta semántica de color se define con tres variantes por cada estado semántico. Por ejemplo, para el estado de éxito: NexusColors.success (verde para iconos y texto), NexusColors.successLight (verde muy claro para fondos de badges) y NexusColors.successText (verde oscuro para texto sobre fondo claro, garantizando contraste suficiente). Esta estructura triple permite componer cualquier badge de estado sin calcular colores manualmente en cada pantalla. Todos los valores se centralizan en app_theme.dart; ninguna pantalla usa valores de color literales.

El rediseño visual del cuarto hito actualizó la pantalla de login con un layout de dos columnas: el panel izquierdo presenta el logo y la identidad visual de Nexus sobre un fondo con gradiente; el panel derecho contiene el formulario de autenticación con el mínimo de elementos necesarios. En pantallas estrechas el panel izquierdo desaparece y el formulario ocupa todo el ancho, manteniendo la funcionalidad en dispositivos móviles.

Durante el rediseño del panel del tutor del centro encontré un bug específico de Flutter Web: la propiedad constraints.maxWidth dentro de un LayoutBuilder devuelve cero durante el primer frame de renderizado en el navegador, antes de que el motor de layout del DOM haya calculado las dimensiones reales. Esto provocaba que el panel de detalle no se renderizara correctamente hasta que el usuario interactuaba con la página. La solución fue sustituir constraints.maxWidth > 600 por MediaQuery.sizeOf(context).width > 600, que consulta el tamaño de la ventana directamente del contexto de Flutter y devuelve el valor correcto desde el primer frame.

El widget NexusAvatar es un componente transversal que encapsula la lógica de mostrar la foto de perfil o, en su ausencia, las iniciales del usuario sobre un fondo de color determinístico. Se usa en las cabeceras de panel, en las listas de alumnos, en el historial del chat y en las tarjetas de seguimientos. Centralizar esta lógica en un único widget garantiza que la foto se muestra de forma consistente en toda la aplicación y que el mecanismo de invalidación de caché FotoCache funciona en todos los puntos donde aparece el avatar.

[SCREENSHOT: Pantalla de login — layout dos columnas con panel branding]
[SCREENSHOT: Comparativa antes/después del rediseño de un panel]

---

═══════════════════════════════════════════════════════════════
## CAPÍTULO 6 — Modelo de la Base de Datos
═══════════════════════════════════════════════════════════════

**ACCIÓN: AÑADIR A CONTINUACIÓN del diagrama ER existente**

---

El esquema final de la base de datos está gestionado por dieciséis migraciones Flyway secuenciales, desde la estructura inicial (V1) hasta la última modificación del cuarto hito (V16). Esta gestión versionada garantiza que cualquier entorno puede alcanzar exactamente el mismo estado del esquema ejecutando ./mvnw flyway:migrate, sin necesidad de scripts manuales ni de instrucciones de configuración adicionales.

Las decisiones de diseño más relevantes del esquema final son las siguientes.

La tabla seguimientos usa un enum PostgreSQL para el campo estado con cuatro valores: PENDIENTE_EMPRESA, PENDIENTE_CENTRO, COMPLETADO y RECHAZADO. Esta decisión limita los valores posibles a nivel de base de datos, añadiendo una capa de validación independiente del código Java que impide la inserción de estados incoherentes incluso mediante acceso directo a la base de datos.

La tabla mensajes incluye una columna canal VARCHAR(20) con un índice compuesto sobre (practica_id, canal). El índice compuesto hace que las consultas de historial —que siempre filtran por práctica y canal simultáneamente— sean eficientes independientemente del volumen de mensajes acumulados.

La tabla evaluaciones_finales tiene una restricción UNIQUE sobre el par (practica_id, tutor_empresa_id), garantizando una única evaluación por práctica y tutor. La restricción actúa como salvaguarda de integridad referencial que ningún error en la lógica de la aplicación puede eludir.

La tabla usuarios almacena la foto de perfil en dos columnas: foto de tipo bytea y foto_content_type VARCHAR(20). Almacenar el tipo MIME junto a los bytes evita tener que detectar el formato en cada petición de descarga y permite devolver la cabecera Content-Type correcta directamente desde el valor almacenado.

La tabla audit_logs almacena el jti del token activo en cada operación registrada, permitiendo correlacionar eventos de auditoría con sesiones específicas en caso de investigación. Junto al email del actor, el módulo, la acción y la marca temporal, el sistema proporciona una trazabilidad que cumple los requisitos mínimos de auditoría de sistemas de información académica.

La tabla ausencias tiene una restricción UNIQUE sobre el par (practica_id, fecha), impidiendo registrar más de una ausencia el mismo día para la misma práctica. Esta restricción se complementa con la validación en el servicio, que devuelve un mensaje descriptivo al cliente en lugar de dejar que el error de base de datos se propague como excepción genérica.

---

═══════════════════════════════════════════════════════════════
## CAPÍTULO 7 — Planificación
═══════════════════════════════════════════════════════════════

**ACCIÓN: REEMPLAZAR el párrafo "Estado Actual (Hito 4 — en desarrollo)" con este texto**

---

**Estado Actual (Cierre Hito 4 — 100%)**

El cuarto hito completó el ciclo funcional del sistema y cerró los módulos planificados desde el inicio del proyecto. El módulo de chat se implementó en su forma definitiva con dos canales independientes: el canal ALUMNO para la comunicación entre el estudiante y el tutor del centro, y el canal TUTORES para la coordinación privada entre el tutor del centro y el tutor de empresa. La separación de canales garantiza que el alumno no puede acceder a conversaciones que no le corresponden. El backend expone el endpoint WebSocket /ws con autenticación en los frames CONNECT y SUBSCRIBE; el cliente Flutter establece la conexión con stomp_dart_client y la gestiona dentro del ciclo de vida del widget para evitar fugas de conexión.

El sistema de notificaciones se integró de forma transversal con los módulos existentes: cualquier validación de parte, rechazo o mensaje nuevo genera automáticamente la notificación correspondiente al destinatario. Un polling ligero cada treinta segundos en el cliente mantiene el indicador del badge actualizado sin generar tráfico excesivo.

La evaluación final del alumno completó el ciclo de supervisión: el tutor de empresa puede emitir una valoración con criterios opcionales y nota global, visible en la ficha del alumno para el tutor del centro. El formulario con controles deslizantes y código de color por rango de nota es el resultado de dos iteraciones de diseño, partiendo de campos de texto numérico hasta llegar a una interfaz que comunica la valoración de forma visual e inmediata.

La gestión de empresas colaboradoras añadió el CRUD completo al panel de administración, cerrando la funcionalidad necesaria para que un centro educativo pueda incorporar nuevas empresas sin acceso directo a la base de datos. El rediseño visual estableció un lenguaje visual coherente en todos los paneles, documentado en app_theme.dart y aplicado de forma consistente en cualquier extensión futura.

La batería de tests alcanzó los 254 casos con una cobertura del 80% de instrucciones, superando en más de diez puntos el objetivo inicial del 69,5% del tercer hito. La corrección de la zona horaria (TZ=Europe/Madrid en Docker Compose + JAVA_TOOL_OPTIONS + spring.jackson.time-zone) resolvió el desfase de dos horas detectado en las marcas temporales de todos los módulos.

---

═══════════════════════════════════════════════════════════════
## CAPÍTULO 8 — Conclusión y Futuro
═══════════════════════════════════════════════════════════════

**ACCIÓN: REEMPLAZAR completamente el texto actual del capítulo 8 con este texto**

---

Este proyecto demuestra que es posible mejorar significativamente la experiencia de las prácticas de Formación Profesional cuando se centraliza en un único entorno digital lo que antes estaba disperso entre correos electrónicos, llamadas y hojas de cálculo. La plataforma Nexus cubre el ciclo completo del seguimiento: el registro semanal de actividad por parte del alumno, la doble validación por tutor de empresa y tutor del centro, la gestión de ausencias con justificantes adjuntos, la comunicación en tiempo real mediante chat con dos canales independientes, el sistema de notificaciones, la foto de perfil sincronizada entre paneles, y la evaluación final del alumno. Todo ello con un sistema de auditoría que garantiza la trazabilidad de cada operación y con controles de seguridad que siguen las recomendaciones del estándar OWASP Top 10.

Uno de los aprendizajes más importantes ha sido comprobar que las decisiones con mayor impacto no son las tecnológicas sino las de lógica de negocio. Detectar que el flujo de validación necesitaba dos pasos diferenciados —uno por la empresa y otro por el centro— antes de construir ninguna pantalla fue un hallazgo que habría costado mucho más corregir a posteriori. Del mismo modo, la decisión de diseñar una tabla independiente para las ausencias en lugar de reutilizar la de seguimientos evitó columnas siempre nulas según el tipo de registro, que son una señal clara de normalización incorrecta en un modelo relacional. Estos no son errores de código, sino de diseño conceptual, y solo se detectan cuando se cuestiona críticamente el modelo antes de implementarlo.

Otro aprendizaje relevante ha sido la importancia de integrar la seguridad como parte del proceso de desarrollo, no como una fase posterior. La revisión sistemática OWASP que realicé durante el tercer hito encontró vulnerabilidades reales: un fallo criptográfico en la generación de tokens JWT, un vector de enumeración de cuentas en el endpoint de registro, ausencia de control de acceso a nivel de objeto en los servicios de seguimiento y ausencias, y cabeceras HTTP de seguridad incompletas en el servidor Nginx. Aplicarlas sobre el código existente tuvo un coste bajo. Haber esperado al final del proyecto habría requerido un esfuerzo mucho mayor y posiblemente cambios de arquitectura.

La batería de 254 tests automatizados con una cobertura del 80% ha sido la red de seguridad que ha permitido refactorizar, ampliar módulos y corregir bugs sin romper funcionalidades existentes. En más de una ocasión, la escritura de un test nuevo para un módulo recién implementado reveló un comportamiento inesperado en un módulo anterior que la ejecución normal no ejercitaba. Esta interdependencia entre tests y correcciones es el argumento más convincente que he encontrado en la práctica para tratar los tests como parte del desarrollo, no como documentación opcional.

Desde el punto de vista tecnológico, combinar Java con Spring Boot en el backend y Flutter en el frontend ha sido una elección que ha funcionado bien. Spring Boot proporciona un ecosistema maduro para la gestión de seguridad, la validación de entradas y la persistencia con JPA, con abstracciones que reducen el código necesario sin ocultar lo que ocurre por debajo. Flutter permite construir una interfaz adaptativa —web, Android e iOS desde una única base de código— con un sistema de estado basado en Provider que, una vez comprendido su modelo reactivo, simplifica la gestión de la interfaz de forma significativa. El reto principal de Flutter ha sido aprender a pensar en términos de árbol de widgets y ciclo de vida, conceptos sin equivalente directo en el desarrollo web tradicional.

La arquitectura modular del sistema, donde cada módulo funcional tiene su propio servicio, controlador y repositorio, está diseñada para facilitar las extensiones naturales. A corto plazo, la firma digital de convenios mediante certificado o firma simple en pantalla táctil eliminaría el único paso que sigue requiriendo papel en el proceso actual. A medio plazo, la gestión del proceso previo a las prácticas —publicación de perfiles por parte de las empresas, preferencias de los alumnos y asignación por el centro— completaría el ciclo completo que Nexus aspira a digitalizar. A largo plazo, notificaciones push en dispositivo móvil y análisis de datos sobre las tendencias de validación y ausencias completarían una plataforma de gestión académica competitiva con las soluciones comerciales existentes.

Este TFG ha sido la primera vez que he desarrollado un sistema completo de principio a fin, tomando decisiones de arquitectura reales con consecuencias reales. La diferencia entre lo que sabía al empezar y lo que sé al terminar no se mide en tecnologías aprendidas, sino en criterio para tomar decisiones técnicas justificadas y en la capacidad de cuestionar el propio diseño antes de que sea demasiado tarde para cambiarlo.

---

═══════════════════════════════════════════════════════════════
## RESUMEN DE ACCIONES POR SECCIÓN
═══════════════════════════════════════════════════════════════

| Capítulo | Acción | Págs. est. |
|----------|--------|------------|
| Cap. 1 | AÑADIR 3 párrafos después del 2º párrafo | +1 |
| Cap. 4.1 | AÑADIR bloque Hito 2 después de "@PreAuthorize" | +1 |
| Cap. 4.1 | AÑADIR bloque Hito 4 nuevos módulos al final de 4.1 | +2 |
| Cap. 4.3 | AÑADIR 2ª y 3ª iteración OWASP al final de 4.3 | +1.5 |
| Cap. 4.4 | REEMPLAZAR sección completa de tests | +1.5 |
| Cap. 4.5 (nueva) | CREAR sección Chat WebSocket/STOMP | +2 |
| Cap. 4.6 (nueva) | CREAR sección Notificaciones | +1 |
| Cap. 4.7 (nueva) | CREAR sección Foto de perfil | +1.5 |
| Cap. 4.8 (nueva) | CREAR sección Evaluación final | +1.5 |
| Cap. 4.9 (nueva) | CREAR sección Gestión de empresas | +1 |
| Cap. 4.10 (nueva) | CREAR sección Infraestructura Docker | +1.5 |
| Cap. 5 intro | AÑADIR párrafo introductorio antes de 5.1 | +0.5 |
| Cap. 5.1 | REEMPLAZAR bullet points Panel Alumno | +2 |
| Cap. 5.2 | REEMPLAZAR bullet points Panel Tutor Centro | +2 |
| Cap. 5.3 | REEMPLAZAR bullet points Panel Admin | +1.5 |
| Cap. 5.4 | REEMPLAZAR bullet points Panel Tutor Empresa | +1.5 |
| Cap. 5.5 (nueva) | CREAR sección Design System y coherencia visual | +1.5 |
| Cap. 6 | AÑADIR después del diagrama ER | +1.5 |
| Cap. 7 | REEMPLAZAR párrafo "Hito 4 en desarrollo" | +1 |
| Cap. 8 | REEMPLAZAR conclusión completa | +1.5 |
| **TOTAL** | | **~28 págs.** |

**Estimación post-integración**: 23 págs. actuales + 28 nuevas ≈ **51 páginas.**

Para llegar a 80 páginas, añadir:
- Screenshots en página completa con pie de foto (cada grupo de 2-3 capturas = ~1 página)
- Diagramas adicionales: UML de secuencia del chat WebSocket, diagrama de estados de seguimientos (con los 4 estados), diagrama de estados de ausencias
- Sección de manual de usuario por rol (pendiente)
- Posibles anexos: tabla completa de endpoints API REST, glosario de términos FCT
