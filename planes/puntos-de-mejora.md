# Puntos de Mejora — Nexus TFG

Actualizado: 10/05/2026 | Entrega final: 19 mayo 2026

---

## Prioridad ALTA — Impacto directo en la nota

### 1. Feature 4 — Evaluación final incompleta
**Problema**: el ciclo de vida de las prácticas no cierra. El alumno nunca recibe una nota formal dentro de la app.
**Impacto**: el tribunal puede señalar que el flujo principal (FCT) no está completo.
**Solución**: V14 migration + entidad `EvaluacionFinal` + controller/service + formulario Flutter en panel tutor centro.
**Estado**: [ ] Pendiente

---

### 2. Tests — Coverage bajo fuera del núcleo
**Problema**: los tests de seguridad (OWASP) y de doble validación están bien, pero los módulos nuevos no tienen tests:
- `NotificacionController` / `NotificacionService` — sin tests
- `UsuarioController` (foto de perfil) — sin tests
- `AusenciaController` — sin tests
- `MensajeController` — sin tests
**Impacto**: el profesor lo valorará. Un TFG con alta cobertura demuestra madurez.
**Solución**: un test de integración por controller, cubriendo al menos el happy path y el caso de acceso denegado.
**Estado**: [ ] Pendiente

---

## Prioridad MEDIA — Mejora la experiencia y la memoria

### 3. Notificaciones no son en tiempo real
**Problema**: el badge de notificaciones solo se actualiza al entrar a la app o al volver de la pantalla de notificaciones. El usuario no sabe que tiene una notificación hasta que lo comprueba manualmente.
**Impacto**: UX claramente limitada en 2026.
**Opciones**:
- A) Polling cada 30 segundos desde `NotificacionProvider` (fácil, 30 min de trabajo)
- B) WebSocket dedicado `/topic/notificaciones/{userId}` (correcto, ~3 horas)
- C) Documentar como limitación conocida en la memoria (si no hay tiempo)
**Estado**: [ ] Pendiente — elegir opción antes del 15 mayo

---

### 4. Feature 5 — Exportar PDF
**Problema**: el botón de exportar PDF existe en `ficha_alumno_screen.dart` pero no hace nada.
**Impacto**: es una feature visible que prometida y no entregada queda peor que no mencionarla.
**Solución**: paquetes `pdf` y `printing` ya instalados. Generar PDF con datos de la práctica, seguimientos y ausencias.
**Estado**: [ ] Pendiente

---

## Prioridad BAJA — Calidad técnica / para la memoria

### 5. Rate limiter en memoria (no distribuido)
**Problema**: `RateLimitFilter` usa `ConcurrentHashMap` en memoria. Si hubiera dos instancias del backend, cada una tendría su propio contador y el límite real sería el doble.
**Impacto**: en producción real sería un bug. Para el TFG está bien, pero hay que nombrarlo.
**Solución recomendada**: documentarlo como limitación conocida en la memoria del TFG. Mencionar Redis como solución real.
**Estado**: [ ] Documentar en memoria

---

### 6. `application-prod.properties` incompleto
**Problema**: el profesor lo señaló. Falta configurar HikariCP (pool size adecuado) y deshabilitar endpoints sensibles de Actuator en producción.
**Solución**:
```properties
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
management.endpoints.web.exposure.include=health,info
```
**Estado**: [ ] Pendiente — 15 minutos de trabajo

---

### 7. `NotificacionProvider` recarga demasiadas veces
**Problema**: el `ChangeNotifierProxyProvider` llama a `cargar()` cada vez que `AuthProvider` cambia, con solo `!cargando` como guardia. Puede generar llamadas duplicadas en ciertos flujos de navegación.
**Impacto**: no visible para el usuario, pero consume llamadas innecesarias al backend.
**Solución**: añadir un flag `_cargado` (bool) además de `_cargando` y solo llamar si `!_cargado && !_cargando`.
**Estado**: [ ] Pendiente — 10 minutos de trabajo

---

## Registro de mejoras completadas

| Fecha | Mejora |
|-------|--------|
| 10/05/2026 | Fix `LazyInitializationException` en WebSocket SUBSCRIBE — `findByIdConParticipantes` con JOIN FETCH |
| 10/05/2026 | Enum `EstadoValidacionEmpresa` — cierra A04 OWASP en validarEmpresa |
| 10/05/2026 | V13 pgcrypto — dependencia explícita en Flyway |
| 10/05/2026 | WebSocket SUBSCRIBE con verificación de participante |
