#!/usr/bin/env bash

K_LOCAL_HOST_NAME=$(hostname)
K_LOCAL_HOST_IP=$(hostname -I | cut -d' ' -f1) # or more reliable: ip -4 -o addr show eth0 | awk '{print $4}' | cut -d'/' -f1

K_MASTER_IP=$K_LOCAL_HOST_IP
K_TLS_SANS="--tls-san=$K_MASTER_IP --tls-san=$K_LOCAL_HOST_NAME --tls-san=rpi003.h.remmirath.com"
K_INSTALL_SCRIPT=./k3s-install.sh
curl --no-progress-meter https://get.k3s.io -o $K_INSTALL_SCRIPT
chmod +x $K_INSTALL_SCRIPT

export INSTALL_K3S_VERSION=1.27.9

COMMAND='--disable=traefik --flannel-backend=host-gw'
for var in "${!K_@}"; do
  COMMAND+=("${!var}")
done
COMMAND+='--cluster-init'

echo "${COMMAND[@]}"

#$K_INSTALL_SCRIPT --disable=traefik --flannel-backend=host-gw $K_TLS_SANS  --bind-address=$K_MASTER_IP --advertise-address=$K_MASTER_IP --node-ip=$K_MASTER_IP --cluster-init

