# Arquitectura del Sistema: Java (Backend) vs Flutter (Frontend) y Contrato de APIs

Para mantener una separación de responsabilidades estricta y profesional en el Trabajo de Fin de Grado, el proyecto adopta una arquitectura Cliente-Servidor clásica mediante servicios RESTful sin estado (*Stateless*).

---

## 1. Responsabilidades de Java Spring Boot (El Servidor / Backend)
El backend actúa como el "cerebro" y único guardián de la persistencia de los datos. Desconoce por completo cómo se ven las pantallas.

*   **Exposición de API RESTful:** Define los endpoints (rutas web) que reciben peticiones y devuelven datos exclusivamente en formato JSON.
*   **Lógica de Negocio (Services):** Toma de decisiones (ej. verificar que un alumno no tenga dos prácticas activas simultáneamente o que solo un tutor puede autorizar un cambio de estado).
*   **Persistencia de Datos (JPA/Hibernate):** Manipula la inserción, actualización y consulta de registros en PostgreSQL mapeando las filas SQL a objetos Java.
*   **Seguridad y Autenticación (Spring Security + JWT):** Genera tokens de sesión criptográficos en el Login, intercepta cada petición entrante y rechaza cualquier acceso que no posea un token válido o los permisos de Rol adecuados.

## 2. Responsabilidades de Flutter (El Cliente / Frontend)
El frontend actúa como la interfaz interactiva. Es "tonto" en cuanto a almacenamiento permanente; su única verdad proviene de consultar al backend.

*   **Renderizado de Interfaz (UI):** Construye las vistas web interactivas (formularios, listas de prácticas, tarjetas de incidencia, chat) empleando Widgets.
*   **Consumo de API (Capa de Red):** Ejecuta peticiones HTTP (`GET`, `POST`, `PUT`, `DELETE`) al puerto 8080 del backend usando paquetes como *Dio* o *http*, enviando el token JWT en las cabeceras.
*   **Gestión de Estado (State Management):** Conserva temporalmente los datos traídos del servidor (usando *Provider* o *Riverpod*) para renderizar la pantalla sin hacer peticiones redundantes.
*   **Almacenamiento Local Seguro:** Almacena el token JWT recibido tras un Login exitoso en la memoria cifrada del navegador/dispositivo (`flutter_secure_storage`) para inyectarlo en las futuras peticiones.

---

## 3. Contrato de APIs (Endpoints de Conexión)
Estos son los endpoints principales que Spring Boot expondrá y que Flutter consumirá para dar vida a la aplicación.

### A. Autenticación y Usuarios
*   `POST /api/auth/login`
    *   **Flutter envía:** JSON con `email` y `password`.
    *   **Java devuelve:** Un token JWT y los datos básicos del usuario y su Rol.
*   `GET /api/usuarios/me`
    *   **Flutter envía:** Token JWT en cabecera.
    *   **Java devuelve:** Perfil extenso del usuario logueado.

### B. Módulo de Prácticas Académicas
*   `GET /api/practicas`
    *   **Java devuelve:** Lista de prácticas filtrada. Si pide un alumno, sus prácticas; si pide el tutor del centro, las de sus tutelados.
*   `POST /api/practicas`
    *   **Flutter envía:** IDs de Alumno, Empresa, Tutor Centro y Tutor Empresa.
    *   **Java:** (Solo permitodo para Rol Admin/Tutor Centro) Crea la nueva práctica en PostgreSQL.
*   `PUT /api/practicas/{practicaId}/estado`
    *   **Flutter envía:** Nuevo estado (ej. "FINALIZADA").
    *   **Java:** Actualiza la BBDD.

### C. Seguimiento e Incidencias
*   `GET /api/practicas/{practicaId}/seguimientos`
    *   **Java devuelve:** Cronología de notas de evaluación sobre esa práctica específica.
*   `POST /api/practicas/{practicaId}/incidencias`
    *   **Flutter envía:** Descripción de un incidente.
    *   **Java devuelve:** Nueva incidencia registrada con estado "ABIERTA".

### D. Comunicaciones (Chat Interno)
*   `GET /api/practicas/{practicaId}/mensajes`
    *   **Java devuelve:** Historial de mensajes cruzados entre el alumno, el tutor de empresa y el del centro correspondientes a esa práctica.
*   `POST /api/practicas/{practicaId}/mensajes`
    *   **Flutter envía:** Contenido del mensaje de texto.
    *   **Java:** Almacena el mensaje con fecha y remitente exacto (el extrae del token JWT que envía Flutter de forma transparente).

---
*(Nota Técnica: Para el chat, la implementación REST base se apoyará en sondeos -polling- desde Flutter (solicitando `GET /mensajes` periódicamente) o, idealmente para mensajería instantánea real en TFG avanzados, migrando este módulo específico a WebSockets en la ruta `ws://api/chat`).*
