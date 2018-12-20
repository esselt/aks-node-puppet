FROM ubuntu:16.04

RUN apt-get update && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        lxc \
        iptables \
        lsb-core \
        cron

RUN curl -sSL https://get.docker.com/ | sh

RUN mkdir -p /app
COPY aks-node-puppet/* /app/
WORKDIR /app

COPY ubuntu-dind/* /usr/local/bin/

ENTRYPOINT [ "entry.sh" ]
CMD [ "docker-compose", "up" ]