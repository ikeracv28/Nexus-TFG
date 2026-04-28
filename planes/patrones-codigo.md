# Patrones de Código — Checklists

## Nuevo endpoint REST (backend)

1. Migración Flyway `VN__Descripcion.sql` si hay cambios en BD.
2. Entidad JPA si es nueva (`@EqualsAndHashCode(of = "id")`, nunca `@Data`).
3. DTOs Request y Response con Bean Validation (`@NotBlank`, `@Size`, enums para estados).
4. Mapper MapStruct (nunca mapear a mano en el servicio).
5. Repository extendiendo JpaRepository.
6. Interfaz `Service` + implementación en `impl/`. Verificar propiedad del recurso en el servicio.
7. Controller con `@PreAuthorize` explícito en cada método. Sin `@CrossOrigin`. Sin `isAuthenticated()` sin justificación.
8. Tests: happy path + acceso denegado + propietario incorrecto.
9. Documentar en `ARQUITECTURA_API.md` antes de implementar.
10. Ejecutar `/owasp-security` sobre los archivos modificados. Resolver CRITICO/ALTO antes del commit.

## Nueva pantalla Flutter

1. Consultar `DESIGN_SYSTEM.md` antes de empezar.
2. Model en `data/models/` sincronizado con el DTO del backend.
3. Service en `data/services/` usando ApiClient. Manejar 401 (redirect login), 403 (error UI), 429 (rate limit).
4. Provider en `presentation/providers/` extendiendo `ChangeNotifier`.
5. Screen en `presentation/screens/` usando `NexusColors`. Validar inputs en cliente antes de enviar.
6. Ruta en go_router con guard de rol si aplica.
7. Ejecutar `/owasp-security` sobre los archivos. Resolver CRITICO/ALTO antes del commit.

## Reglas de negocio invariantes

- Las transiciones de estado se validan en el servicio, no en el controller.
- El orden empresa-primero → centro-después es inviolable.
- Los parámetros de estado son siempre enums o conjuntos cerrados, nunca Strings libres.
- Prohibido concatenar strings en queries JPA.
