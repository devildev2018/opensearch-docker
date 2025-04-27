#!/bin/bash

set -e

cd certs

PASSPHRASE="1nf0M@t1cs"

echo "[+] Generating Root CA..."
openssl genrsa -aes256 -passout pass:$PASSPHRASE -out root-ca.key 4096
openssl req -x509 -new -nodes -key root-ca.key -sha256 -days 3650 \
    -subj "/CN=Root CA" -passin pass:$PASSPHRASE -out root-ca.pem

# ---------------- Admin certs ----------------
echo "[+] Generating admin cert and key..."
openssl genrsa -out admin-key.pem 2048
openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=admin"
openssl x509 -req -in admin.csr -CA root-ca.pem -CAkey root-ca.key -CAcreateserial \
    -out admin.pem -days 365 -sha256 -passin pass:$PASSPHRASE

# ---------------- Node certs ----------------
echo "[+] Generating elkstack-node cert and key..."
openssl genrsa -out elkstack-node-key.pem 2048
openssl req -new -key elkstack-node-key.pem -out elkstack-node.csr -subj "/CN=elkstack-node"
openssl x509 -req -in elkstack-node.csr -CA root-ca.pem -CAkey root-ca.key -CAcreateserial \
    -out elkstack-node.pem -days 365 -sha256 -passin pass:$PASSPHRASE

# ---------------- Kibana (Dashboards) certs ----------------
echo "[+] Generating kibana cert and key..."
openssl genrsa -out kibana.key 2048
openssl req -new -key kibana.key -out kibana.csr -subj "/CN=kibana"
openssl x509 -req -in kibana.csr -CA root-ca.pem -CAkey root-ca.key -CAcreateserial \
    -out kibana.pem -days 365 -sha256 -passin pass:$PASSPHRASE

# ---------------- Truststore ----------------
echo "[+] Creating truststore.jks from root-ca.pem..."
openssl x509 -outform der -in root-ca.pem -out root-ca.der
keytool -import -alias root-ca -keystore truststore.jks -file root-ca.der \
    -storepass $PASSPHRASE -noprompt

# Cleanup intermediate files
rm -f *.csr *.srl *.der

echo "[✔] All certs are created in certs/ directory!"
