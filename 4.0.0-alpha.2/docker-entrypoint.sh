#!/bin/bash
set -e

if [ "$1" = 'jetty.start' ]; then
  if [ "$ES_HOST" != "localhost" ]; then
      sed -i "s#http://localhost:9200#${ES_PROTOCOL}://${ES_HOST}:${ES_PORT}#g" $JETTY_BASE/webapps/geonetwork/WEB-INF/web.xml ;
      sed -i "s#es.host=localhost#es.host=${ES_HOST}#" $JETTY_BASE/webapps/geonetwork/WEB-INF/config.properties ;
  fi;

  if [ "$ES_PROTOCOL" != "http" ] ; then
      sed -i "s#es.protocol=http#es.protocol=${ES_PROTOCOL}#" $JETTY_BASE/webapps/geonetwork/WEB-INF/config.properties ;
  fi

  if [ "$ES_PORT" != "9200" ] ; then
      sed -i "s#es.port=9200#es.port=${ES_PORT}#" $JETTY_BASE/webapps/geonetwork/WEB-INF/config.properties ;
  fi

  if [ "$ES_USERNAME" != "" ] ; then
      sed -i "s#es.username=#es.username=${ES_USERNAME}#" $JETTY_BASE/webapps/geonetwork/WEB-INF/config.properties ;
  fi

  if [ "$ES_PASSWORD" != "" ] ; then
      sed -i "s#es.password=#es.password=${ES_PASSWORD}#" $JETTY_BASE/webapps/geonetwork/WEB-INF/config.properties ;
  fi

  if [ "$KB_URL" != "http://localhost:5601" ]; then
      sed -i "s#kb.url=http://localhost:5601#kb.url=${KB_URL}#" $JETTY_BASE/webapps/geonetwork/WEB-INF/config.properties ;
      sed -i "s#http://localhost:5601#${KB_URL}#g" $JETTY_BASE/webapps/geonetwork/WEB-INF/web.xml ;
  fi

  java $JAVA_OPTIONS -jar /usr/local/jetty/start.jar
else
  exec "$@"
fi
