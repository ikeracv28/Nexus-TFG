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

Para el módulo de incidencias se implementó un primer nivel de consulta que permite listar y
visualizar las incidencias de una práctica. En el tercer hito este módulo se ampliará con la
capacidad de reportar nuevas incidencias desde la aplicación y gestionarlas por parte del
tutor del centro.

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

## BLOQUE 003 — [RESERVADO para Hito 3]
**Sección destino en memoria**: Capítulo 5 (Incidencias y Chat)
**Estado**: [PENDIENTE — se generará al completar las features]

> Este bloque se completará cuando se implementen los módulos de incidencias y chat.
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
