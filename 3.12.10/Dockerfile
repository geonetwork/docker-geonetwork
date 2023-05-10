FROM tomcat:8.5-jdk8

ENV GN_FILE geonetwork.war
ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"

#Environment variables
ENV GN_VERSION 3.12.10
ENV GN_DOWNLOAD_MD5 13555d5289d3256d191edad19f412790

WORKDIR $CATALINA_HOME/webapps

RUN apt-get update && \
     apt-get install -y --no-install-recommends \
          unzip \
          curl &&\
     rm -rf /var/lib/apt/lists/* && \
     curl -fSL -o $GN_FILE \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/${GN_FILE}/download && \
     echo "${GN_DOWNLOAD_MD5} *${GN_FILE}" | md5sum -c && \
     mkdir -p geonetwork && \
     unzip -e $GN_FILE -d geonetwork && \
     rm $GN_FILE

#Set geonetwork data dir
COPY ./docker-entrypoint.sh /entrypoint.sh

# Needed to make GN to create logs, jcs_caching and gn H2 database in the tomcat directory.
WORKDIR $CATALINA_HOME
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
