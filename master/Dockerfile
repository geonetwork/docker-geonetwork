FROM tomcat:8.5-jre8

MAINTAINER pvangenuchten <paul@geocat.net>

WORKDIR $CATALINA_HOME/webapps

ENV GN_FILE geonetwork-3.11.0-SNAPSHOT-2021-01-04.war

RUN mv $CATALINA_HOME/webapps/ROOT $CATALINA_HOME/webapps/TOMCAT && \
    mkdir $CATALINA_HOME/webapps/ROOT && \ 
    cd $CATALINA_HOME/webapps/ROOT && \
    curl -fSL -o geonetwork.war \
    http://nightlybuild.geonetwork-opensource.org/master/${GN_FILE} && \
    unzip -q geonetwork.war && \
    rm geonetwork.war

CMD ["catalina.sh", "run"]


