# Frontend — Java/Maven + Nginx

Generador de frontend estático desarrollado en Java con Maven. Produce los archivos HTML, CSS y JavaScript que son servidos por Nginx. Forma parte del proyecto **Innovatech Chile** desplegado en AWS ECS.

## Tecnologías

- **Build:** Java 17 + Maven 3.9
- **Servidor web:** Nginx 1.25 (Alpine)
- **Contenedor:** Docker multietapa
- **CI/CD:** GitHub Actions → Amazon ECR → Amazon ECS

## Funcionalidades

- Catálogo de productos (conectado al Backend Products en puerto 8082)
- Registro de usuarios (conectado al Backend Users en puerto 8081)
- Diseño responsive con CSS puro

## Variables de entorno (build time)

```env
BACKEND_USERS_URL=http://localhost:8081
BACKEND_PRODUCTS_URL=http://localhost:8082
```

Estas variables se inyectan en tiempo de construcción de la imagen Docker y quedan embebidas en el JavaScript generado.

## Ejecución local (sin Docker)

```bash
cp .env.example .env
# edita .env con las URLs de tus backends
mvn package -DskipTests
mvn exec:java -Dexec.mainClass="com.eval3.frontend.StaticPageGenerator"
# abre output/index.html en el navegador
```

## Ejecución con Docker

```bash
docker build \
  --build-arg BACKEND_USERS_URL=http://localhost:8081 \
  --build-arg BACKEND_PRODUCTS_URL=http://localhost:8082 \
  -t frontend .

docker run -p 80:80 frontend
```

## Ejecución completa con Docker Compose

Desde la carpeta raíz del proyecto:

```bash
docker-compose up --build
```

El frontend estará disponible en `http://localhost`

## Dockerfile multietapa

El Dockerfile usa dos etapas para mantener la imagen final liviana:

1. **Builder (Maven):** compila el Java y genera los archivos estáticos en `output/`
2. **Production (Nginx):** copia solo los archivos estáticos y los sirve

Resultado: imagen final de ~50MB en lugar de ~500MB con Maven incluido.

## Pipeline CI/CD

Cada `push` a la rama `main` dispara el workflow `.github/workflows/deploy.yml` que:

1. **Build** — construye la imagen Docker inyectando las URLs de los backends desde GitHub Variables
2. **Push** — publica la imagen en Amazon ECR con tag del commit
3. **Deploy** — actualiza el servicio en Amazon ECS Fargate

## Arquitectura en la nube

El frontend corre en **Amazon ECS Fargate** dentro de una VPC privada, detrás de un **Application Load Balancer** en el puerto 80. Los logs se envían automáticamente a **Amazon CloudWatch** en el grupo `/ecs/frontend`.
