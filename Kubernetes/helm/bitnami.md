```
https://github.com/bitnami/charts/blob/main/bitnami/kafka/values.yaml
```
**Download kustomize file from bitnami**
```
# put kafka server with values file
helm template logging bitnami/logstash \
  --namespace kafka \
  --output-dir . \
  -f values.yaml \
  --validate
```
