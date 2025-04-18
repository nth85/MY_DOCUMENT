## Download file *tar.gz
### OS#########################################
systemctl stop firewalld
sestatus disable
#Disable swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab 
sudo swapoff -a 
--
sudo vi /etc/security/limits.conf 
cmpprod - nproc 65536
cmpprod - memlock unlimited
--
sudo vi /etc/sysctl.conf 
vm.max_map_count=262144
##apply config with command:
sudo sysctl -p
sudo swapoff -a
==============================================================
## mount disk <2TB
printf "p\nn\np\n1\n\n\nt\n8e\np\nw" | sudo fdisk /dev/sdb
pvcreate /dev/sdb1
vgcreate VG00 /dev/sdb1
lvcreate -l 100%FREE -n LV_data VG00
mkfs.xfs /dev/VG00/LV_data
mkdir /data
echo "/dev/mapper/VG00-LV_data /data xfs defaults 0 0" >> /etc/fstab
mount -a 

sudo chown -R cmpprod:cmpprod /data 
## verify disk mounted
df -h 

##mount disk more than 2T
parted /dev/sdb
mklabel gpt
unit TB
mkpart primary 0 0
print
quit

printf "p\nn\np\n1\n\n\nt\n8e\np\nw" | sudo fdisk /dev/sdb
pvcreate /dev/sdb1
vgcreate VG00 /dev/sdb1
lvcreate -l 100%FREE -n LV_data VG00
mkfs.xfs /dev/VG00/LV_data
mkdir /data
echo "/dev/mapper/VG00-LV_data /data xfs defaults 0 0" >> /etc/fstab
mount -a 

sudo chown -R cmpprod:cmpprod /data 
 ##------------------------------------------------------------------------------------
=================================================================================
## Create "cmpprod" User

groupadd -g 1001 cmpprod
useradd -m -g 1001 -u 1001 -c cmpprod -s /bin/bash cmpprod
touch /home/cmpprod/.rhosts
echo "export TMOUT=1800" >> /home/cmpprod/.bash_profile
echo "umask 0022" >> /home/cmpprod/.bash_profile
echo "cmpprod ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/cmpprod
passwd cmpprod
===================================================================================
## set file hosts
vi /etc/hosts
192.168.56.111 es1
192.168.56.112 es2
...

===============================================
### Install JAVA
#https://jdk.java.net/22/
#tar -zxvf /tmp/openjdk-22.0.1_linux-x64_bin.tar -C /usr/share
#ln -s /usr/share/openjdk-22 /usr/share/jdk 
=====================================================================================
### Install Opensearch with Tarball packaget .tar.gz
tar -xvf /tmp/opensearch-2.14.0-linux-x64.tar.gz -C /home/cmpprod/
ln -s //home/cmpprod/opensearch-2.14.0 /home/cmpprod/opensearch 
==============================================================================
1. ## cofiguration file opensearch.yml
cluster.name: opensearch-cluster
node.name: opensearch-01
node.roles: [ cluster_manager ]  # master node
#node.roles: [ data, ingest ] ## data node

cluster.initial_cluster_manager_nodes: ["hostname-01", "hostanme-02", "hostname-03"] ## hostname master node
discovery.seed_hosts: ["datanode-01", "datanode-02", "datanode-03"]  ## all hostname of nodes in the cluster

plugins.security.ssl.transport.pemcert_filepath: /home/cmpprod/opensearch/config/certs/$HOSTNAME.pem
plugins.security.ssl.transport.pemkey_filepath: /home/cmpprod/opensearch/config/certs/$HOSTNAME-key.pem
plugins.security.ssl.transport.pemtrustedcas_filepath: root-ca.pem

plugins.security.ssl.transport.enforce_hostname_verification: false
plugins.security.ssl.http.enabled: true

plugins.security.ssl.http.pemcert_filepath: /home/cmpprod/opensearch/config/certs/$HOSTNAME.pem
plugins.security.ssl.http.pemkey_filepath: /home/cmpprod/opensearch/config/certs/$HOSTNAME-key.pem
plugins.security.ssl.http.pemtrustedcas_filepath: root-ca.pem

