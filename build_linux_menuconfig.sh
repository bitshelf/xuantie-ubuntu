#!/bin/bash

CORES=$(getconf _NPROCESSORS_ONLN)

wdir=`pwd`

CC=${wdir}/riscv-toolchain/bin/riscv64-unknown-linux-gnu-

cd ./linux/
cp -rv ../BeagleBoard-DeviceTrees/src/thead/*.dts ./arch/riscv/boot/dts/thead/
echo "# SPDX-License-Identifier: GPL-2.0" > arch/riscv/boot/dts/thead/Makefile
echo "dtb-\$(CONFIG_ARCH_THEAD) += th1520-lichee-pi-4a.dtb" >> arch/riscv/boot/dts/thead/Makefile
echo "dtb-\$(CONFIG_ARCH_THEAD) += th1520-beaglev-ahead.dtb" >> arch/riscv/boot/dts/thead/Makefile

#if [ ! -d ./arch/riscv/boot/dts/thead/overlays/ ] ; then
#	mkdir -p ./arch/riscv/boot/dts/thead/overlays/
#fi
#cp -rv ../BeagleBoard-DeviceTrees/src/thead/overlays/*.dts ./arch/riscv/boot/dts/thead/overlays/

cd ../BeagleBoard-DeviceTrees/
make clean ; make
cd ../linux

make ARCH=riscv CROSS_COMPILE=${CC} clean
make ARCH=riscv CROSS_COMPILE=${CC} defconfig
make ARCH=riscv CROSS_COMPILE=${CC} menuconfig
echo "make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs"
make -j${CORES} ARCH=riscv CROSS_COMPILE=${CC} Image modules dtbs

KERNEL_UTS=$(cat "${wdir}/linux/include/generated/utsrelease.h" | awk '{print $3}' | sed 's/\"//g' )

make -s ARCH=riscv CROSS_COMPILE=${CC} modules_install INSTALL_MOD_PATH="${wdir}/deploy/tmp"

if [ -f "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" ] ; then
	rm -rf "${wdir}/deploy/${KERNEL_UTS}-modules.tar.gz" || true
fi
echo "Compressing ${KERNEL_UTS}-modules.tar.gz..."
echo "${KERNEL_UTS}" > "${wdir}/deploy/.modules"
cd "${wdir}/deploy/tmp" || true
tar --create --gzip --file "../${KERNEL_UTS}-modules.tar.gz" ./*
cd "${wdir}/linux/" || exit
rm -rf "${wdir}/deploy/tmp" || true

cp -v ./arch/riscv/boot/dts/thead/th1520-beaglev-ahead.dts ../BeagleBoard-DeviceTrees/src/thead/
cp -v ./.config ../patches/linux/beaglev_defconfig
cp -v ./arch/riscv/boot/Image ../deploy/
cp -v ./arch/riscv/boot/dts/thead/*.dtb ../deploy/

cd ../

touch ./.05_generate_boot.sh
touch ./.06_generate_root.sh
