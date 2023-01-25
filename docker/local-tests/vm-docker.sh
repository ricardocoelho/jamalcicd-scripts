#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

help() {
   cat <<EOF
Usage: $0 [-h] [-l <linux path>] [-p <>iproute2 path] [-i <bzImage>] [-c vCPU] [-m vRAM] [-j JOBS] [-f config] -- [<command>]

Recompile the current kernel, turning on all tc related options in the current .config,
and run the provided command. The original .config file is always preserved.
Options:
        -h            Display this message.
        -l            Path to a p4tc linux folder [Obrigatory].
        -p            Path to a iproute2 folder [Obrigatory].
        -a            Architecture to use.
        -i            Precompiled bzImage to use.
        -c            Number of vCPUs to use.
        -m            Size of vRAM to use.
        -j            Number of compilation jobs.
        -f            Kernel configuration file to use.
EOF
}

DEFAULT_CMD="./tdc.py -c p4tc"
LINUX_PATH=""
IPROUTE_PATH=""
ARCH="x86_64"
KROOT=""
KIMG=""
KCONFIG=""
INAME=""

verify_arch() {
   case "$1" in
      x86)
         LINUX_ARCH="x86"
         if [ -z "${KCONFIG}" ]; then
            KCONFIG="-f config-debug-p4tc-x86"
         fi
         ;;
      x86_64)
         LINUX_ARCH="x86_64"
         if [ -z "${KCONFIG}" ]; then
            KCONFIG="-f config-debug-p4tc-x86"
         fi
         ;;
      s390x)
         LINUX_ARCH="s390"
         if [ -z "${KCONFIG}" ]; then
            KCONFIG="-f config-debug-p4tc-s390x"
         fi
         ;;
      *)
         echo "archicteture $1 is not supported"
         exit 1
         ;;
   esac
}

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
         ARCH="$OPTARG"
         ;;
      i)
         KIMG="-i $OPTARG"
         ;;
      f)
         KCONFIG="-f $OPTARG"
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

if [ -z "${LINUX_PATH}" ]
then
    help
elif [ -z "${IPROUTE_PATH}" ]
then
    help
fi

verify_arch "$ARCH"
if [ $(uname -m) != "$LINUX_ARCH" ]; then
   echo "Running tests for $ARCH"
   KROOT="-r /opt/sysroot"
   docker build -f Dockerfile.cross-$ARCH -t mojatatucicd/cross-$ARCH .
   INAME="mojatatucicd/cross-$ARCH"
else
   docker build -f Dockerfile -t mojatatucicd/ubuntu .
   INAME="mojatatucicd/ubuntu"
fi

docker run --rm -it \
   -v $(realpath $LINUX_PATH):/opt/linux \
   -v $(realpath $IPROUTE_PATH):/opt/iproute \
   -e LINUX_PATH="/opt/linux" \
   -e IPROUTE_PATH="/opt/iproute" \
   -e ARCH="-a $ARCH" \
   -e ROOT="$KROOT" \
   -e CONFIG="$KCONFIG" \
   -e IMAGE="$KIMG" \
   -e SCRIPT="$CMD" \
   -e CPU="$VMCPUS" \
   -e MEMORY="$VMMEM" \
   -e JOBS="$JOBS" \
   -e UID=`id -u` \
   -e GID=`id -g` \
   $INAME