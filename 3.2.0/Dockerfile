FROM tomcat:8-jre8

#Environment variables
ENV GN_VERSION 3.2.0
ENV GN_FILE geonetwork.war
ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Xmx512M -Xss2M -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC"

WORKDIR $CATALINA_HOME/webapps

RUN curl -fSL -o geonetwork.war.MD5 https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/geonetwork.war.MD5/download && \ 
    curl -fSL -o $GN_FILE \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/geonetwork.war/download && \
     echo "$(cat geonetwork.war.MD5) *$GN_FILE" | md5sum -c

RUN  mkdir -p $CATALINA_HOME/webapps/geonetwork && \
        unzip -e $CATALINA_HOME/webapps/$GN_FILE -d $CATALINA_HOME/webapps/geonetwork && \
        rm geonetwork.war

#Set geonetwork data dir
COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
