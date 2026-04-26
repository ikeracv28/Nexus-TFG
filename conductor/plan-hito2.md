L# Plan de Implementación: Correcciones Hito 1 y Continuación Hito 2

Este plan detalla las correcciones del feedback del Hito 1 (25%) proporcionadas por el tutor y continúa con la implementación de la lógica principal del backend requerida para el Hito 2 (50%).

## Objetivo
1. Subsanar vulnerabilidades críticas de seguridad, diseño y despliegue identificadas en el Hito 1.
2. Implementar las entidades faltantes y la lógica de negocio core (Prácticas, Seguimientos).
3. Mantener `BBDD-TFG.sql` pero evitar conflictos con Flyway en Docker.

## Tareas (Tasks)

### Fase 1: Seguridad y Variables de Entorno (Crítico)
- Modificar `application.properties` para extraer credenciales a `${DB_USER}` y `${DB_PASSWORD}`.
- Extraer el secreto JWT a `${JWT_SECRET}` en `JwtUtils.java` y asegurar su inyección por entorno.
- Modificar `generateToken` en `JwtUtils.java` para incluir los roles del usuario como 'claims' en el token JWT.
- Configurar `@EnableMethodSecurity` en `SecurityConfig.java` o la clase principal.
- Asegurar endpoints en `CentroController`, `EmpresaController`, etc., usando `@PreAuthorize("hasRole('ADMIN')")` o los correspondientes.
- Añadir configuración CORS global correcta en `SecurityConfig.java`.

### Fase 2: Refactorización de Diseño y Excepciones
- Reemplazar `@Data` por `@Getter`, `@Setter` y `@EqualsAndHashCode(of = "id")` en todas las entidades (`Usuario`, `Rol`, `Centro`, `Empresa`, etc.).
- Refactorizar `UsuarioMapper`: evitar `NullPointerException` (centro) y eliminar el mapeo directo de `password` a `passwordHash`. El cifrado se delegará exclusivamente en el `Service`.
- Crear excepciones de negocio específicas (ej. `DuplicateEmailException`, `BusinessConflictException`) en el paquete `exceptions` para evitar retornar `409` con mensajes nativos de `RuntimeException`.

### Fase 3: Consolidación de Docker e Inicialización BD
- Crear un archivo `Dockerfile` en el directorio `tfg-nexus-api`.
- Ajustar la ruta del *build context* en `docker-compose.dev.yml` y `docker-compose.prod.yml` para que apunte correctamente a `tfg-nexus-api`.
- Modificar `docker-compose.dev.yml` para NO montar `BBDD-TFG.sql` en `/docker-entrypoint-initdb.d/`, evitando así el conflicto con la migración Flyway, pero conservando el archivo en el proyecto.

### Fase 4: Modelo de Dominio y Funcionalidad Core (Hito 2)
- Implementar entidades Java faltantes (`Incidencia`, `Mensaje`, `Notificacion`) correspondientes a la V1 de Flyway.
- Implementar las clases de Repositorio y Servicio para `Practica` y `Seguimiento`.
- Desarrollar los Controladores (Endpoints REST) para el CRUD de Prácticas y Seguimientos.

## Verificación Final
- La API levanta sin errores de inicialización o conflictos de BD.
- Autenticación JWT y validación basada en roles funcionan de extremo a extremo.
- Docker Compose permite construir y ejecutar el contenedor backend correctamente.
- La BBDD mantiene integridad con Flyway.