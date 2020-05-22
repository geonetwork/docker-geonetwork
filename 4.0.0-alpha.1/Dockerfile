FROM tomcat:8.5-jdk8

ENV GN_FILE geonetwork.war
ENV GN_VERSION 4.0.0-alpha.1
ENV GN_DOWNLOAD_MD5 cbdd928213eb2afedf2a5d3891463c29

ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC -Dspring.profiles.active=es"

ENV ES_HOST localhost
ENV ES_PROTOCOL http
ENV ES_PORT 9200
ENV ES_USERNAME ""
ENV ES_PASSWORD ""
ENV KB_URL http://localhost:5601

WORKDIR $CATALINA_HOME/webapps

#COPY geonetwork.war ./geonetwork.war
RUN curl -fSL -o $GN_FILE \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_unstable_development_versions/${GN_VERSION}/geonetwork.war/download && \
     echo "$GN_DOWNLOAD_MD5 *${GN_FILE}" | md5sum -c && \
     mkdir -p geonetwork && \
     unzip -e $GN_FILE -d geonetwork && \
     rm $GN_FILE


COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
