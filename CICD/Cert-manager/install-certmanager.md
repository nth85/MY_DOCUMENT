*https://raymii.org/s/tutorials/Self_signed_Root_CA_in_Kubernetes_with_k3s_cert-manager_and_traefik.html*
**Installing certmanager**
```
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.0 \
  --set startupapicheck.timeout=10m \
  --set crds.enabled=true \
  --set webhook.timeoutSeconds=30 \
  --set replicaCount=1 \
  --set podDisruptionBudget.enabled=true \
  --set podDisruptionBudget.minAvailable=1
 # --set prometheus.enabled=false \  # Example: disabling prometheus using a Helm parameter
 # --set webhook.timeoutSeconds=4

mkdir certmanager
cd certmanager
```
- Fix bug, create the self signed root CA
```
vi spnw-root-ca.yaml

k -n cert-manager apply -f spnw-root-ca.yaml

kubectl delete mutatingwebhookconfigurations.admissionregistrantion.k8s.io cert-manager-webhook
k delete validatingwebhookconfigurations.admissionregistrantion.k8s.io cert-manager-webhook

k get all -n cert-manager
```
**Check cert**
```
k describe ClusterIssuer -n cert-manager
k get secrets -n cert-manager spnw-intermediate-ca1-secret -o=jsonpath='{.data.tls\.crt}' | base64 --decode | openssl x509 -noot -text
