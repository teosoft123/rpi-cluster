#!/usr/bin/env bash
# Usage: on a target system, run
# curl -sL https://raw.githubusercontent.com/teosoft123/rpi-cluster/main/master-install.sh | bash -
# this settings are important - if you comment it out or delete it,
# you might end up with partially functioning installation
set -e -o pipefail

K_LOCAL_HOST_NAME=$(hostname)
K_LOCAL_HOST_IP=$(hostname -I | cut -d' ' -f1) # or more reliable: ip -4 -o addr show eth0 | awk '{print $4}' | cut -d'/' -f1

K_MASTER_IP=$K_LOCAL_HOST_IP
K_TLS_SANS="--tls-san=$K_MASTER_IP --tls-san=$K_LOCAL_HOST_NAME" # --tls-san=FULL_HOST_NAME"
K_INSTALL_SCRIPT=./k3s-install.sh
curl --no-progress-meter https://get.k3s.io -o $K_INSTALL_SCRIPT
chmod +x $K_INSTALL_SCRIPT

# If these variables are defined before running script, the defined values will be used
export INSTALL_K3S_VERSION=v1.27.9+k3s1  # ${INSTALL_K3S_VERSION:+v1.27.9+k3s1}
export INSTALL_K3S_NAME=rpik3s # ${INSTALL_K3S_NAME:+rpik3s}

RUN_COMMAND="$K_INSTALL_SCRIPT --disable=traefik --flannel-backend=host-gw --bind-address=$K_MASTER_IP --advertise-address=$K_MASTER_IP --node-ip=$K_MASTER_IP $K_TLS_SANS --cluster-init"

printf '%s \n%s\n\n' "This is what you're going to run:" "${RUN_COMMAND[@]}"

#read -rp "This will install k3s master on your host. Enter Yes to proceed, ^C to stop immediately: " ICONFIRM
#if [ "Yes" == "$ICONFIRM" ]; then
#  read -rp "Are you sure?: " ICONFIRM2
#  if [ ! "Yes" == "$ICONFIRM2" ]; then
#    echo "You answered $ICONFIRM2 - it's not Yes, exiting..."
#    exit 253
#    else
#      echo "You answered $ICONFIRM2 - well, you asked for it, proceeding..."
#  fi
#else
#  echo "Getting to Yes failed, exiting..."
#  exit 254
#fi

eval "${RUN_COMMAND[@]}"

## Post-install

# Enable current user to use kubectl
mkdir -p ~/.kube && sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown $USER ~/.kube/config && sudo chmod 600 ~/.kube/config && export KUBECONFIG=~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >> ${HOME}/.bashrc
