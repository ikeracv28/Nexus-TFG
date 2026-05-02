# MEMORIA_ACTUALIZACIONES.md
# Fragmentos listos para copiar en la Memoria TFG Word

Este archivo es generado y mantenido automáticamente por Claude Code.
Cada vez que se completa una feature relevante, se añade aquí un bloque
con el texto listo para integrar en la memoria oficial.

Cómo usarlo:
1. Revisa los bloques pendientes (marcados con [PENDIENTE DE INTEGRAR]).
2. Copia el texto en la sección correspondiente del .docx.
3. Cambia el estado a [INTEGRADO — fecha].

---

## BLOQUE 001 — Hito 1 (25%): Arquitectura base y autenticación JWT
**Sección destino en memoria**: Capítulo 4 (Arquitectura y Tecnologías) + Capítulo 7 (Planificación)
**Estado**: [INTEGRADO en entrega Hito 1]

> Este bloque ya está reflejado en la memoria actual. Se conserva como referencia.

Durante el primer hito se estableció la arquitectura base del sistema. El backend se implementó
con Spring Boot 3.4.1 sobre Java 21, adoptando una arquitectura en tres capas: controladores,
servicios y repositorios. Para la persistencia se eligió PostgreSQL junto con Flyway, herramienta
que gestiona el historial de cambios del esquema de base de datos mediante migraciones
versionadas, garantizando que cualquier entorno (desarrollo, pruebas, producción) parta del
mismo estado conocido.

La seguridad se implementó mediante JWT (JSON Web Tokens). Al hacer login, el servidor genera
un token firmado con un secreto que incluye los roles del usuario. El cliente (Flutter) almacena
ese token de forma cifrada en el dispositivo y lo adjunta en cada petición posterior en la cabecera
`Authorization`. El servidor valida la firma del token sin necesidad de consultar la base de datos
en cada petición, lo que hace el sistema sin estado (stateless) y más escalable.

---

## BLOQUE 002 — Hito 2 (50%): CRUD de Prácticas, Seguimientos y Dashboard Flutter
**Sección destino en memoria**: Capítulo 4.1 (Diseño del Backend) + Capítulo 5 (Diseño de Interfaz)
**Estado**: [PENDIENTE DE INTEGRAR]

### Para el capítulo del Backend (4.1)

En el segundo hito se implementó la lógica de negocio central del sistema. La entidad `Practica`
actúa como pivote del modelo de datos: relaciona a un alumno con su tutor del centro, su tutor
de empresa y la empresa donde realiza la formación. Esta decisión de diseño refleja la realidad
de las prácticas de FP, donde el seguimiento académico y el profesional son responsabilidades
independientes.

Para proteger la integridad del ciclo de vida de una práctica, se implementaron tres estados:
`BORRADOR` (recién creada, solo visible por administradores), `ACTIVA` (en curso, el alumno
puede registrar seguimientos) y `FINALIZADA` (cerrada). Las transiciones entre estados se validan
en la capa de servicio, no en el controlador, siguiendo el principio de que la lógica de negocio
no debe depender del protocolo de transporte.

El módulo de seguimientos permite al alumno registrar sus actividades diarias indicando fecha,
horas realizadas y descripción de las tareas. Cada parte queda en estado `PENDIENTE` hasta que
un tutor lo revisa y lo marca como `VALIDADO` o `RECHAZADO`, pudiendo añadir un comentario.
Esta validación captura automáticamente la identidad del tutor desde el contexto de seguridad
de Spring, sin necesidad de que el cliente lo envíe explícitamente.

Para garantizar que los datos de las entidades JPA nunca se exponen directamente en la API,
se utilizó MapStruct: una librería que genera automáticamente el código de mapeo entre entidades
y DTOs en tiempo de compilación, sin reflection y sin coste en runtime.

Un aspecto que merece mención es el diseño del endpoint `GET /api/v1/practicas/me`. En lugar
de que el cliente tenga que conocer el identificador del alumno para solicitar sus prácticas,
este endpoint extrae la identidad del usuario directamente del token JWT mediante el
`SecurityContextHolder` de Spring Security. Esto simplifica el cliente y elimina la necesidad
de almacenar el ID del usuario de forma separada al token, reduciendo la superficie de posibles
inconsistencias.

Para el módulo de incidencias se implementó tanto la consulta como el reporte de nuevas
incidencias. El endpoint `POST /api/v1/incidencias` identifica al alumno desde el JWT y
vincula automáticamente la incidencia a su práctica activa, sin que el cliente tenga que
conocer ni enviar el identificador de la práctica. En el tercer hito se añadirá la gestión
de resolución por parte del tutor del centro.

### Para el capítulo del Frontend (5.1 Panel del Alumno)

