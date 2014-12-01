FROM maven:3-jdk-7

MAINTAINER Golfen Guo "guo@tianjiancloud.com"

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME" 
ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.57
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

# Install Tomcat
WORKDIR $CATALINA_HOME
RUN curl -SL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
        && curl -SL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
        && tar -xvf tomcat.tar.gz --strip-components=1 \
        && rm bin/*.bat \
        && rm tomcat.tar.gz*

# Prepare by downloading dependencies
WORKDIR /code
ADD pom.xml /code/pom.xml
RUN ["mvn", "dependency:resolve"]

# Adding source, compile and package into a WAR
ADD src /code/src
RUN ["mvn", "-DskipTests=true", "package"]
RUN ["rm", "-rf", "/usr/local/tomcat/webapps/ROOT"]
RUN ["cp", "/code/target/ROOT.war", "/usr/local/tomcat/webapps/"]

# Expose port
EXPOSE 8080

# Start Tomcat
WORKDIR $CATALINA_HOME
CMD ["catalina.sh", "run"]
