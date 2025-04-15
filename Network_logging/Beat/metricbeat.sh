# Install metricbeat tarball
download package metricbeat-8.12.0-linux-x86_64.tar.gz 
# install
tar -xvf metricbeat-8.12.0-linux-x86_64.tar.gz -C /home/user
ln -s /home/user/metricbeat-8.12.0-linux /home/user/metricbeat
## metric tree
vi metricbeat/mericbeat.yml
metricbeat.config.moudules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false
setup.template.settings:
  index.number_of_shards: 1
  index.codec: best_compression
setup.kibana:
  host: "elasticsearch21:5601"
output.elasticserach:
  hosts: ["192.168.56.120:9200", ""]
  username: "elastic"
  password: ""
output.logstash:
  hosts: ["192.168.56.120:5044", ""]
## Check metricbeat service

tail -100f /data/logs/metricbeat/metricbeat

./metricbeat modules list
./metricbeat export config
./metricbeat modules enable linux
./metricbeat setup --dashboards
./metricbeat test config
./metricbeat test output

### Enable modules elasticsearch-xpack in the metricbeat
cd /home/user/metricbeat
./metricbeat modules enable elasticsearch-xpack
./metricbeat modules disable system #config defaul enable
./metricbeat modules disable elasticsearch-xpack

## check plugin of metricbeat
cd /home/user/metricbeat
ll ./modules.d

./metricbeat modules enable elasticsearch-xpack
vi /home/user/metricbeat/modules.d/elasticsearch-xpack
- module: elasticserach
  xpack.enabled: true
  hosts: ["http://129.168.56.123:9200"]
  username:
  password