plugins.security.allow_unsafe_democertificates: true
plugins.security.allow_default_init_securityindex: true

plugins.security.authcz.admin_dn:
  - 'CN=A,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA'
plugins.security.nodes_dn:
  - 'CN=$HOSTNAME.dns.a-record,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA'
  - 'CN=node2.dns.a-record,OU=UNIT,O=ORG,L=TORONTO,ST=ONTARIO,C=CA'
.....
plugins.security.audit.type: internal_opensearch
plugins.security.enable_snapshot_restore_privilege: true
plugins.security.check_snapshot_restore_write_privileges: true
plugins.security.cache.ttl_minutes: 60
plugins.security.restapi.roles_enabled: ["all_access", "security_rest_api_access"]
plugins.security.system_indices.enabled: true
plugins.security.system_indices.indices: [".opendistro-alerting-config", ".opendistro-alerting-alert*", ".opendistro-anomaly-results*", ".opendistro-anomaly-detector*", ".opendistro-anomaly-checkpoints", ".opendistro-anomaly-detection-state", ".opendistro-reports-*", ".opendistro-notifications-*", ".opendistro-notebooks", ".opendistro-asynchronous-search-response*"]
==============================================================
2. ###Config file jvm.options
vi /path/to/opensearch/config/jvm.options
-Xms4g
-Xmx4g

sed -i "s|Xsm1g|Xsm8g|g" /home/cmpprod/opensearch/config/jvm.options
sed -i "s|Xsx1g|Xsx8g|g" /home/cmpprod/opensearch/config/jvm.options
========================================
3. ## Specify the location of the included JDK
export OPENSEARCH_JAVA_HOME=/home/cmpprod/opensearch/jdk
==========================================
4. ## Create Certificate 
mkdir /tmp/certs
cd /tmp/certs
vi certs.sh

# Create a private key for the root certificate
openssl genrsa -out root-ca-key.pem 2048
openssl req -new -x509 -sha256 -key root-ca-key.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=ORG/OU=UNIT/CN=root" -out root-ca.pem -days 9999

# Create a private key for the admin certificate.
openssl genrsa -out admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out admin-key.pem
openssl req -new -key admin-key.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=ORG/OU=UNIT/CN=A" -out admin.csr
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out admin.pem -days 9999

list_node="
opensearch01
opensearch02
client
"
for i in $list_node
do
# Create a private key for the node certificate.
openssl genrsa -out {$i}-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in {$i}-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out {$i}-key.pem
openssl req -new -key {$i}-key.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=ORG/OU=UNIT/CN={$i}.dns.a-record" -out {$i}.csr
echo subjectAltName=DNS:{$i}.dns.a-record > {$i}.ext
openssl x509 -req -in {$i}.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out {$i}.pem -days 9999 -extfile {$i}.ext
done
## Client certification
#openssl genrsa -out client-key-temp.pem 2048
#openssl pkcs8 -inform PEM -outform PEM -in client-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out client-key.pem
#openssl req -new -key client-key.pem -subj "/C=CA/ST=ONTARIO/L=TORONTO/O=ORG/OU=UNIT/CN=A" -out client.csr
#echo 'subjectAltName=DNS:client.dns.a-record' > client.ext
#openssl x509 -req -in client.csr -CA root-ca.pem -CAkey root-ca-key.pem -CAcreateserial -sha256 -out client.pem -days 9999
##Remove temporary files that are no longer required.
for i in $list_node
do
  rm {$i}-key-temp.pem 
  rm {$i}.ext
  rm {$i}.csr
done

.....
==============================================================================
5. Add trust for the self-signed root certificate.
# Copy the root certificate to the correct directory
sudo cp -r /tmp/certs /home/cmpprod/opensearch/config
sudo update-ca-trust
## copy to all nodes
### set environment variable java 
vi /home/cmpprod/.bash_profile
OPENSEARCH_JAVA_HOME=home/cmpprod/opensearch/jdk
source .bash_profile
### 
## create systemd for service
sudo vi /etc/systemd/system/opensearch.service
[Unit]
Description=OpenSearch
Wants=network-online.target
After=network-online.target

