#!/bin/bash
set -e

mkdir -p "$DATA_DIR"

#Set geonetwork data dir
sed -i '$d' /usr/local/tomcat/bin/setclasspath.sh
echo "CATALINA_OPTS=\"\$CATALINA_OPTS -Dgeonetwork.dir=$DATA_DIR\"" >> /usr/local/tomcat/bin/setclasspath.sh
echo "fi" >> /usr/local/tomcat/bin/setclasspath.sh

#Setting host
db_host=""
if grep -F "postgres" /etc/hosts
	then
	 echo "Found db container linked"
	 db_host="postgres"
else
	if [ -z "$POSTGRES_DB_HOST" ]; then
		echo "Found no db container linked. You must set POSTGRES_DB_HOST, if you want to connect to a remote DB"
		exit
	else
		db_host="$POSTGRES_DB_HOST"
	fi
fi

echo "db host:" $db_host

#Setting port
if [ -z "$POSTGRES_DB_PORT" ]; then
	db_port=5432
else
	db_port="$POSTGRES_DB_PORT"
fi
echo "db port:" $db_port

if [ -z "$POSTGRES_DB_USERNAME" ] || [ -z "$POSTGRES_DB_PASSWORD" ]; then
	echo "you must set POSTGRES_DB_USERNAME and POSTGRES_DB_PASSWORD"
	exit
fi

echo  "$db_host:$db_port:*:$POSTGRES_DB_USERNAME:$POSTGRES_DB_PASSWORD" > ~/.pgpass
chmod 0600 ~/.pgpass

db_admin="admin"
db_gn="geonetwork"

#Create databases, if they do not exist yet
if psql -h $db_host -U "$POSTGRES_DB_USERNAME" -p $db_port -lqt | cut -d \| -f 1 | grep -qw $db_gn; then
	echo "database $db_gn exists; do nothing"
else
	createdb -h $db_host -U "$POSTGRES_DB_USERNAME" -p $db_port -O "$POSTGRES_DB_USERNAME" $db_gn
fi

if psql -h $db_host -U "$POSTGRES_DB_USERNAME" -p $db_port -lqt | cut -d \| -f 1 | grep -qw $db_admin; then
	echo "database $db_admin exists; do nothing"
else
	createdb -h $db_host -U "$POSTGRES_DB_USERNAME" -p $db_port -O "$POSTGRES_DB_USERNAME" $db_admin
fi

#Write connection string for GN
echo "jdbc.username=$POSTGRES_DB_USERNAME" >> "$BASE_DIR"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
echo "jdbc.password=$POSTGRES_DB_PASSWORD" >> "$BASE_DIR"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
echo "jdbc.database=geonetwork" >> "$BASE_DIR"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
echo "jdbc.host=$db_host" >> "$BASE_DIR"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
echo "jdbc.port=$db_port" >> "$BASE_DIR"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties

#Fixing an hardcoded port on the connection string (bug fixed on development branch)
sed -i -e 's#5432#${jdbc.port}#g' $BASE_DIR/webapps/geonetwork/WEB-INF/config-db/postgres.xml

rm ~/.pgpass

"$BASE_DIR"/bin/catalina.sh run

exec "$@"
