# Roles del Sistema y Lógica de Validación

## Roles

| Rol | Propósito | Pantalla principal |
|-----|----------|--------------------|
| ROLE_ALUMNO | El estudiante en prácticas | Dashboard con progreso, seguimientos, incidencias, chat |
| ROLE_TUTOR_CENTRO | Tutor del instituto — supervisa lo académico | Panel 3 columnas, validación final, incidencias, chat |
| ROLE_TUTOR_EMPRESA | Responsable en la empresa — valida el trabajo real | Pantalla minimalista para firmar partes semanales |
| ROLE_ADMIN | Administrador del centro educativo | CRUD completo de prácticas, usuarios, empresas, centros |

### Distinción crítica entre los dos tutores

**TUTOR_EMPRESA** — primera validación (equivale a la firma en papel):
- Puede validar o rechazar un parte. El rechazo requiere motivo obligatorio.
- Pantalla minimalista: lista de partes pendientes + botones. Sin chat ni incidencias.
- Sin su validación, el tutor del centro no puede actuar.

**TUTOR_CENTRO** — segunda y definitiva validación:
- Solo ve partes que ya pasaron por el tutor de empresa.
- Acceso completo a incidencias y chat con el alumno.
- Recibe notificación automática si el tutor de empresa rechaza un parte.

---

## Lógica de Validación de Seguimientos — Diseño definitivo

Acordado el 18/04/2025. El flujo de validación simple fue reemplazado por doble validación.

### Estados

```
PENDIENTE_EMPRESA  → Alumno registró el parte. Esperando firma del tutor de empresa.
PENDIENTE_CENTRO   → Tutor de empresa validó. Esperando visto bueno del tutor del centro.
COMPLETADO         → Ambos tutores validaron. Horas contabilizadas en el progreso.
RECHAZADO          → Tutor de empresa rechazó. Se crea incidencia automática.
```

### Flujo paso a paso

1. Alumno registra un parte (fecha, horas, descripción). Estado: `PENDIENTE_EMPRESA`.
2. Tutor de empresa decide:
   - **Valida**: estado → `PENDIENTE_CENTRO`. Tutor del centro recibe aviso.
   - **Rechaza** (motivo obligatorio): estado → `RECHAZADO`. Se crea automáticamente una Incidencia de tipo `RECHAZO_PARTE`. El alumno corrige y reenvía.
3. Tutor del centro da el visto bueno final → estado `COMPLETADO`. Horas sumadas al progreso.

### Endpoints

```
PATCH /api/v1/seguimientos/{id}/validar-empresa
  @PreAuthorize("hasRole('TUTOR_EMPRESA')")
  Params: nuevoEstado (PENDIENTE_CENTRO | RECHAZADO), motivo (obligatorio si RECHAZADO)

PATCH /api/v1/seguimientos/{id}/validar-centro
  @PreAuthorize("hasRole('TUTOR_CENTRO')")
  Params: ninguno
```

Implementación: `SeguimientoServiceImpl.java` — métodos `validarEmpresa`, `validarCentro`, `crearIncidenciaRechazo`.
