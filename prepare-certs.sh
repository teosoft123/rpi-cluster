#!/usr/bin/env bash
# Usage: on a target system, run
# curl -sL https://raw.githubusercontent.com/teosoft123/rpi-cluster/main/prepare-certs.sh | bash -
# this settings are important - if you comment it out or delete it,
# you might end up with partially functioning installation
set -e -o pipefail

ROOT_CERT_DIR=/Volumes/NoSe/projects/ca/root/ca/certs/
ROOT_CERT_NAME=ca.cert.pem
ROOT_KEY_DIR=/Volumes/NoSe/projects/ca/root/ca/private/
ROOT_KEY_NAME=ca.key.pem

TARGET_HOST=k001
#DEST=/var/lib/rancher/k3s/server/tls
DEST="/home/oleg/k3s-certs"

# Try rsync -avP ./{a/*,b/*}  c/

rsync -avP --mkpath ${ROOT_CERT_DIR}/${ROOT_CERT_NAME} $TARGET_HOST:$DEST/root-ca.pem
rsync -avP --mkpath ${ROOT_KEY_DIR}/${ROOT_KEY_NAME} $TARGET_HOST:$DEST/root-ca.key

# On target, as root, run curl -sL https://github.com/k3s-io/k3s/raw/master/contrib/util/generate-custom-ca-certs.sh | bash -