El cliente se desarrolló con Flutter, framework de Google que permite compilar una única base
de código Dart para web, Android e iOS. Para la gestión del estado de la aplicación se utilizó
el patrón Provider: cuando el usuario hace login, el `AuthProvider` almacena sus datos en memoria
y notifica automáticamente a todos los widgets que dependen de esa información, provocando que
la interfaz se actualice sin necesidad de gestión manual.

La comunicación con la API se centraliza en un cliente Dio configurado con un interceptor JWT:
antes de enviar cualquier petición, el interceptor recupera el token del almacenamiento seguro
del dispositivo y lo añade a la cabecera de la petición. Ninguna pantalla ni servicio de la
aplicación necesita gestionar la autenticación; el interceptor lo hace de forma transparente.

El Dashboard carga tres tipos de información al arrancar: la práctica activa del alumno, sus
seguimientos y sus incidencias. Las tres llamadas a la API se ejecutan en paralelo mediante
`Future.wait()` de Dart, lo que reduce el tiempo de carga percibido frente a ejecutarlas de
forma secuencial. La barra de progreso de horas muestra únicamente las horas de los seguimientos
en estado `COMPLETADO`, es decir, aquellos que han recibido el visto bueno definitivo, reflejando
con precisión el avance real de las prácticas.

El sistema de diseño visual establece un código de color semántico consistente en toda la
aplicación: el azul identifica elementos activos y acciones principales, el verde señala
validaciones correctas, el ámbar advierte de elementos pendientes de atención y el rojo alerta
sobre incidencias abiertas o partes rechazados. Todos los colores se definen en un único archivo
centralizado, de modo que ninguna pantalla los hardcodea directamente.

El formulario de registro de seguimientos implementa validación de entrada tanto en cliente
como en servidor. En cliente se verifica que la fecha no sea futura, que las horas estén en
el rango 1-24 y que la descripción tenga al menos 10 caracteres. Al enviar correctamente, el
nuevo seguimiento se añade a la lista local del provider sin necesidad de recargar toda la
información desde la red, lo que proporciona una respuesta inmediata al usuario.

---

## BLOQUE 003 — Hito 2 (complemento): Navegación del Dashboard y pantallas secundarias
**Sección destino en memoria**: Capítulo 5 (Diseño de Interfaz — Panel del Alumno)
**Estado**: [PENDIENTE DE INTEGRAR]

La navegación de la aplicación se diseñó para adaptarse al dispositivo de forma automática. En pantallas anchas (escritorio y tablet, más de 600 píxeles) aparece un `NavigationRail` lateral con iconos, siguiendo las convenciones de las aplicaciones web modernas. En pantallas estrechas (móvil) se muestra un `BottomNavigationBar` en la parte inferior, respetando los patrones de uso táctil. Esta adaptación se implementó con un único `LayoutBuilder` que evalúa el ancho disponible y decide qué componente de navegación renderizar.

El contenido del dashboard se organiza en cuatro pestañas gestionadas por un `IndexedStack`: inicio, seguimientos, incidencias y chat. El `IndexedStack` mantiene todos los hijos montados en memoria aunque no estén visibles, lo que preserva el estado de scroll y evita recargar datos al cambiar de pestaña. Esto es especialmente relevante en la pestaña de seguimientos, que contiene la lista completa de partes del alumno con su barra de progreso de horas.

La pestaña de incidencias permite reportar un problema directamente desde la aplicación mediante un `ModalBottomSheet`. El formulario incluye un selector de tipo de incidencia (acceso, ausencia, comportamiento, accidente u otros) y un campo de texto libre con validación de longitud mínima en cliente. Al confirmarlo, la petición llega al backend, que vincula la incidencia a la práctica activa del alumno usando su identidad del token JWT, devuelve la incidencia creada y la lista se actualiza de inmediato.

La cuarta pestaña muestra una pantalla informativa que anuncia la función de chat en tiempo real prevista para el siguiente hito. Esta decisión de incluir un placeholder visible en la demo cumple dos propósitos: comunica al evaluador que la arquitectura de navegación está completa y anticipa la integración del módulo de mensajería con WebSocket.

## BLOQUE — Hito 3: Seguridad OWASP aplicada al backend y al cliente Flutter
**Sección destino en memoria**: Capítulo 4.2 (Seguridad) o nuevo apartado dentro del capítulo de arquitectura
**Estado**: [PENDIENTE DE INTEGRAR]

Durante el desarrollo del tercer hito realicé una revisión sistemática de seguridad siguiendo el estándar OWASP Top 10 (2021). El objetivo era identificar y corregir vulnerabilidades antes de la entrega, no como un paso posterior al desarrollo sino como parte del proceso. A continuación describo las decisiones más relevantes.

