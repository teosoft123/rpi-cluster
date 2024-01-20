#!/usr/bin/env bash
# Usage: on a target system, run
# curl -sL https://raw.githubusercontent.com/teosoft123/rpi-cluster/main/prepare-host.sh | bash -
# this settings are important - if you comment it out or delete it,
# you might end up with partially functioning installation
#set -e -o pipefail
#
set +x

sudo apt update && sudo apt upgrade -y
sudo apt install smartmontools vim -y

# package iptables-persistent  requires special treatment
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install iptables-persistent -y

echo "Turning the swap off immediately and permanently"
sudo swapoff -av
sudo sed -iE 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=0/g' /etc/dphys-swapfile

echo "Enabling required cgroups only if they're not already present"
BOOTFILE=/boot/cmdline.txt

(sudo cat $BOOTFILE | grep -iE 'cgroup_enable\s*=\s*cpuset' > /dev/null)
CGROUP_ENABLE_CPUSET=$?
(sudo cat $BOOTFILE | grep -iE 'cgroup_memory\s*=\s*1' > /dev/null )
CGROUP_MEMORY_1=$?
(sudo cat $BOOTFILE | grep -iE 'cgroup_enable\s*=\s*memory' > /dev/null)
CGROUP_ENABLE_MEMORY=$?

if [ 1 -eq "$CGROUP_ENABLE_CPUSET" ]; then CGROUP_ENABLE_CPUSET='cgroup_enable=cpuset'; else CGROUP_ENABLE_CPUSET=''; fi
if [ 1 -eq "$CGROUP_MEMORY_1" ]; then CGROUP_MEMORY_1='cgroup_memory=1'; else CGROUP_MEMORY_1=''; fi
if [ 1 -eq "$CGROUP_ENABLE_MEMORY" ]; then CGROUP_ENABLE_MEMORY='cgroup_enable=memory'; else CGROUP_ENABLE_MEMORY=''; fi

ADD_CGROUPS="${CGROUP_ENABLE_CPUSET} ${CGROUP_MEMORY_1} ${CGROUP_ENABLE_MEMORY}"

echo "BOOTFILE: ${BOOTFILE}"
echo "ADD_CGROUPS: ${ADD_CGROUPS}"
sudo sed -i "s/$/ ${ADD_CGROUPS}/" $BOOTFILE

#if [ "" == "$ALL_CGROUPS_PRESENT" ]; then
#  printf "All of required cgroups present, not making any changes: %s\n" "$ALL_CGROUPS_PRESENT"
#else
#  # adding required groups
#  printf "%s\n" "Adding required groups: ${REQUIRED_GROUPS}"
#  sudo sed -i "s/$/ ${REQUIRED_GROUPS}/" $BOOTFILE
#fi

# SCRATCH #
