#!/bin/bash

# Copyright 2023 Radio New Japan.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions
#    and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
#    and the following disclaimer in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or
#    promote products derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT 
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set -e
set -o pipefail
set -u

export LC_ALL=C

SCRDIR=$(pwd)

DISTRO_NAME=""
DISTRO_VERSION=""
DEBIAN_VERSION=""
ARCH=""

source "${SCRDIR}/profiledef.sh"

_user_distinction(){
	if [[ $(whoami) != "root" ]]; then
		echo "Need to run as root!"
		exit 1
	elif [ ! -f /etc/debian_version ]; then
		echo "The operation on the distros other than Debian/Ubuntu-based is not confirmed."
		exit 1
	fi
}

_prepare(){
	# Configure the environment
	apt-get update
	apt-get install -y binutils \
	                   debootstrap \
	                   squashfs-tools \
	                   xorriso \
	                   grub-pc-bin \
	                   grub-efi-amd64-bin \
	                   mtools \
	                   dosfstools \
	                   unzip
	mkdir -p work/chroot

	debootstrap --arch=amd64 --variant=minbase ${DEBIAN_VERSION} work/chroot ${MIRROR_URL}

	cp -pr dirootfs/* work/chroot/
	cp -p packages.amd64 work/
	sed /^\#/d -i work/packages.amd64
	cp -pr grub work/
	cp -pr sources.list work/chroot/etc/apt/
	cp -pr trusted.gpg.d/* work/chroot/etc/apt/trusted.gpg.d/
	if [ -f purge_packages.amd64 ]; then
		cp -p purge_packages.amd64 work/
		sed /^\#/d -i work/purge_packages.amd64
	fi
	if [ -f flatpak_packages.amd64 ]; then
		cp -p flatpak_packages.amd64 work/
	 sed /^\#/d -i work/flatpak_packages.amd64
	fi
	chmod 755 work/chroot/root/customise_dirootfs.d/*.sh
	sed "s/distro_name/${DISTRO_NAME}/g" -i work/grub/grub.cfg
	sed "s/distro_uname/${DISTRO_UNAME}/g" -i work/grub/grub.cfg

	# chroot
	cd work
	mount --bind /dev chroot/dev
	mount --bind /run chroot/run
	chroot chroot mount none -t proc /proc
	chroot chroot mount none -t sysfs /sys
	chroot chroot mount none -t devpts /dev/pts
}

_setup(){
	chmod 700 chroot/root
	chown root:root chroot/root

	if [ -f chroot/root/customise_dirootfs.d/preinstall.sh ]; then
		chroot chroot /root/customise_dirootfs.d/preinstall.sh
	fi

	chroot chroot apt-get update
	chroot chroot apt-get upgrade -y
	chroot chroot apt-get install -y $(cat packages.amd64)

	if [ -f chroot/root/customise_dirootfs.d/postinstall.sh ]; then
		chroot chroot /root/customise_dirootfs.d/postinstall.sh
	fi

	if [ -f purge_packages.amd64 ]; then
		chroot chroot apt-get purge -y --autoremove $(cat purge_packages.amd64)
	fi

	# flatpak's pkgs
	if [ -f flatpak_packages.amd64 ]; then
		chroot chroot apt install flatpak
		chroot chroot flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
		chroot chroot flatpak update
		chroot chroot flatpak install flathub $(cat flatpak_packages.amd64)
	fi

	chroot chroot dpkg-reconfigure locales
	chroot chroot dpkg-reconfigure resolvconf

	cat <<EOF > chroot/etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF
	chroot chroot dpkg-reconfigure network-manager

	chroot chroot apt clean -y

}

_build_iso(){
	umount chroot/proc
	umount chroot/sys
	umount chroot/dev/pts
	umount chroot/dev
	umount chroot/run

	mkdir iso
	mkdir -p iso/{live,isolinux,install}

	# copy memtest86
	cp chroot/boot/memtest86+x64.bin iso/install/memtest86+

	wget https://www.memtest86.com/downloads/memtest86-usb.zip -O iso/install/memtest86-usb.zip
	unzip -p iso/install/memtest86-usb.zip memtest86-usb.img > iso/install/memtest86
	rm -f iso/install/memtest86-usb.zip

	# copy kernel
	cp chroot/boot/vmlinuz-**-**-amd64 iso/live/vmlinuz
	cp chroot/boot/initrd.img-**-**-amd64 iso/live/initrd

	# grub
	touch iso/${DISTRO_UNAME}
	cp grub/grub.cfg iso/isolinux/grub.cfg

	# package list
	chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' > iso/live/filesystem.packages

	# compress rootfs
	mksquashfs chroot iso/live/filesystem.squashfs \
	    -noappend -no-duplicates -no-recovery \
	    -wildcards \
	    -e "var/cache/apt/archives/*" \
	    -e "root/*" \
	    -e "root/.*" \
	    -e "tmp/*" \
	    -e "tmp/.*" \
	    -e "swapfile"

	# generate iso
	pushd iso
	grub-mkstandalone \
	    --format=x86_64-efi \
	    --output=isolinux/bootx64.efi \
	    --locales="" \
	    --fonts="" \
	    "boot/grub/grub.cfg=isolinux/grub.cfg"

	(
        cd isolinux && \
        dd if=/dev/zero of=efiboot.img bs=1M count=10 && \
        mkfs.vfat efiboot.img && \
        LC_CTYPE=C mmd -i efiboot.img efi efi/boot && \
        LC_CTYPE=C mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
	)

	grub-mkstandalone \
        --format=i386-pc \
        --output=isolinux/core.img \
        --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
        --modules="linux16 linux normal iso9660 biosdisk search" \
        --locales="" \
        --fonts="" \
        "boot/grub/grub.cfg=isolinux/grub.cfg"

	cat /usr/lib/grub/i386-pc/cdboot.img isolinux/core.img > isolinux/bios.img

	/bin/bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v -e 'md5sum.txt' -e 'bios.img' -e 'efiboot.img' > md5sum.txt)"

	# build iso
	mkdir ../../out

	xorriso \
	    -as mkisofs \
	    -iso-level 3 \
	    -full-iso9660-filenames \
	    -volid "${DISTRO_UNAME}" \
	    -eltorito-boot boot/grub/bios.img \
	    -no-emul-boot \
	    -boot-load-size 4 \
	    -boot-info-table \
	    --eltorito-catalog boot/grub/boot.cat \
	    --grub2-boot-info \
	    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
	    -eltorito-alt-boot \
	    -e EFI/efiboot.img \
	    -no-emul-boot \
	    -append_partition 2 0xef isolinux/efiboot.img \
	    -output "../../out/${DISTRO_UNAME}-${DISTRO_VERSION}-amd64.iso" \
	    -m "isolinux/efiboot.img" \
	    -m "isolinux/bios.img" \
	    -graft-points \
	       "/EFI/efiboot.img=isolinux/efiboot.img" \
	       "/boot/grub/bios.img=isolinux/bios.img" \
	       "."

	popd
}

_user_distinction
_prepare
_setup
_build_iso

export LC_ALL=$(printenv LANG)

