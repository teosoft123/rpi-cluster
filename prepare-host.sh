#!/usr/bin/env bash
# Usage: on a target system, run
# curl -sL https://raw.githubusercontent.com/teosoft123/rpi-cluster/main/prepare-host.sh | bash -

# this settings are important - if you comment it out or delete it,
# you might end up with partially functioning installation
set -e -o pipefail

sudo apt update && sudo apt upgrade -y
sudo apt install smartmontools vim pcregrep -y

# package iptables-persistent  requires special treatment
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install iptables-persistent -y

echo "Turning the swap off immediately and permanently"
sudo swapoff -av
sudo sed -iE 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=0/g' /etc/dphys-swapfile

echo "Enabling required cgroups only if they're not already present"
# Default boot file: console=serial0,115200 console=tty1 root=PARTUUID=25a1dbb8-02 rootfstype=ext4 fsck.repair=yes rootwait
BOOTFILE=/boot/cmdline.txt

echo "Original Boot command line:"
sudo cat "${BOOTFILE}"
echo

set +e
(sudo egrep -i 'cgroup_enable\s*=\s*cpuset' "${BOOTFILE}" > /dev/null)
CGROUP_ENABLE_CPUSET=$?
(sudo egrep -i 'cgroup_memory\s*=\s*1' "${BOOTFILE}" > /dev/null)
CGROUP_MEMORY_1=$?
(sudo egrep -i 'cgroup_enable\s*=\s*memory' "${BOOTFILE}" > /dev/null)
CGROUP_ENABLE_MEMORY=$?
set -e
echo

if [ 1 -eq "$CGROUP_ENABLE_CPUSET" ]; then CGROUP_ENABLE_CPUSET='cgroup_enable=cpuset'; else CGROUP_ENABLE_CPUSET=''; fi
if [ 1 -eq "$CGROUP_MEMORY_1" ]; then CGROUP_MEMORY_1='cgroup_memory=1'; else CGROUP_MEMORY_1=''; fi
if [ 1 -eq "$CGROUP_ENABLE_MEMORY" ]; then CGROUP_ENABLE_MEMORY='cgroup_enable=memory'; else CGROUP_ENABLE_MEMORY=''; fi

ADD_CGROUPS="${CGROUP_ENABLE_CPUSET} ${CGROUP_MEMORY_1} ${CGROUP_ENABLE_MEMORY}"

echo "Adding required groups: ${ADD_CGROUPS}"
sudo sed  --in-place --follow-symlinks "s/$/ ${ADD_CGROUPS}/" $BOOTFILE

echo "Final Boot command line:"
sudo cat "${BOOTFILE}"
echo

curl -sL https://raw.githubusercontent.com/teosoft123/rpi-cluster/main/utils/monitor.sh -O

K3S_CONFIG=${HOME}/.config/host-k3s-install
mkdir -p ${K3S_CONFIG}
touch ${K3S_CONFIG}/.prepare-host-run-success



# SCRATCH #
