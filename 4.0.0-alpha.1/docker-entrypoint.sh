#!/bin/bash
set -e

if [ "$1" = 'catalina.sh' ]; then

    mkdir -p "$DATA_DIR"

    #Set geonetwork data dir
    export CATALINA_OPTS="$CATALINA_OPTS -Dgeonetwork.dir=$DATA_DIR"

    # postgresql mode enabled: reconfigure the webapp to enable postgres configuration

    if [ $POSTGRES_DB_HOST != "" ]; then
        #Setting host (use $POSTGRES_DB_HOST if it's set, otherwise use "postgres")
        db_host="${POSTGRES_DB_HOST:-postgres}"
        echo "db host: $db_host"

        #Setting port
        db_port="${POSTGRES_DB_PORT:-5432}"
        echo "db port: $db_port"

        if [ -z "$POSTGRES_DB_USERNAME" ] || [ -z "$POSTGRES_DB_PASSWORD" ]; then
            echo >&2 "you must set POSTGRES_DB_USERNAME and POSTGRES_DB_PASSWORD"
            exit 1
        fi

        db_gn="${POSTGRES_DB_NAME:-geonetwork}"

        #Write connection string for GN
        sed -ri '/^jdbc[.](username|password|database|host|port)=/d' "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
        echo "jdbc.username=$POSTGRES_DB_USERNAME" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
        echo "jdbc.password=$POSTGRES_DB_PASSWORD" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
        echo "jdbc.database=$db_gn" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
        echo "jdbc.host=$db_host" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
        echo "jdbc.port=$db_port" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties

        #Fixing an hardcoded port on the connection string (bug fixed on development branch)
        sed -i -e 's#5432#${jdbc.port}#g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-db/postgres.xml

        # reconfigure h2 -> postgres
        sed -i -e 's#<import resource="../config-db/h2.xml"/>#<!--<import resource="../config-db/h2.xml"/> -->#g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-node/srv.xml
        sed -i -e 's#<!--<import resource="../config-db/postgres.xml"/>-->#<import resource="../config-db/postgres.xml"/>#g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-node/srv.xml

    fi

    # Reconfigure Elasticsearch & Kibana if necessary
    if [ "$ES_HOST" != "localhost" ]; then
        sed -i "s#http://localhost:9200#${ES_PROTOCOL}://${ES_HOST}:${ES_PORT}#g" $CATALINA_HOME/webapps/geonetwork/WEB-INF/web.xml ;
        sed -i "s#es.host=localhost#es.host=${ES_HOST}#" $CATALINA_HOME/webapps/geonetwork/WEB-INF/config.properties ;
    fi;

    if [ "$ES_PROTOCOL" != "http" ] ; then
        sed -i "s#es.protocol=http#es.protocol=${ES_PROTOCOL}#" $CATALINA_HOME/webapps/geonetwork/WEB-INF/config.properties ;
    fi

    if [ "$ES_PORT" != "9200" ] ; then
        sed -i "s#es.port=9200#es.port=${ES_PORT}#" $CATALINA_HOME/webapps/geonetwork/WEB-INF/config.properties ;
    fi
    if [ "$ES_USERNAME" != "" ] ; then
        sed -i "s#es.username=#es.username=${ES_USERNAME}#" $CATALINA_HOME/webapps/geonetwork/WEB-INF/config.properties ;
    fi
    if [ "$ES_PASSWORD" != "" ] ; then
        sed -i "s#es.password=#es.password=${ES_PASSWORD}#" $CATALINA_HOME/webapps/geonetwork/WEB-INF/config.properties ;
    fi

    if [ "$KB_URL" != "http://localhost:5601" ]; then
        sed -i "s#kb.url=http://localhost:5601#kb.url=${KB_URL}#" $CATALINA_HOME/webapps/geonetwork/WEB-INF/config.properties ;
        sed -i "s#http://localhost:5601#${KB_URL}#g" $CATALINA_HOME/webapps/geonetwork/WEB-INF/web.xml ;
    fi
fi

exec "$@"
