#!/bin/sh
set -eu
ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir "$TMP/bin"
cat > "$TMP/bin/certbot" <<'MOCK'
#!/bin/sh
printf '%s\n' "$@" > "$ARGS_FILE"
for arg in "$@"; do
    if [ "$arg" = "--force-renewal" ]; then exit 91; fi
done
exit "${MOCK_EXIT:-0}"
MOCK
chmod +x "$TMP/bin/certbot"
export PATH="$TMP/bin:$PATH" ARGS_FILE="$TMP/args"
export CERTBOT_EMAIL=ops@example.test CERTBOT_DOMAINS='example.test *.example.test'
export CF_DNS_API_TOKEN=example-scoped-token
sh "$ROOT/renew.sh"
grep -qx -- '--dns-cloudflare-credentials' "$ARGS_FILE"
grep -qx -- '--keep-until-expiring' "$ARGS_FILE"
grep -qx -- '*.example.test' "$ARGS_FILE"
# A failing certbot must fail the script.
if MOCK_EXIT=42 sh "$ROOT/renew.sh" >/dev/null 2>&1; then
    echo "renew.sh swallowed a certbot failure" >&2
    exit 1
fi
# Missing credentials must fail.
if env -u CF_DNS_API_TOKEN sh "$ROOT/renew.sh" >/dev/null 2>&1; then
    echo "renew.sh accepted missing credentials" >&2
    exit 1
fi
echo "renewal script: OK"
