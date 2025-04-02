https://prometheus.io/download/#prometheus  
## Install prometheus
tar xvf pro..
mkdir /etc/prometheus
cd /prometheus
cp -r consoles console_... prometheus.yml /etc/prometheus
cp prometheus prometool /etc/local/bin
sudo chown prometheus:prometheus ... all_file
## create systemd run prometheus

vi /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /etc/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/consoles_libraries

[Install]
WantedBy=multi-user.target

systemctl start prometheus.service
###########
# install node_exporter
wget ..
tar xvf 
cd node_exporter-1.4.0.linux-amd64
sudo cp node_exporter /usr/local/bin
# create user for exporter
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

vi /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

#######
# setup scrapte
vi /etc/prometheus/prometheus.yml
scrape_configs:
  - job_name: "nodes"
    static_configs:
      - targets: ["node01:9100", "node02:9100"]
# restart prometheus for new config
systemctl restart prometheus
# check on dashboads of prometheus 
target: 