[Service]
Type=forking
RuntimeDirectory=data

WorkingDirectory=/opt/opensearch
ExecStart=/opt/opensearch/bin/opensearch -d

User=opensearch
Group=opensearch
StandardOutput=journal
StandardError=inherit
LimitNOFILE=65535
LimitNPROC=4096
LimitAS=infinity
LimitFSIZE=infinity
TimeoutStopSec=0
KillSignal=SIGTERM
KillMode=process
SendSIGKILL=no
SuccessExitStatus=143
TimeoutStartSec=75

[Install]
WantedBy=multi-user.target
============================================================
##Start Opensearch
sudo systemctl daemon-reload
sudo systemctl enable opensearch.service
sudo systemctl start opensearch
###
chmod 755 /home/cmpprod/opensearch/plugins/opensearch-security/tools/*.sh

# You can omit the environment variable if you declared this in your $PATH. 
#Create .opensearch_security index
/home/cmpprod/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /home/cmpprod/opensearch/config/opensearch-security/ \
-cacert /home/cmpprod/opensearch/config/root-ca.pem \
-cert /home/cmpprod/opensearch/config/admin.pem \
-key /home/cmpprod/opensearch/config/admin-key.pem -icl -nhnv
### Add CA root cert on all node
sudo cp /home/cmpprod/opensearch/config/root-ca.pem /etc/pki/ca-trust/source/anchors/
sudo update-ca-trust
========================
#verify that service running normal
curl -XGET https://$HOSTNAME:9200/cat_nodes?pretty -u 'admin:admin'
======================================================
=============================================================
NOTE::::###################################################
#when crate user service then back up all security from index to file with option -backup
/home/cmpprod/opensearch/plugins/opensearch-security/tools/securityadmin.sh -backup /home/cmpprod/opensearch/config/backup-opensearch-security-date/ \
-cacert /home/cmpprod/opensearch/config/root-ca.pem \
-cert /home/cmpprod/opensearch/config/admin.pem \
-key /home/cmpprod/opensearch/config/admin-key.pem -icl -nhnv
## copy file internal_users.yml to /home/cmpprod/opensearch/config/opensearch-security/
---modify flag if need not delete with API command 
## Apply again to index with option -f
/home/cmpprod/opensearch/plugins/opensearch-security/tools/securityadmin.sh -f /home/cmpprod/opensearch/config/opensearch-security/internal_users.yml \
-cacert /home/cmpprod/opensearch/config/root-ca.pem \
-cert /home/cmpprod/opensearch/config/admin.pem \
-key /home/cmpprod/opensearch/config/admin-key.pem -icl -nhnv -t internalusers
## GEN passwork with hash
cd //home/cmpprod/opensearch/plugins/opensearch-security/tools/
./hash.sh 
[password] <nhap password>
akjfhakjfhakjfhkjah   --> result 
#################################################################################
## Create Role and User service for client 
1. create role with permission 
2. create user and add to role 
#################################################################################
## Create ISM policy for index and auto rollover
https://opensearch.org/docs/latest/im-plugin/ism/policies/
https://opensearch.org/docs/latest/im-plugin/ism/api/
1. Create a policy with an ism_template field: 
#Create ISM policy with rollover, lifecycle delete, add alias template of index
PUT _plugins/_ism/policies/fw_logging_policy
2. Set up a template with the rollover_alias as log :
PUT _index_template/vpc_rollover
3. Create index first ex:vpc-fw-000001 and add to alias
PUT vpc-fw-000001
{
  "aliases": {
    "vpc-fw": {
      "is_write_index": true
    }
  }
}
GET _plugins/_ism/explain/log-000001?pretty  ## check 

=============================================
TRoubleshooting
1. ERROR 00h error permission when create file .log
-- modify log4j command line permission for file log -rw-r----
2. when create cert by hostname then on opensearch.yml set hotsname, error SSL tranfer
3. when log write to /var/log/message then modify file opensearch.service of sysstemd
