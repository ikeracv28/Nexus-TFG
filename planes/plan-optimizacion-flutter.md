# Plan — Optimización Flutter (sesión 26 mayo 2026)

Objetivo: limpiar código muerto, corregir warnings del analyzer y mejorar
la calidad general del frontend antes de la entrega definitiva.

Prerequisito: Flutter SDK instalado en `C:\flutter` y `C:\flutter\bin` en PATH.

---

## Fase 1 — Análisis estático

```bash
cd frontend
flutter pub get
flutter analyze --no-pub 2>&1 | tee analyze_output.txt
```

Clasificar los resultados en:
- **Errores** (E): bloquean compilación — resolver siempre
- **Warnings** (W): código incorrecto pero no bloquea — resolver salvo excepciones
- **Infos / hints** (I): dead code, unused imports, prefer_const, etc. — limpiar todos

---

## Fase 2 — Código muerto y imports

Objetivos concretos:
- Eliminar `import` no usados (el analyze los lista con `unused_import`)
- Eliminar variables locales nunca leídas (`unused_local_variable`)
- Eliminar parámetros de constructor nunca usados (`unused_element`)
- Revisar widgets o funciones privadas definidas pero nunca llamadas
- Revisar archivos `.dart` que no importa nadie (Glob + Grep)

```bash
# Ver cuántos unused imports hay
grep "unused_import" analyze_output.txt | wc -l
# Ver cuántos dead code hay
grep "dead_code" analyze_output.txt | wc -l
```

---

## Fase 3 — Calidad de código

Cosas habituales que el analyzer marca:
- `prefer_const_constructors` — añadir `const` donde sea posible (mejora rendimiento)
- `use_key_in_widget_constructors` — añadir `key` a widgets públicos
- `avoid_print` — reemplazar `print()` por `debugPrint()` o eliminar
- `unnecessary_null_checks` — `!` innecesarios
- `prefer_single_quotes` — consistencia de strings

Ejecutar auto-fix donde sea seguro:
```bash
dart fix --apply
```
> Revisar el diff antes de aceptar — `dart fix` puede cambiar demasiado de golpe.

---

## Fase 4 — Tests de Flutter (si hay tiempo)

Si se quieren añadir tests de widget básicos:
- `flutter test` — ejecuta lo que haya en `test/`
- Candidatos para tests sencillos:
  - `LoginScreen` — renderiza correctamente con AuthProvider mock
  - `_LoginForm` — validación de campos vacíos y email inválido
  - `NexusLogo` — smoke test de renderizado

Instalar dependencias de test si faltan:
```yaml
# pubspec.yaml dev_dependencies:
flutter_test:
  sdk: flutter
mockito: ^5.4.4
build_runner: ^2.4.9
```

---

## Fase 5 — Build de producción limpio

```bash
flutter build web --release --web-renderer canvaskit
```

Verificar que el build no tiene warnings nuevos y que el tamaño de
`build/web/main.dart.js` no ha crecido respecto al baseline del contenedor Docker.

---

## Fase 6 — Re-dockerizar y verificar

Tras limpiar el código, rebuild completo para asegurar que los cambios
no rompieron el contenedor:

```bash
docker-compose build --no-cache frontend
docker rm -f nexus-web
docker-compose up -d frontend
```

Hacer smoke test manual: login con los 4 roles, navegar por las pantallas
principales, verificar que no hay regresiones visuales.

---

## Checklist final

- [ ] `flutter analyze` sin errores ni warnings
- [ ] Sin `print()` en código de producción
- [ ] Sin imports no usados
- [ ] `dart fix --apply` aplicado y revisado
- [ ] `flutter build web --release` sin errores
- [ ] Docker rebuild exitoso
- [ ] Smoke test de los 4 roles OK
- [ ] Commit "chore(flutter): limpieza analyzer + dead code" creado
- [ ] `git push` al repositorio de entrega
- [ ] `HISTORIAL_CAMBIOS.md` actualizado
