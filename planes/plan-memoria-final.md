# Plan Memoria Final — Nexus TFG
# Objetivo: 24 páginas → ~80 páginas | Entrega: 19 mayo 2026
# Actualizado: 13/05/2026

---

## DIAGNÓSTICO RÁPIDO DE LA MEMORIA ACTUAL

La estructura de los 8 capítulos es correcta y el texto ya escrito es de buena calidad.
El problema no es el contenido existente — es lo que FALTA o está en borrador.

### Lo que está completo y no hay que tocar
- Cap. 1: Idea y propuesta ✅
- Cap. 2: Objetivos ✅
- Cap. 3: RF y RNF ✅ (bien detallados, RF-01 a RF-12, RNF-01 a RNF-08)
- Cap. 4.2: Rediseño seguimientos ✅
- Cap. 4.3: OWASP seguridad ✅
- Cap. 8: Conclusiones ✅ (bien escrita)

### Lo que tiene TEXTO DESACTUALIZADO (actualizar)
- Cap. 4.4 Tests: dice "121 tests / 69.5%", ahora son **254 tests / 80%** — ACTUALIZAR
- Cap. 7 Planificación: Hito 4 no tiene evaluación final, slider, bug fix — ACTUALIZAR

### Lo que está VACÍO o en BORRADOR (escribir)
- Cap. 5 Interfaz: cada sección es solo bullets, sin explicación real, sin screenshots
  - 5.5 "Los cuatro paneles en versión móvil" — completamente vacío
- Cap. 6 Base de datos: solo tiene "el resultado es el siguiente diagrama" sin diagrama
- Hito 4 features: chat, notificaciones, foto de perfil, evaluación final — NO están
- No hay Manual de Usuario (el tutor espera capturas de uso real)

---

## PLAN DÍA A DÍA (14-19 mayo)

### MIÉRCOLES 14 MAYO — Integrar lo que ya está escrito [SOLO COPIAR-PEGAR, sin código]

**Objetivo**: Pasar de 24 a ~38 páginas solo copiando bloques ya redactados.

**Paso 1** — Actualizar sección 4.4 Tests (5 minutos):
Sustituir el párrafo que dice "121 tests / 69.5%" por este texto:

> Al cierre del proyecto, la batería cuenta con **doscientos cincuenta y cuatro tests** 
> organizados en veintidós clases. La cobertura global es del **80% de instrucciones**, 
> medida con JaCoCo ejecutando `./mvnw verify`. Los tests nuevos incorporados en el 
> cuarto hito cubren los módulos de notificaciones, usuario (foto de perfil), evaluación 
> final, y los controladores REST de ausencias, seguimientos, incidencias y prácticas. 
> Los catorce tests del módulo de chat del Hito 3 pasan a completar ahora una batería 
> de veintidós clases de test, ocho de tipo `@WebMvcTest` que verifican la seguridad 
> por roles en la capa web, y catorce de tipo `@SpringBootTest` que ejercitan la lógica 
> de negocio contra una base de datos H2 real. Esta cifra supera el objetivo mínimo de 
> 80% establecido al inicio del hito.

**Paso 2** — Añadir subsección 4.5 Chat WebSocket (copiar de MEMORIA_ACTUALIZACIONES.md):
Bloque "Hito 4: Chat en tiempo real con WebSocket y protocolo STOMP" → dentro del Cap. 4,
como nueva sección 4.5 "Comunicación en tiempo real: WebSocket y STOMP".

**Paso 3** — Añadir subsección 4.6 Foto de perfil (copiar de MEMORIA_ACTUALIZACIONES.md):
Bloque "Hito 4: Foto de perfil y sincronización entre paneles" → sección 4.6.

**Paso 4** — Añadir subsección 4.7 Notificaciones (copiar de MEMORIA_ACTUALIZACIONES.md):
Bloque "Hito 4: Sistema de notificaciones" → sección 4.7.

