FROM alpine AS git
RUN apk update && apk add git
WORKDIR /usr/java
RUN git clone https://github.com/adhig93/java_repo1
RUN git clone https://github.com/adhig93/tomcat-config

FROM maven:amazoncorretto AS maven
COPY --from=git /usr/java/java_repo1/src /usr/app/src
COPY --from=git /usr/java/java_repo1/pom.xml /usr/app/
RUN mvn -f /usr/app/pom.xml clean install

FROM tomcat
RUN cp -r webapps.dist/* webapps/
COPY --from=maven /usr/app/target/*.war /usr/local/tomcat/webapps/
COPY --from=git /usr/java/tomcat-config/context.xml /usr/local/tomcat/webapps/host-manager/META-INF/context.xml
COPY --from=git /usr/java/tomcat-config/context.xml /usr/local/tomcat/webapps/manager/META-INF/context.xml
COPY --from=git /usr/java/tomcat-config/tomcat-users.xml /usr/local/tomcat/conf
