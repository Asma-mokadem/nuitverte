# Ã‰tape 1 : compilation (Maven + JDK 17)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /build/scheduler-service
COPY scheduler-service/pom.xml .
COPY contracts /build/contracts
COPY scheduler-service/src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -B -q package -DskipTests

# Ã‰tape 2 : image finale lÃ©gÃ¨re (JRE alpine seulement)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
RUN addgroup -S app && adduser -S app -G app
COPY --from=build /build/scheduler-service/target/app.jar app.jar
USER app
EXPOSE 8080
ENV JAVA_OPTS="-Xmx256m"
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]