**Paso 5** — Añadir subsección 4.8 Evaluación final (copiar de MEMORIA_ACTUALIZACIONES.md):
Bloque "Hito 4: Evaluación final del alumno" → sección 4.8.

**Paso 6** — Añadir subsección 4.9 Docker / Infraestructura (copiar de MEMORIA_ACTUALIZACIONES.md):
Bloque "Infraestructura: Docker Compose y despliegue en contenedores" → sección 4.9
(complementa lo que ya hay en 4 sobre infraestructura).

**Paso 7** — Integrar bloques pendientes del Hito 2 y 3 que siguen como [PENDIENTE]:
En MEMORIA_ACTUALIZACIONES.md hay varios bloques que aún no están en la memoria:
- BLOQUE 002: Backend Hito 2 (MapStruct, endpoints /me, Future.wait) → ampliar 4.1
- BLOQUE 003: Navegación adaptativa, IndexedStack → ampliar 5.1
- BLOQUE 004 Decisión rediseño: texto académico de la decisión → 4.2 (ya tienes algo, esto lo amplía)
- BLOQUE ausencias backend: detalles técnicos ausencias → ampliar la parte de ausencias en 4.1

**Ganancia estimada Miércoles**: +12-14 páginas → total ~38 páginas

---

### JUEVES 15 MAYO — Screenshots + Sección 5 Interfaz [2-3 horas]

**Objetivo**: Pasar de ~38 a ~58 páginas expandiendo el capítulo 5 con capturas reales.

Las secciones 5.1-5.5 son actualmente bullets sin explicación. Cada subsección debería ser:
1. Un párrafo introductorio (qué ve el usuario al entrar, qué puede hacer)
2. 2-3 capturas de pantalla (la app ya funciona, solo hay que sacarlas)
3. Un párrafo por captura explicando lo que se ve

**Capturas que necesitas sacar** (con la app levantada en Docker):

| Rol | Pantalla | Qué capturar |
|-----|----------|--------------|
| Alumno | Dashboard — pestaña Inicio | Tarjeta práctica + barra progreso horas |
| Alumno | Dashboard — pestaña Seguimientos | Lista de partes con estados (pte, validado, rechazado) |
| Alumno | Formulario nuevo parte | Bottom sheet con campos fecha/horas/descripción |
| Alumno | Dashboard — pestaña Incidencias | Lista + modal de reporte |
| Alumno | Dashboard — pestaña Chat | Chat con mensajes en tiempo real |
| Alumno | Dashboard — pestaña Ausencias | Lista + badge estados |
| Alumno | Pantalla Perfil | Avatar + botón subir foto |
| Alumno | Pantalla Notificaciones | Lista con badges por tipo |
| Tutor empresa | Panel — pestaña Partes | Lista partes pendientes con botones validar/rechazar |
| Tutor empresa | Diálogo evaluación | Sliders de criterios con colores rojo/ámbar/verde |
| Tutor empresa | Panel — pestaña Progreso | Tarjeta con barra de progreso del alumno |
| Tutor centro | Panel — Dashboard | 4 stat cards + lista alumnos |
| Tutor centro | Panel — Ficha alumno | Gráficos progreso + tabla seguimientos + evaluación |
| Tutor centro | Panel — Partes pendientes | Lista global partes pendientes |
| Admin | Panel — Usuarios | Tabla con filtros + botón crear |
| Admin | Panel — Prácticas | Lista con estado badges |
| Móvil | Cualquier panel | BottomNav + contenido (redimensiona la ventana Chrome a ~375px) |

**Cómo sacar capturas en Chrome**:
- Abre la app en `http://localhost`
- F12 → Ctrl+Shift+M (modo móvil) para las capturas de móvil
- Snipping Tool (Win+Shift+S) para capturar
- Nómbralas: `cap_alumno_dashboard.png`, `cap_tutor_partes.png`, etc.

