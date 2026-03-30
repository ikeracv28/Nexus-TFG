# Plan: Mejoras en Infraestructura Docker (Multi-stage y Optimización)

## Objetivo
Actualizar y optimizar los archivos de configuración de Docker (`docker-compose.yml`, `frontend/Dockerfile` y crear `backend/Dockerfile`) basándonos en las mejores prácticas de Multi-stage Builds y orquestación.

## Archivos a Modificar / Crear

### 1. `frontend/Dockerfile` (Modificar)
Implementará un Multi-Stage build para compilar la aplicación Flutter Web y servirla usando Nginx.

**Cambios previstos:**
- Etapa 1: Imagen basada en ubuntu para instalar el SDK de Flutter y ejecutar `flutter build web`.
- Etapa 2: Imagen basada en `nginx:alpine` para copiar los artefactos generados de la etapa 1 y exponer el puerto 80.
- Comentarios añadidos explicando cada sección.

### 2. `backend/Dockerfile` (Crear nuevo)
Implementará un Multi-Stage build para el backend Spring Boot, preparado para un entorno similar a producción.

**Cambios previstos:**
- Etapa 1: Imagen basada en Maven para resolver dependencias y empaquetar el `.jar`.
- Etapa 2: Imagen ligera basada en JRE (Eclipse Temurin) que ejecutará el `.jar` compilado sin incluir herramientas de construcción (Maven, JDK completo).
- Comentarios añadidos.

### 3. `docker/docker-compose.yml` (Modificar)
Se actualizará para hacer uso del nuevo `Dockerfile` del backend en lugar de compilar en tiempo de ejecución montando el código fuente.

**Cambios previstos:**
- En el servicio `backend`: Eliminar el uso de la imagen `maven` directa, `working_dir`, `command: mvn spring-boot:run` y los volúmenes enlazados de código fuente.
- En el servicio `backend`: Añadir el bloque `build:` apuntando a `../backend` y a su nuevo Dockerfile.
- Añadir comentarios descriptivos para comprender la función de cada servicio y red.

## Verificación
Una vez aplicados los cambios, podremos iniciar el entorno completo ejecutando:
```bash
cd docker
docker compose up --build
```
Verificaremos que los servicios inician correctamente (Frontend accesible, Backend levantado usando el JAR compilado y Base de Datos Postgres conectada exitosamente).
