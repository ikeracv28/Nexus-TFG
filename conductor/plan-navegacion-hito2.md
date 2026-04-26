# Plan — Navegacion funcional del Dashboard (Hito 2, demo 21/04)

## Contexto rapido

Estamos preparando la demo del Hito 2 para manana (21 de abril de 2026).
El backend con JWT + practicas + seguimientos + incidencias esta 100% funcional
y probado con 10/10 tests pasando en Java 21. Docker levanta los 3 contenedores
(nexus-db, nexus-api, nexus-web) sin errores y la migracion V4 deja datos de prueba:

- Practica activa FCT-2025-001 (EjemploTech S.L., 240h, alumno@nexus.edu)
- 3 seguimientos: 1 COMPLETADO (8h) + 1 VALIDADO (8h) + 1 PENDIENTE (8h)
- 1 incidencia ABIERTA tipo ACCESO

La app Flutter corriendo en http://localhost:3000 ya muestra todo esto
con el sistema visual Nexus (colores desde `core/theme/app_theme.dart`).
El boton "Registrar seguimiento" abre `SeguimientoScreen` y funciona.

## Lo que no funciona (problema a resolver)

En el dashboard actual, el `_navIndex` del state cambia al pulsar los items
del `NavigationRail` (web) o `BottomNavigationBar` (movil), pero el contenido
del Scaffold no cambia porque siempre se renderiza `_DashboardContent`.

Sintomas visibles en la demo:

- Pulsar los iconos de la izquierda (web) o los tabs de abajo (movil) no
  navega a ninguna pantalla. Solo marca el item como seleccionado.
- El boton "Ver todos" en el card de Seguimientos no hace nada (onPressed vacio).
- El boton "Reportar" en el card de Incidencias no hace nada.

## Objetivo de esta tarea

Que la navegacion del dashboard sea funcional. Al pulsar un item del
nav lateral/inferior se cambia de pantalla. "Ver todos" y "Reportar"
tambien navegan a la pantalla correspondiente.

Chat NO se implementa todavia — dejamos un placeholder "Proximamente"
estilo Nexus.

## Arquitectura a implementar

Mantenemos la estructura actual (Provider + Navigator imperativo). No
metemos go_router aun porque para el Hito 2 solo necesitamos 4 pantallas
y un switch de contenido. go_router entra en Hito 3 cuando tengamos
guards por rol.

Cambio concreto: el `DashboardScreen` deja de mostrar un `_DashboardContent`
fijo y pasa a usar un `IndexedStack` que mantiene las 4 pantallas vivas
en memoria (preserva scroll y estado). El `_navIndex` decide cual se pinta.

```
DashboardScreen (Scaffold + NavigationRail/BottomNav)
  body: IndexedStack(index: _navIndex, children: [
    _InicioTab()         <- el contenido actual del dashboard (lo refactorizamos)
    SeguimientosScreen() <- lista completa de partes
    IncidenciasScreen()  <- lista de incidencias + boton "Reportar"
    _ChatPlaceholder()   <- pantalla "Proximamente"
  ])
```

## Pasos concretos de implementacion

### Paso 1 — Refactorizar DashboardScreen

En `frontend/lib/presentation/screens/dashboard_screen.dart`:

1. Extraer todo el `_DashboardContent` (el `SingleChildScrollView` con
   saludo, card de practica, grid de seguimientos/incidencias, acciones
   rapidas) a una clase independiente `_InicioTab extends StatelessWidget`.

2. Reemplazar el `body` del Scaffold por un `IndexedStack` con 4 hijos.
   Mantener el `LayoutBuilder` para el NavigationRail/BottomNav.

3. Pasar el callback `onVerTodosSeguimientos` a `_InicioTab` (para el
   "Ver todos" del card) que simplemente hace `setState(() => _navIndex = 1)`.

4. Mismo callback `onReportarIncidencia` que hace `_navIndex = 2`.

### Paso 2 — Crear SeguimientosScreen

Nuevo archivo `frontend/lib/presentation/screens/seguimientos_screen.dart`.

