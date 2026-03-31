FROM casper-base:latest

# Install casper packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       casper-client casper-node-launcher \
    && rm -rf /var/lib/apt/lists/*

# /var/lib/casper  - chain state and binaries (persist this)
# /var/log/casper  - node logs (persist this)
# /etc/casper      - config and validator keys (persist this)
VOLUME ["/var/lib/casper", "/var/log/casper", "/etc/casper"]

# 7779  - BINARYPORT
# 8888  - REST API
# 35000 - P2P
EXPOSE 7779 8888 35000

COPY entrypoint-casper-node.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
COPY casper-logrotate /etc/logrotate.d/casper
RUN chmod 644 /etc/logrotate.d/casper

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
