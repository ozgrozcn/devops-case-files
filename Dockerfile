FROM openjdk:17

WORKDIR /app
COPY ./hello-world-java/target/hello-world-0.1.jar /app/hello-world-0.1.jar

ENTRYPOINT ["java", "-jar", "/app/hello-world-0.1.jar"]

