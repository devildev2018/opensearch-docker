#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Define certificate folder
CERTS_DIR="./certs"

# Create the certificates directory if it doesn't exist
mkdir -p "$CERTS_DIR"

# Passphrase
PASSPHRASE="1nf0M@t1cs"

# ============================================
# 1. Generate Root CA
# ============================================

echo "Generating Root Certificate Authority (CA)..."

openssl genpkey -algorithm RSA -out "$CERTS_DIR/root-ca.key" -aes256 -pass pass:$PASSPHRASE

openssl req -key "$CERTS_DIR/root-ca.key" -new -x509 -out "$CERTS_DIR/root-ca.pem" -days 3650 \
  -subj "/C=DE/ST=Test/L=Test/O=Test/CN=Root-CA" -passin pass:$PASSPHRASE

echo "Root CA generated at $CERTS_DIR/root-ca.pem"

# ============================================
# 2. Generate Admin Certificate
# ============================================

echo "Generating Admin Certificate (Transport)..."

# Encrypted private key
openssl genpkey -algorithm RSA -out "$CERTS_DIR/admin-key.pem" -aes256 -pass pass:$PASSPHRASE

# Decrypt private key (overwrite same file)
openssl rsa -in "$CERTS_DIR/admin-key.pem" -out "$CERTS_DIR/admin-key.pem.tmp" -passin pass:$PASSPHRASE
mv "$CERTS_DIR/admin-key.pem.tmp" "$CERTS_DIR/admin-key.pem"

# Create CSR
openssl req -key "$CERTS_DIR/admin-key.pem" -new -out "$CERTS_DIR/admin.csr" -subj "/C=DE/ST=Test/L=Test/O=Test/CN=admin"

# Sign certificate
openssl x509 -req -in "$CERTS_DIR/admin.csr" -CA "$CERTS_DIR/root-ca.pem" -CAkey "$CERTS_DIR/root-ca.key" \
  -CAcreateserial -out "$CERTS_DIR/admin.pem" -days 3650 -passin pass:$PASSPHRASE

# Cleanup
rm "$CERTS_DIR/admin.csr"

echo "Admin certificate generated at $CERTS_DIR/admin.pem"

# ============================================
# 3. Generate Node Certificate (for OpenSearch Nodes)
# ============================================

echo "Generating Node Certificate (for all OpenSearch nodes)..."

# Encrypted private key
openssl genpkey -algorithm RSA -out "$CERTS_DIR/opensearch-nodes-key.pem" -aes256 -pass pass:$PASSPHRASE

# Decrypt private key (overwrite same file)
openssl rsa -in "$CERTS_DIR/opensearch-nodes-key.pem" -out "$CERTS_DIR/opensearch-nodes-key.pem.tmp" -passin pass:$PASSPHRASE
mv "$CERTS_DIR/opensearch-nodes-key.pem.tmp" "$CERTS_DIR/opensearch-nodes-key.pem"

# OpenSSL config
cat > "$CERTS_DIR/opensearch-nodes.cnf" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C = DE
ST = Test
L = Test
O = Test
CN = opensearch-cluster

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = opensearch-node1
DNS.2 = opensearch-node2
DNS.3 = opensearch-node3
DNS.4 = opensearch-node4
IP.1 = 127.0.0.1
EOF

# Create CSR
openssl req -new -key "$CERTS_DIR/opensearch-nodes-key.pem" -out "$CERTS_DIR/opensearch-nodes.csr" -config "$CERTS_DIR/opensearch-nodes.cnf"

# Sign certificate
openssl x509 -req -in "$CERTS_DIR/opensearch-nodes.csr" -CA "$CERTS_DIR/root-ca.pem" -CAkey "$CERTS_DIR/root-ca.key" \
  -CAcreateserial -out "$CERTS_DIR/opensearch-nodes.pem" -days 3650 -sha256 -extfile "$CERTS_DIR/opensearch-nodes.cnf" -extensions req_ext -passin pass:$PASSPHRASE

# Cleanup
rm "$CERTS_DIR/opensearch-nodes.csr" "$CERTS_DIR/opensearch-nodes.cnf"

echo "Certificate for OpenSearch nodes generated at $CERTS_DIR/opensearch-nodes.pem"

# ============================================
# 4. Generate Separate Certificate for OpenSearch Dashboards
# ============================================

echo "Generating separate certificate for OpenSearch Dashboards..."

# Encrypted private key
openssl genpkey -algorithm RSA -out "$CERTS_DIR/opensearch-dashboards-key.pem" -aes256 -pass pass:$PASSPHRASE

# Decrypt private key (overwrite same file)
openssl rsa -in "$CERTS_DIR/opensearch-dashboards-key.pem" -out "$CERTS_DIR/opensearch-dashboards-key.pem.tmp" -passin pass:$PASSPHRASE
mv "$CERTS_DIR/opensearch-dashboards-key.pem.tmp" "$CERTS_DIR/opensearch-dashboards-key.pem"

# OpenSSL config
cat > "$CERTS_DIR/opensearch-dashboards.cnf" <<EOF
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C = DE
ST = Test
L = Test
O = Test
CN = opensearch-dashboards

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = opensearch-dashboards
IP.1 = 127.0.0.1
EOF

# Create CSR
openssl req -new -key "$CERTS_DIR/opensearch-dashboards-key.pem" -out "$CERTS_DIR/opensearch-dashboards.csr" -config "$CERTS_DIR/opensearch-dashboards.cnf"

# Sign certificate
openssl x509 -req -in "$CERTS_DIR/opensearch-dashboards.csr" -CA "$CERTS_DIR/root-ca.pem" -CAkey "$CERTS_DIR/root-ca.key" \
  -CAcreateserial -out "$CERTS_DIR/opensearch-dashboards.pem" -days 3650 -sha256 -extfile "$CERTS_DIR/opensearch-dashboards.cnf" -extensions req_ext -passin pass:$PASSPHRASE

# Cleanup
rm "$CERTS_DIR/opensearch-dashboards.csr" "$CERTS_DIR/opensearch-dashboards.cnf"

echo "Certificate for OpenSearch Dashboards generated at $CERTS_DIR/opensearch-dashboards.pem"

# ============================================
# 5. Create Truststore (JKS)
# ============================================

echo "Generating Truststore (JKS)..."

keytool -import -file "$CERTS_DIR/root-ca.pem" -keystore "$CERTS_DIR/truststore.jks" \
  -alias root-ca -storepass changeit -noprompt

echo "Truststore created at $CERTS_DIR/truststore.jks"

# ============================================
# Final Message
# ============================================

echo ""
echo "✅ All certificates and keys have been generated in the '$CERTS_DIR' directory."