**Texto que añadir a cada subsección**:
Para 5.1 Panel del Alumno, por ejemplo:
> Al autenticarse, el alumno accede a un dashboard organizado en pestañas mediante 
> un NavigationRail lateral en web y un BottomNavigationBar en móvil. La primera 
> pestaña muestra la tarjeta de su práctica activa con el nombre de la empresa, el código 
> del convenio y una barra de progreso circular que refleja las horas completadas 
> —únicamente seguimientos en estado COMPLETADO— frente al total comprometido...
> [captura]
> La pestaña de seguimientos lista todos los partes registrados ordenados por fecha. 
> El código de color indica el estado de cada parte: verde para los completados, 
> azul para los pendientes de validación del centro, ámbar para los pendientes de 
> empresa, y rojo para los rechazados...
> [captura]

**Ganancia estimada Jueves**: +18-20 páginas → total ~58 páginas

---

### VIERNES 16 MAYO — Diagrama ER + Diagramas técnicos [2-3 horas]

**Objetivo**: Completar Cap. 6 (Base de datos) y añadir diagramas al Cap. 4.

**6.1 Diagrama ER completo**:
La sección 6 actualmente solo tiene "el resultado es el siguiente diagrama" sin el diagrama.
Tienes que dibujar el ER con todas las tablas actuales (15 tablas Flyway V1-V14):

Tablas actuales (verificar en BD o en migraciones Flyway):
- usuarios, roles, usuario_roles
- empresas, centros
- practicas
- seguimientos
- incidencias
- ausencias
- mensajes
- notificaciones
- evaluaciones_finales
- audit_logs

Herramienta más rápida: **dbdiagram.io** (gratuito, online)
O: pgAdmin → "ERD Tool" (se genera automáticamente desde la BD real)

**4.1 Diagrama de arquitectura del sistema**:
Añadir un diagrama de componentes (puede ser simple):
```
[Flutter Web] ←HTTPS→ [Nginx] ←→ [Spring Boot API] ←→ [PostgreSQL]
                         ↑
                    [Docker Compose]
                      nexus-web | nexus-api | nexus-db
```
Herramienta: draw.io (gratuito) o simplemente un recuadro bien hecho en Word.

**4.5 Diagrama de secuencia — Flujo de doble validación**:
Añadir debajo del texto de 4.2 un diagrama de secuencia UML:
```
Alumno → API: POST /seguimientos (parte semanal)
API → BD: INSERT seguimiento PENDIENTE_EMPRESA
Tutor empresa → API: PATCH /seguimientos/{id}/validar-empresa (PENDIENTE_CENTRO)
API → NotificacionService: crear notif para alumno
Tutor centro → API: PATCH /seguimientos/{id}/validar-centro (COMPLETADO)
API → NotificacionService: crear notif para alumno
```

**Ganancia estimada Viernes**: +8-10 páginas → total ~66-68 páginas

---

### SÁBADO 17 MAYO — Manual de usuario + Conclusiones ampliadas [2-3 horas]

**Objetivo**: Pasar de ~68 a ~76 páginas con un manual básico por rol.

**Nuevo capítulo: Manual de Usuario** (entre cap 5 y cap 8, o como anexo):

Estructura:
```
7. Manual de Usuario
   7.1 Requisitos para el usuario
   7.2 Cómo acceder a la plataforma
   7.3 Guía del alumno (paso a paso)
   7.4 Guía del tutor de empresa
   7.5 Guía del tutor del centro
   7.6 Guía del administrador
```

Cada sección: 1 párrafo de introducción + pasos numerados + 2-3 capturas.
Con capturas bien tamaño y explicadas, cada subsección son ~1.5 páginas.
6 subsecciones × 1.5 páginas = ~9 páginas.

**Cap. 8 Conclusiones — ampliar el trabajo futuro**:
Añadir un párrafo sobre dificultades técnicas concretas que encontraste:
- Hibernate 6 y el problema de BYTEA vs OID con @Lob
- WebSocket con Spring Security — autenticación del frame CONNECT
- Flyway checksums y la migración V6 para contraseñas
- ValueNotifier para sincronización de foto sin provider global

