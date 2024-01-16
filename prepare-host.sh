#!/usr/bin/env bash

# this settings are important - if you comment it out or delete it,
# you might end up with partially functioning installation
set -e -o pipefail

sudo apt update && sudo apt upgrade -y
sudo apt install iptables-persistent smartmontools vim -y
# turn the swap off immediately and permanently
sudo swapoff -a
sudo sed -iE 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=0/g' /etc/dphys-swapfile

# enable required cgroups only if they're not already present
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
