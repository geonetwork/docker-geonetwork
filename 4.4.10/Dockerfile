FROM tomcat:9-jre11

ENV DATA_DIR=/catalogue-data
ENV WEBAPP_CONTEXT_PATH=/geonetwork
ENV GN_CONFIG_PROPERTIES="-Dgeonetwork.dir=${DATA_DIR} \
        -Dgeonetwork.formatter.dir=${DATA_DIR}/data/formatter \
        -Dgeonetwork.schema.dir=/opt/geonetwork/WEB-INF/data/config/schema_plugins \
        -Dgeonetwork.indexConfig.dir=/opt/geonetwork/WEB-INF/data/config/index"


ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true \
        -Xms512M -Xss512M -Xmx2G -XX:+UseConcMarkSweepGC"

RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        curl \
        unzip && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${DATA_DIR} && \
    mkdir -p /opt/geonetwork && \
    mkdir -p /usr/local/tomcat/conf/Catalina/localhost

ENV GN_FILE=geonetwork.war
ENV GN_VERSION=4.4.10
ENV GN_DOWNLOAD_MD5=920136a8a502e52fd1bfa1417df83a05

RUN cd /opt/geonetwork/ && \
     curl -fSL -o geonetwork.war \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/${GN_FILE}/download && \
     echo "${GN_DOWNLOAD_MD5} *geonetwork.war" | md5sum -c && \
     unzip -q geonetwork.war && \
     rm geonetwork.war

COPY tomcat/geonetwork_context_template.xml /usr/local/share/geonetwork/geonetwork_context_template.xml
COPY tomcat/server.xml /usr/local/tomcat/conf/server.xml
COPY ./docker-entrypoint.sh /geonetwork-entrypoint.sh

ENTRYPOINT ["/geonetwork-entrypoint.sh"]
CMD ["catalina.sh","run"]

VOLUME [ "${DATA_DIR}" ]
