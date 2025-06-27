FROM certbot/dns-cloudflare AS builder

RUN apt-get update && \
    apt-get install -y python3-dnspython cron && \
    rm -rf /var/lib/apt/lists/*

COPY renew.sh /renew.sh
RUN chmod +x /renew.sh

COPY crontab /etc/cron.d/renew-certs
RUN chmod 0644 /etc/cron.d/renew-certs && \
    touch /var/log/cron.log

CMD ["/bin/sh", "-c", "/renew.sh && crond -n"]