-- V1__Esquema_Inicial.sql
-- Creación de tablas base según el modelo de negocio del TFG.

-- Tabla de roles: Define los permisos (Alumno, Tutor Centro, Tutor Empresa, Administrador).
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50) UNIQUE NOT NULL,
  descripcion TEXT
);

-- Tabla de centros: Datos de la institución educativa.
CREATE TABLE centros (
  id BIGSERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion TEXT,
  telefono VARCHAR(20),
  email VARCHAR(100),
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de usuarios: Entidad principal para la autenticación.
CREATE TABLE usuarios (
  id BIGSERIAL PRIMARY KEY,
  dni VARCHAR(20) UNIQUE NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  centro_id BIGINT REFERENCES centros(id),
  activo BOOLEAN DEFAULT TRUE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Relación Many-to-Many entre Usuarios y Roles.
CREATE TABLE usuario_roles (
  usuario_id BIGINT REFERENCES usuarios(id),
  rol_id INT REFERENCES roles(id),
  PRIMARY KEY (usuario_id, rol_id)
);

-- Tabla de empresas: Donde se realizan las prácticas.
CREATE TABLE empresas (
  id BIGSERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  cif VARCHAR(20) UNIQUE NOT NULL,
  direccion TEXT,
  email_contacto VARCHAR(100),
  telefono_contacto VARCHAR(20),
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de prácticas: El núcleo del sistema. 
-- IMPORTANTE: Aquí implementamos la corrección de tutor_centro y tutor_empresa.
CREATE TABLE practicas (
  id BIGSERIAL PRIMARY KEY,
  codigo VARCHAR(50) UNIQUE NOT NULL,
  alumno_id BIGINT REFERENCES usuarios(id) NOT NULL,
  tutor_centro_id BIGINT REFERENCES usuarios(id) NOT NULL, -- Tutor del Instituto.
  tutor_empresa_id BIGINT REFERENCES usuarios(id) NOT NULL, -- Tutor de la Empresa.
  empresa_id BIGINT REFERENCES empresas(id) NOT NULL,
  fecha_inicio DATE,
  fecha_fin DATE,
  horas_totales INT,
  estado VARCHAR(20) DEFAULT 'BORRADOR', -- Ej: BORRADOR, ACTIVA, FINALIZADA.
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seguimientos semanales/diarios de los alumnos.
CREATE TABLE seguimientos (
  id BIGSERIAL PRIMARY KEY,
  practica_id BIGINT REFERENCES practicas(id) NOT NULL,
  fecha_registro DATE NOT NULL,
  horas_realizadas INT NOT NULL,
  descripcion TEXT,
  estado VARCHAR(20) DEFAULT 'PENDIENTE', -- PENDIENTE, VALIDADO, RECHAZADO.
  validado_por BIGINT REFERENCES usuarios(id),
  comentario_tutor TEXT,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Incidencias durante el periodo de prácticas.
CREATE TABLE incidencias (
  id BIGSERIAL PRIMARY KEY,
  practica_id BIGINT REFERENCES practicas(id) NOT NULL,
  creada_por BIGINT REFERENCES usuarios(id) NOT NULL,
  tipo VARCHAR(50), -- Ej: AUSENCIA, COMPORTAMIENTO, OTROS.
  descripcion TEXT NOT NULL,
  estado VARCHAR(20) DEFAULT 'ABIERTA',
  resuelta_por BIGINT REFERENCES usuarios(id),
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_resolucion TIMESTAMP
);

-- Mensajería interna (Chat) de la práctica.
CREATE TABLE mensajes (
  id BIGSERIAL PRIMARY KEY,
  practica_id BIGINT REFERENCES practicas(id) NOT NULL,
  emisor_id BIGINT REFERENCES usuarios(id) NOT NULL,
  contenido TEXT NOT NULL,
  leido BOOLEAN DEFAULT FALSE,
  fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notificaciones genéricas al usuario.
CREATE TABLE notificaciones (
  id BIGSERIAL PRIMARY KEY,
  usuario_id BIGINT REFERENCES usuarios(id) NOT NULL,
  tipo VARCHAR(50),
  mensaje TEXT NOT NULL,
  leida BOOLEAN DEFAULT FALSE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
