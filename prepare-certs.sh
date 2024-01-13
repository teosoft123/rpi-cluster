#!/usr/bin/env bash

TARGET=rpi003
#DEST=/var/lib/rancher/k3s/server/tls
DEST="/home/oleg"

#rsync -avP /Volumes/NOSE/nose/remmirath.llc/certs/root_ca.crt $TARGET:$DEST/root-ca.pem
#rsync -avP /Volumes/NOSE/nose/remmirath.llc/secrets/root_ca_key $TARGET:$DEST/root-ca.key

rsync -avP /Volumes/NOSE/projects/ca/root/ca/certs/ca.cert.pem $TARGET:$DEST/root-ca.pem
rsync -avP /Volumes/NOSE/projects/ca/root/ca/private/ca.key.pem $TARGET:$DEST/root-ca.key

# On target, run curl -sL https://github.com/k3s-io/k3s/raw/master/contrib/util/generate-custom-ca-certs.sh | bash -
