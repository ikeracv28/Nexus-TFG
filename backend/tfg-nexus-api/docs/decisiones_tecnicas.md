# Nexus TFG - Bitácora de Decisiones Técnicas

Este documento detalla la evolución arquitectónica del backend y el razonamiento detrás de cada elección tecnológica.

## 1. Identidad del Proyecto
**Nombre:** Nexus TFG (Nexus-API)
**Concepto:** "Nexus" representa el punto de unión entre alumnos, centros educativos y empresas, centralizando la gestión de la FP Dual y prácticas externas.

## 2. Decisiones de Base (Infraestructura)

### Java 21 LTS + Spring Boot 3.4.1
- **Razón:** Se opta por las versiones más modernas y estables. Java 21 introduce mejoras de rendimiento (Virtual Threads) y sintaxis (Records) que utilizaremos para los DTOs, reduciendo el código repetitivo.
- **Impacto:** Un backend más ligero, rápido y preparado para el futuro.

### Flyway (Migraciones de Base de Datos)
- **Razón:** En lugar de permitir que Hibernate genere las tablas (`ddl-auto=update`), delegamos el control a Flyway.
- **Decisión Crítica:** El esquema inicial (`V1`) ya incluye la separación de `tutor_centro_id` y `tutor_empresa_id` en la tabla `practicas`. Esta decisión previene problemas futuros donde un solo tutor no bastaba para cubrir ambas responsabilidades (académica y profesional).

### Arquitectura de Paquetes
- **Razón:** Se implementa una separación clara de responsabilidades:
    - `controllers`: Exposición de la API.
    - `services`: Lógica de negocio pura.
    - `models.entity`: Espejo de la base de datos (JPA).
    - `models.dto`: Objetos ligeros para transferencia de datos.
    - `models.mapper`: Automatización de la conversión entre Entidad y DTO (vía MapStruct).

## 3. Seguridad y Comunicación

### JWT (Stateless)
- **Razón:** Al ser una API que servirá a una aplicación móvil (Flutter), no podemos usar sesiones tradicionales de servidor (JSESSIONID). JWT permite que el cliente sea el encargado de enviar su identidad en cada petición.

### MapStruct
- **Razón:** Evitar el mapeo manual de objetos. MapStruct genera código en tiempo de compilación, lo que es mucho más rápido que usar librerías de reflexión como ModelMapper.

## 4. Capa de Persistencia (Repositories)

### Spring Data JPA & Query Derivation
- **Razón:** Utilizamos `JpaRepository` para delegar el CRUD a Spring. 
- **Decisión Crítica:** El uso de **Query Derivation** (como `findByEmail`) simplifica el código al no requerir sentencias SQL manuales. Spring analiza el nombre del método y genera la consulta óptima para PostgreSQL.

### Modelo de Dominio Core (Entities & Relationships)
- **Empresa:** Se diseña como una entidad independiente que almacena datos corporativos (CIF, contacto) necesarios para el convenio de prácticas.
- **Practica (Entidad Pivote):** Es el núcleo funcional del sistema. Relaciona a un `Alumno` con su `Empresa`, un `TutorCentro` y un `TutorEmpresa`. 
    - **Decisión Crítica:** Se opta por relaciones `@ManyToOne` con `FetchType.LAZY` en todas las claves foráneas para evitar la carga masiva de datos innecesarios en memoria (N+1 Select Problem).
- **Seguimiento (Diario de Actividad):** Permite el registro cronológico de tareas. 
    - **Decisión Crítica:** Se incluye una relación con el `Usuario` (Tutor) que valida el registro, permitiendo un flujo de aprobación formal integrado en la base de datos.

### Repositorios Especializados
- **PracticaRepository:** Se incluyen métodos personalizados para filtrar por alumno, tutor de centro y estado, permitiendo que cada rol visualice únicamente los convenios que le corresponden.
- **SeguimientoRepository:** Implementa ordenación cronológica descendente por defecto (`OrderByFechaRegistroDesc`) para que el alumno y el tutor vean siempre la actividad más reciente primero.

### Uso de Optional
- **Razón:** Todos los métodos de búsqueda devuelven un objeto de tipo `Optional<T>`. 
- **Impacto:** Esto obliga al desarrollador (a nosotros) a manejar explícitamente el caso de "dato no encontrado", evitando el clásico y temido `NullPointerException` en producción.

## 5. Lógica de Autenticación y Seguridad

### Cifrado BCrypt (SecurityConfig)
- **Razón:** No se almacenan contraseñas en texto plano. Se utiliza `BCryptPasswordEncoder` para generar hashes seguros con 'salt' automático.
- **Seguridad:** Cumple con los estándares de la OWASP para la protección de credenciales.

### Java 21 Records (DTOs)
- **Razón:** Se utilizan `Records` para los objetos de transferencia de datos (como `RegisterRequest`). 
- **Decisión Crítica:** Al ser inmutables, garantizan que los datos que llegan del frontend no se modifiquen durante el flujo del servicio, lo que hace el sistema más predecible y seguro.

### Capa de Servicio (AuthService)
- **Razón:** Se separa la lógica de negocio (validar duplicados, cifrar contraseñas, asignar roles) de la capa de transporte (Controladores).
- **Transaccionalidad:** Se usa `@Transactional` para asegurar la integridad de los datos en el proceso de registro (todo o nada).

### Capa de Control (AuthController)
- **Razón:** Se exponen endpoints REST bajo la ruta `/api/v1/auth`. 
- **Validación:** Se utiliza `@Valid` para interceptar datos incorrectos antes de que lleguen al servicio, ahorrando recursos de procesamiento.
- **CORS:** Se habilita `@CrossOrigin(origins = "*")` para permitir que el cliente Flutter (ya sea en web o móvil) pueda consumir la API sin bloqueos de navegador.
- **Naming:** Se sigue la convención de plurales para recursos, aunque en autenticación se usan verbos de acción (`/login`, `/register`) por ser operaciones procedimentales.

### 6. Arquitectura de Seguridad JWT (Task 3)


### JwtUtils (Generación y Validación)
- **Razón:** Centraliza la lógica de creación de tokens. Utiliza el algoritmo HS256 y una clave secreta configurable.
- **Seguridad:** Los tokens incluyen fecha de emisión y expiración (24h por defecto) para mitigar riesgos de robo de tokens.

### UserDetailsServiceImpl (Puente de Datos)
- **Razón:** Implementa la interfaz estándar de Spring Security para cargar usuarios desde nuestra base de datos PostgreSQL.
- **Conversión:** Transforma nuestras entidades `Rol` en `GrantedAuthority`, permitiendo que el framework gestione los permisos de forma nativa.

### JwtAuthenticationFilter (Interceptor de Peticiones)
- **Razón:** Implementa un filtro `OncePerRequestFilter` que extrae el token de la cabecera `Authorization: Bearer`.
- **Estrategia:** Valida la firma del token y establece el contexto de seguridad en cada petición, permitiendo que la API sea **Stateless**.

### SecurityFilterChain (Configuración Maestra)
- **Razón:** Define las políticas de acceso globales. 
- **Decisión Crítica:** Se deshabilita CSRF y se configura la política de sesiones como `STATELESS`. Se permite el acceso libre a la ruta de autenticación y se protege el resto de la API por defecto.

---
*Última actualización: 31 de marzo de 2026*
