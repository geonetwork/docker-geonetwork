FROM geonetwork:3.0.4

RUN apt-get update && apt-get install -y postgresql-client && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

#Set PostgreSQL as default GN DB
RUN sed -i -e 's#<import resource="../config-db/h2.xml"/>#<!--<import resource="../config-db/h2.xml"/> -->#g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-node/srv.xml
RUN sed -i -e 's#<!--<import resource="../config-db/postgres.xml"/>-->#<import resource="../config-db/postgres.xml"/>#g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-node/srv.xml

COPY ./jdbc.properties $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-db/jdbc.properties

#Initializing database & connection string for GN
COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
