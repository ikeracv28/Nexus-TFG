# Nexus TFG — Gestión de Prácticas Académicas
# Configuración para Claude Code — Iker Acevedo Donate / CampusFP

---

## Identidad del Proyecto

- **Autor**: Iker Acevedo Donate
- **Institución**: CampusFP
- **Propósito**: TFG — Plataforma centralizada para gestión del ciclo de prácticas académicas (FCT).
- **Problema**: Sustituir correos, Excel y llamadas por una app única con chat real, seguimiento de horas, gestión de incidencias y paneles por rol.

---

## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| Backend | Java 21 + Spring Boot 3.4.1 |
| Seguridad | Spring Security + JWT (jjwt 0.12.5) |
| Persistencia | PostgreSQL + Hibernate (JPA) + Flyway |
| Mapeo | MapStruct 1.6.3 + Lombok |
| Frontend | Flutter (Dart) — SDK ^3.11.4 |
| Estado Flutter | Provider 6.1.1 |
| HTTP Flutter | Dio 5.4.0 + flutter_secure_storage |
| Navegación | go_router 13.2.0 |
| Infraestructura | Docker Compose (db + backend + frontend/Nginx) |

---

## Estructura del Repositorio

```
TFG/
├── CLAUDE.md                        ← este archivo (leer siempre al iniciar)
├── DESIGN_SYSTEM.md                 ← sistema visual Flutter completo
├── MEMORIA_ACTUALIZACIONES.md       ← fragmentos listos para copiar en la memoria Word
├── HISTORIAL_CAMBIOS.md             ← bitácora técnica de decisiones
├── ARQUITECTURA_API.md              ← contrato REST completo
├── docker-compose.yml
├── conductor/
│   ├── tracks/                      ← planes de implementación por fase
│   ├── product.md
│   ├── tech-stack.md
│   └── workflow.md
├── backend/tfg-nexus-api/
│   └── src/main/java/com/tfg/api/
│       ├── controllers/             ← Auth, Practica, Seguimiento, Centro, Empresa, Usuario
│       ├── services/impl/
│       ├── models/entity/           ← Usuario, Practica, Seguimiento, Incidencia, Mensaje, Notificacion
│       ├── models/dto/
│       ├── models/mapper/           ← MapStruct
│       ├── models/repository/
│       ├── security/                ← JwtUtils, Filter, UserDetailsServiceImpl
│       ├── config/                  ← SecurityConfig
│       └── exceptions/
└── frontend/lib/
    ├── core/
    │   ├── config/api_client.dart
    │   └── theme/app_theme.dart     ← sistema de colores y estilos (crear en Hito 3)
    ├── data/models/
    ├── data/services/
    ├── presentation/providers/
    └── presentation/screens/
```

---

## Comandos Esenciales

### Backend
```bash
# Desde backend/tfg-nexus-api/
./mvnw spring-boot:run          # Arrancar API en :8080
./mvnw clean install            # Compilar y empaquetar
./mvnw test                     # Ejecutar todos los tests
./mvnw flyway:info              # Ver estado de migraciones
```

### Frontend
```bash
# Desde frontend/
flutter pub get                 # Instalar dependencias
flutter run -d chrome           # Ejecutar en web
flutter run                     # Ejecutar en emulador/dispositivo
flutter test                    # Tests
```

### Docker (entorno completo)
```bash
# Desde TFG/
docker-compose up -d            # Levantar todo (BD + API + Web)
docker-compose down             # Parar todo
docker-compose logs -f backend  # Logs del backend en tiempo real
```

### Usuarios de prueba (seed V3)
| Email | Contraseña | Rol |
|-------|-----------|-----|
| admin@nexus.edu | admin123 | ADMIN |
| tutor@nexus.edu | 123456 | TUTOR_CENTRO |
| alumno@nexus.edu | 123456 | ALUMNO |

> Pendiente: añadir usuario de prueba para TUTOR_EMPRESA en migración V4 o V5.

---

## Roles del Sistema — Lógica Completa

