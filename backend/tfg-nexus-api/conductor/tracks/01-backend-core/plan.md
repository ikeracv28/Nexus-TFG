# Track: Core del Backend - Nexus TFG

Este track cubre la implementación de las funcionalidades base necesarias para que el sistema sea operativo y seguro.

## Objetivo
Establecer el sistema de autenticación JWT y el modelo de datos principal (Empresas y Prácticas).

## Tareas (Tasks)

- [x] **Task 1: Configuración de Infraestructura Base**
    - [x] Estructura de paquetes Spring Boot.
    - [x] Configuración de PostgreSQL y Flyway.
    - [x] Esquema inicial de base de datos (V1).

- [x] **Task 2: Modelo de Usuarios y Autenticación Base**
    - [x] Entidades JPA (`Usuario`, `Rol`, `Centro`).
    - [x] Repositorios con Query Derivation.
    - [x] Lógica de Servicio para Registro y Login (sin JWT aún).
    - [x] Controlador de Autenticación (`AuthController`).

- [x] **Task 3: Implementación de Seguridad JWT**
    - [x] Creación de `JwtUtils` para generar y validar tokens.
    - [x] Implementación de `UserDetailsService` (Spring Security).
    - [x] Filtro de Autenticación JWT (`JwtAuthenticationFilter`).
    - [x] Configuración del `SecurityFilterChain` para proteger rutas.

- [ ] **Task 4: Modelo de Gestión de Prácticas**
    - [ ] Entidades `Empresa` y `Practica`.
    - [ ] Repositorios y Servicios correspondientes.
    - [ ] Endpoint para crear y listar prácticas.

- [ ] **Task 5: Sistema de Seguimientos y Chat**
    - [ ] Entidad `Seguimiento` (Partes semanales).
    - [ ] Entidad `Mensaje` (Comunicación interna).
    - [ ] Lógica de validación de seguimientos por parte de tutores.

## Verificación Final
- [x] Registro de un alumno con éxito.
- [ ] Login con obtención de Token JWT válido.
- [ ] Creación de una práctica vinculada a una empresa y dos tutores.
