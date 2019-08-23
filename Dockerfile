FROM alpine:3.9

RUN apk add curl gettext bash
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod a+x ./kubectl && mv ./kubectl /usr/bin

RUN curl -LO https://github.com/mikefarah/yq/releases/download/2.3.0/yq_linux_amd64 && \
    chmod a+x ./yq_linux_amd64 && mv ./yq_linux_amd64 /usr/bin/yq


RUN curl -LO https://github.com/rancher/cli/releases/download/v2.3.0-rc1/rancher-linux-amd64-v2.3.0-rc1.tar.gz && \
    tar -xzf rancher-linux-amd64-v2.3.0-rc1.tar.gz && \
    mv rancher-v2.3.0-rc1/rancher /usr/bin && \
    chmod a+x /usr/bin/rancher

# install REG
RUN curl -Lo /usr/bin/reg https://github.com/genuinetools/reg/releases/download/v0.13.0/reg-linux-amd64 && chmod +x /usr/bin/reg

# FIX bug in GO name resolution -> https://github.com/golang/go/issues/22846
RUN echo "hosts: files dns" > /etc/nsswitch.conf

ADD ./scripts/rancher-deploy.sh /usr/bin/rancher-deploy.sh