| Rol | Propósito real | Pantalla principal |
|-----|---------------|--------------------|
| ROLE_ALUMNO | El estudiante en prácticas | Dashboard con progreso, seguimientos, incidencias, chat |
| ROLE_TUTOR_CENTRO | Tutor del instituto — supervisa lo académico | Panel con lista de alumnos, validación final, incidencias, chat |
| ROLE_TUTOR_EMPRESA | Responsable en la empresa — valida el trabajo real | Pantalla minimalista solo para firmar partes semanales |
| ROLE_ADMIN | Administrador del centro educativo | CRUD completo de prácticas, usuarios, empresas, centros |

### Distinción crítica entre los dos tutores

**TUTOR_EMPRESA** — valida el trabajo real (equivale a la firma en papel actual):
- Recibe aviso cuando el alumno registra un parte semanal.
- Puede validar o rechazar (rechazo requiere motivo obligatorio).
- Su pantalla es minimalista: lista de partes pendientes de firma + botones.
- NO tiene acceso a chat, incidencias, ni historial académico.
- Es la primera validación. Sin ella, el tutor del centro no puede actuar.

**TUTOR_CENTRO** — supervisa el proceso formativo global:
- Solo ve los partes que ya pasaron por el tutor de empresa.
- Da el visto bueno final (segunda y definitiva validación).
- Tiene acceso completo a incidencias y chat con el alumno.
- Es el interlocutor del alumno cuando hay un problema con la empresa.
- Recibe notificación automática si el tutor de empresa rechaza un parte.

---

## Lógica de Validación de Seguimientos — DISEÑO DEFINITIVO

Acordado el 18/04/2025. Reemplaza el flujo anterior de validación simple.

### Estados del seguimiento

```
PENDIENTE_EMPRESA  → Alumno registró el parte. Esperando firma del tutor de empresa.
PENDIENTE_CENTRO   → Tutor de empresa lo validó. Esperando visto bueno del tutor del centro.
COMPLETADO         → Ambos tutores validaron. Horas contabilizadas en el progreso.
RECHAZADO          → Tutor de empresa lo rechazó. Se crea incidencia automática.
```

La migración V4 actualiza el campo `estado` en `seguimientos`:
- `PENDIENTE` existente pasa a ser `PENDIENTE_EMPRESA`.
- `VALIDADO` existente pasa a ser `COMPLETADO`.

### Flujo paso a paso

1. Alumno registra un parte (fecha, horas, descripción). Estado: `PENDIENTE_EMPRESA`.
2. Tutor de empresa recibe aviso y decide:
   - **Valida**: estado pasa a `PENDIENTE_CENTRO`. Tutor del centro recibe aviso.
   - **Rechaza** (motivo obligatorio): estado pasa a `RECHAZADO`. Se crea automáticamente
     una Incidencia de tipo `RECHAZO_PARTE` vinculada a la práctica. El tutor del centro
     la ve en su panel. El alumno corrige y reenvía el parte.
3. Tutor del centro revisa el parte (ya validado por empresa) y da el visto bueno.
   Estado pasa a `COMPLETADO`. Las horas se suman al progreso de la práctica.

### Reglas de negocio en el servicio (nunca en el controller)

```java
// validarEmpresa(): solo actúa sobre PENDIENTE_EMPRESA
if (!seguimiento.getEstado().equals("PENDIENTE_EMPRESA")) {
    throw new BusinessRuleException("Este parte ya fue procesado por la empresa");
}

// validarCentro(): solo actúa sobre PENDIENTE_CENTRO
if (!seguimiento.getEstado().equals("PENDIENTE_CENTRO")) {
    throw new BusinessRuleException(
        "El parte debe ser validado por la empresa antes de que el centro actúe"
    );
}

// Al rechazar: crear incidencia automática
if (nuevoEstado.equals("RECHAZADO")) {
    Incidencia incidencia = Incidencia.builder()
        .practica(seguimiento.getPractica())
        .creadaPor(tutorEmpresa)
        .tipo("RECHAZO_PARTE")
        .descripcion("Parte rechazado. Motivo: " + motivo)
        .estado("ABIERTA")
        .build();
    incidenciaRepository.save(incidencia);
}
```

