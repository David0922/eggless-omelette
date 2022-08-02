FROM openjdk:17-jdk-alpine AS build
RUN mkdir /app
WORKDIR /app
ADD . /app
RUN ./gradlew build

FROM openjdk:17-jdk-alpine
COPY --from=build /app/build/libs/goodbyeworld-0.0.1.jar /app/main.jar
CMD ["java", "-jar", "/app/main.jar"]
