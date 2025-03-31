**1.create ssl certificate for registry**
```
sudo mkdir -p /root/harbor/certs/
cd /root/harbor/certs/
```
2. Tạo CA (Certificate Authority)
```
sudo openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout ca.key \
    -x509 -days 365 -out ca.crt
```
3. Certificate Signing Request
```
sudo openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout harbor.trhuy.com.key \
    -out harbor.trhuy.com.csr
```
4. certificate for registry host
```
sudo openssl x509 -req -days 9999 -in harbor.trhuy.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out harbor.trhuy.com.crt
```
5. docker host muốn sử dụng registry này, copy file ca.crt vào đường dẫn sau /etc/docker/certs.d/harbor.trhuy.com/ca.crt
```
cp /root/harbor/certs/ca.crt /etc/docker/certs.d/harbor.trhuy.com/ca.crt
```
## Setup for harbor v2.7.0
**Download**
```
sudo wget https://github.com/goharbor/harbor/releases/download/v2.7.0/harbor-offline-installer-v2.7.0.tgz
sudo tar xvf harbor-offline-installer-v2.7.0.tgz
cd harbor
```
**Modify name file**
```
sudo cp harbor.yml.tmpl harbor.yml
```
**Config harbor.yml file**
```
# Cấu hình hostname hoặc ip để truy cập admin-ui và registry service
hostname: harbor.trhuy.com

# https related config
https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate: /root/harbor/certs/harbor.trhuy.com.crt
  # Ex: /home/ducbinh/certs/yourdomain.com.crt
  private_key: /root/harbor/certs/harbor.trhuy.com.key
  # Ex: /home/ducbinh/certs/yourdomain.com.key
```
**Run script start container**
```
sudo ./install.sh
```

**Access domain**
http://harbor.trhuy.com

# Setup for Harbor
**1. Login to**
```
Account admin: admin/Abc12345
```
*Create user: Chọn Administration/Users - thanh navidation bên trái.
*Create user: Demo/Abc@123

*Create Project: Chọn Projects - thanh navidation bên trái.
Create Project: DemoProject - private




