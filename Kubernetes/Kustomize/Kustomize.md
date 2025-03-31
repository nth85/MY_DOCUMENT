**Install kustomizetion**
```
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
mv kustomize /usr/local/bin/
```
**add bash-completion for kustomize**
```
yum install bash-completion
kustomize completion bash > /etc/bash_completion.d/kustomize
# out and access again
```
**architech of kustomization**

![image](https://github.com/user-attachments/assets/113b79c3-8a78-4910-b1cd-03b57b9396d3)

**Create kustomize file**
```
mkdir -p resouce/base
cd resouce/base
kustomize init  # create file kustomization.yaml defaul
cat kustomization.yaml 
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - pvc.yaml
  - base
```
**Run test kustomize**
```
kustomize build .
```
```
kustomize build .  | kubectl apply -f -
```
```
kustomize build .  | kubectl delete -f -
```
*Transformer common*
```
- modify  (images)
- add (annotations)
- add (labels)
- add (namespace)
- add (prefix/suffix) (đầu/cuối)
```
**modify kustomize*
```
kustomize init
tree
├── api-depl.yaml
├── api-service.yaml
└── kustomization.yaml

# vim kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - api-depl.yaml
  - api-service.yaml

# add transformer namespace for all .yaml
namespace: tuanda

# modify transformer image and tag in the deployment if "name"
images:
  - name: httpd
    newName: nginx
    newTag: 1.21.0

#transformer Đặt tên đầu và cuối cho .yaml. 
#VD: xxx thành LAB-xxx-dev
namePrefix: LAB-
nameSuffix: -dev

#Thêm Annotations
commonAnnotations:
  branch: master

#add Labels into all .yaml
commonLabels:
  someName: someValue
  owner: tuanda
  app: bingo
```


