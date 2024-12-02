#!/bin/bash

set -e

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Setting up mkcert on macOS..."
    brew install mkcert
    brew install nss
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Setting up mkcert on Linux..."
    sudo apt install -y libnss3-tools
    curl -JLO https://dl.filippo.io/mkcert/latest?for=linux/amd64
    chmod +x mkcert-v*-linux-amd64
    sudo mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
else
    echo "mkcert setup is not automated for this OS."
    exit 1
fi

echo "Installing mkcert CA..."
mkcert -install
