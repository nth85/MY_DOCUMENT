**Set label for K8S Node**
```
k label nodes master network-logging=enbaled
k label nodes worker01 network-logging=enbaled
k get nodes -l network-logging=enbaled
```
**Create Image private on Harbor repo**
```
1. Opensearch
docker login harbor.trhuy.com -u admin -p <password>
vi Dockerfile

FROM docker.io/opensearchproject/opensearch:2.17.0
ADD https://github.com/aiven/prometheus-exporter-plugin-for-opensearch/releases/download/2.17.1.0/prometheus-exporter-2.17.1.0.zip prometheus-exporter-2.17.1.0.zip
USER root
RUN chmod 755 /usr/share/opensearch/prometheus-exporter-2.17.1.0.zip
RUN bin/opensearch-plugin install -b file://usr/share/opensearch/prometheus-exporter-2.17.1.0.zip
USER opensearch

docker build -t opensearch:2.17.0 .

- Push Image to Harbor
docker tag  opensearch:2.17.0 harbor.trhuy.com/demo/opensearch:2.17.0
docker login harbor.trhuy.com -u admin -p <password>
docker push harbor.trhuy.com/demo/opensearch:2.17.0

2. Logstash
vi Dockerfile

FROM logstash:8.15.0
RUN echo 'OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)' >> /usr/share/logstash/lib/pluginmanager/install.rb
RUN bin/logstash-plugin install logstash-output-opensearch
RUN sed -i '/OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)/d' /usr/share/logstash/lib/pluginmanager/install.rb

docker build -t opensearch:2.17.0 .
OR:
docker pull opensearchproject/logstash-oss-with-opensearch-output-plugin:8.9.0
```
**Create Manifest file config for Service**

*1. Opensearch*
```
cd /firewall/opensearch
vi values.yaml
- download manifest file config
helm repo add opensearch https://opensearch-project.github.io/helm-charts/
helm repo update
helm repo list
helm search repo opensearch

helm template --validate --output-dir . --version 2.22.1 --namespace opensearch -f values.yaml opensearch opensearch/opensearch

- Create kustomize tree
kustomize init
kustomize build .

- Push to git
git init
git add .
git status
git commit -m "update"
git remote add origin "https://my_git.com"
git push origin master --force

git pull origin master

- Deploy app into K8S by ArgoCD
- check Opensearch within pod
k exec -it -n opensearch openserach-cluster-master-0 -- bash
curl -XGET "https://$HOSTNAME:9200/_cat/plugins?v=true&pretty" -k -u 'admin:password'
curl -XGET "https://$HOSTNAME:9200/_cluster/health?pretty" -k -u 'admin:password'
curl -XGET "https://$HOSTNAME:9200/_cat/nodes?pretty" -k -u 'admin:password'

- Opensearch-Dashboard

helm template --validate --output-dir . --version 2.20.0 --namespace opensearch -f values.yaml opensearch-dashboards opensearch/opensearch-dashboards

- Create kustomize tree
kustomize init
kustomize build .

- Push to git
git init
git add .
git status
git commit -m "update"
git remote add origin "https://my_git.com"
git push origin master --force
```

*2.Deploy Prometheus and Grafana*
```
1. Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm template --validate --output-dir . --version 25.23.0 --namespace monitoring -f values.yaml prometheus prometheus-community/prometheus
- Create kustomize tree
kustomize init
kustomize build .

2. Grafana
helm repo add grafana https://grafana.github.io/helm-charts

helm template --validate --output-dir . --version 8.8.5 --namespace monitoring -f values.yaml grafana grafana/grafana
- Create kustomize tree
kustomize init
kustomize build .

git add .
git status
git commit -m "update"
git push origin master --force
```

*3.Deploy Logtash service*
```
vi values.yaml
helm repo add elastic
helm repo update
helm template --validate --output-dir . --version 8.5.1--namespace opensearch -f values.yaml logstash elastic/logstash
- Create kustomize tree
kustomize init
kustomize build .
```

*4.Deploy filebeat service*
```
vi values.yaml
helm repo add elastic
helm repo update
helm template --validate --output-dir . --version 8.5.1--namespace opensearch -f values.yaml filebeat elastic/filebeat
- Create kustomize tree
kustomize init
kustomize build .
```

*6. Deploy akhq service*
```
vi values.yaml
helm repo add akhq https://akhq.io/
helm repo update

helm template --validate --output-dir . --version 0.25.1--namespace kafka -f values.yaml akhq akhq/akhq
- Create kustomize tree
kustomize init
kustomize build .
```