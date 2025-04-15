# values.yaml
---
daemonset:
  extraEnvs: []
    - name: "ELASTICSEARCH_USERNAME"
      valueFrom:
        secretKeyRef:
          name: elasticsearch-master-credentials
          key: username
    - name: "ELASTICSEARCH_PASSWORD"
      valueFrom:
        secretKeyRef:
          name: elasticsearch-master-credentials
          key: password

  filebeatConfig:
    filebeat.yml: |
      filebeat.inputs:
      - type: container
        paths:
          - /var/log/containers/*.log
        processors:
        - add_kubernetes_metadata:
            host: ${NODE_NAME}
            matchers:
            - logs_path:
                logs_path: "/var/log/containers/"
      
      output.logstash:
        hosts: ["logstash-logstash:5044"]
        loadbalance: true
        index: sglog

    #   output.elasticsearch:
    #     host: '${NODE_NAME}'
    #     hosts: '["https://${ELASTICSEARCH_HOSTS:elasticsearch-master:9200}"]'
    #     username: '${ELASTICSEARCH_USERNAME}'
    #     password: '${ELASTICSEARCH_PASSWORD}'
    #     protocol: https
    #     ssl.certificate_authorities: ["/usr/share/filebeat/certs/ca.crt"]


  maxUnavailable: 1
  nodeSelector: {}
  secretMounts: {}

deployment:
  enabled: false

replicas: 1

image: "docker.elastic.co/beats/filebeat"
imageTag: "8.5.1"
imagePullPolicy: "IfNotPresent"
imagePullSecrets: []
