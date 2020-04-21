#!/bin/bash
set -e

if [ "$1" = 'catalina.sh' ]; then

	mkdir -p "$DATA_DIR"

	#Set geonetwork data dir
	export CATALINA_OPTS="$CATALINA_OPTS -Dgeonetwork.dir=$DATA_DIR"
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

exec "$@"
