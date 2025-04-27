#!/bin/bash

# Run securityadmin.sh to initialize the cluster
echo "Running securityadmin.sh..."
/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
  -cd /usr/share/opensearch/config/opensearch-security/ \
  -cacert /usr/share/opensearch/config/certs/root-ca.pem \
  -cert /usr/share/opensearch/config/certs/admin.pem \
  -key /usr/share/opensearch/config/certs/admin-key.pem \
  -nhnv \
  -h opensearch-node2

# Execute the OpenSearch default entrypoint
exec /usr/local/bin/entrypoint.sh
