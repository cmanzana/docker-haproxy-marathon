FROM haproxy:latest

RUN apt-get update && apt-get install -y curl supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY marathon-check.sh /usr/bin/marathon-check.sh
RUN chmod a+x /usr/bin/marathon-check.sh

CMD ["/usr/bin/supervisord"]