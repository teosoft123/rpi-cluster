#!/usr/bin/env bash
# Usage: on a target system, run
# curl -sL https://raw.githubusercontent.com/teosoft123/rpi-cluster/main/prepare-host.sh | bash -
# this settings are important - if you comment it out or delete it,
# you might end up with partially functioning installation
set -e -o pipefail

sudo apt update && sudo apt upgrade -y
sudo apt install smartmontools vim -y

# package iptables-persistent  requires special treatment
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install iptables-persistent -y

echo "Turning the swap off immediately and permanently"
sudo swapoff -a
sudo sed -iE 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=0/g' /etc/dphys-swapfile

echo "Enabling required cgroups only if they're not already present"
BOOTFILE=/boot/cmdline.txt
REQUIRED_GROUPS="cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
ALL_CGROUPS_PRESENT=$(sudo cat $BOOTFILE |  grep -iE 'cgroup_enable\s*=\s*cpuset' | grep -iE 'cgroup_memory\s*=\s*1' | grep 'cgroup_enable\s*=\s*memory')
if [ "" != "$ALL_CGROUPS_PRESENT" ]; then
  printf "All of required cgroups present, not making any changes: %s\n" "$ALL_CGROUPS_PRESENT"
else
  # adding required groups
  printf "%s\n" "Adding required groups: ${REQUIRED_GROUPS}"
  sudo sed -i "s/$/ ${REQUIRED_GROUPS}/" $BOOTFILE
fi

# SCRATCH #
