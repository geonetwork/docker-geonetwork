FROM jetty:9-jdk11

ENV DATA_DIR /catalogue-data
ENV WEBAPP_CONTEXT_PATH /geonetwork
ENV GN_CONFIG_PROPERTIES -Dgeonetwork.dir=${DATA_DIR} \
        -Dgeonetwork.formatter.dir=${DATA_DIR}/data/formatter \
        -Dgeonetwork.schema.dir=/opt/geonetwork/WEB-INF/data/config/schema_plugins \
        -Dgeonetwork.indexConfig.dir=/opt/geonetwork/WEB-INF/data/config/index


ENV JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true \
        -Xms512M -Xss512M -Xmx2G -XX:+UseConcMarkSweepGC

USER root
RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
        curl \
        unzip && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p ${DATA_DIR} && \
    chown -R jetty:jetty ${DATA_DIR} && \
    mkdir -p /opt/geonetwork && \
    chown -R jetty:jetty /opt/geonetwork

USER jetty
ENV GN_FILE geonetwork.war
ENV GN_VERSION 4.4.0
ENV GN_DOWNLOAD_MD5 fe2e0d3e665a4d0913c91a87dff244a2

RUN cd /opt/geonetwork/ && \
     curl -fSL -o geonetwork.war \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/${GN_FILE}/download && \
     echo "${GN_DOWNLOAD_MD5} *geonetwork.war" | md5sum -c && \
     unzip -q geonetwork.war && \
     rm geonetwork.war

COPY jetty/geonetwork_context_template.xml /usr/local/share/geonetwork/geonetwork_context_template.xml
COPY ./docker-entrypoint.sh /geonetwork-entrypoint.sh

RUN java -jar /usr/local/jetty/start.jar --create-startd --add-module=http-forwarded

ENTRYPOINT ["/geonetwork-entrypoint.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]

VOLUME [ "${DATA_DIR}" ]
