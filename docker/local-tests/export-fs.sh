#!/bin/bash

NBD_DEVICE=/dev/nbd0

set -e

container_id=$(docker run -d jamalcicd/s390x)
docker export $container_id -o s390x.tar
#qemu-img convert -f tar -O qcow2 s390x.tar s390-image.qcow2

qemu-img create -f qcow2 s390x.qcow2 20G
sudo modprobe nbd
sudo qemu-nbd --connect=${NBD_DEVICE} ./s390x.qcow2
sudo fdisk ${NBD_DEVICE} <<EOF
g
n
1


w
EOF
sudo mkfs.ext4 ${NBD_DEVICE}p1
sudo mount ${NBD_DEVICE}p1 ./mnt
sudo tar xvf ./s390x.tar --directory ./mnt/.
sudo umount ./mnt
sudo qemu-nbd --disconnect ${NBD_DEVICE}

