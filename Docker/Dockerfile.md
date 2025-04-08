`https://github.com/Aiven-Open/prometheus-exporter-plugin-for-opensearch`

**Create image Opensearch have prometheus-exporter**
```
FROM docker.io/opensearchproject/opensearch:2.16.0
ADD https://github.com/aiven/prometheus-exporter-plugin-for-opensearch/releases/download/2.16.0.0/prometheus-exporter-2.16.0.0.zip prometheus-exporter-2.16.0.0.zip
USER root
RUN chmod 755 /usr/share/opensearch/prometheus-exporter-2.16.0.0.zip
RUN bin/opensearch-plugin install -b file:/usr/share/opensearch/prometheus-exporter-2.16.0.0.zip
USER opensearch
```
**Run build Image on Docker**
```
docker build -t openseach:2.16.0 .
```
--------------------------------------------
