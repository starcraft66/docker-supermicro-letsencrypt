FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    ca-certificates \
    coreutils \
    lego \
    openssl \
    python3 \
    python3-pip \
    python3-requests \
    python3-lxml \
    && rm -rf /var/lib/apt/lists/*

ADD le-supermicro-ipmi.sh supermicro-ipmi-updater.py /

VOLUME /.lego

WORKDIR /

ENTRYPOINT ["/le-supermicro-ipmi.sh"]
