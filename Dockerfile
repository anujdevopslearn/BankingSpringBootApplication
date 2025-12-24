FROM openjdk:21-ea-oraclelinux8
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
EXPOSE 8989
ENTRYPOINT ["java","-jar","/app.jar"]

