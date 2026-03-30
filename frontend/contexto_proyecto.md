# Contexto del Proyecto: Gestión de Prácticas Académicas

## Datos Generales
- **Autor**: Iker Acevedo Donate
- **Institución**: CampusFP
- **Propósito**: Trabajo de Fin de Grado (TFG)

## 1. Definición del Problema
La gestión actual de las prácticas académicas está fragmentada y resulta caótica. Alumnos, tutores de centro y tutores de empresa se comunican mediante hilos de correos electrónicos, llamadas y archivos Excel aislados. Esto dificulta el seguimiento real del día a día del alumno y la detección temprana de bloqueos o incidencias durante la estancia formativa.

## 2. Objetivo Principal
Centralizar el seguimiento y la comunicación del ciclo de prácticas en un único entorno digital. En su fase inicial (alcance de este TFG), el foco prioritario será:
- **Comunicación centralizada**: Chat interno asociado a la práctica.
- **Seguimiento real**: Registro visual y ágil de tareas semanales y horas.
- **Gestión de incidencias**: Sistema de alerta estructurado entre alumno y tutor.
- **Supervisión general**: Paneles de control para el centro educativo.

## 3. Arquitectura y Stack Tecnológico
Arquitectura Cliente-Servidor basada en Servicios Web Restful (API REST).
- **Backend**: Java con Spring Boot. Logica de negocio, roles y seguridad (JWT).
- **Base de Datos**: PostgreSQL. Gestión relacional de identidades, prácticas, logs y mensajería.
- **Frontend**: Flutter (Dart). Desarrollo de aplicacion cliente para plataformas móviles o web.

## 4. Diseño del Sistema por Roles

### 4.1. Alumno
- **Contador de Horas**: Progreso visual del tiempo de prácticas restante.
- **Seguimiento Semanal**: Registro continuo tipo "diario" de las actividades realizadas.
- **Botón de Incidencias**: Herramienta de reporte oficial ante situaciones anómalas (asignación de tareas incorrectas, problemas de horario, etc.).
- **Chat**: Canal directo, único y profesional con la tutoría.

### 4.2. Tutor (Empresa / Centro)
- **Lista de Alumnos**: Visión global de todos los perfiles bajo su tutela.
- **Alertas**: Notificaciones e indicadores visuales para incidencias activas o seguimientos sin rellenar.

### 4.3. Centro Educativo
- **Gestión de Tutores**: Supervisión de la carga lectiva/tutorización por profesor.
- **Estadísticas**: Métricas en tiempo real sobre los convenios activos y alumnos desplazados.

## 5. Modelo de Base de Datos Principal
Sistema de entidades fuertemente interconectado:
- `usuarios` / `roles`: Autenticación y control de acceso (Alumno, Tutor, Centro).
- `empresas`: Entidad corporativa.
- `practicas`: Entidad pivote. Relaciona 1 Alumno con 1 Empresa, 1 Tutor de Centro y 1 Tutor de Empresa.
- `seguimientos` e `incidencias`: Historial de reportes vinculados a una práctica en particular.
- `mensajes` / `chat`: Historial cronológico de la comunicación interna.

## 6. Alcance a Corto Plazo y Futuro
- **Scope actual restrictivo**: Diseño de BBDD, API y Frontend centrado en Login, Seguimiento Mensual, Incidencias y Chat.
- **Fuera del Scope actual (Plan de Futuro)**: Firma digital de convenios, alertas automatizadas ("push notifications"), IA para análisis semántico del grado de satisfacción en diarios, y un sistema automatizado de *matchmaking* entre perfiles de alumnos y ofertas empresariales.