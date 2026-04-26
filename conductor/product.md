# Guía de Producto: Gestión de Prácticas Académicas (TFG)

## Concepto Inicial
Sistema centralizado para la gestión del ciclo de prácticas académicas, facilitando la comunicación y el seguimiento entre alumnos, tutores (empresa/centro) e instituciones educativas.

---

## Visión General
El producto resuelve la fragmentación en la comunicación y el seguimiento de las prácticas externas (FCT), sustituyendo hilos de correo y hojas Excel por una plataforma web/móvil única y estructurada.

## Objetivos del Producto
*   **Centralización**: Consolidar toda la información de la práctica (seguimientos, incidencias, chat) en una única entidad persistente.
*   **Transparencia**: Permitir que el tutor del centro y el tutor de empresa tengan visibilidad en tiempo real del progreso del alumno.
*   **Gestión SaaS**: Arquitectura diseñada para soportar múltiples instituciones educativas bajo un modelo multi-inquilino.

## Usuarios Objetivo
*   **Alumno**: Registra diarios de actividades, visualiza horas restantes y reporta incidencias.
*   **Tutor (Centro/Empresa)**: Supervisa alumnos, gestiona alertas de incidencias y evalúa seguimientos.
*   **Centro Educativo**: Administrador del sistema que gestiona usuarios, roles e instituciones (SaaS).

## Características Principales (MVP)
*   **Seguimiento Semanal**: Registro cronológico de actividades y contador de horas de prácticas.
*   **Gestión de Incidencias**: Sistema de alertas para el reporte de bloqueos o problemas durante la estancia formativa.
*   **Autenticación JWT**: Seguridad basada en roles (Alumno, Tutor, Admin) gestionada internamente.
*   **Arquitectura Multi-inquilino**: Capacidad para segregar datos entre diferentes instituciones educativas.

## Consideraciones Técnicas
*   **Interfaz**: Desarrollada en Flutter para una experiencia consistente en web y dispositivos móviles.
*   **Backend**: API REST sin estado construida con Java Spring Boot y PostgreSQL.
*   **Idioma**: La plataforma operará exclusivamente en español en su fase inicial.
