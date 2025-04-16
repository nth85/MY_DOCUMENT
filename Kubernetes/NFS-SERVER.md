**NFS SERVER Install*
- Link document
*https://viblo.asia/p/k8s-phan-3-cai-dat-storage-cho-k8s-dung-nfs-RnB5pAw7KPG*

- Install nfs-server on k8s on CENTOS
```
- on server NFS
sudo -s
yum install nfs-utils -y #all incluce node k8s

- Create shared folder
mkdir -p /data/delete
mkdir -p /data/retain

- Change folder
chmod -R 755 /data
 
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap 

- on all node 
/data/retain    192.168.10.0/24(rw,sync,no_root_squash,no_all_squash)
/data/delete    192.168.10.0/24(rw,sync,no_root_squash,no_all_squash)
systemctl restart nfs-server

- test all node
showmount -e 192.168.56.121 #ip NFS server
export list: ....
```
- On NFS or Master nodes Install kubectl and helm
```
mkdir /home/nfs-storage
cd /home/nfs-storage

- install kubectl 
curl -LO https://dl.k8s.io/release/v1.30.4/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

mkdir -p $HOME/.kube
scp viettq-master1:~/.kube/config  $HOME/.kube/
sudo chown $(id -u):$(id -g) $HOME/.kube/config

- install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
sudo chmod 700 get_helm.sh
./get_helm.sh
```
**Install NFS pod on K8S***
```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm pull nfs-subdir-external-provisioner/nfs-subdir-external-provisioner
tar -xzf nfs-subdir-external-provisioner-4.0.18.tgz

cp nfs-client-provisioner/values.yaml nfs-delete.yaml
cp nfs-client-provisioner/values.yaml nfs-retain.yaml

- change file values
vi nfs-delete.yaml
replicaCount: 1
nfs:
  server: 192.168.56.121
  path: /data/delete
  volumeName: nfs-storage-delete-provisioner-root
  reclaimPolicy: Delete

storageClass:
  create: true
  provisionerName: nfs-storage-delete
  defaultClass: false
  name: nfs-delete
  allowVolumeExpansion: true
  reclaimPolicy: Delete
  archiveOnDelete: false
  accessModes: ReadWriteOnce
  volumeBindingMode: Immediate

vi nfs-retain.yaml
replicaCount: 1
nfs:
  server: 192.168.56.121
  path: /data/retain
  reclaimPolicy: Retain
storageClass:
  create: true
  provisionerName: nfs-storage-retain
  defaultClass: true
  name: nfs-retain
  allowVolumeExpansion: true
  reclaimPolicy: Retain
  archiveOnDelete: true
  accessModes: ReadWriteOnce
  volumeBindingMode: Immediate

- Deploy Pod
kubectl create namespace "storage"
namespace/storage created
helm install nfs-delete -f nfs-delete.yaml nfs-subdir-external-provisioner
helm install nfs-retain -f nfs-retain.yaml nfs-subdir-external-provisioner

- check pod and service
kubectl get pods -n storage
kubectl get sc

- PVC test
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-pvc-delete
spec:
  storageClassName: nfs-delete
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
```
**FIX Issue if pvc pending not bound create pv**
```
- version 1.30.4 not issue, if pending then.

k edit deployments -n storage nfs-storage...

-change image:
gcr.io/k8s-staging-sig-storage/nsf-subdir-external-provisioner:v4.0.0
```
