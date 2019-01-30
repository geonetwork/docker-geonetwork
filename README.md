# About this Repo
Changes in /3.4.4/postgres/docker-entrypoint.sh to allow multiple geonetworks on the same DMBS and/or the possibility to use a database-user without permission to create databases.


# Origianl Repo
[geonetwork/docker-geonetwork](https://registry.hub.docker.com/_/geonetwork/)

This is the Git repo of the official Docker image for [geonetwork](https://registry.hub.docker.com/_/geonetwork/). See the
Hub page for the full readme on how to use the Docker image and for information
regarding contributing and issues.

The full readme is generated over in [docker-library/docs](https://github.com/docker-library/docs),
specificially in [docker-library/docs/geonetwork](https://github.com/docker-library/docs/tree/master/geonetwork).

# Como usar este Repo
Si los cambios aún no fueron incluidos en el repositorio original, tenés que crear una imagen docker a partir de este repo y luego instanciar esa imagen para cada geonetwork que quieras iniciar.

# Clonar Repositorio
```
git clone https://github.com/gvarela1981/docker-geonetwork.git
```

# Constuir la imágen en una red con proxy
```
docker build --no-cache -t geonetwork:postgres-customdb --build-arg http_proxy=http://<ip_proxy>:<puerto> --build-arg https_proxy=https://<ip_proxy>:<puerto>  .
```
no olvidar el punto al final 
# Constuir la imágen en una red sin proxy
```
docker build --no-cache -t geonetwork:postgres-customdb .

```
no olvidar el punto al final 

# Instanciar el contenedor
```
docker run --name <nombre_instancia_elgido> -p <puerto_elegido>:8080 -e POSTGRES_DB_HOST=<ip_server_db> -e POSTGRES_DB_NAME=<nombre_db_ya_creada> -e POSTGRES_DB_USERNAME=<username_con_acceso_escritura_a_la_db> -e POSTGRES_DB_PASSWORD=<password> -d geonetwork:postgres-customdb; docker logs -f<nombre_instancia_elgido>
```

El <puerto_elejido> se utilizará luego para ingresar al sistema.

Se observarán muchos datos y mensajes, cuando termine se verá este mensaje.
```
Deployment of web application directory [/usr/local/tomcat/webapps/src] has finished in [xxx] ms
```
Una vez que aparece ese mensaje se puede utilizar el geonetwork ingresando en el navegador web la IP y el puerto donde se ejecuta el contenedor

Ejemplo:

http://192.168.1.54:5003/geonetwork/

Ya puede iniciar todas las instancias de prueba con docker, para iniciar instancias en contenedores que publicarán metadatos de forma contínua se recomienda instanciarlos en forma de servicios, de esa manera la administración de los contenedores será mas sencilla en el día a día.

# Instanciar un segundo contenedor
```
docker run --name <nombre_2da_instancia_elgido> -p <otro_puerto_elegido>:8080 -e POSTGRES_DB_HOST=<ip_server_db> -e POSTGRES_DB_NAME=<nombre_otra_db_ya_creada> -e POSTGRES_DB_USERNAME=<username_con_acceso_escritura_a_la_db> -e POSTGRES_DB_PASSWORD=<password> -d geonetwork:postgres-customdb; docker logs -f<nombre_2da_instancia_elgido>
```
Al finalizar el proces puede ingresar al segundo sistema ingresando la misma IP en el nuevo puerto

Ejemplo:

http://192.168.1.54:5026/geonetwork/
