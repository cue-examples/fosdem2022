# golang:1.17.6
FROM golang@sha256:0fa6504d3f1613f554c42131b8bf2dd1b2346fb69c2fc24a312e7cba6c87a71e

ARG TARGETARCH

# create a temporary build dir
RUN mkdir /tmp/build
WORKDIR /tmp/build

# docker
RUN apt-get update
RUN apt-get -y install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common apt-utils
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository    "deb [arch=$TARGETARCH] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
RUN apt-get update
RUN apt-get -y install docker-ce docker-ce-cli containerd.io

RUN apt-get -y install sudo vim nano unzip tree

# kubectl
RUN apt-get install -y apt-transport-https ca-certificates curl
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl
RUN apt-mark hold kubectl

# Clean up
RUN apt-get -y autoremove && \
  apt-get clean

# k3d
RUN curl -s https://raw.githubusercontent.com/rancher/k3d/v5.3.0/install.sh | TAG=v5.3.0 bash

# cue
RUN GOBIN=/usr/local/go/bin go install cuelang.org/go/cmd/cue@v0.4.2

# protoc
RUN case $TARGETARCH in arm64) arch="aarch_64" ;; amd64) arch="x86_64" ;; esac && \
    mkdir /usr/local/protoc && \
    curl -sLO https://github.com/protocolbuffers/protobuf/releases/download/v3.19.3/protoc-3.19.3-linux-$arch.zip && \
    unzip -d /usr/local/protoc protoc-3.19.3-linux-$arch.zip && \
    chmod -R a+rX /usr/local/protoc

# grpc
RUN GOBIN=/usr/local/go/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
RUN GOBIN=/usr/local/go/bin go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2.0

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chown root:root /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Image environment
ENV PATH=/usr/local/protoc/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GOPATH=

COPY profile /root/.profile
COPY bashrc /root/.bashrc

# remove temp build dir
RUN rm -rf /tmp/build
