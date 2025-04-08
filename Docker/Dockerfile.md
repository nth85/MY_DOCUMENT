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
```
docker run <imageID>
```

**Run container by image local**
``
docker run -t -p 9200:9200 -p 9600:9600 -e "discovery.type=single-node" -e "OPENSEARCH_INITIAL_ADMIN_PASSWORD=Opensearch#123" openseach:2.16.0
``
**check docker opensearch service**
```
docker exec -it 8afa9ee6b998 sh
curl https://localhost:9200 -ku admin:Opensearch#123
curl https://localhost:9200/_cat/plugins?v -ku admin:Opensearch#123
```

--------------------------------------------
