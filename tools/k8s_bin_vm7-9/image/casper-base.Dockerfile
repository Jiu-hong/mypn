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
       > /etc/apt/sources.list.d/casper.list \
    && apt-get update \
    && rm -rf /var/lib/apt/lists/*
