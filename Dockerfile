FROM alpine:3.9

RUN apk add curl gettext bash
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod a+x ./kubectl && mv ./kubectl /usr/bin

RUN curl -LO https://github.com/mikefarah/yq/releases/download/2.3.0/yq_linux_amd64 && \
    chmod a+x ./yq_linux_amd64 && mv ./yq_linux_amd64 /usr/bin/yq


RUN curl -LO https://github.com/rancher/cli/releases/download/v2.2.0/rancher-linux-amd64-v2.2.0.tar.gz && \
    tar -xzf rancher-linux-amd64-v2.2.0.tar.gz && \
    mv rancher-v2.2.0/rancher /usr/bin && \
    chmod a+x /usr/bin/rancher

ADD ./scripts/rancher-deploy.sh /usr/bin/rancher-deploy.sh

