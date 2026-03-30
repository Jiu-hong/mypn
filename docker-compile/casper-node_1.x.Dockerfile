FROM ubuntu:focal AS stage1

# DEBIAN_FRONTEND required for tzdata dependency install
RUN apt-get update \
      && DEBIAN_FRONTEND="noninteractive" \
      apt-get install -y sudo tzdata curl gnupg gcc git ca-certificates \
              protobuf-compiler libprotobuf-dev supervisor jq \
              pkg-config libssl-dev make build-essential gettext-base lsof \
      && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"] 

# install cmake
RUN curl -Ls https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3-Linux-x86_64.tar.gz | sudo tar -C /usr/local --strip-components=1 -xz

# install rust nigthly and rustup
RUN curl -f -L https://static.rust-lang.org/rustup.sh -O \
    && sh rustup.sh -y 
ENV PATH="$PATH:/root/.cargo/bin"

# set few environment variables needed for the nctl build scripts

# copy the casper-node repo from host machine and build binaries
WORKDIR /
RUN rustup toolchain install 1.85.0-x86_64-unknown-linux-gnu
# RUN git clone -b release-1.3.4 https://github.com/casper-network/casper-node.git
# RUN git clone -b release-2.2.0 https://github.com/casper-network/casper-node.git
# RUN git clone -b release-2.1.1 https://github.com/casper-network/casper-node.git
RUN git clone https://github.com/casper-network/casper-node.git \
    && cd casper-node \
    && git checkout 9aa22ac6c998c9d2d5288721974266b0fb44fb36 
WORKDIR casper-node
RUN OPENSSL_STATIC=1 cargo build --release -p casper-node

# target/upgrade_build
# save built binaries and resources folders to a temp folder to 
# copy them back in the second stage
FROM stage1
WORKDIR /tmp
RUN tar -czvf "bin.tar.gz"  -C /casper-node/target/release/ casper-node

FROM scratch
COPY --from=1 /tmp/* /tmp/casper-node/