La primera categoría revisada fue el control de acceso (A01). Detecté que varios controladores REST usaban la anotación `@CrossOrigin(origins = "*")`, que permite peticiones desde cualquier origen. Esto es especialmente problemático en una API con autenticación, porque anula la protección que CORS ofrece. La solución fue eliminar estas anotaciones y centralizar la configuración CORS en `SecurityConfig`, especificando solo los orígenes permitidos (`localhost:3000` y `localhost:8080`) y activando el soporte de credenciales. También corregí dos expresiones SpEL en `@PreAuthorize` que referenciaban `.principal.id`, una propiedad inexistente sobre el objeto `UserDetails` de Spring Security. Las sustituí por llamadas a métodos de servicio que comprueban si el usuario autenticado es participante de la práctica solicitada, una verificación de propiedad real que previene el acceso entre recursos de distintos alumnos.

En la categoría de fallos criptográficos (A02) encontré que el método de firma de JWT usaba `secret.getBytes()` para obtener la clave de firma a partir del secreto configurado en las variables de entorno. Este secreto es una cadena en Base64, por lo que `getBytes()` trata los caracteres Base64 literales como bytes de la clave, no los bytes reales que representan. La corrección es usar `Decoders.BASE64.decode(secret)`, que decodifica correctamente la cadena y obtiene los bytes reales. La consecuencia práctica es que los tokens generados con el método antiguo son incompatibles con los generados con el método correcto, lo que obligó a invalidar las sesiones existentes durante el despliegue del fix.

Para la categoría de diseño inseguro (A04) implementé un filtro de rate limiting sobre los endpoints de autenticación. El filtro, registrado con prioridad máxima en la cadena de filtros, mantiene un contador por dirección IP dentro de una ventana deslizante de un minuto. Al superar las diez peticiones, el servidor devuelve HTTP 429 con un mensaje JSON. Este límite protege contra ataques de fuerza bruta sin requerir dependencias externas, usando solo las estructuras concurrentes de la biblioteca estándar de Java.

En el apartado de fallos de autenticación (A07) identifiqué un problema de enumeración de cuentas. El endpoint de registro lanzaba mensajes de error distintos según si el campo que ya existía era el email o el DNI, permitiendo a un atacante determinar qué datos de una persona están registrados en el sistema. La corrección fue unificar la comprobación de unicidad y lanzar siempre el mismo mensaje genérico, sin revelar qué campo causó el conflicto. El endpoint de login también se corrigió para no exponer si un email existe en el sistema cuando las credenciales son incorrectas.

Finalmente, en el apartado de registro y monitorización (A09) añadí logs estructurados para los eventos de seguridad más relevantes: intentos de login fallidos (registrando IP y User-Agent, sin datos personales), accesos denegados y cambios de estado en los seguimientos. Estos registros permiten detectar patrones de ataque en producción sin comprometer la privacidad de los usuarios.

Como resultado de esta revisión, el sistema cuenta ahora con una batería de treinta y cinco tests automatizados que verifican el comportamiento correcto de cada control de seguridad implementado, incluyendo tests de cabeceras HTTP, comportamiento CORS, rate limiting, enumeración de cuentas y verificación de propiedad de recursos.

---

## BLOQUE — Hito 3: Seguridad OWASP Bloque 2 — logout server-side, validación de entradas y auditoría de dependencias
**Sección destino en memoria**: Capítulo 4.2 (Seguridad) — ampliar el apartado existente
**Estado**: [PENDIENTE DE INTEGRAR]

En una segunda iteración de seguridad apliqué cuatro mejoras adicionales que complementan las implementadas en el Bloque 1.

La primera mejora afecta a la validación de entradas (A03). El método `cambiarEstado()` de `PracticaServiceImpl` aceptaba cualquier cadena de texto como nuevo estado de una práctica. Aunque los estados son un concepto cerrado del dominio (`BORRADOR`, `ACTIVA`, `FINALIZADA`), no existía ninguna comprobación que impidiese valores arbitrarios como `"ELIMINADA"` o `"ADMIN"`. La corrección fue introducir un `Set.of()` inmutable con los valores permitidos y lanzar `BusinessRuleException` si el valor recibido no pertenece al conjunto. Este patrón evita la inyección de estados incoherentes sin necesidad de convertir el campo a un enum Java, que requeriría una migración de esquema.

La segunda mejora cierra un hueco importante en la gestión de sesiones (A07). Hasta este punto, el logout era puramente local: eliminar el token del almacenamiento seguro del dispositivo. Sin embargo, si un atacante hubiera obtenido el token durante la sesión, seguía siendo válido hasta su expiración natural (24 horas). Para invalidar tokens de forma inmediata implementé una blacklist de identificadores de token en el servidor. Cada JWT generado incluye ahora un claim `jti` (JWT ID) con un UUID único. Al hacer logout, el servidor registra ese `jti` en un `ConcurrentHashMap` en memoria. El filtro de autenticación verifica la blacklist antes de aceptar cualquier token. La desventaja conocida y aceptada para el contexto del TFG es que la blacklist no persiste entre reinicios del servidor; en producción se sustituiría por Redis con TTL. En el cliente Flutter, `AuthService.logout()` llama primero a `POST /auth/logout` para revocar el token en el servidor y solo entonces elimina el almacenamiento local, garantizando que ambos lados queden limpios incluso si la conexión falla (el bloque `finally` garantiza la limpieza local).

