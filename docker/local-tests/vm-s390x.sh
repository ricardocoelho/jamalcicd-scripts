#!/bin/bash

set -e

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
   exit
}

LINUX_PATH=""
IPROUTE_PATH=""
CMD="./tdc.py -c p4tc"
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
      \? )
         help
         exit 1
         ;;
   esac
done
shift $((OPTIND -1))

if [ -z "${LINUX_PATH}" ]
then
    help
elif [ -z "${IPROUTE_PATH}" ]
then
    help
fi

docker build -f Dockerfile.cross-s390x -t mojatatucicd/cross-s390x .

docker run --rm -it \
       -v $(realpath $LINUX_PATH):/opt/linux \
       -v $(realpath $IPROUTE_PATH):/opt/iproute \
    -e LINUX_PATH="/opt/linux" \
    -e IPROUTE_PATH="/opt/iproute" \
    -e ARCH="$ARCH" \
    -e ROOT="-r /opt/sysroot" \
    -e CPU="$VMCPUS" \
    -e MEMORY="$VMMEM" \
    -e JOBS="$JOBS" \
    -e CONFIG="-f config-debug-p4tc-s390x" \
    -e DRY="$DRYRUN" \
    -e CONFIG_GEN="$KCONFIG_GEN" \
    -e IMAGE="$KIMG" \
    -e SCRIPT="$CMD" \
    -e SHELL="$VMSHELL" \
       -e UID=`id -u` \
       -e GID=`id -g` \
       mojatatucicd/cross-s390x

# CC="s390x-linux-gnu-gcc --sysroot=/opt/sysroot" HOSTCC=gcc ./configure
# LDLIBS="-L/opt/sysroot/usr/lib/s390x-linux-gnu -l:libgssapi_krb5.so.2.2 -l:libtirpc.so.3.0.0" make V=1
# make DESTDIR=/opt/sysroot install
