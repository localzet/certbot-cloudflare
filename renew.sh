#!/bin/sh
set -e

DOMAINS="${CERTBOT_DOMAINS}"
CERT_NAME="${CERTBOT_CERT_NAME:-default-cert}"

if [ -z "$DOMAINS" ]; then
  echo "Error: CERTBOT_DOMAINS is not set"
  exit 1
fi

echo "=> Checking certs for domains: $DOMAINS"

certbot certonly --dns-cloudflare \
  --dns-cloudflare-email "$CF_EMAIL" \
  --dns-cloudflare-api-key "$CF_API_KEY" \
  --agree-tos \
  --no-eff-email \
  --email "$CERTBOT_EMAIL" \
  --key-type rsa \
  --preferred-challenges dns-01 \
  --cert-name "$CERT_NAME" \
  -d $DOMAINS \
  --non-interactive \
  --force-renewal || echo "Failed to renew certificate"

echo "=> Done"