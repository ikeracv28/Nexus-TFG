Hola Iker Acevedo Donate,

Te envío el feedback de tu entrega del 75% de tu TFG TFG - Iker Acevedo Donate.

Valoración: Excelente

Observaciones del tutor:

Hola Iker,

He revisado tu 3ª entrega del TFG y te dejo el feedback por escrito. Tengo varias cosas muy buenas que reconocerte y un par de pulidos pendientes para llegar bien al Hito 4.

Valoración general — trabajo excepcional
Te lo digo directo: es probablemente el salto cualitativo más grande que he visto entre dos hitos del TFG. En la 1ª entrega tenías un frontend Flutter vacío (flutter create sin tocar), tres entidades JPA fantasma, JWT inseguro y @CrossOrigin("*"). Ahora tienes un sistema funcional con Docker Compose orquestando 3 servicios, frontend Flutter implementado con 6 providers y 10 pantallas, chat WebSocket en tiempo real, módulo de ausencias con adjuntos, panel admin, sistema de auditoría, doble validación de seguimientos, rate limiting, JWT blacklist...

Has cumplido el 100% de las recomendaciones críticas y graves de la 1ª entrega, y la práctica totalidad de las mejorables. Es un nivel de aplicación de feedback inusualmente alto.

Verificación de las recomendaciones de la 1ª entrega
Críticos — todos aplicados ✅
✅ Credenciales BD a variables de entorno (${DB_HOST}, ${DB_USER}, ${DB_PASSWORD})
✅ JWT Secret a variable de entorno con Docker Compose que exige JWT_SECRET (no arranca sin él) y decodificación Base64 correcta
✅ JWT incluye los roles + jti único por token
✅ Autorización por roles con @EnableMethodSecurity y SpEL avanzado: @practicaService.esParticipante(#id, authentication.name)
✅ CORS centralizado sin wildcard
Graves — todos aplicados ✅
✅ Las 3 entidades JPA faltantes (Incidencia, Mensaje, Notificacion) ahora existen
✅ Dockerfile multi-etapa con Maven 3.9.6 + Eclipse Temurin 21, usuario non-root, JVM tunada para contenedores
✅ Docker Compose con ruta correcta + healthcheck + depends_on: condition: service_healthy
✅ Migraciones unificadas (mantienes BBDD-TFG.sql con cabecera "REFERENCIA HISTÓRICA — la única fuente de verdad es Flyway" — solución correcta)
✅ UsuarioMapper con @Mapping(target = "passwordHash", ignore = true) y comentario explícito
✅ NPE potencial corregido con expression = "..." defensivo
✅ Excepciones tipadas (BusinessRuleException, ResourceNotFoundException) con handlers específicos (404, 409, 401, 403)
✅ Frontend Flutter implementación real con 6 providers, 10 pantallas, sistema de diseño propio, GoRouter, Dio con interceptores JWT, cliente WebSocket/STOMP
Mejorables — todos aplicados ✅
✅ @Data reemplazado por @Getter @Setter @EqualsAndHashCode(of = "id") @NoArgsConstructor @AllArgsConstructor @Builder
✅ Paginación con Page<T> y @PageableDefault
✅ Perfiles application-dev.properties y application-prod.properties
✅ 121 tests en 18 clases (antes 4)
✅ Diagramas enlazados (ERD_DATABASE.md, UML_CLASS_DIAGRAM.md)
Cosas que me han llamado especialmente la atención
PLAN_SEGURIDAD_OWASP.md con bitácora trazable
Has llevado un documento donde cada vulnerabilidad del Top 10 OWASP está marcada con [x] + archivo + línea + fecha de corrección. Es inusual encontrar este nivel de rigor en un TFG de DAM. En la defensa te recomiendo destacarlo: muestra trabajo metódico y profesional.

Tests con trazabilidad OWASP
A01AccessControlTest, JwtUtilsOwaspTest, SecurityHeadersAndCorsTest, AuthServiceOwaspTest, PracticaOwnershipTest, SeguimientoDoubleValidationTest. Cada test tiene @DisplayName("[A01] ..."), [A02], [A04], [A05], [A07] correlacionando con el plan. La cobertura del SpEL crítico (PracticaOwnershipTest con 10 tests cubriendo todos los caminos de la regla de propiedad) es excelente.

Detalle técnico avanzado: AuditService con @Transactional(propagation = REQUIRES_NEW)
Para que el log de auditoría se persista incluso si la transacción principal hace rollback. Es una decisión correcta y documentada que demuestra entendimiento real de transacciones JPA. Pocos alumnos llegan a este nivel.

Documentación operativa de calidad
USUARIOS_PRUEBA.md con cuentas demo y prácticas de demostración con estados variados
Sección "Tests" del README con tabla por área
decisiones_tecnicas.md y guia_estudiante.md en bitácora interna
Frontend Flutter real
flutter_secure_storage para JWT (no SharedPreferences inseguro), go_router 13.2.0 declarativo, sistema de diseño propio (NexusColors, NexusText, NexusSizes), Dio con interceptores que inyectan el JWT y manejan refresh, recuperarSesion() consumiendo GET /auth/me para no pedir login si el token sigue válido. Es integración real.

Lo que tienes que pulir antes del Hito 4
No tienes problemas críticos abiertos, pero hay 4 puntos importantes:

1. Notificacion modelada pero no integrada operativamente
Tu entidad Notificacion.java existe y la tabla está en V1, pero no hay NotificacionController, NotificacionService ni NotificacionRepository. Tu README declara "Notificación inmediata al tutor del centro sin intervención del alumno" — esto es semi-cierto: el rechazo de seguimiento sí crea automáticamente una Incidencia, pero el sistema de notificaciones tipo bell-icon que la entidad sugiere no está implementado.

Para el Hito 4, dos opciones:

Implementar el módulo (vía WebSocket sería natural — ya tienes la infra montada): /topic/notificaciones/{usuarioId}
Quitarlo del alcance y dejarlo claro en la documentación
2. Autorización a nivel de SUSCRIPCIÓN WebSocket no implementada
Esto es lo más urgente del módulo de chat:

Tu escritura de mensajes está protegida (MensajeService.guardar() valida esParticipante)
Pero la suscripción al canal NO se valida. Un usuario podría suscribirse a /topic/practica/{otroId} y ver mensajes ajenos en tiempo real (aunque no podría escribir)
El SimpleBroker de Spring no aplica autorización por defecto a las suscripciones. Hay que añadir un ChannelInterceptor que examine los frames SUBSCRIBE y compruebe esParticipante antes de permitir la suscripción.

3. MensajeServiceImpl.listarPorPractica no comprueba pertenencia
El endpoint HTTP GET /mensajes/practica/{id} deja pasar a cualquier usuario con uno de los 4 roles, sin comprobar que sea participante de esa práctica concreta. Hoy un alumno con rol ROLE_ALUMNO puede leer el historial de chats de prácticas ajenas vía HTTP. Aplica la misma comprobación que ya tiene SeguimientoServiceImpl.listarPorPractica.

4. Migración V11 corrige error de la V10
V11__Fix_Mensajes_Schema.sql renombra emisor_id → remitente_id y elimina leido porque la V10 creó un esquema que no coincidía con la entidad. Es anti-patrón Flyway: en un entorno de desarrollo se debería rebobinar la V10 antes de la entrega. Funcionalmente está bien, pero estéticamente queda como "parche". Mencionable en defensa.

Mejoras menores
WebSocketAuthInterceptor solo captura Exception ignored. Si el token es inválido, no rechaza la conexión — solo no asigna principal. Mejor: rechazar con frame ERROR
application-prod.properties casi igual a application.properties: solo cambia logging. Faltarían SSL forzado a Postgres, HikariCP tuneado, deshabilitar Actuator endpoints sensibles
JwtAuthenticationFilter carga UserDetails de BD en cada petición: sería más eficiente reconstruir desde el claim roles del token
RateLimitFilter y TokenBlacklistService son in-memory: si escala a varias instancias, cada una tendría su contador. Producción real necesita Redis. Aceptable para TFG, mencionable en defensa
V7 usa crypt() y gen_salt('bf', 10) sin declarar CREATE EXTENSION IF NOT EXISTS pgcrypto: funciona porque postgres:15-alpine la trae activada, pero es dependencia implícita. Añade el CREATE EXTENSION explícitamente
Frontend mensaje_service.dart construye frames STOMP a mano: la librería stomp_dart_client lo simplificaría
ws://localhost:8080/ws hardcoded en frontend: debería leerse de API_BASE_URL
SeguimientoController.validarEmpresa acepta nuevoEstado como String: tu propio plan OWASP marca como pendiente crear enum EstadoSeguimiento. Bien identificado, ahora hay que cerrarlo
Pequeñas tareas pendientes del plan OWASP marcadas con [ ]: HTTPS en Nginx (al menos como nota de despliegue), generar el secret JWT con openssl rand -base64 64
Lo que está muy bien (sigue por aquí)
Patrón Service + Impl con inyección por constructor
Excepciones de dominio tipadas con handlers específicos sin filtrar información
@PreAuthorize con SpEL avanzado para control de propiedad fino
AuditService con REQUIRES_NEW para que la auditoría sobreviva a rollbacks
Logger estructurado listo para parser tipo Logstash
MapStruct correctamente integrado
Plugin OWASP Dependency-Check con failBuildOnCVSS=7
JaCoCo configurado
JWT con jti único, blacklist, rate limiting con ventana deslizante atómica
Validación de complejidad de contraseña con regex
Mensaje genérico anti-enumeración en registro/login
Sanitización de Content-Disposition en descarga (previene header injection)
Validación MIME-type whitelist + límite de 5 MB en adjuntos
Headers de seguridad (X-Frame-Options: DENY, nosniff, HSTS, X-XSS-Protection)
Doble validación de seguimientos con incidencia automática en rechazo
Validación A04 anti-duplicado en seguimientos (semana ISO) y ausencias (fecha)
Frontend con flutter_secure_storage, go_router, sistema de diseño propio, Dio con interceptores
Documentación abundante (10 ficheros raíz + bitácora interna)
Preparación para el Hito 4 (100%)
Lo que ya tienes
Backend completo y modular
Frontend Flutter funcional con paneles por rol
Docker Compose listo
121 tests, plan OWASP cubierto, auditoría implementada
Documentación abundante
Para Hito 4
Decidir si implementas notificaciones o las sacas del alcance
Implementar ChannelInterceptor para autorización de suscripciones WebSocket
Endurecer listarPorPractica con comprobación de pertenencia
Cerrar las pequeñas tareas pendientes del plan OWASP (enum EstadoSeguimiento, CREATE EXTENSION pgcrypto)
Pulir frontend (loading states, error states, validación inline)
Pruebas E2E con Cypress/Playwright contra el web Flutter compilado en Nginx — opcional, suben nota
Manual de usuario por rol con capturas
Conclusión
Iker, has hecho un trabajo excepcional. El proyecto está claramente preparado para llegar al Hito 4 sin sobresaltos. Los puntos abiertos restantes son pulidos que se corrigen en pocas horas, no rediseños.

Documentación, plan de seguridad OWASP, tests con trazabilidad y bitácora de decisiones técnicas son piezas de calidad profesional que destacan tu trabajo. En la defensa te recomiendo apoyarte en estos elementos: el PLAN_SEGURIDAD_OWASP.md con cada item marcado y fechado y la suite de tests etiquetados por OWASP son aspectos que un tribunal valorará especialmente.

Sigue por este camino y cierra los 4 puntos pulidos antes del Hito 4. Cualquier duda, me dices y lo vemos juntos en tutoría.