La tercera mejora refuerza la política de contraseñas (A02). Los usuarios de prueba creados en la migración V3 tenían contraseñas débiles de seis caracteres. Dado que Flyway no permite modificar migraciones ya aplicadas sin romper el historial, apliqué la corrección en una nueva migración V6 que actualiza los hashes BCrypt directamente. Las nuevas contraseñas cumplen la política OWASP de doce caracteres mínimo con mayúscula, minúscula, número y símbolo.

La cuarta mejora es la incorporación del plugin `dependency-check-maven` de OWASP (A06), que analiza las dependencias del proyecto en busca de vulnerabilidades conocidas (CVE). La configuración establecida falla el build si se detecta alguna con puntuación CVSS mayor o igual a 7, equivalente a severidad alta o crítica, y genera informes en formato HTML y JSON para su revisión.

---

## BLOQUE 004 — [RESERVADO para Hito 3]
**Sección destino en memoria**: Capítulo 5 (Incidencias y Chat)
**Estado**: [PENDIENTE — se generará al completar las features]

> Este bloque se completará cuando se implementen el chat y la doble validación de seguimientos.
> Incluirá la explicación del protocolo WebSocket/STOMP para el chat en tiempo real.

---

## GUÍA DE ESTILO PARA NUEVOS BLOQUES

Cuando Claude Code genere un nuevo bloque, seguirá estas reglas para mantener
coherencia con la memoria existente:

- Primera persona del singular ("he implementado", "he decidido", "he optado").
- Tono académico pero cercano, sin tecnicismos innecesarios.
- Cada decisión técnica va acompañada de su justificación ("elegí X porque Y").
- Longitud: entre 150 y 400 palabras por bloque, según la complejidad de la feature.
- No usar bullet points en los fragmentos para la memoria; usar párrafos fluidos.
- Los nombres de tecnologías, clases y métodos van en `código` o en cursiva.

---

## BLOQUE 003 — Hito 3: Diseño visual y lógica de doble validación
**Sección destino en memoria**: Capítulo 4.1 (Backend — decisiones de diseño) + Capítulo 5 (Interfaz)
**Estado**: [PENDIENTE DE INTEGRAR — redactar cuando esté implementado]

### Para el capítulo de arquitectura (4.1)

Durante el desarrollo del tercer hito identifiqué un problema de lógica en el flujo de validación
de seguimientos. El diseño inicial contemplaba una validación única por parte de cualquier tutor,
pero al analizar cómo funciona la gestión de prácticas en la realidad, quedó claro que existen
dos figuras con responsabilidades completamente distintas.

El tutor de empresa es quien sabe realmente qué ha hecho el alumno durante la semana. En el
proceso actual en papel, es esta persona quien firma el parte semanal de horas. Por tanto, la
validación del trabajo real corresponde exclusivamente a este rol. El tutor del centro, por su
parte, tiene una función supervisora de carácter académico: se asegura de que el alumno progresa
adecuadamente, gestiona cualquier conflicto o problema que pueda surgir, y da el visto bueno final
desde el punto de vista formativo.

Para reflejar esta distinción en el sistema, rediseñé el campo de estado de los seguimientos
para que contemple cuatro valores: PENDIENTE_EMPRESA (el alumno ha registrado el parte y espera
la firma de la empresa), PENDIENTE_CENTRO (la empresa ha validado y el centro puede revisar),
COMPLETADO (ambas partes han dado su visto bueno y las horas se contabilizan) y RECHAZADO.

El caso del rechazo merece una mención especial. Si el tutor de empresa rechaza un parte, el
sistema genera automáticamente una incidencia vinculada a esa práctica, visible para el tutor
del centro. Esta decisión de diseño responde a una realidad que puede darse en la práctica: un
rechazo puede ser consecuencia de un error del alumno, pero también puede indicar un problema
más serio con la empresa. Que el tutor del centro lo vea de forma automática, sin que el alumno
tenga que reportarlo por separado, añade una capa de protección al estudiante.

### Para el capítulo de interfaz (5)

El sistema de diseño visual de Nexus parte de una filosofía de claridad funcional: el color
comunica estado, no decora. Cada elemento visual tiene un significado concreto que el usuario
aprende una vez y reconoce en toda la aplicación. El azul indica acciones y estado activo, el
verde señala que algo ha sido validado correctamente, el ámbar advierte de que hay algo pendiente
de atención, y el rojo alerta sobre incidencias o rechazos.

