# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM --platform=linux/amd64 ubuntu:22.04

LABEL maintainer="miguelmendoza@google.com.com"

ARG PORT=8080
EXPOSE ${PORT}

# GoLang
ARG GO_VERSION=1.20.6
ARG GO_TARGZ_URL=https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz

# install core utilities
RUN apt-get update && apt-get install -y curl zip unzip protobuf-compiler

RUN echo "**** Download and install golang version: ${GO_VERSION}" \
    && echo "**** url: ${GO_TARGZ_URL}" \
    && curl -o go.tar.gz -sfL "${GO_TARGZ_URL}"  \
    && tar -xvf "go.tar.gz" \
    && mv go go-sdk \
    && mkdir go

ENV PATH="${PATH}:/go-sdk/bin:/go/bin"

RUN mkdir /app

COPY pkg /app/pkg/
COPY cmd /app/pkg/
COPY go.mod /app/
COPY go.sum /app/

RUN echo "*** Build application" \
    && cd /app \
    && ls -la \
    && pwd \
    && export GOROOT=/go-sdk \
    && export GOARCH=amd64 \
    && export GOOS=linux \
    && export PATH="$PATH:$(go env GOPATH)/bin" \
    && go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28 \
    && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2 \
    && go generate ./... \
    && go build -o grpc-greeter-plaintext ./pkg/plaintext

RUN echo "*** Setting env "
ENV GOROOT /go-sdk
ENV GOARCH amd64
ENV GOOS linux

ENTRYPOINT ["bash", "-c", "/app/grpc-greeter-plaintext"]