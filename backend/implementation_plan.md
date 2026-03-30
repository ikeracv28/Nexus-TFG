# Plan de Implementación Backend: Gestión de Prácticas Académicas

El presente plan detalla la reestructuración y desarrollo del backend para el nuevo modelo API REST del TFG, partiendo del esquema de base de datos PostgreSQL ya existente. Con el objetivo de consumir estos datos más adelante desde una aplicación móvil (Flutter), abandonamos la renderización de vistas con Thymeleaf y adoptamos una arquitectura basada en **Servicios RESTful** sin estado (Stateless), utilizando **Spring Boot** y securizada mediante **JWT (JSON Web Tokens)**.

> [!IMPORTANT]
> **Revisión del Usuario Requerida**
> Antes de escribir código, necesito tu aprobación o comentarios sobre este plan. Especialmente, fíjate en la propuesta de los roles y la adopción de JWT para asegurar la compatibilidad con el futuro cliente en Flutter.

## 1. Actualización de Tecnologías y Dependencias (pom.xml)

El proyecto actual `UsuarioCrud` contiene configuraciones para Thymeleaf y MySQL. Procederemos a:
- **[DELETE]** Dependencias de Thymeleaf, `spring-boot-starter-session-jdbc`.
- **[DELETE]** Dependencias del driver de MySQL.
- **[NEW]** Añadir driver de **PostgreSQL** (`org.postgresql:postgresql`).
- **[NEW]** Añadir soporte para **JWT** (e.g., `io.jsonwebtoken:jjwt-api`).
- **[NEW]** Añadir `spring-boot-starter-validation` para validar las peticiones DTO.
- **[MODIFY]** Mantener y actualizar Spring Security, Spring Web y Spring Data JPA.

## 2. Mapeo de Entidades JPA (PostgreSQL)

> [!TIP]
> **Uso de DTOs**
> En arquitecturas REST, nunca devolveremos las Entidades JPA puras en los controladores para evitar ciclos infinitos de serialización JSON y esconder datos sensibles (como `password_hash`).

La base de datos existente se mapeará al paquete `com.example.tfg.models.entity`. La convención incluirá las siguientes relaciones principales:

*   **`Rol`**: Entidad simple (`@Table(name="roles")`).
*   **`Centro`**: Entidad simple (`@Table(name="centros")`), relación `@OneToMany` hacia `Usuario` (opcional).
*   **`Usuario`**: `@Table(name="usuarios")`.
    *   `@ManyToMany` con `Rol` a través de la tabla intermedia `usuario_roles`.
    *   `@ManyToOne` con `Centro`.
*   **`Empresa`**: `@Table(name="empresas")`.
*   **`Practica`**: `@Table(name="practicas")`. Es el núcleo del sistema.
    *   `@ManyToOne` hacia `Usuario` (alumno mapeado por `alumno_id`).
    *   `@ManyToOne` hacia `Usuario` (tutor del centro educativo mapeado por `tutor_centro_id`).
    *   `@ManyToOne` hacia `Usuario` (tutor de la empresa mapeado por `tutor_empresa_id`).
    *   `@ManyToOne` hacia `Empresa` (`empresa_id`).
    > [!TIP]
    > **Actualización del Esquema SQL:** Modificaremos la tabla preexistente `practicas` para reemplazar el antiguo campo `tutor_id` por dos columnas diferenciadas: `tutor_centro_id` y `tutor_empresa_id`.
*   **`Seguimiento`**: `@Table(name="seguimientos")`.
    *   `@ManyToOne` hacia `Practica`.
    *   `@ManyToOne` hacia `Usuario` (validado_por).
*   **`Incidencia`**: `@Table(name="incidencias")`.
    *   `@ManyToOne` hacia `Practica` e inversores a los Usuarios correspondientes.
*   **`Mensaje` / `Notificacion`**: Entidades vinculadas a la Práctica o al Usuario general. Fechas mapeadas con `LocalDateTime`.

## 3. Estructura de Capas (Arquitectura Limpia)

Toda la lógica se organizará para seguir los principios S.O.L.I.D.:

