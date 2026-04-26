# Track: Core del Backend - Nexus TFG

Este track cubre la implementaci贸n de las funcionalidades base necesarias para que el sistema sea operativo y seguro.

## Objetivo
Establecer el sistema de autenticaci贸n JWT y el modelo de datos principal (Empresas y Pr谩cticas).

## Tareas (Tasks)

- [x] **Task 1: Configuraci贸n de Infraestructura Base**
    - [x] Estructura de paquetes Spring Boot.
    - [x] Configuraci贸n de PostgreSQL y Flyway.
    - [x] Esquema inicial de base de datos (V1).

- [x] **Task 2: Modelo de Usuarios y Autenticaci贸n Base**
    - [x] Entidades JPA (`Usuario`, `Rol`, `Centro`).
    - [x] Repositorios con Query Derivation.
    - [x] L贸gica de Servicio para Registro y Login (sin JWT a煤n).
    - [x] Controlador de Autenticaci贸n (`AuthController`).

- [x] **Task 3: Implementaci贸n de Seguridad JWT**
    - [x] Creaci贸n de `JwtUtils` para generar y validar tokens.
    - [x] Implementaci贸n de `UserDetailsService` (Spring Security).
    - [x] Filtro de Autenticaci贸n JWT (`JwtAuthenticationFilter`).
    - [x] Configuraci贸n del `SecurityFilterChain` para proteger rutas.

- [x] **Task 4: Modelo de Gesti髇 de Pr醕ticas**
    - [ ] Entidades `Empresa` y `Practica`.
    - [x] Repositorios y Servicios correspondientes.
    - [x] Endpoint para crear y listar pr醕ticas.

- [ ] **Task 5: Sistema de Seguimientos y Chat**
    - [ ] Entidad `Seguimiento` (Partes semanales).
    - [ ] Entidad `Mensaje` (Comunicaci贸n interna).
    - [x] L骻ica de validaci髇 de seguimientos por parte de tutores.

## Verificaci贸n Final
- [x] Registro de un alumno con 茅xito.
- [ ] Login con obtenci贸n de Token JWT v谩lido.
- [ ] Creaci贸n de una pr谩ctica vinculada a una empresa y dos tutores.