### Endpoints nuevos en SeguimientoController

```
PATCH /api/v1/seguimientos/{id}/validar-empresa
  @PreAuthorize("hasRole('TUTOR_EMPRESA')")
  Params: nuevoEstado (PENDIENTE_CENTRO | RECHAZADO), motivo (obligatorio si RECHAZADO)

PATCH /api/v1/seguimientos/{id}/validar-centro
  @PreAuthorize("hasRole('TUTOR_CENTRO')")
  Params: ninguno (solo puede completar, no rechazar en esta fase)
```

### Orden de implementación obligatorio

1. Migración V4 (estados nuevos en BD + seed tutor empresa prueba).
2. IncidenciaRepository e IncidenciaService básico (necesario para el rechazo automático).
3. Refactorizar SeguimientoServiceImpl: separar en validarEmpresa() y validarCentro().
4. Actualizar SeguimientoController con los dos nuevos endpoints.
5. Tests de los cuatro casos de negocio (validar empresa, rechazar empresa, validar centro, saltarse el orden).
6. Flutter: pantalla tutor empresa (validacion_empresa_screen.dart).
7. Flutter: actualizar pantalla tutor centro con segunda fase de validación.

---

## Estado Actual del Proyecto

### Hito 2 (50%) — Completado

- [x] Autenticación JWT completa (registro, login, token con roles en claims)
- [x] CRUD completo de Prácticas con estados (BORRADOR / ACTIVA / FINALIZADA)
- [x] Sistema de Seguimientos base (registro, validación simple — refactorizar en Hito 3)
- [x] Entidades JPA completas: Usuario, Practica, Seguimiento, Incidencia, Mensaje, Notificacion
- [x] Seguridad por roles con @PreAuthorize en todos los endpoints
- [x] Tests de integración: AuthController, PracticaController, SeguimientoService
- [x] Flutter: LoginScreen funcional conectada a la API
- [x] Flutter: DashboardScreen con datos reales de la práctica activa
- [x] Docker Compose con healthcheck y red interna

### CORRECCIONES PREVIAS A LA ENTREGA DEL HITO 2
> Resolver ANTES de continuar con features nuevas. Menos de 1 hora en total.

- [ ] FIX-1: JWT Secret — el fallback en JwtUtils.java es texto plano en el repo.
  Generar clave aleatoria real (64+ caracteres) en .env. El fallback queda como CAMBIAR_EN_PRODUCCION.

- [ ] FIX-2: Rol.java usa @Data. Cambiar a @Getter + @Setter + @EqualsAndHashCode(of = "id").

- [ ] FIX-3: Dos lanzamientos de RuntimeException en PracticaServiceImpl.
  Reemplazar por BusinessRuleException. El GlobalExceptionHandler devolverá 409 en vez de 500.

- [ ] FIX-4: BBDD-TFG.sql sin cabecera. Añadir comentario explicando que es referencia histórica
  y que Flyway (V1__Esquema_Inicial.sql) es la única fuente de verdad del esquema.

- [ ] FIX-5: Sin perfiles Spring. Crear application-dev.properties y application-prod.properties.

- [ ] FIX-6: PracticaController.listarTodas() devuelve List sin paginar.
  Cambiar a Page<PracticaResponse> con Pageable como parámetro.

### Pendiente — Hito 3

