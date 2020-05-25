# Version 4.0.0-alpha1

## Running with integrated Elasticsearch

1. Clone this repository

```shell
git clone https://github.com/geonetwork/docker-geonetwork.git
cd docker-geonetwork/4.0.0-alpha.1
```

2. Run the docker-composition from the current directory:

```shell
docker-compose up
```

3. Open http://localhost:8080/geonetwork/ in a browser



## Running with remote Elasticsearch


```shell
docker run -p 8080:8080 \
-e "ES_HOST=my-es-host" \
-e "ES_PORT=9200" \
-e "ES_PROTOCOL=http" \
-e "KB_URL=http://my-kb-host:5601" \
geonetwork:4.0.0-alpha
```


## Running with custom geonetwork.war


This directory includes two Dockerfiles:
* `Dockerfile` is cannonical one used to generate the Docker Hub official 
image. It downloads GeoNetwork 4.0.0-alpha.1 WAR file from sourceforge.  
* `Dockerfile.local` needs a `geonetwork.war` file next to it to build
the image.

It also includes two docker-compose configuration files.
* `docker-compose.yml` uses official GeoNetwork image from Docker Hub.
* `docker-compose.dev.yml` can be applied to override the image used in 
`docker-compose.yml` and build the GeoNetwork image using `Dockerfile.local`.


### Pre-built image

To use the pre-built image you can use the `docker-compose.yml` file provided 
in this directory:

```shell
docker-compose up 
```

### Local image

To be able to generate an elasticsearch-ready docker image, you will have:

1. Build your geonetwork.war (https://geonetwork-opensource.org/manuals/trunk/en/maintainer-guide/installing/installing-from-source-code.html#the-quick-way)
2. Clone this repository

```shell
git clone https://github.com/geonetwork/docker-geonetwork.git
cd docker-geonetwork/4.0.0-alpha.1
```

3. Get the generated webapp in the current directory, name it `geonetwork.war`

```shell
cp ../../core-geonetwork/web/target/geonetwork.war .
```

4. Run the docker-composition from the current directory:

```shell
docker-compose -f docker-compose.yml -f docker-compose.dev.yml docker-compose up --build
```

5. Open http://localhost:8080/geonetwork/ in a browser

## Database configuration

See "Connecting to a postgres database" https://hub.docker.com/_/geonetwork


```shell
docker run --name geonetwork -d -p 8080:8080 \
-e POSTGRES_DB_HOST=my-db-host \
-e POSTGRES_DB_PORT=5434 \
-e POSTGRES_DB_USERNAME=postgres  \
-e POSTGRES_DB_PASSWORD=mysecretpassword \
-e POSTGRES_DB_NAME=mydbname \
geonetwork:4.0.0-alpha
```