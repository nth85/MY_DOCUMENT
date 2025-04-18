
https://opensearch.org/docs/latest/about/
## download opensearch-dashboard with version the same opensearch
tar -zxf opensearch-dashboards-2.15.0-linux-x64.tar.gz
ln -s /home/user/opensearch-dashboards-2.15.0 /home/user/dashboard
##### Config 
https://opensearch.org/docs/latest/install-and-configure/install-dashboards/tls/

vi /home/user/dashboard/config/opensearch_dashboards.yml

opensearch.hosts: ["https://opensearch-01:9200", "https://opensearch-02:9200" ]

server.host: "$HOTSNAME"
server.port: 5601

server.ssl.enabled: true
server.ssl.certificate: /usr/share/opensearch-dashboards/config/client-cert.pem
server.ssl.key: /usr/share/opensearch-dashboards/config/client-cert-key.pem

opensearch.ssl.verificationMode: full
opensearch.username: "kibanaserver"
opensearch.password: "kibanaserver"

opensearch.ssl.certificateAuthorities: [ "/usr/share/opensearch-dashboards/config/root-ca.pem", "/usr/share/opensearch-dashboards/config/intermediate-ca.pem" ]

opensearch.requestHeadersAllowlist: [ authorization,securitytenant ]
opensearch_security.multitenancy.enabled: true
opensearch_security.multitenancy.tenants.preferred: ["Private", "Global"]
#opensearch_security.readonly_mode.roles: ["kibana_read_only"]
opensearch_security.cookie.secure: true

## Setup file systemd for opesearch-dashboard
vi /etc/systemd/system/opensearch-dashboards.service
Unit]
Description=OpenSearch
Wants=network-online.target
After=network-online.target

[Service]
Type=forking
RuntimeDirectory=data

User=opensearch
Group=opensearch

WorkingDirectory=/home/user/dashboards
ExecStart=/home/user/dashboards/bin/opensearch-dashboards
Restart=always

StandardOutput=journal
StandardError=inherit

[Install]
WantedBy=multi-user.target
===========================================
sudo systemctl enable opensearch-dashboards
sudo systemctl start opensearch-dashboards

#######################
#Setup opensearch-dashboards can authentcation for create role and user
vi /home/user/opensearch/config/opensearch-security/config.yml
....

