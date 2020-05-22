# Elasticsearch

Version to use: `7.6.2`

Note: there are some infos to take into account when using elasticsearch docker images in production, see here:
https://www.elastic.co/guide/en/elasticsearch/reference/7.5/docker.html

For now, we will set the following environment variable in our compo:

```
discovery.type: single-node
```

# Working scenario

Shall we keep a "standalone GN image" ? For Geonetwork with integrated h2, it
seems possible, but having an Elasticsearch in the same docker image as
GeoNetwork seems to get against docker's best practices.

Yes, we shall consider having a standalone GN image with all softwares in one,
but not a priority for now.

# ES GN integration

Need to activate the "es" spring profile
it seems possible to activate it via the system properties (`-Dspring.profiles.active=es`).

# Kibana

Relying on the web admin ui, it requires modifications from the
config.properties

Also, the image will require a specific configuration for GN:
https://github.com/geonetwork/core-geonetwork/tree/es/es/es-dashboards#install-configure-and-start-kibana

The Kibana custom configuration is located in the `kibana/` subdirectory.

In case of custom ES hosts, one will require to adapt the `kibana/kibana.yml` config file.

# Reconfiguration

We can take advantage of the `docker-entrypoint.sh` script to patch the
configuration at startup for both ES and Kibana. 2 files need to be modified:

* `WEB-INF/web.xml`
* `WEB-INF/config.properties`

