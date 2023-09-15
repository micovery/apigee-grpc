#!/bin/bash

export OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
export ARCH="$(uname -m | tr '[:upper:]' '[:lower:]')"
export GO_VERSION=1.20.6
export GO_TARGZ_URL=https://go.dev/dl/go${GO_VERSION}.${OS}-${ARCH}.tar.gz

if [ "${OS}" == "linux" ] ; then
  sudo apt-get update
  sudo apt-get install -y curl
fi

echo "*** Downloading go tar ball ... "
curl -o go.tar.gz -sfL "${GO_TARGZ_URL}"
tar -xvf "go.tar.gz"
rm -f go.tar.gz

export GOROOT="${HOME}/go-${GO_VERSION}-sdk"
echo "*** Installing go tar ball ..."
if [ -d "${GOROOT}" ] ; then
  rm -rf "${GOROOT}"
fi
mv go "${GOROOT}"


if [ ! -d "${HOME}/go" ] ; then
  mkdir "${HOME}/go"
fi

echo "***"
echo "***"
echo "Go ${GO_VERSION} installed to ${HOME}/go-${GO_VERSION}-sdk ..."
echo "Run the following commands to use it: "
echo ""
echo 'export GOROOT="${HOME}/go-'"${GO_VERSION}"'-sdk"'
echo 'export GOARCH='"${ARCH}"
echo 'export GOOS='"${OS}"
echo 'export PATH="${GOROOT}/bin:${HOME}/go/bin:${PATH}"'
echo ""