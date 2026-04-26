# Plan de Sincronización y Fortalecimiento: Hito 1 (25%)

Este plan aborda las discrepancias identificadas entre la memoria de seguimiento, la documentación técnica (`ARQUITECTURA_API.md`) y el estado real del código, asegurando una entrega sólida para mañana.

## Objetivos
1.  **Corregir la percepción de "Falta de Manejo de Excepciones":** Verificar y asegurar que `GlobalExceptionHandler` sea visible y funcional.
2.  **Sincronizar Documentación y Código:** Implementar los endpoints básicos de "Maestros" (Centros y Empresas) y el perfil de usuario (`/me`) para cumplir con lo prometido en la memoria.
3.  **Reducir Riesgos de Evaluación:** Actualizar `ARQUITECTURA_API.md` para reflejar con precisión qué está implementado y qué es parte del roadmap del Hito 2.

## Cambios Propuestos

### 1. Modelado y DTOs (Capa de Datos)
*   **Nuevo DTO `UsuarioResponse.java`:** Record para devolver el perfil del usuario sin datos sensibles (passwordHash).
*   **Nuevo DTO `CentroResponse.java` y `EmpresaResponse.java`:** Records para listar centros y empresas.
*   **Actualizar `UsuarioMapper.java`:** Añadir métodos para mapear `Usuario` a `UsuarioResponse`.
*   **Nuevos Mappers `CentroMapper.java` y `EmpresaMapper.java`:** Para la gestión de maestros.

### 2. Controladores (Capa de API)
*   **`UsuarioController.java`:**
    *   `GET /api/v1/usuarios/me`: Devuelve el perfil del usuario autenticado (extrayendo el email del SecurityContext).
*   **`CentroController.java`:**
    *   `GET /api/v1/centros`: Listado de centros educativos (solo lectura para este hito).
*   **`EmpresaController.java`:**
    *   `GET /api/v1/empresas`: Listado de empresas colaboradoras (solo lectura para este hito).

### 3. Documentación
*   **Actualizar `ARQUITECTURA_API.md`:** 
    *   Marcar claramente los endpoints de Prácticas, Seguimientos y Chat como "Diseño de Contrato - Implementación en Hito 2".
    *   Asegurar que las rutas coincidan con el código (`/api/v1/...`).

## Pasos de Implementación

1.  **Crear DTOs:** Definir `UsuarioResponse`, `CentroResponse` y `EmpresaResponse` como Java Records.
2.  **Configurar Mappers:** Implementar/Actualizar mappers con MapStruct.
3.  **Desarrollar Controladores:** Implementar la lógica mínima en los nuevos controladores.
4.  **Pruebas Rápidas:** Verificar que los nuevos endpoints responden correctamente con un token JWT válido.
5.  **Refactor de Docs:** Ajustar la `ARQUITECTURA_API.md`.

## Verificación
*   Ejecutar `./mvnw test` para asegurar que no hay regresiones.
*   Probar manualmente `GET /api/v1/usuarios/me` usando Postman o cURL con un token obtenido en `/login`.
