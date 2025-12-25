#!/usr/bin/env sh
set -eu

CERT_DIR="/etc/nginx/certs"
CRT="$CERT_DIR/server.crt"
KEY="$CERT_DIR/server.key"

if [ -f "$CRT" ] && [ -f "$KEY" ]; then
    echo "[nginx] SSL certificate already exists"
    exit 0
fi

echo "[nginx] Generating self-signed SSL certificate..."

mkdir -p "$CERT_DIR"

openssl req -x509 -nodes -days 3650 \
  -newkey rsa:2048 \
  -keyout "$KEY" \
  -out "$CRT" \
  -subj "/C=IR/ST=Local/L=Local/O=Internal/CN=localhost"

chmod 600 "$KEY"
chmod 644 "$CRT"

echo "[nginx] SSL certificate generated"
