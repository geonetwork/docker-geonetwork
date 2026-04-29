#!/bin/bash
set -e

export CATALINA_OPTS="${JAVA_OPTIONS}"

if [[ "$1" = "catalina.sh" ]]; then
    if [[ -n "${REMOTE_IP_INTERNAL_PROXIES}" ]]; then
        sed -i "s@REMOTE_IP_INTERNAL_PROXIES_VALUE@${REMOTE_IP_INTERNAL_PROXIES//\\/\\\\}@" "${CATALINA_HOME}/conf/server.xml"
    else
        sed -i 's/ internalProxies="REMOTE_IP_INTERNAL_PROXIES_VALUE"//' "${CATALINA_HOME}/conf/server.xml"
    fi

    # Sanity check: ES_HOST variable is mandatory
    if [[ -z "${ES_HOST}" ]]; then
        cat >&2 <<- EOWARN
			********************************************************************
			WARNING: Environment variable ES_HOST is mandatory

			GeoNetwork requires an Elasticsearch instance to store the index.
			Please define the variable ES_HOST with the Elasticsearch
			host name. For example

			docker run -e ES_HOST=elasticsearch geonetwork:${GN_VERSION}

			********************************************************************
		EOWARN
        exit 2
    fi;

    GN_WEBAPPS_DIR=/usr/local/tomcat/webapps/geonetwork

    # config.properties resolves ES/Kibana settings via Spring SpEL systemEnvironment[...]
    # lookups, so translate the legacy ES_*/KB_URL contract into the GEONETWORK_* names.
    [[ -n "${ES_HOST}" ]]     && export GEONETWORK_ES_HOST="${ES_HOST}"
    [[ -n "${ES_PORT}" ]]     && export GEONETWORK_ES_PORT="${ES_PORT}"
    [[ -n "${ES_PROTOCOL}" ]] && export GEONETWORK_ES_PROTOCOL="${ES_PROTOCOL}"
    [[ -n "${ES_USERNAME}" ]] && export GEONETWORK_ES_USERNAME="${ES_USERNAME}"
    [[ -n "${ES_PASSWORD}" ]] && export GEONETWORK_ES_PASSWORD="${ES_PASSWORD}"
    [[ -n "${KB_URL}" ]]      && export GEONETWORK_KIBANA_URL="${KB_URL}"

    # web.xml proxy servlets still hard-code localhost targets — rewrite them.
    if [[ "${ES_HOST}" != "localhost" ]]; then
        sed -i "s#http://localhost:9200#${ES_PROTOCOL:=http}://${ES_HOST}:${ES_PORT:=9200}#g" "${GN_WEBAPPS_DIR}/WEB-INF/web.xml"
    fi

    if [[ -n "${KB_URL}" ]] && [[ "${KB_URL}" != "http://localhost:5601" ]]; then
        sed -i "s#http://localhost:5601#${KB_URL}#g" "${GN_WEBAPPS_DIR}/WEB-INF/web.xml"
    fi

    if [[ -n "${ES_INDEX_RECORDS}" ]] && [[ "${ES_INDEX_RECORDS}" != "gn-records" ]]; then
        sed -i "s#es.index.records=gn-records#es.index.records=${ES_INDEX_RECORDS}#" "${GN_WEBAPPS_DIR}/WEB-INF/config.properties"
    fi

    exec "$@"
else
    exec "$@"
fi
