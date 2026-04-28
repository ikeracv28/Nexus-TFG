# Estrategia de Repositorios y Entregas

## El problema

Los archivos de configuración de IA (CLAUDE.md, DESIGN_SYSTEM.md, planes/, etc.) no deben aparecer en el repositorio que ve el profesor.

## Repositorio de trabajo (privado)

Contiene todo: código, archivos de IA, planes/, CLAUDE.md, DESIGN_SYSTEM.md.
Aquí es donde se trabaja con Claude Code.

## Repositorio de entrega (público, para el profesor)

URL: https://github.com/ikeracv28/TFG-Seguimiento

Contiene solo: código fuente limpio, memoria, README, diagramas.

### Qué NO debe aparecer en el repo de entrega

- CLAUDE.md, DESIGN_SYSTEM.md, MEMORIA_ACTUALIZACIONES.md, HISTORIAL_CAMBIOS.md
- planes/ (toda la carpeta)
- conductor/ (toda la carpeta)
- skills-lock.json
- .agents/ (toda la carpeta)
- Cualquier archivo .md de configuración de agentes IA

## Flujo de trabajo

1. Desarrollar y commitear en el repositorio de trabajo.
2. Antes de cada entrega de hito, sincronizar el código limpio al repositorio de entrega.
3. El repositorio de entrega es el que se incluye en el vídeo demo y se entrega al profesor.
