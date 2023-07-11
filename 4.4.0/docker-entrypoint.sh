#!/bin/bash
set -e

export JAVA_OPTIONS="${JAVA_OPTS} ${GN_CONFIG_PROPERTIES}"
GN_BASE_DIR=/opt/geonetwork
ES_ACTUAL_HOST=${ES_HOST:-localhost}

if ! command -v -- "$1" >/dev/null 2>&1 ; then
	set -- java -jar "$JETTY_HOME/start.jar" "$@"
fi

if [[ "$1" = jetty.sh ]] || [[ $(expr "$*" : 'java .*/start\.jar.*$') != 0 ]]; then

    # Set Elasticsearch properties
    sed -i "s#http://localhost:9200#${ES_PROTOCOL:="http"}://${ES_ACTUAL_HOST}:${ES_PORT:="9200"}#g" "${GN_BASE_DIR}/WEB-INF/web.xml" ;
    sed -i "s#es.host=localhost#es.host=${ES_ACTUAL_HOST}#" "${GN_BASE_DIR}/WEB-INF/config.properties" ;


    if [ -n "${ES_PROTOCOL}" ] && [ "${ES_PROTOCOL}" != "http" ] ; then
        sed -i "s#es.protocol=http#es.protocol=${ES_PROTOCOL}#" "${GN_BASE_DIR}/WEB-INF/config.properties" ;
    fi

    if [ -n "${ES_PORT}" ] && [ "$ES_PORT" != "9200" ] ; then
        sed -i "s#es.port=9200#es.port=${ES_PORT}#" "${GN_BASE_DIR}/WEB-INF/config.properties" ;
    fi

    if [ -n "${ES_INDEX_RECORDS}" ] && [ "$ES_INDEX_RECORDS" != "gn-records" ] ; then
        sed -i "s#es.index.records=gn-records#es.index.records=${ES_INDEX_RECORDS}#" "${GN_BASE_DIR}/WEB-INF/config.properties" ;
    fi

    if [ "${ES_USERNAME}" != "" ] ; then
        sed -i "s/es.username=.*/es.username=${ES_USERNAME}/" "${GN_BASE_DIR}/WEB-INF/config.properties" ;
    fi

    if [ "${ES_PASSWORD}" != "" ] ; then
        sed -i "s/es.password=.*/es.password=${ES_PASSWORD}/" "${GN_BASE_DIR}/WEB-INF/config.properties" ;
    fi

    if [ -n "${KB_URL}" ] && [ "$KB_URL" != "http://localhost:5601" ]; then
        sed -i "s#kb.url=http://localhost:5601#kb.url=${KB_URL}#" "${GN_BASE_DIR}/WEB-INF/config.properties" ;
        sed -i "s#http://localhost:5601#${KB_URL}#g" "${GN_BASE_DIR}/WEB-INF/web.xml" ;
    fi

    # Customize context path
    if [ ! -f "{$JETTY_BASE}/webapps/geonetwork.xml" ]; then
        echo "Using $WEBAPP_CONTEXT_PATH for deploying the application"
        cp /usr/local/share/geonetwork/geonetwork_context_template.xml "${JETTY_BASE}/webapps/geonetwork.xml"
        sed -i "s#GEONETWORK_CONTEXT_PATH#${WEBAPP_CONTEXT_PATH}#" "${JETTY_BASE}/webapps/geonetwork.xml"
    fi

    # Delegate on base image entrypoint to start jetty
    exec /docker-entrypoint.sh "$@"
else
    exec "$@"
fi
