FROM tomcat:9-jre11

ENV DATA_DIR=/catalogue-data
ENV WEBAPP_CONTEXT_PATH=/geonetwork
ENV GN_CONFIG_PROPERTIES="-Dgeonetwork.dir=${DATA_DIR} \
        -Dgeonetwork.formatter.dir=${DATA_DIR}/data/formatter \
        -Dgeonetwork.schema.dir=/opt/geonetwork/WEB-INF/data/config/schema_plugins \
        -Dgeonetwork.indexConfig.dir=/opt/geonetwork/WEB-INF/data/config/index"


ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true \
        -Xms512M -Xss512M -Xmx2G -XX:+UseConcMarkSweepGC"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        unzip \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p "${DATA_DIR}"; \
    mkdir -p /opt/geonetwork; \
    mkdir -p /usr/local/tomcat/conf/Catalina/localhost

ENV GN_FILE=geonetwork.war
ENV GN_VERSION=4.4.11
ENV GN_DOWNLOAD_SHA256=e01355d8a1462e7bba1db6b8483bf0ffd692a17e96a04f239c9136f4c41c1ee6

RUN set -eux; \
    cd /opt/geonetwork/; \
    curl -fSL -o geonetwork.war \
        "https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/${GN_FILE}/download"; \
   echo "${GN_DOWNLOAD_SHA256} *geonetwork.war" | sha256sum -c; \
    unzip -q geonetwork.war; \
    rm geonetwork.war

COPY tomcat/geonetwork_context_template.xml /usr/local/share/geonetwork/geonetwork_context_template.xml
COPY tomcat/server.xml /usr/local/tomcat/conf/server.xml
COPY ./docker-entrypoint.sh /geonetwork-entrypoint.sh

ENTRYPOINT ["/geonetwork-entrypoint.sh"]
CMD ["catalina.sh","run"]

VOLUME [ "${DATA_DIR}" ]
