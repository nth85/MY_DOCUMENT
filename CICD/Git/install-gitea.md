**Install Gitea on k8s**
https://docs.gitea.com/installation/install-on-kubernetes

```
helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo update gitea

helm template --output-dir . git --namesapce --values 1.yaml gitea gitea-charts/gitea
vi values.yaml
```
