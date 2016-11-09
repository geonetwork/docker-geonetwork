#!/bin/bash
set -e

mkdir -p "$DATA_DIR"

#Set geonetwork data dir
sed -i '$d' /usr/local/tomcat/bin/setclasspath.sh
echo "CATALINA_OPTS=\"\$CATALINA_OPTS -Dgeonetwork.dir=$DATA_DIR\"" >> /usr/local/tomcat/bin/setclasspath.sh
echo "fi" >> /usr/local/tomcat/bin/setclasspath.sh

"$BASE_DIR"/bin/catalina.sh run

exec "$@"
