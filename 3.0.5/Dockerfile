FROM tomcat:8.0

#Environment variables
ENV GN_VERSION 3.0.5
ENV GN_DOWNLOAD_MD5 5ca886ea790fd9fe82c7a77c12e1b68d
ENV GN_FILE geonetwork.war
ENV BASE_DIR /usr/local/tomcat
ENV DATA_DIR=$BASE_DIR/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Xmx512M -Xss2M -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC"

WORKDIR $BASE_DIR/webapps

RUN curl -fSL -o $GN_FILE \
  https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/geonetwork.war/download && \
  echo "$GN_DOWNLOAD_MD5 *$GN_FILE" | md5sum -c

RUN  mkdir -p $BASE_DIR/webapps/geonetwork && \
        unzip -e $BASE_DIR/webapps/$GN_FILE -d $BASE_DIR/webapps/geonetwork

EXPOSE 8080

#Set geonetwork data dir
COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
