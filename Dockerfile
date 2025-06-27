FROM certbot/dns-cloudflare AS builder

COPY renew.sh /renew.sh
RUN chmod +x /renew.sh

RUN apk add --no-cache dcron

COPY crontab /etc/crontabs/root

CMD ["crond", "-f", "-l", "2"]