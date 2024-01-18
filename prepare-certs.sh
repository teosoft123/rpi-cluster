#!/usr/bin/env bash

ROOT_CERT_DIR=/Volumes/NOSE/projects/ca/root/ca/certs
ROOT_CERT_NAME=ca.cert.pem
ROOT_KEY_DIR=/Volumes/NOSE/nose/remmirath.llc/secrets/
ROOT_KEY_NAME=root_ca_key

TARGET_HOST=rpi003
#DEST=/var/lib/rancher/k3s/server/tls
DEST="/home/oleg"

rsync -avP ${ROOT_CERT_DIR}/${ROOT_CERT_NAME} $TARGET_HOST:$DEST/root-ca.pem
rsync -avP ${ROOT_KEY_DIR}/${ROOT_KEY_NAME} $TARGET_HOST:$DEST/root-ca.key

# On target, run curl -sL https://github.com/k3s-io/k3s/raw/master/contrib/util/generate-custom-ca-certs.sh | bash -