Para garantizar la coherencia visual en toda la aplicación, centralicé todos los colores,
tamaños y estilos en un único archivo de tema, app_theme.dart. Ninguna pantalla define colores
directamente; todas importan desde este archivo. Esto facilita el mantenimiento: si en el futuro
se decide cambiar el tono de azul de la marca, basta con modificar un único valor.

La aplicación está diseñada para funcionar correctamente tanto en web como en dispositivos
móviles desde la misma base de código Flutter. En pantallas anchas (web, tablet) la navegación
se presenta como una barra lateral de iconos a la izquierda, siguiendo el patrón de herramientas
profesionales como Notion o Linear. En pantallas estrechas (móvil) la navegación migra
automáticamente a una barra inferior, que es el patrón estándar en aplicaciones móviles. Este
comportamiento adaptativo se gestiona con el widget LayoutBuilder de Flutter, que detecta el
ancho disponible y elige el componente de navegación adecuado.

---

## BLOQUE 004 — Decisión de rediseño: detección de error de lógica en validación
**Sección destino en memoria**: Capítulo 7 (Planificación) o nuevo apartado 4.2 (Decisiones de rediseño)
**Estado**: [LISTO PARA INTEGRAR — este bloque no depende de implementación, ocurrió durante el análisis]

### Texto para la memoria

Durante la fase de implementación del módulo de seguimientos detecté un problema de lógica en
el diseño original del sistema. El modelo inicial contemplaba una única figura de tutor con
capacidad de validar los partes semanales del alumno, sin distinguir entre el tutor del centro
educativo y el tutor de la empresa. Al revisar el flujo en detalle, identifiqué que esta
simplificación no reflejaba la realidad del proceso de prácticas.

En la gestión actual de las FCT existen dos figuras con responsabilidades radicalmente distintas.
El tutor de empresa es la persona que trabaja codo a codo con el alumno y sabe con exactitud
qué tareas ha realizado, cuántas horas ha dedicado y si el trabajo se ha hecho correctamente.
Es quien firma el parte semanal en papel hoy en día. El tutor del centro, en cambio, no tiene
visibilidad directa sobre el trabajo diario del alumno en la empresa; su función es supervisar
que el proceso formativo va bien, resolver conflictos si los hay, y garantizar que los objetivos
académicos del ciclo se están cumpliendo.

Diseñar el sistema con una validación única mezclaba estas dos responsabilidades en una sola
acción, lo cual habría resultado en una herramienta que no se corresponde con el proceso real
que pretende digitalizar. Un tutor del centro validando directamente el trabajo de un alumno
en una empresa que no conoce en detalle no tiene sentido; igualmente, un tutor de empresa
tomando decisiones sobre el cumplimiento académico excede su rol.

El rediseño establece un flujo de doble validación en cascada. Primero actúa el tutor de
empresa, que confirma o rechaza el trabajo registrado por el alumno, replicando digitalmente
la firma semanal en papel. Solo después de esa confirmación, el tutor del centro puede dar
el visto bueno final desde la perspectiva académica. Este orden no es opcional: el sistema
lo impone a nivel de lógica de negocio en el servicio, devolviendo un error si alguien
intenta saltarse la secuencia.

Un aspecto especialmente relevante del rediseño fue el tratamiento de los rechazos. Cuando
el tutor de empresa rechaza un parte, el sistema genera automáticamente una incidencia
vinculada a esa práctica, que el tutor del centro recibe sin que el alumno tenga que hacer
nada. Esta decisión responde a que un rechazo puede tener causas muy distintas: desde un
simple error del alumno al registrar las horas hasta una situación problemática con la empresa,
como la asignación de tareas que no corresponden al perfil del ciclo. En cualquier caso, el
tutor del centro debe estar informado, y hacerlo de forma automática elimina la dependencia
de que el alumno lo reporte manualmente, algo que en la práctica real no siempre ocurre.

Este proceso de detección y corrección del error de lógica es un ejemplo del valor de revisar
críticamente el diseño antes de implementar. El coste de hacer este cambio en la fase de
análisis es mínimo: actualizar los estados en la base de datos, separar un método de servicio
en dos, y añadir la lógica de creación automática de incidencias. El mismo cambio aplicado
tras haber construido el frontend completo habría supuesto rehacer todas las pantallas de
validación y modificar el contrato de la API, con el consiguiente impacto en los tests y en
la documentación.

---

## REGISTRO DE CAMBIOS DE DISEÑO
> Esta sección documenta los cambios de diseño detectados durante el desarrollo.
> El tutor valora especialmente que estos cambios estén justificados y registrados.

### Cambio 001 — Validación de seguimientos (18/04/2025)

