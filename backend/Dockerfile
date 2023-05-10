FROM bitnami/git:2.40.1 as git

WORKDIR /usr/app

RUN git clone https://github.com/realraec/quizgame-backend.git .


FROM maven:3.9.1-amazoncorretto-17

LABEL maintainer="realraec.xyz"

WORKDIR /usr/app

COPY --from=git /usr/app /usr/app

RUN mvn package
# RUN mvn install -DskipTests

ENTRYPOINT java -jar ./target/quizgame-0.0.1-SNAPSHOT.jar