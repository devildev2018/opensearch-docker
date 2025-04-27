OpenSearch Cluster with Logstash, Filebeat, and SSL Configuration
This repository provides a Docker Compose setup for deploying an OpenSearch cluster, Logstash, and Filebeat with SSL encryption for secure communication. The configuration ensures the proper security and data flow between the components, making it suitable for production and secure logging environments.

Components:
OpenSearch Cluster: A distributed search and analytics engine built for scalability and security.

Logstash: A powerful pipeline that collects, processes, and forwards logs from various sources (e.g., Filebeat) to OpenSearch.

Filebeat: A lightweight shipper that collects log data from various systems and forwards them to Logstash for processing.

SSL Encryption: All communication between OpenSearch, Logstash, and Filebeat is encrypted using SSL/TLS certificates to ensure secure data transfer.
