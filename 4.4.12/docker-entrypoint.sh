#!/bin/bash
set -e

export CATALINA_OPTS="${GN_CONFIG_PROPERTIES}"

GN_BASE_DIR=/opt/geonetwork

if [[ "$1" = "catalina.sh" ]]; then
    if [[ -n "${REMOTE_IP_INTERNAL_PROXIES}" ]]; then
        sed -i "s@REMOTE_IP_INTERNAL_PROXIES_VALUE@${REMOTE_IP_INTERNAL_PROXIES//\\/\\\\}@" "${CATALINA_HOME}/conf/server.xml"
    else
        sed -i 's/ internalProxies="REMOTE_IP_INTERNAL_PROXIES_VALUE"//' "${CATALINA_HOME}/conf/server.xml"
    fi

    # Customize context path (Tomcat-style: file name = context path)
    if [[ ! "${WEBAPP_CONTEXT_PATH}" =~ ^/[a-zA-Z0-9_-]+$ ]]; then
        echo "ERROR: WEBAPP_CONTEXT_PATH must start with / followed by letters, digits, hyphens, or underscores (got: ${WEBAPP_CONTEXT_PATH})" >&2
        exit 2
    fi
    CONTEXT_NAME="${WEBAPP_CONTEXT_PATH#/}"
    CONTEXT_FILE="${CATALINA_HOME}/conf/Catalina/localhost/${CONTEXT_NAME}.xml"
    if [[ ! -f "${CONTEXT_FILE}" ]]; then
        echo "Using ${WEBAPP_CONTEXT_PATH} for deploying the application"
        mkdir -p "${CATALINA_HOME}/conf/Catalina/localhost"
        cp /usr/local/share/geonetwork/geonetwork_context_template.xml "${CONTEXT_FILE}"
        sed -i "s#GEONETWORK_CONTEXT_PATH#${WEBAPP_CONTEXT_PATH}#" "${CONTEXT_FILE}"
    fi

    exec "$@"
else
    exec "$@"
fi
