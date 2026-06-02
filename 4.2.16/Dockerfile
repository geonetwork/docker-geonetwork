FROM tomcat:9-jre8-temurin-noble

ENV DATA_DIR=/catalogue-data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom \
        -Djava.awt.headless=true \
        -Xms512M -Xss512M -Xmx2G -XX:+UseConcMarkSweepGC \
        -Dgeonetwork.resources.dir=${DATA_DIR}/resources \
        -Dgeonetwork.data.dir=${DATA_DIR} \
        -Dgeonetwork.codeList.dir=/usr/local/tomcat/webapps/geonetwork/WEB-INF/data/config/codelist \
        -Dgeonetwork.schema.dir=/usr/local/tomcat/webapps/geonetwork/WEB-INF/data/config/schema_plugins"

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        unzip \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p "${DATA_DIR}"; \
    mkdir -p /usr/local/tomcat/webapps/geonetwork

ENV GN_FILE=geonetwork.war
ENV GN_VERSION=4.2.16
ENV GN_DOWNLOAD_SHA256=caba3eaa9e7b9d7406dbd0a95081cef1d8c363918dde3a0849f09c24f7a74002

RUN set -eux; \
    cd /usr/local/tomcat/webapps/geonetwork/; \
    curl -fSL -o geonetwork.war \
        "https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/${GN_FILE}/download"; \
    echo "${GN_DOWNLOAD_SHA256} *geonetwork.war" | sha256sum -c; \
    unzip -q geonetwork.war; \
    rm geonetwork.war

COPY tomcat/server.xml /usr/local/tomcat/conf/server.xml
COPY ./docker-entrypoint.sh /geonetwork-entrypoint.sh
ENTRYPOINT ["/geonetwork-entrypoint.sh"]
CMD ["catalina.sh","run"]

VOLUME [ "${DATA_DIR}" ]
