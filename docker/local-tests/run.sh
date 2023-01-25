#!/bin/bash

echo create group
groupadd -g ${GID} usergroup

set -e

echo create user

useradd user -u ${UID} -g ${GID} -m -s /bin/bash

if [[ "$ARCH" == *"s390x"* ]]; then
sudo -u user bash <<EOF
whoami
echo compile iproute

cd ${IPROUTE_PATH}
CC="s390x-linux-gnu-gcc --sysroot=/opt/sysroot" HOSTCC=gcc ./configure

LDLIBS="-L/opt/sysroot/usr/lib/s390x-linux-gnu -l:libgssapi_krb5.so.2.2 -l:libtirpc.so.3.0.0" make -C ${IPROUTE_PATH} -j $(nproc) V=1
EOF
make -C ${IPROUTE_PATH} DESTDIR=/opt/sysroot install
sudo -u user bash <<EOF
echo compile linux
cd ${LINUX_PATH}
/opt/vm.sh ${ARCH} ${ROOT} ${CPU} ${MEMORY} ${JOBS} ${IMAGE} ${CONFIG} ${SCRIPT}
EOF

else
sudo -u user bash <<EOF
whoami
echo compile iproute

cd ${IPROUTE_PATH}
./configure --prefix=/usr

make -C ${IPROUTE_PATH} -j $(nproc)
EOF
make -C ${IPROUTE_PATH} install

sudo -u user bash <<EOF
echo compile linux
cd ${LINUX_PATH}
/opt/vm.sh ${ARCH} ${ROOT} ${CPU} ${MEMORY} ${JOBS} ${IMAGE} ${CONFIG} ${SCRIPT}
EOF

fi