**Ganancia estimada Sábado**: +8-10 páginas → total ~76-78 páginas

---

### DOMINGO 18 MAYO — Revisión, índice, bibliografía, polish [2 horas]

**Objetivo**: Cerrar en ~80 páginas, corregir, añadir bibliografía.

**Bibliografía** (1-2 páginas):
- Spring Boot Documentation 3.4.1 — spring.io/projects/spring-boot
- Flutter Documentation — flutter.dev
- OWASP Top 10 2021 — owasp.org/Top10
- JWT RFC 7519 — rfc-editor.org/rfc/rfc7519
- PostgreSQL 16 Documentation — postgresql.org/docs
- JaCoCo Documentation — jacoco.org
- Docker Documentation — docs.docker.com
- Flyway Documentation — flywaydb.org

**Revisión del índice**:
Actualizar números de página en el índice (auto-actualizar en Word).
Añadir las nuevas secciones (4.5-4.9, el capítulo de Manual de Usuario).

**Revisión final del Cap. 7 Planificación**:
El apartado "Estado Actual (Hito 4)" dice "121 tests en chat" — actualizar con el estado real:
evaluación final implementada, 254 tests, slider de evaluación, bug fix ficha alumno.

**Formato del documento**:
- Numerar todas las páginas
- Comprobar que todas las imágenes tienen pie de foto
- Comprobar que los títulos de sección son consistentes

---

### LUNES 19 MAYO — Entrega

Solo ajustes de último momento. No añadir secciones nuevas.

---

## RESUMEN DEL PLAN — GANANCIA POR DÍA

| Día | Tarea | Páginas ganadas | Total acum. |
|-----|-------|-----------------|-------------|
| Actual | — | — | ~24 págs |
| Miér 14 | Copiar bloques MEMORIA_ACTUALIZACIONES.md | +14 | ~38 |
| Juev 15 | Screenshots + expandir Cap. 5 | +20 | ~58 |
| Vier 16 | ER diagram + diagramas técnicos | +10 | ~68 |
| Sáb 17 | Manual de usuario + Conclusiones | +10 | ~78 |
| Dom 18 | Bibliografía + revisión + polish | +2-4 | ~80-82 |

---

## OPCIONALES — Solo si sobra tiempo (implementación)

Ordenados por impacto en la nota vs esfuerzo de código:

| Feature | Esfuerzo | Impacto | Notas |
|---------|----------|---------|-------|
| PDF export ficha alumno | 3-4h | Alto | Botón ya existe (onPressed: null), paquetes instalados |
| Excel export desde admin | 2-3h | Medio | `excel: ^4.0.6` ya añadido, falta implementación |
| Chat tutor empresa ↔ tutor centro | 1h test | Bajo | Ya funciona, solo verificar en demo |
| Pulido visual (hover states, animaciones) | 2-3h | Bajo | Nice-to-have |

**Recomendación**: No implementar nada nuevo hasta tener la memoria en ~70 páginas.
La nota de la memoria pesa más que la última feature.

---

## ARCHIVOS FUENTE PARA LOS BLOQUES DE TEXTO

Todos los bloques listos para copiar están en:
`C:\Carpeta TFG\TFG\MEMORIA_ACTUALIZACIONES.md`

Buscar las secciones marcadas como `[PENDIENTE DE INTEGRAR]`:
- BLOQUE 002: Hito 2 Backend → para ampliar sección 4.1
- BLOQUE 003: Navegación adaptativa → para ampliar sección 5.1
- BLOQUE Chat WebSocket → para nueva sección 4.5
- BLOQUE Foto de perfil → para nueva sección 4.6
- BLOQUE Notificaciones → para nueva sección 4.7
- BLOQUE Evaluación final → para nueva sección 4.8
- BLOQUE JaCoCo 80% → para actualizar sección 4.4
- BLOQUE Docker Compose → para nueva sección 4.9
- BLOQUE Módulo ausencias → para ampliar lo que ya hay en 4.1 y 5.4
