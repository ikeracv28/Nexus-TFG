# Plan de Profesionalización — Nexus TFG

**Contexto**: La dirección del centro va a ver la app. Se acordó añadir features que eleven el nivel visual y funcional antes del 19 mayo 2026.

---

## Features acordadas (9 total)

| # | Feature | Estado | Prioridad |
|---|---------|--------|-----------|
| 1 | Gráficos de progreso (donut + barras horas/semana) | ✅ Completado | Alta |
| 2 | Ficha completa del alumno (expediente FCT) | ✅ Completado | Alta |
| 3 | Comparativa entre alumnos (panel tutor centro) | ⏳ Pendiente | Alta |
| 4 | Evaluación final del alumno | ⏳ Pendiente | Media |
| 5 | Exportar informe PDF | ⏳ Pendiente | Alta |
| 6 | Notificaciones in-app (badges de pendientes) | ⏳ Pendiente | Media |
| 7 | Timeline visual del alumno | ⏳ Pendiente | Media |
| 8 | Calendario de prácticas | ⏳ Pendiente | Media |
| 9 | Perfil de usuario con foto | ✅ Completado | Alta |

---

## Feature 1 — Gráficos de progreso ✅

### Qué se implementó
- **Donut chart** en el dashboard del alumno: horas completadas vs restantes, con porcentaje en el centro
- **Bar chart "Horas por semana"**: agrupa los seguimientos COMPLETADOS por semana desde el inicio de la práctica

### Archivos modificados
| Archivo | Acción |
|---------|--------|
| `frontend/pubspec.yaml` | Añadido `fl_chart: ^0.69.0`, `pdf: ^3.10.8`, `printing: ^5.12.0` |
| `frontend/lib/presentation/widgets/nexus_charts.dart` | CREADO — `ProgresoDonutChart` + `HorasSemanaChart` |
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Reemplazado `_ProgressBar` por `ProgresoDonutChart`, añadida card `HorasSemanaChart` |

---

## Feature 2 — Ficha completa del alumno ✅

### Qué se implementó
Pantalla completa accesible desde el panel del tutor de centro al pulsar el icono "Ver ficha" junto al alumno seleccionado. Muestra el expediente FCT completo:
- Cabecera con iniciales/foto, nombre, empresa, código convenio, fechas, estado
- Progreso FCT: donut chart de horas + datos numéricos
- Tabla de seguimientos (fecha, horas, estado con badge de color)
- Lista de incidencias (tipo, estado, descripción)
- Ausencias con contador diferenciado por tipo

### Archivos modificados
| Archivo | Acción |
|---------|--------|
| `frontend/lib/presentation/screens/ficha_alumno_screen.dart` | CREADO |
| `frontend/lib/presentation/screens/panel_tutor_centro_screen.dart` | Añadido botón "Ver ficha" (Icons.open_in_new) en `_DetailPanel` |
| `frontend/lib/presentation/providers/tutor_centro_provider.dart` | Añadido getter `ausenciasDe()` |

---

## Feature 9 — Perfil de usuario con foto ✅

### Qué se implementó
- Foto de perfil subible por el propio usuario (JPG/PNG/WebP, máx. 5 MB)
- Avatar con foto en TODOS los paneles: dashboard alumno, tutor empresa, tutor centro, admin
- Los tutores ven la foto del alumno asignado (en partes, ausencias, progreso, lista de alumnos)
- Al cambiar la foto en el perfil, se actualiza en tiempo real en toda la app (sin recarga)
- Fallback a iniciales si el usuario no tiene foto

### Arquitectura
- `FotoCache` — mapa estático `{userId → bytes}` + `ValueNotifier` para notificaciones globales
- `NexusAvatar` — widget reutilizable que escucha el cache y se auto-refresca
- `PerfilProvider` global (via `ChangeNotifierProxyProvider`) — se carga al autenticarse
- `FotoCache.set()` tras subir foto → todos los `NexusAvatar` con ese userId se actualizan al instante

### Archivos creados/modificados
| Archivo | Acción |
|---------|--------|
| `V12__Foto_Perfil.sql` | CREADO — `ALTER TABLE usuarios ADD COLUMN foto_perfil BYTEA, foto_content_type VARCHAR(50)` |
| `Usuario.java` | Añadidos campos `fotoPerfil` y `fotoContentType` |
| `UsuarioResponse.java` | Añadido `boolean tieneFoto` |
| `UsuarioMapper.java` | Método `default toResponse()` que calcula `tieneFoto` manualmente |
| `UsuarioService.java` / `UsuarioServiceImpl.java` | Métodos `uploadFoto()` y `getFoto()` con validación MIME y límite 5 MB |
| `UsuarioController.java` | `POST /me/foto` + `GET /{id}/foto` |
| `GlobalExceptionHandler.java` | Handler para `IllegalArgumentException` → 400 Bad Request |
| `application.properties` | Límites multipart subidos a 10 MB |
| `auth_models.dart` | `User` con `tieneFoto` + `copyWith()` |
| `usuario_service.dart` | CREADO — `getMe()`, `uploadFoto()`, `downloadFoto()` |
| `foto_cache.dart` | CREADO — cache estático global |
| `nexus_avatar.dart` | CREADO — widget `NexusAvatar` reutilizable |
| `perfil_provider.dart` | CREADO — ChangeNotifier global con upload y cache |
| `perfil_screen.dart` | CREADO — pantalla de perfil con foto, info, dark mode |
| `main.dart` | Añadido `PerfilProvider` via `ChangeNotifierProxyProvider` |
| `dashboard_screen.dart` | Avatar → NexusAvatar + navegación a PerfilScreen |
| `panel_tutor_empresa_screen.dart` | Sidebar + _ParteCard + _AusenciaEmpresaCard → NexusAvatar |
| `panel_tutor_centro_screen.dart` | Sidebar + _StudentItem + _IncidenciaRow + comparativa → NexusAvatar |
| `panel_admin_screen.dart` | Botón perfil en sidebar |

