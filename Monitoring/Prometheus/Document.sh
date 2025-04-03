## Alerting
Setup into rules
```
vi rules.yaml
groups:
  - name: node
    rules:
      - alert: node down
        expr: up{job="node"} == 0
        for: 5m
```
## Labels and annototion
```
groups:
  - name: node
    rules:
      - alert: node_filesystem_free_percent
        expr: 100 * node_filesystem_free_bytes{job="node"} / node_filesystem_size_bytes{job="node"} < 70
        annotations:
          description: "filesystem {{.Labels.device}} on {{.Labels.instance}} is low on space, current available space is {{.Values}}"
#the same--> noti
filesystem /dev/sda3 on 192.168.56.1:9100 is low on space, current available space is 20.4011
```
## Alertmanager Architecture
# Install alertmanager and localhost:9093
```
vi prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
alerting: 
  alertmanager: 
    - static_configs:
        - targets:
          - alertmanager1: 9093
          - alertmanager2: 9093
rules_files:
  - "*-rules.yml"
scrape_configs:
```
## setup systemd for alertmanager
```
sudo useradd --no-create-home --shell /bin/false alertmanager
sudo mkdir /etc/alertmanager
sudo mv alertmanager.yml /etc/alertmanager
sudo chown -R alertmanager:alertmanager /etc/alertmanager/alertmanager.yml

sudo cp alertmanager /usr/local/bin
sudo cp amtool /usr/local/bin 
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool
```
```
vi /etc/systemd/system/alertmanager.service
[Unit]
Description=Alert Manager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=alertmanager
Group=alertmanager
ExecStart=/usr/local/bin/alertmanager \
  --config.file=/etc/alertmanager/alertmanager.yml \
  --storage.path=/etc/alertmanager

Restart=always

[Install]
WantedBy=multi-user.target
```
