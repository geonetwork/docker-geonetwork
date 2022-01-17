FROM jetty:9-jre8

ENV DATA_DIR /catalogue-data
ENV JAVA_OPTS -Dorg.eclipse.jetty.annotations.AnnotationParser.LEVEL=OFF \
        -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true \
        -Xms512M -Xss512M -Xmx2G -XX:+UseConcMarkSweepGC \
        -Dgeonetwork.resources.dir=${DATA_DIR}/resources \
        -Dgeonetwork.data.dir=${DATA_DIR} \
        -Dgeonetwork.codeList.dir=/var/lib/jetty/webapps/geonetwork/WEB-INF/data/config/codelist \
        -Dgeonetwork.schema.dir=/var/lib/jetty/webapps/geonetwork/WEB-INF/data/config/schema_plugins 

USER root
RUN apt-get -y update && \
    apt-get -y install curl && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /${DATA_DIR} && \
    chown -R jetty:jetty ${DATA_DIR} && \
    mkdir -p /var/lib/jetty/webapps/geonetwork && \
    chown -R jetty:jetty /var/lib/jetty/webapps/geonetwork

USER jetty
ENV GN_FILE GeoNetwork-4.0.5-0.war
ENV GN_VERSION 4.0.5
ENV GN_DOWNLOAD_MD5 7dfcfdffc66b9a97f0d24b0769e9c3b7
ENV LOG4J_VERSION=2.17.1
ENV LOG4J_SHA512=b7e948df6c6f57d903d990de2cc0270c1537b711285e9b6b91280db6ace38418fced713785b2c20512dd9a4238c2d1d0ceb414d9936df2ca110ff14993ae04dc

RUN cd /var/lib/jetty/webapps/geonetwork/ && \
     curl -fSL -o geonetwork.war \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/${GN_FILE}/download && \
     echo "${GN_DOWNLOAD_MD5} *geonetwork.war" | md5sum -c && \
     unzip -q geonetwork.war && \
     rm geonetwork.war && \
     rm /var/lib/jetty/webapps/geonetwork/WEB-INF/lib/log4j-core-* && \
     rm /var/lib/jetty/webapps/geonetwork/WEB-INF/lib/log4j-api* && \
     curl -fSL -o apache-log4j-${LOG4J_VERSION}-bin.tar.gz "https://dlcdn.apache.org/logging/log4j/${LOG4J_VERSION}/apache-log4j-${LOG4J_VERSION}-bin.tar.gz" && \
     echo "${LOG4J_SHA512} apache-log4j-${LOG4J_VERSION}-bin.tar.gz" | sha512sum -c && \
     tar -xvzf apache-log4j-${LOG4J_VERSION}-bin.tar.gz && \
     cp apache-log4j-${LOG4J_VERSION}-bin/log4j-core-${LOG4J_VERSION}.jar /var/lib/jetty/webapps/geonetwork/WEB-INF/lib/ && \
     cp apache-log4j-${LOG4J_VERSION}-bin/log4j-api-${LOG4J_VERSION}.jar /var/lib/jetty/webapps/geonetwork/WEB-INF/lib/ && \
     rm -rf apache-log4j-${LOG4J_VERSION}-bin*

COPY ./docker-entrypoint.sh /geonetwork-entrypoint.sh
ENTRYPOINT ["/geonetwork-entrypoint.sh"]
CMD ["java","-jar","/usr/local/jetty/start.jar"]

VOLUME [ "${DATA_DIR}" ]
