FROM casper-base:latest

# Install casper packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
       casper-sidecar \
    && rm -rf /var/lib/apt/lists/*

# 7777- RPC PORT
EXPOSE 7777

COPY casper-sidecar-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER csidecar

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
