FROM ubuntu:jammy

# Install base dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       curl gnupg jq ca-certificates vim logrotate \
    && rm -rf /var/lib/apt/lists/*

# Add casper apt repo
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://repo.casper.network/casper-repo-pubkey.gpg \
       -o /etc/apt/keyrings/casper-repo-pubkey.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/casper-repo-pubkey.gpg] https://repo.casper.network/releases jammy main" \
       > /etc/apt/sources.list.d/casper.list

# Install casper packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       casper-client casper-node-launcher casper-sidecar \
    && rm -rf /var/lib/apt/lists/*

# /var/lib/casper  - chain state and binaries (persist this)
# /var/log/casper  - node logs (persist this)
# /etc/casper      - config and validator keys (persist this)
VOLUME ["/var/lib/casper", "/var/log/casper", "/etc/casper"]

# 7779  - BINARYPORT
# 8888  - REST API
# 35000 - P2P
EXPOSE 7779 8888 35000

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
COPY casper-logrotate /etc/logrotate.d/casper
RUN chmod 644 /etc/logrotate.d/casper


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
