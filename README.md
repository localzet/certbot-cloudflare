# Certbot Cloudflare

Automated Let's Encrypt DNS-01 certificate issuance/renewal with the official `certbot/dns-cloudflare` plugin. Use a **scoped Cloudflare API token** with `Zone:DNS:Edit` permissions for the relevant zone. Do not use a Cloudflare Global API Key.

## Setup

```sh
cp .env.example .env
# Fill in a scoped API token; .env is ignored by Git.
chmod 600 .env
docker compose config --quiet
docker compose up -d --build
docker compose exec certbot /renew.sh
```

Environment variables:
- `CF_DNS_API_TOKEN`: scoped Cloudflare API token.
- `CERTBOT_EMAIL`: Let's Encrypt account email.
- `CERTBOT_DOMAINS`: **space-separated**, e.g. `example.com *.example.com`; quote in shell/.env as needed.
- `CERTBOT_CERT_NAME`: optional lineage name, default `default-cert`.
- `CLOUDFLARE_CREDENTIALS_FILE`: optional path to a pre-mounted credentials INI instead of passing a token in environment (set when running `/renew.sh` manually).

The script creates a temporary credentials file with restrictive permissions, removes it when finished and propagates Certbot failures. The container cron invokes the script every day; `--keep-until-expiring` prevents unnecessary certificate replacements. Certbot does **not** automatically reload the web server using these certificates: configure a trusted deploy hook or a reload mechanism on the consumer.

### Dry-run without altering issued certificates

For an initial issuance check, construct the credentials file separately and run:

```sh
docker compose exec certbot sh -c 'certbot certonly --dns-cloudflare --dns-cloudflare-credentials /path/to/credentials.ini --dry-run -d example.com'
```

Do not store credentials in the repository. Avoid printing the interpolated Compose config or credentials in CI/logs. The checked-in `docker-compose.yml` expects environment variables from an ignored `.env` file.
