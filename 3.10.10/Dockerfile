FROM tomcat:8.5-jdk8

ENV GN_FILE geonetwork.war
ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"

#Environment variables
ENV GN_VERSION 3.10.10
ENV GN_DOWNLOAD_MD5 de09ba1a43d6f3a224ad5ff02b4c4fb3

WORKDIR $CATALINA_HOME/webapps

RUN curl -fSL -o $GN_FILE \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/${GN_FILE}/download && \
     echo "$GN_DOWNLOAD_MD5 *${GN_FILE}" | md5sum -c && \
     mkdir -p geonetwork && \
     unzip -e $GN_FILE -d geonetwork && \
     rm $GN_FILE && \
     rm geonetwork/WEB-INF/lib/log4j-core-* && \
     rm geonetwork/WEB-INF/lib/log4j-api*
COPY log4j/ geonetwork/WEB-INF/lib
RUN ls -lah geonetwork/WEB-INF/lib/log4j*

#Set geonetwork data dir
COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
