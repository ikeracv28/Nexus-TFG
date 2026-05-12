# Puntos de Mejora — Nexus TFG

Actualizado: 12/05/2026 | Entrega final: 19 mayo 2026 | **Quedan 7 días**

---

## ✅ Completado hoy (12/05/2026)

| # | Mejora | Archivo |
|---|--------|---------|
| ✅ | `ws://localhost:8080/ws` hardcoded → `ApiClient.wsBaseUrl` dinámico | `api_client.dart`, `mensaje_service.dart` |
| ✅ | `application-prod.properties` — HikariCP pool 10/5 + Actuator solo health,info | `application-prod.properties` |
| ✅ | `NotificacionProvider` — flag `_cargado` evita dobles llamadas + polling cada 30s | `notificacion_provider.dart`, `main.dart` |
| ✅ | Paquete `excel: ^4.0.6` añadido a pubspec.yaml | `pubspec.yaml` |

---

## Prioridad ALTA — Impacto directo en la nota

### 1. Evaluación final del alumno (Feature 4)
**Problema**: el ciclo de vida de las prácticas no cierra. El alumno nunca recibe una nota formal dentro de la app.
**Impacto**: el tribunal puede señalar que el flujo principal (FCT) no está completo.
**Solución**:
- V14 migration: tabla `evaluacion_final` (practica_id FK, nota DECIMAL, comentario TEXT, fecha TIMESTAMP)
- Entidad `EvaluacionFinal` + DTO + mapper + repositorio
- `EvaluacionService` / `EvaluacionServiceImpl` + `EvaluacionController` (POST por tutor centro, GET por todos los participantes)
- Formulario Flutter en `panel_tutor_centro_screen.dart`: nota (0–10) + comentario + botón guardar
- Mostrar la nota en `dashboard_screen.dart` del alumno y en `ficha_alumno_screen.dart`
**Estimación**: ~4h
**Estado**: [ ] Pendiente

---

### 2. Informe del alumno — Exportar PDF y Excel (Feature 5)
**Problema**: `ficha_alumno_screen.dart` ya muestra todos los datos (seguimientos, incidencias, ausencias, horas, gráficos) pero el botón de exportar no hace nada.
**Requisito del profesor (tutoría 12/05/2026)**: el tutor del centro debe poder ver y exportar un informe completo por alumno con faltas justificadas/injustificadas, incidencias, horas realizadas vs comprometidas.
**Solución**:
- PDF: usar paquetes `pdf` + `printing` (ya instalados). Generar documento con: cabecera alumno/empresa, resumen horas, tabla seguimientos, tabla ausencias (justificadas vs no), tabla incidencias.
- Excel: usar paquete `excel: ^4.0.6` (ya añadido). Generar `.xlsx` con una hoja por sección.
- Añadir botón Excel junto al botón PDF en el AppBar de `ficha_alumno_screen.dart`.
- Asegurarse de que las ausencias muestren claramente `justificada: true/false`.
**Estimación**: ~2-3h
**Estado**: [ ] Pendiente

---

### 3. Tests — Subir cobertura JaCoCo del 69% a ≥80%
**Problema**: última medición JaCoCo = 69%. Módulos nuevos sin cobertura:
- `NotificacionController` / `NotificacionService`
- `UsuarioController` (foto de perfil)
- `AusenciaController`
- `MensajeController`
**Impacto**: el profesor lo valorará. Un TFG con alta cobertura demuestra madurez.
**Solución**: un test de integración por controller — happy path + acceso denegado (403) como mínimo.
**Estimación**: ~3h
**Estado**: [ ] Pendiente

---

## Prioridad MEDIA — Mejora la experiencia

### 4. Notificaciones en tiempo real ✅ PARCIALMENTE RESUELTO
**Problema original**: el badge solo se actualizaba al entrar a la app.
**Solución aplicada hoy**: polling cada 30 segundos con `Timer.periodic`.
**Pendiente**: si hay tiempo, mejorar a WebSocket `/topic/notificaciones/{userId}` (~2h). Si no, el polling es suficiente para el TFG.
**Estado**: [x] Polling 30s implementado — WebSocket opcional

---

## Prioridad BAJA — Calidad técnica / para la memoria

### 5. Rate limiter en memoria (no distribuido)
**Problema**: `RateLimitFilter` usa `ConcurrentHashMap`. No escala a múltiples instancias.
**Solución**: documentar como limitación conocida en la memoria del TFG. Mencionar Redis como solución real.
**Estado**: [ ] Documentar en memoria TFG

### 6. `application-prod.properties` ✅ RESUELTO (12/05/2026)

### 7. `NotificacionProvider` dobles llamadas ✅ RESUELTO (12/05/2026)

---

## Nuevos requisitos (tutoría profesor 12/05/2026)

### 8. Chat tutor empresa ↔ tutor centro
**Requisito**: el profesor pide que haya comunicación entre el tutor de prácticas (empresa) y el tutor del centro. Dice que no hace falta tiempo real, pero nuestra implementación WebSocket ya lo cubre.
**Decisión**: el chat WebSocket actual ya admite 3 participantes (alumno + tutor empresa + tutor centro) en el canal `/topic/practica/{id}`. No requiere cambios técnicos — solo verificar que el tutor centro y el tutor empresa pueden usar el chat de la práctica.
**Estado**: [ ] Verificar y documentar que ya funciona

### 9. Investigar aplicaciones similares de gestión FCT
**Requisito**: el profesor sugiere investigar apps similares para detectar funcionalidades que nos falten y justificar decisiones de diseño en la memoria.
**Solución**: investigar FPEmpresa, Séneca (Junta de Andalucía), IESfácil, Alexia, etc.
**Estado**: [ ] Pendiente — para la memoria del TFG

---

## Registro de mejoras completadas

| Fecha | Mejora |
|-------|--------|
| 12/05/2026 | `ws://localhost:8080/ws` → `ApiClient.wsBaseUrl` dinámico |
| 12/05/2026 | `application-prod.properties` — HikariCP + Actuator restringido |
| 12/05/2026 | `NotificacionProvider` — flag `_cargado` + polling 30s |
| 12/05/2026 | Paquete `excel: ^4.0.6` añadido |
| 10/05/2026 | Fix `LazyInitializationException` WebSocket SUBSCRIBE |
| 10/05/2026 | Enum `EstadoValidacionEmpresa` — cierra A04 OWASP |
| 10/05/2026 | V13 pgcrypto — dependencia explícita en Flyway |
| 10/05/2026 | WebSocket SUBSCRIBE con verificación de participante |
