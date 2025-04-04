## Alerting
Setup into rules
vi rules.yaml
groups:
  - name: node
    rules:
      - alert: node down
        expr: up{job="node"} == 0
        for: 5m
## Labels and annototion
groups:
  - name: node
    rules:
      - alert: node_filesystem_free_percent
        expr: 100 * node_filesystem_free_bytes{job="node"} / node_filesystem_size_bytes{job="node"} < 70
        annotations:
          description: "filesystem {{.Labels.device}} on {{.Labels.instance}} is low on space, current available space is {{.Values}}"
#the same--> noti
filesystem /dev/sda3 on 192.168.56.1:9100 is low on space, current available space is 20.4011

## Alertmanager Architecture
# Install alertmanager and localhost:9093
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
## setup systemd for alertmanager
sudo useradd --no-create-home --shell /bin/false alertmanager
sudo mkdir /etc/alertmanager
sudo mv alertmanager.yml /etc/alertmanager
sudo chown -R alertmanager:alertmanager /etc/alertmanager/alertmanager.yml

sudo cp alertmanager /usr/local/bin
sudo cp amtool /usr/local/bin 
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool

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
### Exam
vi rules.yaml

groups:
  - name: node
    rules:
      - alert: LowDiskSpace
        expr: 100 * node_filesystem_free_bytes{job="nodes"} / node_filesystem_size_bytes{job="nodes"} < 10
        labels:
          severity: warning
          environment: prod
      - alert: NodeDown
        expr: up{job="nodes"} == 0
        for: 10s
        labels:
          severity: critical

 curl localhost:9090/api/v1/rules | jq
### Setup Alert
cd /etc/prometheus
vi rules.yaml
groups:
  - name: my-alerts
    interval: 15s
    rules:
      - alert: NodeDown
        expr: up{job="node"} == 0
        for: 1m 
        labels:
          team: infra
          env: prod
        annotations:
          message: "instance {{.Labels.instance}} is currently down"

      - alert: DatabaseDown
        expr: up{job="db1"} == 0
        for: 0m 
        labels:
          team: database
          env: prod
        annotations:
          message: "instance {{.Labels.instance}} is currently down"
      - alert: DatabaseDown-dev
        expr: up{job="db2"} == 0
        for: 0m 
        labels:
          team: database
          env: dev
        annotations:
          message: "instance {{.Labels.instance}} is currently down"
#3 add rule_file into prometheus.yml
rule_files:
  - "rules.yaml"
alerting:
  alertmanagers:
    - static_configs:
        - targets: 
            - localhost:9093

#restart prometheus

# on Alertmanager
vi alertmanaget.yaml
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 1m
  repeat_interval: 2m
  receiver: 'web.hook'
  routes:
    - match_re:
        job: (node|db1|db2)
      group_by: ['team', 'env']
      receiver: slack
receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'
  - name: slack
    slack_configs:
      - api_url:
        channel: '#alerts'
        title: '{{.GroupLabels.team}} has alerts in env: {{.GroupLabels.env}}'
        text: '{{range .Alerts}}
{{.Annotations.message}}{{"\n"}}{{end}}'

systemctl restart alermanager

### exam
vi rules.yaml
groups:
  - name: node
    rules:
      - alert: NodeDown
        expr: up{job="nodes"} == 0
        for: 10s
        labels:
          severity: critical
          team: global-infra
      - alert: HostOutOfMemory
        expr: node_memory_MemAvailable_bytes{job="nodes"} / node_memory_MemTotal_bytes{job="nodes"} * 100 < 10  ## alert set < 95
        labels:
          severity: warning
          team: internal-infra
        annotations:
          message: "node {{.Labels.instance}} is seeing high memory usage, currently available memory: {{.Value}}%"
##
vi vi /etc/alertmanager/alertmanager.yml
global:
  smtp_smarthost: 'localhost:25'
  smtp_from: 'alertmanager@prometheus-server.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 2m
  repeat_interval: 1h
  receiver: 'general-email'
  routes:
    - match:
        team: internal-infra
      receiver: internal-infra-email
    - match:
        team: global-infra
      receiver: global-infra-email

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'
  - name: global-infra-email
    email_configs:
      - to: root@prometheus-server.com
        require_tls: false
  - name: internal-infra-email
    email_configs:
      - to: admin@prometheus-server.com
        require_tls: false
  - name: general-email
    email_configs:
      - to: admin@prometheus-server.com
        require_tls: false
### GUIDE###############
global:
  smtp_smarthost: 'localhost:25'
  smtp_from: 'alertmanager@prometheus-server.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 2m
  repeat_interval: 1h
  receiver: 'general-email'
  routes:
    - match:
        team: global-infra
      receiver: global-infra-email
    - match:
        team: internal-infra
      receiver: internal-infra-email

receivers:
  - name: 'web.hook'
    webhook_configs:
      - url: 'http://127.0.0.1:5001/'
  - name: global-infra-email
    email_configs:
      - to: "root@prometheus-server.com"
        require_tls: false
  - name: internal-infra-email
    email_configs:
      - to: "admin@prometheus-server.com"
        require_tls: false
  - name: general-email
    email_configs:
      - to: "admin@prometheus-server.com"
        require_tls: false
3
##check logs into email from 
admin@prometheus-server.com

less /var/spool/mail/admin
# name server root@prometheus-server

