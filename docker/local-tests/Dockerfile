FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

#Linux
RUN apt-get install -y git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison 
RUN apt-get install -y libz-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc curl

#QEMU
RUN apt-get install -y busybox-static kmod
RUN apt-get -y install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon

#Others
RUN apt-get -y install rng-tools haveged initramfs-tools
RUN apt-get install -y python3-scapy
RUN apt-get install -y dwarves

#Virtme
RUN mkdir /home/virtme
RUN apt-get install -y python3-setuptools
RUN cd /home/virtme && git clone https://github.com/expertisesolutions/virtme.git . && python3 setup.py install

#Iproute2
RUN mkdir /home/iproute2
RUN apt install -y gawk flex bison libelf-dev libmnl-dev pkg-config

WORKDIR /home/linux
