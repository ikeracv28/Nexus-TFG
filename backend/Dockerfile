# =========================================================================
# MULTI-STAGE DOCKERFILE PARA BACKEND SPRING BOOT (JAVA)
# =========================================================================
# Utiliza un enfoque de dos etapas. Primero empaqueta el código en un 
# archivo .jar ejecutable usando Maven, y luego lo copia a una imagen 
# mínima de Java JRE para ejecutarlo.
# =========================================================================

# -------------------------------------------------------------------------
# ETAPA 1: BUILDER (Construcción del JAR)
# -------------------------------------------------------------------------
# Utilizamos una imagen oficial de Maven con la versión requerida de Java (21)
FROM maven:3.9-eclipse-temurin-21 AS builder

# Establecemos el directorio de trabajo
WORKDIR /app

# 1. Copiamos el pom.xml PRIMERO. Esto es un truco de optimización (caching).
# Si el pom.xml no cambia, Docker reutilizará la capa de dependencias en
# compilaciones futuras, ahorrando mucho tiempo.
COPY pom.xml .

# 2. Descargamos las dependencias en modo offline.
RUN mvn dependency:go-offline

# 3. Copiamos el código fuente de la aplicación.
COPY src ./src

# 4. Compilamos el código y generamos el archivo .jar. 
# Usamos -DskipTests para acelerar la creación de la imagen (asumiendo que 
# los tests se pasan en una etapa CI/CD externa).
RUN mvn clean package -DskipTests

# -------------------------------------------------------------------------
# ETAPA 2: RUNTIME (Ejecución de la API)
# -------------------------------------------------------------------------
# Utilizamos una imagen de solo ejecución (JRE), mucho más ligera que el JDK.
# "alpine" denota una distribución de Linux ultra-ligera, ideal para contenedores.
FROM eclipse-temurin:21-jre-alpine

# Establecemos el directorio de trabajo para la aplicación final
WORKDIR /app

# 5. Copiamos el archivo .jar generado en la etapa "builder".
# Buscamos cualquier archivo que termine en .jar en la carpeta target/.
COPY --from=builder /app/target/*.jar app.jar

# 6. Exponemos el puerto 8080 (donde Spring Boot escucha por defecto)
EXPOSE 8080

# 7. Definimos el punto de entrada. Este comando ejecuta el .jar al iniciar el contenedor.
ENTRYPOINT ["java", "-jar", "app.jar"]
