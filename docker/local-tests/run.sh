#!/bin/bash

echo create group
groupadd -g ${GID} usergroup

set -e

echo create user

useradd user -u ${UID} -g ${GID} -m -s /bin/bash

sudo -u user bash <<EOF
whoami
echo compile iproute

cd ${IPROUTE_PATH}
./configure --prefix=/usr

make -C ${IPROUTE_PATH} -j $(nproc)
make -C ${IPROUTE_PATH} install

echo compile linux
cd ${LINUX_PATH}
/opt/vm.sh ${ARCH} ${ROOT} ${CPU} ${MEMORY} ${JOBS} ${IMAGE} ${CONFIG} ${DRY} ${CONFIG_GEN} ${SHELL} ${SCRIPT}
EOF