**Problema detectado**: El flujo original tenía una validación única por cualquier tutor,
sin distinguir entre tutor de empresa y tutor de centro.

**Por qué es un error**: Mezcla dos responsabilidades distintas en una sola acción. El tutor
de empresa valida el trabajo real (sabe lo que hace el alumno). El tutor del centro supervisa
lo académico (no tiene visibilidad directa del trabajo diario). Son roles diferentes y el
sistema debe reflejarlo.

**Solución aplicada**: Flujo de doble validación en cascada con cuatro estados:
- `PENDIENTE_EMPRESA` — alumno registró, espera firma empresa
- `PENDIENTE_CENTRO` — empresa validó, espera visto bueno del centro
- `COMPLETADO` — ambos validaron, horas contabilizadas
- `RECHAZADO` — empresa rechazó, genera incidencia automática

**Impacto en el código**:
- Migración Flyway V4: actualizar enum de estados en tabla `seguimientos`
- `SeguimientoServiceImpl`: separar `validar()` en `validarEmpresa()` y `validarCentro()`
- `SeguimientoController`: dos endpoints con `@PreAuthorize` diferente
- `IncidenciaService`: lógica de creación automática al rechazar
- Tests: cuatro casos de negocio nuevos obligatorios

**Decisión adicional**: El rechazo genera incidencia automática visible para el tutor del centro,
sin que el alumno tenga que reportarla. Protege al alumno en situaciones donde la empresa puede
estar actuando incorrectamente.

**Momento de detección**: Durante análisis del flujo de implementación, antes de escribir código.
Coste del cambio en este momento: bajo. Coste si se hubiera detectado tras implementar el frontend: alto.

---

## [PENDIENTE DE INTEGRAR] — Hito 3: Doble Validación y Paneles de Tutor (26/04/2026)

### Bloque: Implementación del flujo de doble validación de seguimientos

En el Hito 3 se implementó el mecanismo de doble validación para los partes de seguimiento semanales, que constituye el núcleo funcional del proceso de supervisión de prácticas en el sistema real.

El flujo parte de una decisión de diseño tomada durante el análisis: en las FCT reales existen dos actos de validación conceptualmente distintos. El tutor de empresa certifica que el trabajo descrito en el parte es real y se ha realizado correctamente en la empresa. El tutor del centro, por su parte, valida que ese trabajo encaja con los objetivos formativos del ciclo. Tratar ambas validaciones como una sola —como hacía el sistema anterior— perdía esta distinción fundamental.

La implementación refleja esta realidad mediante cuatro estados posibles para cada parte: `PENDIENTE_EMPRESA` (alumno ha registrado el parte, espera al tutor de empresa), `PENDIENTE_CENTRO` (tutor de empresa ha dado su visto bueno, espera la validación académica del centro), `COMPLETADO` (ambas validaciones realizadas, horas contabilizadas en el progreso del alumno) y `RECHAZADO` (tutor de empresa ha rechazado el parte indicando el motivo).

Un aspecto especialmente relevante desde el punto de vista de la calidad del sistema es la creación automática de incidencias al rechazar un parte. Cuando el tutor de empresa rechaza, el servicio `SeguimientoServiceImpl` crea automáticamente una entidad `Incidencia` de tipo `RECHAZO_PARTE` vinculada a la práctica. Esta automatización protege al alumno: el tutor del centro queda informado del rechazo sin que el alumno tenga que reportarlo manualmente, y sin que el tutor de empresa necesite conocer la existencia del módulo de incidencias.

La separación de responsabilidades entre los dos métodos `validarEmpresa()` y `validarCentro()` garantiza la regla de negocio principal: ningún tutor del centro puede actuar sobre un parte que no haya pasado primero por el tutor de empresa. Esta invariante se verifica en el propio servicio, no en el controlador, siguiendo el principio de que las reglas de negocio no deben filtrarse hacia las capas de presentación.

Se añadieron cinco tests de integración que cubren los cuatro casos de negocio críticos: registro con estado inicial correcto, aprobación por tutor de empresa, rechazo con generación automática de incidencia, e intento de saltarse el orden por parte del tutor del centro. El quinto test verifica el flujo completo de extremo a extremo.

### Bloque: Arquitectura de pantallas para los roles de tutor

En paralelo al backend, se implementaron las pantallas Flutter para los dos roles de supervisión, siguiendo el sistema de diseño Nexus establecido en iteraciones anteriores.

La pantalla del tutor de empresa (`PanelTutorEmpresaScreen`) sigue una filosofía minimalista acorde con el rol: su única función es firmar partes. La interfaz muestra tres métricas en la cabecera (partes pendientes, partes procesados, horas acumuladas) y la lista de partes pendientes, cada uno con la descripción del alumno en formato de cita y dos acciones bien diferenciadas visualmente. El rechazo abre un bottom sheet que exige motivo obligatorio antes de confirmar.

