#!/usr/bin/env bash

K_LOCAL_HOST_NAME=$(hostname)
K_LOCAL_HOST_IP=$(hostname -I | cut -d' ' -f1) # or more reliable: ip -4 -o addr show eth0 | awk '{print $4}' | cut -d'/' -f1

K_MASTER_IP=$K_LOCAL_HOST_IP
K_TLS_SANS="--tls-san=$K_MASTER_IP --tls-san=$K_LOCAL_HOST_NAME" # --tls-san=FULL_HOST_NAME"
K_INSTALL_SCRIPT=./k3s-install.sh
curl --no-progress-meter https://get.k3s.io -o $K_INSTALL_SCRIPT
chmod +x $K_INSTALL_SCRIPT

export INSTALL_K3S_VERSION=1.27.9

RUN_COMMAND="$K_INSTALL_SCRIPT --disable=traefik --flannel-backend=host-gw --bind-address=$K_MASTER_IP --advertise-address=$K_MASTER_IP --node-ip=$K_MASTER_IP $K_TLS_SANS --cluster-init"

printf '%s \n%s\n' "This is what you're going to run:" "${RUN_COMMAND[@]}"

read -rp "This will install k3s master on your host. Enter Yes to proceed, ^C to stop immediately: " ICONFIRM
if [ "Yes" == "$ICONFIRM" ]; then
  read -rp "Are you sure?: " ICONFIRM2
  if [ ! "Yes" == "$ICONFIRM2" ]; then
    echo "You answered $ICONFIRM2 - it's not Yes, exiting..."
    exit 253
    else
      echo "You answered $ICONFIRM2 - well, you asked for it, proceeding..."
  fi
else
  echo "Getting to Yes failed, exiting..."
  exit 254
fi

echo "${RUN_COMMAND[@]}"
