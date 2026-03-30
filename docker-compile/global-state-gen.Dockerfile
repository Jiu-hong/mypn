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
RUN git clone -b release-2.1.1 https://github.com/casper-network/casper-node.git
# RUN git clone https://github.com/casper-network/casper-node.git \
#     && cd casper-node \
#     && git checkout a7e4ff100549d6b34aa6b800812f29313378663b
WORKDIR casper-node
RUN cargo build -p global-state-update-gen --release

# target/upgrade_build
# save built binaries and resources folders to a temp folder to 
# copy them back in the second stage
FROM scratch
COPY --from=stage1 /casper-node/target/release/global-state-update-gen /tmp/global-state-update-gen/
