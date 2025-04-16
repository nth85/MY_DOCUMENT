**Install Gitea on k8s**
https://docs.gitea.com/installation/install-on-kubernetes

```
helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo update gitea

helm template --output-dir . git --namesapce --values 1.yaml gitea gitea-charts/gitea
vi values.yaml

helm template --output-dir . gitea --namespace gitea -f values.yaml gitea-charts/gitea

cd gitea
k create ns gitea

k apply -f ./charts --recursive
k get pods -A
k apply -f . gitea --recursive
```

**Command Gitea**
```
k exec -it -n gitea gitea-... --bash

gitea admin user list
gitea admin user change-password --username nt.huy --password <pass>

gitea admin user create --username nt.huy --password <pass> --email user@example.com

gitea admin user delete --id 3 --username nt.huy
```
