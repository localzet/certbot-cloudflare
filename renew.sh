#!/bin/sh
set -eu

: "${CERTBOT_EMAIL:?CERTBOT_EMAIL is required}"
: "${CERTBOT_DOMAINS:?CERTBOT_DOMAINS is required}"

CERT_NAME="${CERTBOT_CERT_NAME:-default-cert}"
CREDENTIALS_FILE="${CLOUDFLARE_CREDENTIALS_FILE:-}"
TMP_CREDENTIALS=""

cleanup() {
    if [ -n "$TMP_CREDENTIALS" ]; then
        rm -f "$TMP_CREDENTIALS"
    fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [ -z "$CREDENTIALS_FILE" ]; then
    : "${CF_DNS_API_TOKEN:?Set CF_DNS_API_TOKEN or CLOUDFLARE_CREDENTIALS_FILE}"
    case "$CF_DNS_API_TOKEN" in
        *'
'*) echo "Cloudflare token must be one line" >&2; exit 1 ;;
    esac
    umask 077
    TMP_CREDENTIALS="$(mktemp)"
    CREDENTIALS_FILE="$TMP_CREDENTIALS"
    printf 'dns_cloudflare_api_token = %s\n' "$CF_DNS_API_TOKEN" > "$CREDENTIALS_FILE"
fi

if [ ! -r "$CREDENTIALS_FILE" ]; then
    echo "Cloudflare credentials file is not readable" >&2
    exit 1
fi

# Split the documented space-delimited list without pathname expansion.
set -f
set --
for domain in $CERTBOT_DOMAINS; do
    set -- "$@" -d "$domain"
done

if [ "$#" -eq 0 ]; then
    echo "No domains specified" >&2
    exit 1
fi

# Never force-renew daily: keep valid certificates until renewal is due.
certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$CREDENTIALS_FILE" \
    --agree-tos \
    --no-eff-email \
    --email "$CERTBOT_EMAIL" \
    --key-type rsa \
    --preferred-challenges dns-01 \
    --cert-name "$CERT_NAME" \
    --keep-until-expiring \
    --non-interactive \
    "$@"