- Escucha al `PracticaProvider` y pinta TODOS los seguimientos (no solo
  los 3 primeros como en el dashboard).
- Reusar el widget `_SeguimientoTile` — mover `dashboard_screen.dart`
  a un archivo compartido `presentation/widgets/seguimiento_tile.dart`
  (public, sin underscore) y exportarlo desde ambas pantallas.
- Cabecera con total de horas completadas vs totales (reutilizar
  `provider.horasCompletadas` del PracticaProvider).
- Boton flotante (FloatingActionButton) para navegar a `SeguimientoScreen`
  (la pantalla de registro que ya existe).
- Empty state si no hay seguimientos: "Aun no has registrado ningun parte".

Estructura minima:

```dart
class SeguimientosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PracticaProvider>(
      builder: (_, provider, __) {
        final seguimientos = provider.seguimientos;
        return Scaffold(
          backgroundColor: NexusColors.surfaceAlt,
          body: RefreshIndicator(
            onRefresh: provider.cargarDashboard,
            child: ListView(
              padding: EdgeInsets.all(NexusSizes.space2XL),
              children: [
                _HeaderHoras(
                  completadas: provider.horasCompletadas,
                  totales: provider.practicaActiva?.horasTotales ?? 0,
                ),
                SizedBox(height: NexusSizes.space2XL),
                ...seguimientos.map((s) => SeguimientoTile(seguimiento: s)),
                if (seguimientos.isEmpty) _EmptySeguimientos(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SeguimientoScreen()),
            ),
            icon: Icon(Icons.add),
            label: Text('Nuevo parte'),
            backgroundColor: NexusColors.primary,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }
}
```

### Paso 3 — Crear IncidenciasScreen

Nuevo archivo `frontend/lib/presentation/screens/incidencias_screen.dart`.

- Lista completa de incidencias (reutilizar `IncidenciaTile` como widget
  compartido igual que con seguimientos).
- Boton "Reportar incidencia" arriba (no FAB, que sea boton outline
  en linea) que abre un `_ReportarIncidenciaBottomSheet`.
- El bottom sheet tiene dos campos: tipo (dropdown: ACCESO, AUSENCIA,
  COMPORTAMIENTO, ACCIDENTE, OTROS) y descripcion (textarea).
- Al enviar llama a `POST /api/v1/incidencias` — PERO este endpoint
  NO existe todavia (solo tenemos GET). Hay que crearlo.

Para que el boton Reportar funcione hay que anadir antes en el backend:

- DTO `IncidenciaRequest` (record con `tipo` y `descripcion`).
- En `IncidenciaController` anadir:

```java
@PostMapping
@PreAuthorize("hasAnyRole('ALUMNO', 'TUTOR_CENTRO', 'TUTOR_EMPRESA')")
public ResponseEntity<IncidenciaResponse> crear(
    @Valid @RequestBody IncidenciaRequest request) {
    // Obtener alumno autenticado via SecurityContextHolder
    // Buscar su practica ACTIVA
    // Crear Incidencia con estado ABIERTA
    // Guardar y devolver IncidenciaResponse
}
```

Flutter: nuevo metodo en `IncidenciaService.reportar()` que llame al POST.

### Paso 4 — Chat placeholder

Nuevo archivo `frontend/lib/presentation/screens/chat_placeholder_screen.dart`.

Pantalla minimal con icono grande de chat, texto "Chat en tiempo real"
y subtexto "Disponible en el Hito 3". Usar los mismos estilos Nexus.

### Paso 5 — Navegacion en DashboardScreen

Modificar el `_navIndex` del State para que realmente cambie la pantalla
via IndexedStack. El `onDestinationSelected` del `NavigationRail` y el
`onTap` del `BottomNavigationBar` ya estan bien — solo falta que el body
reaccione.

