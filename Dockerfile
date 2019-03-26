FROM alpine:3.9

RUN apk add curl gettext bash
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod a+x ./kubectl && mv ./kubectl /usr/bin
RUN curl -LO https://github.com/mikefarah/yq/releases/download/2.3.0/yq_linux_amd64
RUN chmod a+x ./yq_linux_amd64 && mv ./yq_linux_amd64 /usr/bin/yq
ADD ./scripts/rancher-deploy.sh /usr/bin/rancher-deploy.sh




