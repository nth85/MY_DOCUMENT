**Install MetalLB for LoadBlancer**
- link support
*https://metallb.universe.tf/installation/*
- Enable strict ARP mode If you
```
kubectl edit configmap -n kube-system kube-proxy

apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true

-- OR run command

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system
```
- Install MetalLB
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
```
- Configuration for to advertise the IP pool
```
vi metallb-ipadd-pool.yaml

apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.56.240-192.168.56.250

k apply -f metallb-ipadd-pool.yaml

-If not apply use for fix
k delete validatingwebhookconfigurations metallb-webhook-configuration
```
- Advertise the IP Address pool
```
vi metallb-pool-advertise.yaml

apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool

k apply -f metallb-pool-advertise.yaml
k get pod -n metallb-system
```
- Test deploy app and expose service with type loadbalancer
```
k expose deployment nginx-web-server --port=80 --target-port=80 --type=LoadBalancer
```

**Install NGINX INgress controller**
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-class ingress-nginx/ingress-nginx

#helm uninstall ingress-class
```
