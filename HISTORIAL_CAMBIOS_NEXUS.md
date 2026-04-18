# HISTORIAL DE CAMBIOS — Nexus TFG
# Complemento al HISTORIAL_CAMBIOS.md del proyecto
# Registra decisiones de rediseño detectadas durante el desarrollo

---

## [18/04/2025] — Rediseño del flujo de validación de seguimientos

### Contexto
Durante la sesión de análisis previo a la implementación del Hito 3 se detectó un error
de lógica en el diseño del módulo de seguimientos.

### Problema
El sistema original tenía un endpoint único `PATCH /seguimientos/{id}/validar` accesible
por cualquier tutor (TUTOR_CENTRO o TUTOR_EMPRESA), con tres estados posibles:
PENDIENTE, VALIDADO, RECHAZADO. Este diseño mezclaba las responsabilidades del tutor
de empresa y del tutor del centro en una misma acción.

### Análisis
En la realidad de las FCT existen dos validaciones distintas:
1. El tutor de empresa firma el parte semanal (valida el trabajo real hecho en la empresa).
2. El tutor del centro da el visto bueno académico (supervisa el proceso formativo).

Son responsabilidades distintas, con información distinta y en momentos distintos.
Permitir que cualquiera de los dos valide directamente al estado final no refleja
el proceso real y elimina la trazabilidad de quién hizo qué.

### Solución
Flujo de doble validación en cascada:
- Cuatro estados: PENDIENTE_EMPRESA, PENDIENTE_CENTRO, COMPLETADO, RECHAZADO
- Dos endpoints separados con @PreAuthorize diferente
- El orden es obligatorio y se valida en el servicio con BusinessRuleException
- El rechazo de empresa genera incidencia automática sin intervención del alumno

### Archivos afectados
- V4__Estados_Seguimiento.sql (nueva migración Flyway)
- SeguimientoServiceImpl.java (separar validar() en dos métodos)
- SeguimientoController.java (dos endpoints nuevos)
- IncidenciaService.java (creación automática en rechazo)
- SeguimientoServiceTest.java (cuatro nuevos casos de negocio)
- ARQUITECTURA_API.md (actualizar contrato)

### Por qué se detectó antes de implementar
La revisión crítica del diseño antes de escribir código es parte del workflow definido
en conductor/workflow.md. El coste de este cambio antes de implementar es bajo.
El mismo cambio tras haber construido el frontend completo habría requerido rehacer
todas las pantallas de validación.

---

## [18/04/2025] — Definición del sistema de diseño visual

### Contexto
El frontend tenía un DashboardScreen funcional pero sin sistema de diseño definido.
Los colores estaban hardcodeados directamente en los widgets.

### Decisión
Definir un sistema de diseño centralizado antes de implementar más pantallas:
- Archivo app_theme.dart con NexusColors y NexusSizes
- Color semántico obligatorio (verde=validado, ámbar=pendiente, rojo=incidencia, azul=activo)
- Navegación adaptativa con LayoutBuilder (web: NavigationRail, móvil: BottomNavigationBar)
- Referencia visual documentada en DESIGN_SYSTEM.md

### Por qué ahora y no después
Definir el sistema de diseño con una sola pantalla implementada es el momento óptimo.
Con más pantallas habría que refactorizar todas. Con ninguna no hay referencia visual real.
