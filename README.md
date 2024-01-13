# Raspberry Pi Kubernetes Cluster

[[_TOC_]]

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
    * Optionally, install vim: sudo apt install vim -y
    * Disable swap
    * Ensure cgroups requires by k8s are enabled
    * Install iptables persistence package; answer No to save current: sudo apt install iptables-persistent -y
    * Configure static IP (recommended) or static DHCP mapping
    * Optionally, configure RPi to boot from USB, if you use USB drive: sudo raspi-config, Advanced Options, Boot Order
    * Reboot - you will be asked to reboot on the previous step. Or reboot manually.
    * 


# k8s - Master node installation

## One Liner

    EXPORT K_MASTER_IP=172.21.200.87
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC= \
        "server --disable=traefik \
        --flannel-backend=host-gw \
        --tls-san=$K_MASTER_IP \
        --bind-address=$K_MASTER_IP \
        --advertise-address=$K_MASTER_IP \
        --node-ip=$K_MASTER_IP \
        --cluster-init" sh -s -


# References

## Raspberry Pi Imager
https://www.raspberrypi.com/software/

## Raspberry Pi configuration

https://help.nextcloud.com/t/raspberrypi-4-change-boot-order-manually/126485

## Installing k8s cluster

https://medium.com/@stevenhoang/step-by-step-guide-installing-k3s-on-a-raspberry-pi-4-cluster-8c12243800b9
or, original post
https://drunkcoding.net/posts/ks-install-k3s-on-raspberry-pi-cluster/













