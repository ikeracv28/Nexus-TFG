CREATE TABLE "roles" (
  "id" serial PRIMARY KEY,
  "nombre" varchar UNIQUE,
  "descripcion" text
);

CREATE TABLE "centros" (
  "id" bigserial PRIMARY KEY,
  "nombre" varchar,
  "direccion" text,
  "telefono" varchar,
  "email" varchar,
  "fecha_creacion" timestamp
);

CREATE TABLE "usuarios" (
  "id" bigserial PRIMARY KEY,
  "dni" varchar UNIQUE,
  "nombre" varchar,
  "apellidos" varchar,
  "email" varchar UNIQUE,
  "password_hash" varchar,
  "centro_id" bigint,
  "activo" boolean,
  "fecha_creacion" timestamp
);

CREATE TABLE "usuario_roles" (
  "usuario_id" bigint,
  "rol_id" int,
  PRIMARY KEY ("usuario_id", "rol_id")
);

CREATE TABLE "empresas" (
  "id" bigserial PRIMARY KEY,
  "nombre" varchar,
  "cif" varchar UNIQUE,
  "direccion" text,
  "email_contacto" varchar,
  "telefono_contacto" varchar,
  "fecha_creacion" timestamp
);

CREATE TABLE "practicas" (
  "id" bigserial PRIMARY KEY,
  "codigo" varchar UNIQUE,
  "alumno_id" bigint,
  "tutor_id" bigint,
  "empresa_id" bigint,
  "fecha_inicio" date,
  "fecha_fin" date,
  "horas_totales" int,
  "estado" varchar,
  "fecha_creacion" timestamp
);

CREATE TABLE "seguimientos" (
  "id" bigserial PRIMARY KEY,
  "practica_id" bigint,
  "fecha_registro" date,
  "horas_realizadas" int,
  "descripcion" text,
  "estado" varchar,
  "validado_por" bigint,
  "comentario_tutor" text,
  "fecha_creacion" timestamp
);

CREATE TABLE "incidencias" (
  "id" bigserial PRIMARY KEY,
  "practica_id" bigint,
  "creada_por" bigint,
  "tipo" varchar,
  "descripcion" text,
  "estado" varchar,
  "resuelta_por" bigint,
  "fecha_creacion" timestamp,
  "fecha_resolucion" timestamp
);

CREATE TABLE "mensajes" (
  "id" bigserial PRIMARY KEY,
  "practica_id" bigint,
  "emisor_id" bigint,
  "contenido" text,
  "leido" boolean,
  "fecha_envio" timestamp
);

CREATE TABLE "notificaciones" (
  "id" bigserial PRIMARY KEY,
  "usuario_id" bigint,
  "tipo" varchar,
  "mensaje" text,
  "leida" boolean,
  "fecha_creacion" timestamp
);

ALTER TABLE "usuarios" ADD FOREIGN KEY ("centro_id") REFERENCES "centros" ("id");

ALTER TABLE "usuario_roles" ADD FOREIGN KEY ("usuario_id") REFERENCES "usuarios" ("id");

ALTER TABLE "usuario_roles" ADD FOREIGN KEY ("rol_id") REFERENCES "roles" ("id");

ALTER TABLE "practicas" ADD FOREIGN KEY ("alumno_id") REFERENCES "usuarios" ("id");

ALTER TABLE "practicas" ADD FOREIGN KEY ("tutor_id") REFERENCES "usuarios" ("id");

ALTER TABLE "practicas" ADD FOREIGN KEY ("empresa_id") REFERENCES "empresas" ("id");

ALTER TABLE "seguimientos" ADD FOREIGN KEY ("practica_id") REFERENCES "practicas" ("id");

ALTER TABLE "seguimientos" ADD FOREIGN KEY ("validado_por") REFERENCES "usuarios" ("id");

ALTER TABLE "incidencias" ADD FOREIGN KEY ("practica_id") REFERENCES "practicas" ("id");

ALTER TABLE "incidencias" ADD FOREIGN KEY ("creada_por") REFERENCES "usuarios" ("id");

ALTER TABLE "incidencias" ADD FOREIGN KEY ("resuelta_por") REFERENCES "usuarios" ("id");

ALTER TABLE "mensajes" ADD FOREIGN KEY ("practica_id") REFERENCES "practicas" ("id");

ALTER TABLE "mensajes" ADD FOREIGN KEY ("emisor_id") REFERENCES "usuarios" ("id");

ALTER TABLE "notificaciones" ADD FOREIGN KEY ("usuario_id") REFERENCES "usuarios" ("id");
