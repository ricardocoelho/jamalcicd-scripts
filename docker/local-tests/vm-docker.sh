#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

help() {
   cat <<EOF
Usage: $0 [-h] [-l <linux path>] [-p <>iproute2 path] [-i <bzImage>] [-c vCPU] [-m vRAM] [-j JOBS] [-f config] [-s] [-g] [-d] -- [<command>]

Recompile the current kernel, turning on all tc related options in the current .config,
and run the provided command. The original .config file is always preserved.
Options:
        -h            Display this message [Obrigatory].
        -l            Path to a p4tc linux folder [Obrigatory].
        -p            Path to a iproute2 folder.
        -a            Architecture to use.
        -r            Root filesystem to use.
        -i            Precompiled bzImage to use.
        -c            Number of vCPUs to use.
        -m            Size of vRAM to use.
        -j            Number of compilation jobs.
        -f            Kernel configuration file to use.
        -s            Start an interactive shell inside the VM.
                      No command is run inside the VM.
        -g            Generate a default kernel config if needed.
        -d            Dry run. Also prints the QEMU command line.
EOF
}

DEFAULT_CMD="./tdc.py -c p4tc"
LINUX_PATH=""
IPROUTE_PATH=""
ARCH=""
ROOTFS=""
VMCPUS=""
KIMG=""
VMMEM=""
SCRIPT=""
JOBS=""
KCONFIG=""
VMSHELL=""
KCONFIG_GEN=""
DRYRUN=""

while getopts 'hl:p:a:r:i:c:m:j:f:sgd' OPT; do
   case "$OPT" in
      h)
         help
         exit 0
         ;;
      l)
        LINUX_PATH="$OPTARG"
        ;;
      p)
        IPROUTE_PATH="$OPTARG"
        ;;
      a)
         ARCH="-a $OPTARG"
         ;;
      r)
         ROOTFS="-r $OPTARG"
         ;;
      i)
         KIMG="-i $OPTARG"
         ;;
      c)
         VMCPUS="-c $OPTARG"
         ;;
      m)
         VMMEM="-m $OPTARG"
         ;;
      j)
         JOBS="-j $OPTARG"
         ;;
      f)
         KCONFIG="-f $OPTARG"
         ;;
      s)
         VMSHELL="-s"
         ;;
      g)
         KCONFIG_GEN="-g"
         ;;
      d)
         DRYRUN="-d"
         ;;
      \? )
         help
         exit 1
         ;;
   esac
done
shift $((OPTIND -1))

if [[ $# -eq 0 ]]; then
   if ! [ "$VMSHELL" == "y" ]; then
      CMD="$DEFAULT_CMD"
   fi
else
   CMD="$@"
fi

docker build . -t p4tc_docker

docker run -t --rm --device=/dev/kvm \
    -v $(realpath $LINUX_PATH):/opt/linux \
    -v $(realpath $IPROUTE_PATH):/opt/iproute \
    -e LINUX_PATH="/opt/linux" \
    -e IPROUTE_PATH="/opt/iproute" \
    -e ARCH="$ARCH" \
    -e ROOT="$ROOTFS" \
    -e CPU="$VMCPUS" \
    -e MEMORY="$VMMEM" \
    -e JOBS="$JOBS" \
    -e CONFIG="$KCONFIG" \
    -e DRY="$DRYRUN" \
    -e CONFIG_GEN="$KCONFIG_GEN" \
    -e IMAGE="$KIMG" \
    -e SCRIPT="$CMD" \
    -e SHELL="$VMSHELL" \
    -e UID=`id -u` \
    -e GID=`id -g` \
    p4tc_docker
