# TFG Nexus - Gestión de Prácticas Académicas (Backend)

## Resumen del Proyecto
Sistema centralizado para la gestión y seguimiento de prácticas académicas (FCT), diseñado para interactuar con un cliente Flutter mediante una API REST sin estado securizada con JWT.

## Comandos Esenciales

| Acción | Comando | Directorio |
|--------|---------|------------|
| Ejecutar API | `./mvnw spring-boot:run` | `tfg-nexus-api/` |
| Construir Proyecto | `./mvnw clean install` | `tfg-nexus-api/` |
| Verificar Migraciones | `./mvnw flyway:info` | `tfg-nexus-api/` |
| Ejecutar Tests | `./mvnw test` | `tfg-nexus-api/` |

## Estructura del Repositorio

| Directorio | Propósito |
|------------|-----------|
| `tfg-nexus-api/` | **Implementación principal**. API moderna con Flyway y MapStruct. |
| `conductor/` | Configuración de pistas (tracks), guías de producto y estilo. |
| `docs/` | Decisiones técnicas y guías detalladas para el estudiante. |
| `.agents/` | Definiciones de habilidades (skills) personalizadas para el agente. |

## Índice de Referencia (Revelación Progresiva)

| Si necesitas saber sobre... | Consulta el documento... | Contenido clave |
|-----------------------------|--------------------------|-----------------|
| Arquitectura y Endpoints | `ARQUITECTURA_API.md` | Definición de capas y contrato de la API REST. |
| Contexto del Negocio | `contexto_proyecto.md` | Definición del problema, objetivos y roles. |
| Plan de Implementación | `implementation_plan.md` | Pasos de reestructuración desde el modelo antiguo. |
| Decisiones Técnicas | `tfg-nexus-api/docs/decisiones_tecnicas.md` | Justificación del stack (PostgreSQL, JWT, Flyway). |
| Estado del Track Actual | `tfg-nexus-api/conductor/tracks/01-backend-core/plan.md` | Tareas pendientes y progreso del desarrollo core. |

## Habilidades del Agente (Skills)

| Nombre Skill | Definición de Uso | Identificador |
|--------------|-------------------|---------------|
| `java-expert` | Desarrollo avanzado en Java 21+ y ecosistema Spring Enterprise. | `java-expert` |
| `java-springboot` | Aplicación de mejores prácticas en proyectos Spring Boot. | `java-springboot` |
| `java-junit` | Creación de tests unitarios y de integración con JUnit 5. | `java-junit` |
| `api-documentation` | Generación de documentación técnica para APIs (REST/OpenAPI). | `api-documentation` |
| `documentation-writer` | Redacción técnica profesional siguiendo el marco Diátaxis. | `documentation-writer` |
| `agents-md-creator` | Mantenimiento de documentación optimizada para agentes AI. | `agents-md-creator` |
| `frontend-design` | Diseño y desarrollo de interfaces de alta calidad visual. | `frontend-design` |
| `docker-compose-orchestration` | Configuración y despliegue de entornos multi-contenedor. | `docker-compose-orchestration` |
| `gitignore-gen` | Análisis del proyecto y generación automática de .gitignore. | `gitignore-gen` |

## Reglas de Oro (Iron Rules)

### Principios Fundamentales
*   **Puntuación:** Prohibido el uso de la raya larga (em dash). Utilizar punto y coma, punto, o reescribir la oración.
*   **Idioma:** Responder exclusivamente en español técnico y seco.
*   **Documentación de Código:** Cada bloque de código debe incluir comentarios exhaustivos línea por línea, explicando lógica e interacciones.
*   **Actitud Crítica:** Dudar siempre de las propuestas del usuario. Verificar estándares mediante skills o MCP antes de dar la razón.
*   **Lógica de Conductor:** Seguir rigurosamente la metodología de pistas (tracks) definida en `conductor/`.
*   **Rol Pedagógico:** Actuar como profesor al explicar conceptos críticos, arquitecturas complejas o cambios de gran envergadura. Proporcionar contexto didáctico para asegurar la comprensión del estudiante.

### Flujo de Trabajo y Git
*   **Estrategia de Commits:** Realizar commits únicamente tras completar bloques funcionales significativos o hitos técnicos relevantes. No realizar commits por cambios menores aislados.
*   **Mensajes de Commit:** Redactar mensajes en español con un tono humano y profesional. Evitar descripciones genéricas generadas por IA; centrarse en el "por qué" y el impacto del cambio.
*   **Documentación Continua:** Registrar cada decisión técnica, justificación arquitectónica e impacto de los cambios significativos en `tfg-nexus-api/docs/decisiones_tecnicas.md` tras completar una funcionalidad o cambio de calado.

### Estilo de Comunicación
*   **Voz Activa:** Utilizar siempre voz activa.
*   **Sin Rellenos:** Evitar frases introductorias o transicionales ("ah the old", "no es opcional; es requerido").
*   **Directo al Grano:** Declaraciones funcionales directas sin metáforas contrastivas ni juicios de valor.
*   **Formato:** Respuesta terse, minimalista, sin emojis ni chunking visual excesivo.

## Antes de Modificar Código

1.  **Verificar el Track:** Consultar `conductor/tracks/` para asegurar que el cambio está alineado con el plan actual.
2.  **Validar Entidades:** Asegurar que los cambios en `tfg-nexus-api` incluyen la migración Flyway correspondiente en `src/main/resources/db/migration/`.
3.  **Cumplir el Contrato:** Cualquier cambio en la API debe reflejarse en `ARQUITECTURA_API.md`.