La pantalla del tutor del centro (`PanelTutorCentroScreen`) responde a un rol más complejo mediante un layout de tres columnas en web: una barra lateral de iconos funcionales, una lista de alumnos con indicadores de estado, y un panel de detalle del alumno seleccionado. La barra lateral tiene cuatro modos: vista de alumno individual (con su progreso FCT, partes pendientes e incidencias abiertas), vista global de todos los partes pendientes, vista de incidencias agrupadas por estado, y placeholder de chat para el Hito 4. En dispositivos móviles se adapta a un patrón de navegación inferior con las mismas cuatro secciones.

La barra de progreso FCT en el panel de detalle es un indicador clave para el tutor del centro: muestra en todo momento cuántas horas ha completado el alumno del total acordado en la práctica, permitiendo detectar retrasos antes de que se conviertan en un problema.

---

## BLOQUE — Módulo de ausencias: origen, diseño e implementación
**Sección destino en memoria**: Capítulo 4.1 (Backend — módulos funcionales) + Capítulo 5 (Interfaz)
**Estado**: [PENDIENTE DE INTEGRAR]

### Para el capítulo del Backend (4.1)

La implementación del módulo de ausencias surgió a raíz de una observación del tutor durante el seguimiento académico del proyecto: al revisar las funcionalidades del sistema, se preguntó si la plataforma gestionaba también las ausencias de los alumnos durante el periodo de prácticas. La ausencia es un evento diferente al seguimiento semanal: no describe trabajo realizado, sino una falta documentada que requiere justificación formal y que puede tener consecuencias sobre el cómputo total de horas del alumno. Ninguno de los módulos existentes capturaba este concepto de forma explícita.

Para no mezclar semánticas distintas en la misma entidad, diseñé una tabla independiente `ausencias` mediante la migración Flyway V8. La decisión de usar una tabla propia, en lugar de añadir un flag `esAusencia` a la tabla de seguimientos, responde a una razón de diseño de datos: una ausencia no tiene horas realizadas, no tiene descripción de tareas y tiene un campo que los seguimientos no tienen —un fichero adjunto de justificante—. Mezclar ambos conceptos en una sola tabla habría generado columnas nulas obligatorias, señal clara de un modelo incorrecto.

El flujo de estados es más sencillo que el de los seguimientos. El alumno registra la ausencia indicando la fecha y el motivo, y el estado queda en `PENDIENTE`. El tutor de empresa es quien revisa la justificación y la marca como `JUSTIFICADA` o `INJUSTIFICADA`, pudiendo añadir un comentario. Esta asignación de roles responde a la lógica del proceso real: es el tutor de empresa quien sabe con certeza si el alumno estuvo o no presente en el centro de trabajo y si la causa fue legítima. La decisión de a quién corresponde revisar las ausencias surgió durante el análisis del flujo, tras descartar inicialmente asignarla al tutor del centro, que no tiene visibilidad directa del día a día en la empresa.

El tutor del centro tiene acceso de solo lectura a las ausencias marcadas como injustificadas. Cuando el tutor de empresa marca una ausencia como injustificada, esta aparece automáticamente en el panel del tutor del centro como una alerta informativa, sin que el alumno tenga que comunicarlo por separado. Esta decisión es coherente con la responsabilidad académica del tutor del centro: una falta injustificada puede tener implicaciones sobre la calificación final del alumno o requerir una comunicación con la familia, y el sistema garantiza que esta información llegue al canal correcto de forma automática.

El sistema permite adjuntar un fichero justificante (partes médicos, comunicados oficiales) en formatos PDF, JPG o PNG con un tamaño máximo de 5 MB. El fichero se almacena como `bytea` en PostgreSQL, vinculado directamente al registro de la ausencia, evitando la complejidad de gestionar un sistema de ficheros externo para el alcance de este proyecto. La respuesta JSON incluye un campo `tieneJustificante` de tipo booleano: el cliente puede saber si existe un justificante sin necesidad de descargar los bytes hasta que el usuario lo solicite. Para la descarga, se implementó un endpoint `GET /ausencias/{id}/justificante` que devuelve los bytes con el `Content-Type` original del fichero, de modo que el navegador puede abrirlo directamente en una nueva pestaña.

Desde el punto de vista de la seguridad, el servicio aplica dos controles adicionales. El primero es una verificación de propiedad: el alumno solo puede registrar ausencias en prácticas que le pertenecen, previniendo la manipulación de registros ajenos. El segundo es un control de duplicados por fecha: no puede existir más de una ausencia registrada para la misma práctica y la misma fecha, evitando entradas redundantes en el historial. Adicionalmente, el método de revisión verifica que el tutor de empresa solo pueda actuar sobre ausencias de las prácticas que supervisa directamente, cerrando un vector de acceso indebido entre tutores de distintas empresas.

