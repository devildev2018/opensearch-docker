#!/bin/bash

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

# Generate Root CA private key with a passphrase
openssl genpkey -algorithm RSA -out "$CERTS_DIR/root-ca.key" -aes256 -pass pass:$PASSPHRASE

# Create Root CA certificate (self-signed)
openssl req -key "$CERTS_DIR/root-ca.key" -new -x509 -out "$CERTS_DIR/root-ca.pem" -days 3650 \
  -subj "/C=DE/ST=Test/L=Test/O=Test/CN=Root-CA" -passin pass:$PASSPHRASE

echo "Root CA generated at $CERTS_DIR/root-ca.pem"

# ============================================
# 2. Generate Admin Certificate (Transport)
# ============================================

echo "Generating Admin Certificate (Transport)..."

# Generate Admin private key with passphrase
openssl genpkey -algorithm RSA -out "$CERTS_DIR/admin-key.pem" -aes256 -pass pass:$PASSPHRASE

# Create Admin CSR (Certificate Signing Request)
openssl req -key "$CERTS_DIR/admin-key.pem" -new -out "$CERTS_DIR/admin.csr" -subj "/C=DE/ST=Test/L=Test/O=Test/CN=admin" -passin pass:$PASSPHRASE

# Sign Admin certificate with the Root CA
openssl x509 -req -in "$CERTS_DIR/admin.csr" -CA "$CERTS_DIR/root-ca.pem" -CAkey "$CERTS_DIR/root-ca.key" -CAcreateserial -out "$CERTS_DIR/admin.pem" -days 3650 -passin pass:$PASSPHRASE

echo "Admin certificate generated at $CERTS_DIR/admin.pem"

# ============================================
# 3. Generate Node Certificate (HTTP)
# ============================================

echo "Generating Node Certificate (HTTP)..."

# Generate Node private key with passphrase
openssl genpkey -algorithm RSA -out "$CERTS_DIR/elkstack-node-key.pem" -aes256 -pass pass:$PASSPHRASE

# Create Node CSR
openssl req -key "$CERTS_DIR/elkstack-node-key.pem" -new -out "$CERTS_DIR/elkstack-node.csr" -subj "/C=DE/ST=Test/L=Test/O=Test/CN=elkstack-node" -passin pass:$PASSPHRASE

# Sign Node certificate with the Root CA
openssl x509 -req -in "$CERTS_DIR/elkstack-node.csr" -CA "$CERTS_DIR/root-ca.pem" -CAkey "$CERTS_DIR/root-ca.key" -CAcreateserial -out "$CERTS_DIR/elkstack-node.pem" -days 3650 -passin pass:$PASSPHRASE

echo "Node certificate generated at $CERTS_DIR/elkstack-node.pem"

# ============================================
# 4. Generate Kibana Certificate (with SAN)
# ============================================

echo "Generating Kibana Certificate..."

KIBANA_CN="opensearch-dashboards"

# Generate Kibana private key
openssl genpkey -algorithm RSA -out "$CERTS_DIR/kibana-key.pem" -aes256 -pass pass:$PASSPHRASE

# Create OpenSSL config file for SAN
cat > "$CERTS_DIR/kibana.cnf" <<EOF
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
CN = $KIBANA_CN

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $KIBANA_CN
EOF

# Create CSR
openssl req -new -key "$CERTS_DIR/kibana-key.pem" -out "$CERTS_DIR/kibana.csr" -config "$CERTS_DIR/kibana.cnf" -passin pass:$PASSPHRASE

# Sign certificate
openssl x509 -req -in "$CERTS_DIR/kibana.csr" -CA "$CERTS_DIR/root-ca.pem" -CAkey "$CERTS_DIR/root-ca.key" \
  -CAcreateserial -out "$CERTS_DIR/kibana.pem" -days 3650 -sha256 -extfile "$CERTS_DIR/kibana.cnf" -extensions req_ext -passin pass:$PASSPHRASE

# Clean up
rm "$CERTS_DIR/kibana.csr" "$CERTS_DIR/kibana.cnf"

echo "Kibana certificate generated at $CERTS_DIR/kibana.pem"

# ============================================
# 5. Create Truststore (JKS)
# ============================================

echo "Generating Truststore (JKS)..."

# Create the Truststore and import the Root CA certificate
keytool -import -file "$CERTS_DIR/root-ca.pem" -keystore "$CERTS_DIR/truststore.jks" -alias root-ca -storepass changeit -noprompt

echo "Truststore created at $CERTS_DIR/truststore.jks"

# ============================================
# Final Message
# ============================================

echo "All certificates and keys have been generated in the '$CERTS_DIR' directory."