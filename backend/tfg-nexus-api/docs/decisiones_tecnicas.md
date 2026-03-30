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

### Uso de Optional
- **Razón:** Todos los métodos de búsqueda devuelven un objeto de tipo `Optional<T>`. 
- **Impacto:** Esto obliga al desarrollador (a nosotros) a manejar explícitamente el caso de "dato no encontrado", evitando el clásico y temido `NullPointerException` en producción.

---
*Última actualización: 30 de marzo de 2026*