- [ ] [BACKEND] Migración Flyway V4: nuevos estados de seguimientos + seed tutor empresa
- [ ] [BACKEND] IncidenciaController + IncidenciaService completos
- [ ] [BACKEND] Refactorizar SeguimientoServiceImpl: doble validación con incidencia automática
- [ ] [BACKEND] Tests del nuevo flujo (4 casos de negocio obligatorios)
- [ ] [BACKEND] WebSocket/STOMP para chat en tiempo real
- [ ] [FLUTTER] Crear core/theme/app_theme.dart con NexusColors y NexusSizes
- [ ] [FLUTTER] Configurar go_router con rutas por rol y guards de autenticación
- [ ] [FLUTTER] Navegación adaptativa: NavigationRail en web, BottomNavigationBar en móvil
- [ ] [FLUTTER] Pantalla de registro de seguimiento (alumno)
- [ ] [FLUTTER] Pantalla de validación del tutor de empresa (minimalista, solo firma partes)
- [ ] [FLUTTER] Panel del tutor del centro (lista alumnos, segunda validación, incidencias)
- [ ] [FLUTTER] Pantalla de incidencias (alumno y tutor centro)
- [ ] [FLUTTER] Pantalla de chat (WebSocket)
- [ ] [FLUTTER] Contador visual de horas (suma seguimientos COMPLETADOS vs horasTotales)

---

## Reglas de Oro (Iron Rules)

### Código
- Entidad nueva en backend siempre con migración Flyway VN__Descripcion.sql.
- Endpoint nuevo siempre documentado en ARQUITECTURA_API.md antes de implementar.
- Los DTOs protegen siempre las entidades JPA. Nunca exponer entidades en controllers.
- Los mapeos van en MapStruct. Nunca mapear a mano en el servicio.
- Las transiciones de estado se validan en el servicio, no en el controller.
- El orden empresa-primero-centro-después es una regla de negocio inviolable en el servicio.

### Diseño Visual Flutter
- Todos los colores vienen de NexusColors en app_theme.dart. Nunca hardcodear colores en pantallas.
- Verde para validado/éxito, ámbar para pendiente, rojo para rechazado/incidencia, azul para activo.
- Pantallas adaptativas con LayoutBuilder (ancho > 600px = web con NavigationRail).
- Consultar DESIGN_SYSTEM.md antes de implementar cualquier pantalla nueva.

### Git
- Commits por bloques funcionales completos (no por archivo, no acumulando semanas).
- Commit tras completar: endpoint + servicio + test (backend); pantalla conectada a API (Flutter).
- Push tras cada commit de feature completa y siempre antes de terminar sesión.
- Mensajes en español explicando el por qué, no el qué.

### Memoria del TFG
- Cada feature completada genera bloque listo para copiar en MEMORIA_ACTUALIZACIONES.md.
- Primera persona, tono académico cercano, cada decisión con su justificación.

### Rol Pedagógico
- Flutter: explicar el concepto antes del código. Iker no tiene experiencia con Flutter.
- Cambios arquitectónicos: explicar el por qué con diagrama antes de implementar.
- Las explicaciones van ANTES del código, nunca después.

### Comunicación
- Español técnico. Sin raya larga (em dash). Actitud crítica. Voz activa. Sin rellenos.

---

## Contexto del Evaluador

El tutor corrige con dos IAs: una local entrenada por él y Claude en la nube.

Valora: arquitectura por capas limpia, JWT funcional con roles, decisiones justificadas por escrito,
tests reales con casos de negocio, coherencia doc/código, sin secretos en repo.

Penaliza: inconsistencias doc/código, excepciones genéricas con info interna,
features en la memoria inexistentes en el código, código sin tests.

---

## Decisiones Técnicas Registradas

**Flyway sobre ddl-auto=update**: Control total y auditable. update puede destruir datos en producción.

**MapStruct sobre mapeo manual**: Genera código en compilación sin reflection. Errores en compilación, no en runtime.

**@EqualsAndHashCode(of = "id") sobre @Data**: @Data rompe JPA con relaciones lazy y provoca StackOverflowError.

**Provider sobre Riverpod**: Suficiente para el TFG, más sencillo de justificar en la memoria.

**WebSocket/STOMP para el chat**: REST con polling tiene latencia inaceptable. STOMP es el estándar en Spring Boot.

**Doble validación de seguimientos (18/04/2025)**: La validación simple no refleja la realidad de las FCT.
Existe una firma semanal del tutor de empresa (valida el trabajo real) y una supervisión académica del
tutor del centro (valida lo formativo). Son responsabilidades distintas. El rechazo genera incidencia
automática para proteger al alumno sin que tenga que reportarlo manualmente.

