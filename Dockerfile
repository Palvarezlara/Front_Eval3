FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
COPY src ./src

ARG BACKEND_USERS_URL=http://localhost:8081
ARG BACKEND_PRODUCTS_URL=http://localhost:8082

RUN echo "BACKEND_USERS_URL=${BACKEND_USERS_URL}" > .env && \
    echo "BACKEND_PRODUCTS_URL=${BACKEND_PRODUCTS_URL}" >> .env

RUN mvn package -DskipTests -q && \
    mvn exec:java -Dexec.mainClass="com.eval3.frontend.StaticPageGenerator" -q

FROM nginx:1.25-alpine

COPY --from=builder /app/output /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