---

## Feature 3 — Comparativa entre alumnos

### Qué se implementa
Vista nueva en el panel del tutor de centro (nuevo modo en el sidebar). Tabla con todos los alumnos en columnas comparativas:
- Nombre + empresa
- Barra de progreso de horas (visual)
- % completado
- Partes pendientes de validar
- Incidencias abiertas
- Ausencias injustificadas
- Estado general (semáforo: verde/amarillo/rojo)

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/lib/presentation/screens/panel_tutor_centro_screen.dart` | Añadir `_Mode.comparativa` + `_ComparativaPanel` widget |

---

## Feature 4 — Evaluación final del alumno

### Qué se implementa
Formulario que el tutor de centro rellena al cerrar la práctica. Criterios con nota del 1 al 5 + observaciones + nota final. Visible para el alumno al terminar.

### Archivos involucrados (backend)
| Archivo | Acción |
|---------|--------|
| `V13__Evaluacion_Final.sql` | CREAR — tabla `evaluaciones_finales` |
| `EvaluacionFinal.java` | CREAR entidad |
| `EvaluacionFinalController.java` | CREAR — POST/GET por práctica |
| `EvaluacionFinalService.java` | CREAR |

### Archivos involucrados (Flutter)
| Archivo | Acción |
|---------|--------|
| `frontend/lib/data/models/evaluacion_model.dart` | CREAR |
| `frontend/lib/data/services/evaluacion_service.dart` | CREAR |
| `frontend/lib/presentation/screens/evaluacion_screen.dart` | CREAR |

---

## Feature 5 — Exportar informe PDF

### Qué se implementa
Botón "Descargar informe" accesible desde la ficha del alumno y desde el dashboard del propio alumno. Genera un PDF con:
- Logo/cabecera Nexus
- Datos del alumno y empresa
- Tabla de seguimientos validados
- Resumen de horas e incidencias
- Firma del tutor (texto)

### Librerías
- `pdf: ^3.10.8` — ya añadida al pubspec
- `printing: ^5.12.0` — ya añadida al pubspec

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/lib/core/utils/pdf_generator.dart` | CREAR — función `generarInformePDF(practica, seguimientos, ...)` |
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Añadir botón PDF |
| `frontend/lib/presentation/screens/ficha_alumno_screen.dart` | Activar botón PDF (ya tiene el placeholder con `onPressed: null`) |

---

## Feature 6 — Notificaciones in-app

### Qué se implementa
Badges numéricos en los iconos de la navegación:
- Tutor empresa: partes sin validar
- Tutor centro: partes pendientes de VB + incidencias abiertas
- Alumno: ausencias pendientes de revisión

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Badge en tab de ausencias/seguimientos |
| `frontend/lib/presentation/screens/panel_tutor_empresa_screen.dart` | Badge en el tab de partes |
| `frontend/lib/presentation/screens/panel_tutor_centro_screen.dart` | Badges en sidebar (ya existen parcialmente) |

---

## Feature 7 — Timeline visual del alumno

### Qué se implementa
Vista cronológica del FCT: línea de tiempo vertical con todos los eventos ordenados (inicio práctica, cada parte registrado, rechazos, incidencias, ausencias, cierre). Accesible desde el dashboard del alumno.

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/lib/presentation/widgets/fct_timeline.dart` | CREAR |
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Integrar como tab nuevo |

---

## Feature 8 — Calendario de prácticas

### Qué se implementa
Vista de calendario mensual donde el alumno puede ver los días en que registró partes, ausencias, y fechas clave. Accesible desde el dashboard.

### Librerías candidatas
- `table_calendar: ^3.1.2`

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/pubspec.yaml` | Añadir `table_calendar: ^3.1.2` |
| `frontend/lib/presentation/screens/calendario_screen.dart` | CREAR |
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Añadir tab o botón de acceso |

---

## Orden de implementación recomendado (pendiente)

1. **Feature 3** (comparativa) — sin backend, datos ya disponibles
2. **Feature 5** (PDF) — librerías ya añadidas al pubspec, placeholder ya existe
3. **Feature 4** (evaluación final) — requiere backend + migración Flyway (V13)
4. **Features 6, 7, 8** — si da tiempo antes del 19 mayo

---

## Notas técnicas

- **fl_chart 0.69**: `BarTouchTooltipData` usa `getTooltipColor` (callback), no `tooltipBgColor` (deprecated).
- **pdf + printing**: en Flutter web, `Printing.layoutPdf()` abre el diálogo de impresión del navegador.
- **Dark mode**: todos los widgets nuevos deben usar `context.nxt.*` en vez de `NexusColors.*` para colores de texto y fondo.
- **NexusAvatar**: siempre pasar `userId` y `nombre`. No usar `CircleAvatar` directamente para usuarios.
- **FotoCache**: el backend devuelve 404 si no hay foto → `NexusAvatar` lo captura con `catch (_)` y guarda `null` en cache (no reintenta).
- **Migración V12**: añade `foto_perfil BYTEA` y `foto_content_type VARCHAR(50)` a `usuarios`. Usar `columnDefinition = "bytea"` en la entidad (no `@Lob`) para evitar el problema de OID en Hibernate 6 + PostgreSQL.
