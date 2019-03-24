FROM: alpine:3.9

RUN: apk add curl gettext
RUN: curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN: chmod a+x ./kubectl && mv ./kubectl /usr/bin