### Para el capítulo del Frontend (5 — Interfaz de cada rol)

En el cliente Flutter se añadió una pestaña dedicada de Ausencias al dashboard del alumno, accesible tanto desde el `NavigationRail` lateral (web y tablet) como desde el `BottomNavigationBar` inferior (móvil). La pantalla muestra la lista de ausencias ordenada por fecha descendente. Cada elemento indica su estado mediante el código de color del sistema de diseño Nexus: ámbar para las pendientes de revisión, verde para las justificadas y rojo para las injustificadas. Si el alumno tiene un fichero adjunto, se muestra el nombre del archivo bajo el motivo, y puede eliminarlo siempre que la ausencia siga pendiente.

El formulario de registro, presentado como un `BottomSheet`, incluye un selector de fecha con calendario nativo de Flutter limitado a fechas pasadas o presentes, alineando la validación del cliente con la anotación `@PastOrPresent` del backend. El motivo requiere un mínimo de diez caracteres. La opción de adjuntar un justificante está disponible ya en el momento del registro, usando el paquete `file_picker` para seleccionar un fichero del dispositivo. Si el alumno no lo adjunta al registrar, puede hacerlo después desde la lista, usando el botón Adjuntar que aparece en las ausencias pendientes sin justificante.

En el panel del tutor de empresa se añadió una sección específica para ausencias pendientes, separada visualmente de la sección de partes de seguimiento. Cada tarjeta de ausencia muestra el alumno, la fecha, el motivo y un badge verde con el texto Ver justificante si existe un fichero adjunto. Al pulsar ese badge, la aplicación descarga los bytes mediante una petición autenticada con Dio y los abre en una nueva pestaña del navegador usando una URL de objeto Blob de la API del navegador, sin exponer el token JWT en la barra de direcciones. Los botones de acción permiten marcar la ausencia como Justificada o Injustificada, con confirmación previa mediante un diálogo.

En el panel del tutor del centro, las ausencias injustificadas de cada alumno aparecen como una sección de solo lectura en el panel de detalle individual, debajo de las incidencias abiertas. El nombre del alumno en la lista lateral muestra un badge rojo cuyo número suma tanto las incidencias abiertas como las ausencias injustificadas, de modo que el tutor puede detectar de un vistazo qué alumnos requieren su atención sin tener que abrir cada ficha.

---

## BLOQUE — OWASP Bloque 3: hardening final de entradas y configuración
**Sección destino en memoria**: Capítulo 4.2 (Seguridad) — ampliar con el tercer y último bloque de mejoras
**Estado**: [PENDIENTE DE INTEGRAR]

En una tercera y última iteración de seguridad antes de la entrega del Hito 3 apliqué las mejoras restantes identificadas en el plan de seguridad OWASP.

La primera mejora refuerza la política de contraseñas en el registro de nuevos usuarios (A02). El validador `@Pattern` añadido sobre el campo `password` del DTO de registro impone que toda contraseña nueva cumpla cuatro requisitos simultáneamente: al menos una letra mayúscula, al menos una minúscula, al menos un dígito y al menos un carácter especial, con un mínimo de diez caracteres. Este patrón es más estricto que el mínimo de ocho caracteres que existía anteriormente y está en línea con las recomendaciones del NIST para contraseñas de aplicaciones de gestión académica. La validación actúa en la capa de entrada, antes de que la contraseña llegue al servicio o sea procesada por BCrypt.

La segunda mejora cierra un vector de abuso en el módulo de seguimientos (A04). El servicio comprueba ahora si ya existe un parte del alumno en estado `PENDIENTE_EMPRESA` para la misma semana ISO (de lunes a domingo) antes de permitir el registro de uno nuevo. Esta restricción replica la lógica del proceso real: un alumno entrega un único parte semanal, no partes diarios. Sin este control, un alumno podría acumular múltiples partes pendientes en la misma semana, sobrecargando a los tutores con validaciones redundantes y generando inconsistencias en el cómputo de horas.

La tercera mejora añade las cabeceras de seguridad HTTP que faltaban en el servidor Nginx del frontend (A05). Las cabeceras `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin` y una `Content-Security-Policy` restringida protegen al navegador del usuario frente a ataques de clickjacking, MIME sniffing y ejecución de recursos de terceros no autorizados. Estas cabeceras complementan las que ya estaban configuradas en Spring Security para las respuestas de la API, completando la cobertura tanto en las peticiones a la API como en la carga de la aplicación web.

Finalmente, se establecieron límites de tamaño de petición en la configuración de Spring Boot: 5 MB para peticiones multipart (ficheros adjuntos) y 1 MB para formularios, previniendo ataques de denegación de servicio por peticiones masivas.
