# Certbot Cloudflare

Контейнер для автоматического получения и обновления SSL-сертификатов через Let's Encrypt и Cloudflare DNS.

## 🔧 Переменные окружения

| Переменная          | Описание                                                   |
|---------------------|------------------------------------------------------------|
| `CF_EMAIL`          | Email от аккаунта Cloudflare                               |
| `CF_API_KEY`        | API ключ Cloudflare                                        |
| `CERTBOT_EMAIL`     | Email для уведомлений Let’s Encrypt                        |
| `CERTBOT_DOMAINS`   | Список доменов через пробел (включая поддомены)            |
| `CERTBOT_CERT_NAME` | Имя сертификата (опционально, по умолчанию `default-cert`) |

## 📦 Использование с Docker Compose

```yaml
version: '3'

services:
  certbot:
    image: ghcr.io/localzet/certbot-cloudflare:latest
    container_name: certbot-cloudflare
    environment:
      CF_EMAIL: your_cloudflare_email@example.com
      CF_API_KEY: your_cloudflare_api_key_here
      CERTBOT_EMAIL: admin@yourdomain.com
      CERTBOT_DOMAINS: yourdomain.com *.yourdomain.com
    volumes:
      - ./certs:/etc/letsencrypt
    restart: unless-stopped

  yourapp:
    image: your-app
    ports:
      - "443:443"
    volumes:
      - ./certs/live/default-cert:/ssl
    environment:
      SSL_CERT_PATH: "/ssl/fullchain.pem"
      SSL_KEY_PATH: "/ssl/privkey.pem"
    depends_on:
      - certbot
    restart: unless-stopped
```

## ✅ Где взять Cloudflare API ключ?

[https://dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)
Создайте API Token с правами:

- Zone: DNS — Edit
- Email: Read

Или используйте Global API Key.