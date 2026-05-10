# Plan de Profesionalización — Nexus TFG

**Contexto**: La dirección del centro va a ver la app. Se acordó añadir features que eleven el nivel visual y funcional antes del 19 mayo 2026.

---

## Features acordadas (8 total)

| # | Feature | Estado | Prioridad |
|---|---------|--------|-----------|
| 1 | Gráficos de progreso (donut + barras horas/semana) | 🔄 En curso | Alta |
| 2 | Ficha completa del alumno (expediente FCT) | ⏳ Pendiente | Alta |
| 3 | Comparativa entre alumnos (panel tutor centro) | ⏳ Pendiente | Alta |
| 4 | Evaluación final del alumno | ⏳ Pendiente | Media |
| 5 | Exportar informe PDF | ⏳ Pendiente | Alta |
| 6 | Notificaciones in-app (badges de pendientes) | ⏳ Pendiente | Media |
| 7 | Timeline visual del alumno | ⏳ Pendiente | Media |
| 8 | Calendario de prácticas | ⏳ Pendiente | Media |

---

## Feature 1 — Gráficos de progreso

### Qué se implementa
- **Donut chart** en el dashboard del alumno: horas completadas vs restantes, con porcentaje en el centro
- **Bar chart "Horas por semana"**: agrupa los seguimientos COMPLETADOS por semana desde el inicio de la práctica

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/pubspec.yaml` | Añadir `fl_chart: ^0.69.0`, `pdf: ^3.10.8`, `printing: ^5.12.0` |
| `frontend/lib/presentation/widgets/nexus_charts.dart` | CREAR — `ProgresoDonutChart` + `HorasSemanaChart` |
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Reemplazar `_ProgressBar` por `ProgresoDonutChart`, añadir card `HorasSemanaChart` |

### Estado
- [x] pubspec.yaml actualizado
- [x] nexus_charts.dart creado
- [ ] dashboard_screen.dart integrado
- [ ] Docker rebuild y test visual

---

## Feature 2 — Ficha completa del alumno

### Qué se implementa
Pantalla/modal accesible desde el panel del tutor de centro al seleccionar un alumno. Muestra toda la información del FCT en un solo vistazo pensado para que lo vea la dirección:
- Cabecera: foto/iniciales, nombre, empresa, código convenio, fechas, estado
- Progreso: donut chart de horas + barra
- Seguimientos: tabla compacta de todos los partes (fecha, horas, estado)
- Incidencias: lista resumen
- Ausencias: contador y lista
- Evaluación final (si existe)
- Botón "Exportar PDF"

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/lib/presentation/screens/ficha_alumno_screen.dart` | CREAR |
| `frontend/lib/presentation/screens/panel_tutor_centro_screen.dart` | Añadir botón "Ver ficha" en `_DetailPanel` |

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
| `V12__Evaluacion_Final.sql` | CREAR — tabla `evaluaciones_finales` |
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
- `pdf: ^3.10.8` — generación del PDF en memoria
- `printing: ^5.12.0` — descarga/impresión en web

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/lib/core/utils/pdf_generator.dart` | CREAR — función `generarInformePDF(practica, seguimientos, ...)` |
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Añadir botón PDF |
| `frontend/lib/presentation/screens/ficha_alumno_screen.dart` | Añadir botón PDF |

---

## Feature 6 — Notificaciones in-app

### Qué se implementa
Badges numéricos en los iconos de la navegación que muestran el número de acciones pendientes:
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
Vista cronológica del FCT: una línea de tiempo vertical con todos los eventos ordenados (inicio práctica, cada parte registrado, rechazos, incidencias, ausencias, cierre). Accesible desde el dashboard del alumno como tab adicional o desde la ficha.

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/lib/presentation/widgets/fct_timeline.dart` | CREAR |
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Integrar en `_InicioTab` o como tab nuevo |

---

## Feature 8 — Calendario de prácticas

### Qué se implementa
Vista de calendario mensual donde el alumno puede ver los días en que registró partes, ausencias, y fechas clave de la práctica. Accesible desde el dashboard.

### Librerías candidatas
- `table_calendar: ^3.1.2` — calendario flexible, compatible con Flutter web

### Archivos involucrados
| Archivo | Acción |
|---------|--------|
| `frontend/pubspec.yaml` | Añadir `table_calendar: ^3.1.2` |
| `frontend/lib/presentation/screens/calendario_screen.dart` | CREAR |
| `frontend/lib/presentation/screens/dashboard_screen.dart` | Añadir tab o botón de acceso |

---

## Orden de implementación recomendado

1. **Feature 1** (gráficos) — ✅ en curso
2. **Feature 2** (ficha completa) — sin backend, solo UI, muy impactante
3. **Feature 3** (comparativa) — sin backend, datos ya disponibles
4. **Feature 5** (PDF) — librerías ya añadidas al pubspec
5. **Feature 4** (evaluación final) — requiere backend + migracion Flyway
6. **Features 6, 7, 8** — si da tiempo antes del 19 mayo

---

## Notas técnicas

- **fl_chart 0.69**: `BarTouchTooltipData` usa `getTooltipColor` (callback), no `tooltipBgColor` (deprecated).
- **pdf + printing**: en Flutter web, `Printing.layoutPdf()` abre el diálogo de impresión del navegador. `Printing.sharePdf()` descarga el archivo directamente.
- **Dark mode**: todos los widgets nuevos deben usar `context.nxt.*` en vez de `NexusColors.*` para colores de texto y fondo. Los colores de acento de los charts pueden ser `NexusColors.primary` (es constante azul que funciona en ambos modos).
