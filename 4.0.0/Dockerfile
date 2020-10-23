FROM jetty:9-jre8

ENV GN_FILE GeoNetwork-4.0.0-0.war
ENV GN_VERSION 4.0.0
ENV GN_DOWNLOAD_MD5 TODO

USER root
RUN apt-get -y update && \
    apt-get -y install curl && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /catalogue-data && \
    chown -R jetty:jetty /catalogue-data && \
    mkdir -p /var/lib/jetty/webapps/geonetwork && \
    chown -R jetty:jetty /var/lib/jetty/webapps/geonetwork

USER jetty
RUN cd /var/lib/jetty/webapps/geonetwork/ && \
    curl -fSL -o geonetwork.war \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_unstable_development_versions/${GN_VERSION}/$GN_FILE/download && \
     echo "$GN_DOWNLOAD_MD5 *geonetwork.war" | md5sum -c && \
     unzip geonetwork.war && \
     rm geonetwork.war

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["jetty.start"]
