#!/bin/bash

UBOOT_BRANCH="beaglev-v2020.01-1.0.3"
LINUX_BRANCH="beaglev-v5.10.113-1.0.3"

if [ -f ./.gitlab-runner ] ; then
	git clone --reference-if-able /mnt/yocto-cache/git/riscv-toolchain/ git@git.beagleboard.org:beaglev-ahead/riscv-toolchain.git --depth=1
else
	if [ ! -d ./riscv-toolchain ] ; then
		echo "Log riscv-toolchain: [git clone git@git.beagleboard.org:beaglev-ahead/riscv-toolchain.git --depth=1]"
		git clone git@git.beagleboard.org:beaglev-ahead/riscv-toolchain.git --depth=1
	else
		cd ./riscv-toolchain/
		echo "Log riscv-toolchain: [git pull --rebase]"
		git pull --rebase
		cd -
	fi
fi

if [ -f ./.gitlab-runner ] ; then
	git clone --reference-if-able /mnt/yocto-cache/git/opensbi/ git@git.beagleboard.org:beaglev-ahead/opensbi.git --depth=1
else
	if [ ! -d ./opensbi ] ; then
		echo "Log opensbi: [git clone git@git.beagleboard.org:beaglev-ahead/opensbi.git --depth=10]"
		git clone git@git.beagleboard.org:beaglev-ahead/opensbi.git --depth=10
	else
		cd ./opensbi/
		echo "Log opensbi: [git pull --rebase]"
		git pull --rebase
		cd -
	fi
fi

if [ -d ./u-boot ] ; then
	rm -rf ./u-boot || true
fi

if [ -f ./.gitlab-runner ] ; then
	git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-u-boot/ -b ${UBOOT_BRANCH} git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-u-boot.git ./u-boot/ --depth=1
else
	git clone -b ${UBOOT_BRANCH} git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-u-boot.git ./u-boot/ --depth=10
fi

if [ -d ./BeagleBoard-DeviceTrees ] ; then
	rm -rf ./BeagleBoard-DeviceTrees || true
fi

git clone -b v5.10.x-ti-unified git@git.beagleboard.org:beaglev-ahead/BeagleBoard-DeviceTrees.git

if [ -d ./linux ] ; then
	rm -rf ./linux || true
fi

if [ -f ./.gitlab-runner ] ; then
	git clone --reference-if-able /mnt/yocto-cache/git/beaglev-ahead-linux/ -b ${LINUX_BRANCH} git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-linux.git ./linux/ --depth=1
else
	git clone -b ${LINUX_BRANCH} git@git.beagleboard.org:beaglev-ahead/beaglev-ahead-linux.git ./linux/ --depth=10
fi

if [ -f ./.gitlab-runner ] ; then
	rm -f ./.gitlab-runner || true
fi

#
