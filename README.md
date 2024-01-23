# Yet Another Raspberry Pi Kubernetes Cluster

<!-- TOC -->
* [Yet Another Raspberry Pi Kubernetes Cluster](#yet-another-raspberry-pi-kubernetes-cluster)
* [Hardware](#hardware)
* [Initial - OS Setup and Configuration](#initial---os-setup-and-configuration)
* [k8s - Master node installation](#k8s---master-node-installation)
  * [Custom CA Note](#custom-ca-note-)
  * [One Liner](#one-liner)
* [k8s - Worker node installation](#k8s---worker-node-installation)
  * [Allowing more configuration options](#allowing-more-configuration-options)
    * [k3s server command options](#k3s-server-command-options)
* [References](#references)
  * [Raspberry Pi Imager](#raspberry-pi-imager)
  * [Raspberry Pi configuration](#raspberry-pi-configuration)
  * [Installing k8s cluster](#installing-k8s-cluster)
<!-- TOC -->

TODO after initial file is written, I may split it into multiple files 

# Hardware

ToDo

# Initial - OS Setup and Configuration

* Install Raspberry Pi OS Lite (64-bit) using Raspberry Pi Imager
    * Configure user name, password, host name and enable SSH server
* Boot from the media created on previous steps
    * Ensure you can login from remote terminal using ssh
    * sudo apt update && sudo apt upgrade -y 
    * Optionally, add your users SSH key(s)
    * Optionally, install extra tools: sudo apt install smartmontools vim -y
    * Optionally, create or enable your favorite aliases (also maybe for root user)    
    * Disable swap
    * Ensure cgroups requires by k8s are enabled: 
    * Install iptables persistence package; answer No to save current: sudo apt install iptables-persistent -y
    * Configure static IP (recommended) or static DHCP mapping
    * Optionally, configure RPi to boot from USB, if you use USB drive: sudo raspi-config, Advanced Options, Boot Order
    
    * Reboot - you will be asked to reboot on the previous step. Or reboot manually.

Disable swap:

sudo swapoff -a
sudo vi /etc/dphys-swapfile -> set CONF_SWAPSIZE=0
reboot

Enable required cgroups:

sudo vi /boot/cmdline.txt
add this to the end of current line:

    cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory

reboot


# k8s - Master node installation

## Custom CA Note 

If you want to use your own CA, you have to create all certificates required by k8s __before__ first start of the k8s master.
Use this script and follow instructions provided at the beginning of the script: 

    https://github.com/k3s-io/k3s/blob/master/contrib/util/generate-custom-ca-certs.sh

## One Liner

See docs


# k8s - Worker node installation

TODO Do I need to copy certs to /var/lib/rancher/k3s/server/tls first?
^^^^ probably not - should a node obtain certs from master?

And definitely need to add own CA to all nodes, see:
https://stackoverflow.com/questions/72326132/unable-to-connect-worker-node-to-master-using-k3s

Copy CA cert to /usr/local/share/ca-certificates, then issue an
sudo update-ca-certificates

Obtain k3s token: on master, run:

  sudo cat /var/lib/rancher/k3s/server/node-token

export INSTALL_K3S_VERSION=v1.27.9+k3s1
curl -sfL https://get.k3s.io K3S_URL=https://172.21.200.80:6443 \
   K3S_TOKEN="K10a8add08cdd2949d4c523a7de6a07d2d92e0aee6c9bdfc95481493e1b5731e1da::server:ccc765dfddb01c1929d55f7d336cd286" | sh -

## Allowing more configuration options

TODO write a shell script that can be downloaded and executed as one-liner, on a target system, like curl -sL <script_url> | bash -   
Executing it on the target host allows getting local environment such as IP address and host name, and manipulating local files

Here's how to use said script on the target master node: 

[//]: # (curl -sL -H "Authorization: Bearer ATCTT3xFfGN0itnmNCIB6Gp2FWuCqfpXAnNkIor6MkhIRdIqHHjtp6A9rOfoArpHaQYO0K2ynubK5tBoRCrsMeRnK7I5yCQDByuSqel_0nAdM_XOJPVXyVfgZPkadv_bt5PsvKfuTUhyMBYRiLoTkOCbB2d51vsHwV6nh2TdD0MSgKTauWSvA6U=F7365245" https://api.bitbucket.org/2.0/repositories/remmirath/rpi-cluster/src/main/master-install.sh | bash -)

curl -sL https://raw.githubusercontent.com/teosoft123/rpi-cluster/main/master-install.sh | bash -

    export K_MASTER_IP=172.21.200.87
    export K_TLS_SANS="--tls-san=$K_MASTER_IP --tls-san=rpi003 --tls-san=rpi003.h.remmirath.com"
    export K_INSTALL_SCRIPT=./k3s-install.sh
    curl https://get.k3s.io -o $K_INSTALL_SCRIPT
    chmod +x $K_INSTALL_SCRIPT

    export INSTALL_K3S_VERSION=1.27.9

TODO specify k8s version!!!

TODO add instructions for storage: https://docs.k3s.io/storage#setting-up-longhorn

    INSTALL_K3S_SKIP_START="true" $K_INSTALL_SCRIPT --disable=traefik --flannel-backend=host-gw $K_TLS_SANS  --bind-address=$K_MASTER_IP --advertise-address=$K_MASTER_IP --node-ip=$K_MASTER_IP --cluster-init

After the above commands executed successfully, you can add custom CA. It's recommended to add Intermediary CA, which will allow not to use Root CA key. Follow instructions here:    

https://docs.k3s.io/cli/certificate#certificate-authority-ca-certificates

On the _target server node,_ **As root:**

    mkdir -p /var/lib/rancher/k3s/server/tls
    copy CA/Key to above dir - use prepare-certs.sh script to copy certs from your source
    name them root-ca.pem root-ca.key
    then run

curl -sL https://github.com/k3s-io/k3s/raw/master/contrib/util/generate-custom-ca-certs.sh | bash -

After all is successful:

    CA certificate generation complete. Required files are now present in: /var/lib/rancher/k3s/server/tls
    For security purposes, you should make a secure copy of the following files and remove them from cluster members:
    /var/lib/rancher/k3s/server/tls/intermediate-ca.crt
    /var/lib/rancher/k3s/server/tls/intermediate-ca.key
    /var/lib/rancher/k3s/server/tls/intermediate-ca.pem
    /var/lib/rancher/k3s/server/tls/root-ca.crt
    /var/lib/rancher/k3s/server/tls/root-ca.pem

### k3s server command options

https://docs.k3s.io/cli/server

# References

## Raspberry Pi Imager
https://www.raspberrypi.com/software/

## Raspberry Pi configuration

https://help.nextcloud.com/t/raspberrypi-4-change-boot-order-manually/126485

## Installing k8s cluster

https://medium.com/@stevenhoang/step-by-step-guide-installing-k3s-on-a-raspberry-pi-4-cluster-8c12243800b9
or, original post
https://drunkcoding.net/posts/ks-install-k3s-on-raspberry-pi-cluster/













