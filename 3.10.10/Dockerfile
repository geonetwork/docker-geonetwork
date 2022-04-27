FROM tomcat:8.5-jdk8

ENV GN_FILE geonetwork.war
ENV DATA_DIR=$CATALINA_HOME/webapps/geonetwork/WEB-INF/data
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"

#Environment variables
ENV GN_VERSION 3.10.10
ENV GN_DOWNLOAD_MD5 de09ba1a43d6f3a224ad5ff02b4c4fb3
ENV LOG4J_VERSION=2.17.2
ENV LOG4J_SHA512=cb3c349ae03b94ee9f066c8a1eaf9810a5cd56b9357180e5ff9c13d66c2aceea8b9095650ac4304dbcccea6c1280f255e940fde23045b6598896b655594bd75f

WORKDIR $CATALINA_HOME/webapps

RUN curl -fSL -o $GN_FILE \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/${GN_FILE}/download && \
     echo "$GN_DOWNLOAD_MD5 *${GN_FILE}" | md5sum -c && \
     mkdir -p geonetwork && \
     unzip -e $GN_FILE -d geonetwork && \
     rm $GN_FILE && \
     rm geonetwork/WEB-INF/lib/log4j-core-* && \
     rm geonetwork/WEB-INF/lib/log4j-api* && \
     curl -fSL -o apache-log4j-${LOG4J_VERSION}-bin.tar.gz "https://dlcdn.apache.org/logging/log4j/${LOG4J_VERSION}/apache-log4j-${LOG4J_VERSION}-bin.tar.gz" && \
     echo "${LOG4J_SHA512} apache-log4j-${LOG4J_VERSION}-bin.tar.gz" | sha512sum -c && \
     tar -xvzf apache-log4j-${LOG4J_VERSION}-bin.tar.gz && \
     cp apache-log4j-${LOG4J_VERSION}-bin/log4j-core-${LOG4J_VERSION}.jar "${CATALINA_HOME}/webapps/geonetwork/WEB-INF/lib/" && \
     cp apache-log4j-${LOG4J_VERSION}-bin/log4j-api-${LOG4J_VERSION}.jar "${CATALINA_HOME}/webapps/geonetwork/WEB-INF/lib/" && \
     rm -rf apache-log4j-${LOG4J_VERSION}-bin*

#Set geonetwork data dir
COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
