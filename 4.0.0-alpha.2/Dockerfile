FROM jetty:9-jre8

ENV GN_FILE geonetwork.war
ENV GN_VERSION 4.0.0-alpha.2
ENV GN_DOWNLOAD_MD5 TODO

ARG id
USER root
RUN apt-get -y update && \
    apt-get -y install vim \
    wget \
    curl \
    sudo

RUN mkdir -p /catalogue-data && \
    chown -R jetty:jetty /catalogue-data

RUN mkdir -p /var/lib/jetty/webapps/geonetwork && \
    chown -R jetty:jetty /var/lib/jetty/webapps/geonetwork

USER jetty

RUN cd /var/lib/jetty/webapps/geonetwork/ && \
    curl -fSL -o $GN_FILE \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_unstable_development_versions/${GN_VERSION}/geonetwork.war/download && \
     echo "$GN_DOWNLOAD_MD5 *${GN_FILE}" | md5sum -c \
     unzip geonetwork.war && \
     rm geonetwork.war

COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh", "jetty.start"]