```dart
body: LayoutBuilder(
  builder: (context, constraints) {
    final isWide = constraints.maxWidth > 600;
    final content = IndexedStack(
      index: _navIndex,
      children: [
        _InicioTab(
          onVerTodosSeguimientos: () => setState(() => _navIndex = 1),
          onReportarIncidencia: () => setState(() => _navIndex = 2),
        ),
        const SeguimientosScreen(),
        const IncidenciasScreen(),
        const ChatPlaceholderScreen(),
      ],
    );
    if (isWide) {
      return Row(children: [
        _NexusRail(
          selectedIndex: _navIndex,
          onDestinationSelected: (i) => setState(() => _navIndex = i),
        ),
        const VerticalDivider(width: 1, thickness: 0.5, color: NexusColors.border),
        Expanded(child: content),
      ]);
    }
    return content;
  },
),
```

### Paso 6 — Conectar "Ver todos" y "Reportar" del Inicio

En los cards del `_InicioTab` los botones ya no estan con `onPressed: () {}`.
Reciben por constructor el callback y lo invocan.

```dart
// En _SectionCard: action ahora tambien recibe onActionTap.
// En _SeguimientosCard: action='Ver todos', onActionTap=onVerTodosSeguimientos.
// En _IncidenciasCard: action='Reportar', onActionTap=onReportarIncidencia.
```

### Paso 7 — Commit

```
feat: navegacion funcional del dashboard con IndexedStack + pantallas completas

- Refactor DashboardScreen: IndexedStack de 4 tabs con navigation lateral/inferior
- Nueva SeguimientosScreen con lista completa y FAB para nuevo parte
- Nueva IncidenciasScreen con listado y bottom sheet para reportar
- POST /api/v1/incidencias para que el alumno reporte desde la app
- ChatPlaceholderScreen como placeholder profesional (Hito 3)
- Widgets compartidos: SeguimientoTile e IncidenciaTile movidos a presentation/widgets/
```

## Como probar antes de commitear

1. Tests backend: `JAVA_HOME="C:/Program Files/Eclipse Adoptium/jdk-21.0.10.7-hotspot" ./mvnw test`
   Debe seguir siendo 10/10 + los nuevos tests del POST de incidencias.

2. Reconstruir la app web: `docker compose up -d --build frontend backend`

3. Manual testing en http://localhost:3000 como alumno@nexus.edu / 123456:
   - Pulsar cada tab de la barra lateral/inferior → cambia contenido.
   - "Ver todos" en Inicio → navega al tab Seguimientos.
   - "Reportar" en Inicio → navega al tab Incidencias.
   - FAB en Seguimientos → abre pantalla de registro (ya existente).
   - "Reportar incidencia" en Incidencias → bottom sheet → POST real.
   - Tab Chat → pantalla placeholder bonita.

## Reglas de oro a respetar (del CLAUDE.md)

- Colores SIEMPRE desde `NexusColors`. Cero hardcode.
- Verde = validado/exito, ambar = pendiente, rojo = rechazado/incidencia,
  azul = activo.
- Adaptativo web/movil con `LayoutBuilder` (ancho > 600px).
- DTOs en el backend, nunca exponer entidades. Mapper si aplica.
- `@PreAuthorize` en cada endpoint nuevo.
- Reglas de negocio en el servicio, no en el controller.
- Commits por bloques funcionales completos, en espanol explicando el por que.

## Archivos que vas a tocar

Backend:
- NUEVO `models/dto/IncidenciaRequest.java`
- MODIFICAR `controllers/IncidenciaController.java` (anadir POST)

Frontend:
- MODIFICAR `presentation/screens/dashboard_screen.dart` (refactor grande)
- NUEVO `presentation/screens/seguimientos_screen.dart`
- NUEVO `presentation/screens/incidencias_screen.dart`
- NUEVO `presentation/screens/chat_placeholder_screen.dart`
- NUEVO `presentation/widgets/seguimiento_tile.dart`
- NUEVO `presentation/widgets/incidencia_tile.dart`
- MODIFICAR `data/services/incidencia_service.dart` (metodo reportar)

## Lo que NO hay que hacer

- NO migrar a go_router todavia. Eso es Hito 3.
- NO implementar el chat real. Solo placeholder.
- NO tocar la validacion doble de seguimientos. Eso tambien es Hito 3.
- NO anadir nuevos estados o cambiar el flujo del backend existente.