**Sistema visual Nexus (18/04/2025)**: Diseño limpio estilo Notion/Linear. Color semántico obligatorio.
Adaptativo web/móvil con LayoutBuilder. Todo centralizado en app_theme.dart para coherencia y mantenimiento.

---

## Patrones de Código Establecidos

### Nuevo endpoint REST (backend)
1. Migración Flyway si hay cambios en BD.
2. Entidad JPA si es nueva.
3. DTOs Request y Response.
4. Mapper MapStruct.
5. Repository extendiendo JpaRepository.
6. Interfaz Service e implementación en impl/.
7. Controller con @PreAuthorize en cada método.
8. Tests cubriendo casos de negocio (no solo el happy path).
9. Actualizar ARQUITECTURA_API.md.

### Nueva pantalla Flutter
1. Consultar DESIGN_SYSTEM.md.
2. Model en data/models/ sincronizado con el DTO.
3. Service en data/services/ usando ApiClient.
4. Provider en presentation/providers/ extendiendo ChangeNotifier.
5. Screen en presentation/screens/ usando NexusColors.
6. Ruta en go_router con guard de rol si aplica.

### Implementar el flujo de doble validación (orden obligatorio)
1. Migración V4 primero.
2. IncidenciaRepository e IncidenciaService básico.
3. Refactorizar SeguimientoServiceImpl.
4. Actualizar SeguimientoController.
5. Tests de los 4 casos.
6. Flutter pantalla tutor empresa.
7. Flutter pantalla tutor centro actualizada.

---

## Estrategia de Repositorios

### El problema
Los archivos de configuración de IA (CLAUDE.md, DESIGN_SYSTEM.md, conductor/, etc.)
no deben aparecer en el repositorio que ve el profesor. La solución adoptada es mantener
dos repositorios separados.

### Repositorio de trabajo (privado/personal)
Contiene todo: código, archivos de IA, conductor/, CLAUDE.md, DESIGN_SYSTEM.md, etc.
Aquí es donde trabajamos con Claude Code.

### Repositorio de entrega (público, para el profesor)
URL: https://github.com/ikeracv28/TFG-Seguimiento
Contiene solo: código fuente limpio, memoria, README, diagramas.
Sin archivos de IA, sin conductor/, sin CLAUDE.md.

### Flujo de trabajo
1. Desarrollar y commitear en el repositorio de trabajo.
2. Antes de cada entrega de hito, sincronizar el código limpio al repositorio de entrega.
3. El repositorio de entrega es el que se incluye en el vídeo demo y se entrega al profesor.

### Qué NO debe aparecer en el repositorio de entrega
- CLAUDE.md
- DESIGN_SYSTEM.md
- MEMORIA_ACTUALIZACIONES.md
- HISTORIAL_CAMBIOS_NEXUS.md
- conductor/ (toda la carpeta)
- skills-lock.json
- Cualquier archivo .md de configuración de agentes IA

### Calendario de entregas
| Hito | Fecha | Requisitos |
|------|-------|-----------|
| 25% | 7 abril | Entregado |
| 50% | 21 abril | Memoria + repo limpio + vídeo 5min |
| 75% | 5 mayo | Memoria + repo limpio + vídeo 5min |
| 100% | 19 mayo | Memoria + repo limpio + vídeo 5min |
| Memoria defensa | 26 mayo | Memoria definitiva |
| Defensa tribunal | 2-5 junio | Presentación oral |

### Vídeo de demo — qué mostrar en cada hito
**Hito 2 (21 abril)**: Login funcional con JWT, Dashboard con datos reales,
endpoints en Postman (prácticas, seguimientos, seguridad por roles), Docker levantando todo.

**Hito 3 (5 mayo)**: Todo lo anterior + pantallas Flutter funcionales (seguimientos,
incidencias, panel tutor), demo del flujo de doble validación.

**Hito 4 (19 mayo)**: Demo completa de la app, todos los roles, chat en tiempo real.
