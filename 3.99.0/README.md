# Usage

To be able to generate a elasticsearch-ready docker image, you will have first
to build your geonetwork.war and put it into the current directory.

1. checkout the geonetwork/core-geonetwork project on github, branch es
2. mvn clean install
3. Get the generated webapp in the current directory, name it `geonetwork.war`
4. Run the docker-composition from the current directory:

```
$ docker-compose build && docker-compose up
```


