FROM debian:stable-slim

ENV BEASTPORT=30005 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

COPY scripts/ /scripts/

RUN set -x && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        bash \
        ca-certificates \
        curl \
        libc6 \
        lsb-base \
        procps \
        && \
    bash /scripts/install_pfclient.sh && \
    mkdir -p /var/log/pfclient && \
    chown -R nobody /var/log/pfclient && \
    mkdir /config && \
    chown -R nobody /config && \
    rm -rf /config/* /var/log/pfclient/* /etc/pfclient-config.json && \
    touch /run/pfclient.pid && \
    chown nobody /run/pfclient.pid && \
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    apt-get clean -y && \
    rm -rf /tmp/* /src /var/lib/apt/lists/* && \
    echo "pfclient $(pfclient --version | head -1 | rev | cut -d " " -f 1 | rev)" >> /VERSION

COPY etc/ /etc/

ENTRYPOINT [ "/init" ]

EXPOSE 30053/tcp 30054/tcp
