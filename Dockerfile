FROM certbot/dns-cloudflare

COPY renew.sh /renew.sh
RUN chmod +x /renew.sh

RUN apk add --no-cache dcron

COPY crontab /etc/crontabs/root

RUN mkdir -p /var/log && touch /var/log/cron.log

CMD ["crond", "-f", "-l", "2"]