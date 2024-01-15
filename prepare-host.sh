#!/usr/bin/env bash

# this settings are important - if you comment it out or delete it,
# you might end up with partially functioning installation
set -e -o pipefail

sudo apt update && sudo apt upgrade -y
sudo apt install smartmontools vim -y
# turn the swap off immediately and permanently
sudo swapoff -a
sudo sed -iE 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=0/g' /etc/dphys-swapfile
# enable required cgroups if they're not already present
CGROUPS_PRESENT=$(sudo cat /boot/cmdline.txt | grep -iEo "cgroup_enable\s*=\s*cpuset|cgroup_memory\s*=\s*1|cgroup_enable\s*=\s*memory")
if [ "" == "$CGROUPS_PRESENT" ]; then
  printf "One of required cgroups present, cannot continue: %s\n" "$CGROUPS_PRESENT"
fi

#sudo vi /etc/dphys-swapfile -> set CONF_SWAPSIZE=0