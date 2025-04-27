OpenSearch Cluster with Logstash, Filebeat, and SSL Configuration
This repository provides a Docker Compose setup for deploying an OpenSearch cluster, Logstash, and Filebeat with SSL encryption for secure communication. The configuration ensures the proper security and data flow between the components, making it suitable for production and secure logging environments.

Components:
OpenSearch Cluster: A distributed search and analytics engine built for scalability and security.

Logstash: A powerful pipeline that collects, processes, and forwards logs from various sources (e.g., Filebeat) to OpenSearch.

Filebeat: A lightweight shipper that collects log data from various systems and forwards them to Logstash for processing.

SSL Encryption: All communication between OpenSearch, Logstash, and Filebeat is encrypted using SSL/TLS certificates to ensure secure data transfer.

Architecture Overview:
OpenSearch Cluster:

Three nodes in a Docker-based cluster with SSL encryption for secure internal communication.

Logstash:

Two Logstash nodes handling data ingestion from Filebeat.

Filebeat:

Configured to forward logs securely to Logstash.

The configuration also includes health checks to ensure the services are running as expected.

Requirements:
Docker

Docker Compose

Make sure Docker Desktop is installed and running on your machine.

Setup:
Step 1: Generate SSL Certificates
Before starting the Docker Compose stack, you need to generate the SSL certificates for OpenSearch, Logstash, and Filebeat using the provided generate-certs.sh script.

Run the following command to generate the certificates:
./gencert.sh

This will generate the necessary certificates in the certs/ directory.

Start the containers: Use Docker Compose to bring up the stack:

docker-compose up -d

This will ensure that the containers are up and running, you can always verify the nodes using

docker-compose logs -f

Docker Compose Configuration
OpenSearch Service
Three OpenSearch nodes (opensearch-node1, opensearch-node2, opensearch-node3) are created with SSL-enabled communication. Each node is configured to use the certificates generated earlier.

The OpenSearch Dashboards service (opensearch-dashboards) is configured to connect securely to the OpenSearch cluster using SSL.

Logstash Service
Logstash is configured to receive logs from Filebeat over HTTP/HTTPS and send them to the OpenSearch cluster securely.

The logstash.conf configuration file defines pipelines for processing the logs, applying filters, and sending them to OpenSearch.

Filebeat Service
Filebeat ships logs from the host machine (or Docker containers) to Logstash. The configuration file filebeat.yml contains details about the Logstash input and the SSL certificates required for secure communication.

SSL Certificates Configuration
SSL certificates are crucial for securing the communication between OpenSearch, Logstash, and Filebeat. These certificates are generated dynamically using the provided gencert.sh script.

Root CA: Used to sign the certificates.

Node Certificates: Used for each OpenSearch node and Logstash to ensure secure communication.

Admin Certificate: Used for administrative actions, such as interacting with OpenSearch via RESTful API.

The certificates are placed in the certs/ directory, and each service uses its own private key and certificate for secure communication.

Accessing OpenSearch Dashboards
Once the Docker Compose setup is complete, you can access OpenSearch Dashboards via the following URL:

https://localhost:5601

You will need to accept the SSL certificate if it’s self-signed.

Health Checks
Each service is configured with health checks to ensure that they are up and running. For example:

OpenSearch: The health check ensures the cluster status is green before it is considered healthy.

Logstash: The health check verifies that Logstash is able to connect to OpenSearch and receive logs.

Filebeat: The health check ensures Filebeat is sending logs correctly to Logstash.

You can monitor the status of each service using docker-compose ps or by checking the logs with docker-compose logs.

Cleanup
To stop and remove all containers and networks created by Docker Compose, run:

docker-compose down

If you want to also remove volumes (i.e., all persistent data), use:

docker-compose down -v

Notes
Certificates: Ensure that the certificates are properly generated and mounted for all services. Missing certificates or incorrect paths can prevent the services from starting.

Resource Management: Depending on your system resources, you might need to adjust the Docker Compose configuration to allocate sufficient resources (e.g., memory) for the OpenSearch nodes.




