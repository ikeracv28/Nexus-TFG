# Stack Tecnológico: Gestión de Prácticas Académicas

## Backend (Servidor)
*   **Lenguaje**: Java 21 (JDK 21 - eclipse-temurin).
*   **Framework**: Spring Boot 3.4.1.
    *   **Módulos**:
        *   Spring Boot Starter Web (API REST).
        *   Spring Boot Starter Data JPA (Persistencia).
        *   Spring Boot Starter Security (Autenticación y Autorización).
        *   Validation (Validación de beans).
*   **Seguridad**: JWT (io.jsonwebtoken 0.11.5) para autenticación sin estado.
*   **Gestión de Dependencias**: Maven (pom.xml).
*   **Desarrollo**: Lombok para reducción de código repetitivo y DevTools para recarga en caliente.

## Frontend (Cliente)
*   **Framework**: Flutter (Dart).
*   **Arquitectura**: Cliente-Servidor (Stateless REST).
*   **Consumo de API**: Capa de red HTTP (Dio o http).
*   **Gestión de Estado**: Provider o Riverpod.
*   **Almacenamiento Local**: flutter_secure_storage (tokens JWT).

## Persistencia (Datos)
*   **Base de Datos**: PostgreSQL (Relacional).
*   **ORM**: Hibernate (vía Spring Data JPA).

## Infraestructura y Despliegue
*   **Contenedor**: Docker (Dockerfile multi-etapa).
    *   **Etapa Build**: maven:3.9-eclipse-temurin-21.
    *   **Etapa Runtime**: eclipse-temurin:21-jre-alpine (ligera).
*   **Puerto**: 8080 (Servidor Spring Boot).