*   `com.example.tfg.controllers.api`: Expondrán los Endpoints REST mapeando y devolviendo DTOs y `ResponseEntity`.
*   `com.example.tfg.models.dto`: Objetos de transferencia (Ej. `SeguimientoRequestDTO`, `PracticaResponseDTO`).
*   `com.example.tfg.models.entity`: Clases JPA.
*   `com.example.tfg.models.repository`: Interfaces `JpaRepository` e integración con SQL.
*   `com.example.tfg.services`: Contendrá las interfaces de lógica de negocio y un subpaquete `.impl` con sus implementaciones.
*   `com.example.tfg.security`: Configuración pura de JWT (Filtros, Provider, Services de usuario).
*   `com.example.tfg.exceptions`: Manejo global de excepciones (`@ControllerAdvice`) para retornar JSON de errores siempre consistentes.

## 4. Diseño de Endpoints REST Principales

La API tendrá cómo base la ruta `/api/v1`. Para este alcance, diseñaremos lo siguiente:

### Autenticación
*   `POST /api/v1/auth/login` → Recibe Credenciales, devuelve `{ "token": "ey..." }`.

### Gestión de Prácticas
*   `GET /api/v1/practicas` → Lista las prácticas (Si es alumno ve la suya; si es tutor ve las de sus alumnos).
*   `GET /api/v1/practicas/{id}` → Detalle completo de la práctica (empresa, tutor, fechas).

### Seguimientos
*   `GET /api/v1/practicas/{id}/seguimientos` → Lista entregas y partes de horas del alumno.
*   `POST /api/v1/practicas/{id}/seguimientos` → El Alumno envía su parte semanal.
*   `PUT /api/v1/seguimientos/{idSeguimiento}/validar` → El Tutor aprueba y añade comentarios.

### Incidencias y Mensajes (Comunicación Centralizada)
*   `GET /api/v1/practicas/{id}/incidencias` → Histórico de alarmas.
*   `POST /api/v1/practicas/{id}/incidencias` → Botón del alumno para alertar de problemas.
*   `GET /api/v1/practicas/{id}/mensajes` → Historial del Chat interno de la práctica.
*   `POST /api/v1/practicas/{id}/mensajes` → Envío de mensajes al chat.

## 5. Estrategia de Seguridad / Autenticación (JWT y Roles)

1.  **JWT Filter**: En cada request a `api/v1/`, un filtro leerá la cabecera `Authorization: Bearer <Token>`. Si es válido, configura el contexto de Spring Security.
2.  **Stateless Session**: Desactivaremos la creación de sesiones JSESSIONID.
3.  **Roles (`GrantedAuthorities`)**: Evaluaremos si el usuario que accede al endpoint tiene el permiso adecuado.
    *   El Backend inyectará automáticamente el prefijo `ROLE_` por convención o validaremos manualmente según la tabla `roles` (ej. `ROLE_ALUMNO`, `ROLE_TUTOR_CENTRO`, `ROLE_TUTOR_EMPRESA`).
    *   *Data-Ownership*: Se validará no recíprocamente que tengas acceso al endpoint, sino *a esos datos específicos*. (Ej. Un alumno no puede modificar el seguimiento de otro alumno, lo comprobaremos a nivel de Lógica del Service).

## Decisiones Arquitectónicas Confirmadas
> [!NOTE]
> **Acuerdos basados en tus comentarios:**
> 1. **Doble Tutoría**: Se creará explícitamente la distinción entre `tutorCentro_id` y `tutorEmpresa_id` en la tabla `practicas`. Ambos serán relaciones a la tabla `usuarios` (asumiendo sus roles respectivos), manteniendo también el `empresa_id` para identificar la organización.
> 2. **Reestructuración de UsuarioCrud**: Modificaremos y refactorizaremos el proyecto `UsuarioCrud` existente. Se eliminarán de raíz las dependencias de Thymeleaf, configuraciones estáticas y plantillas MVC, transformándolo puramente en una API REST orientada al futuro Frontend en Flutter.

## Verification Plan
1. **Verificación de Base de datos:** Ejecutaremos el proyecto y revisaremos mediante los logs que Hibernate valida la estructura contra tu PostgreSQL sin alterar tus tablas en producción (`spring.jpa.hibernate.ddl-auto=validate` o `none`).
2. **Postman/Bruno/cURL**: Construiré ejemplos de peticiones JSON para probar los flujos de creación de seguimiento y envío de chat.
