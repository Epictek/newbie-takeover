#!/bin/sh

# [[ "$(/busybox whoami)" == "root" ]] ||  echo "Please run as root."; exit 1

ALPINEVER="3.15.2"
STARTSECONDSSH="no"

# Based off some parts of this issue: https://github.com/marcan/takeover.sh/issues/5
echo "Here we go!"
# mount a temp filesystem (tmpfs)
mkdir /takeover || echo "Directory was made, no need to make it"
echo "Mounting the file system"
mount -t tmpfs tmpfs /takeover
# copy files for the takeover
cp fakeinit.c /takeover/
cp takeover.sh /takeover/
cp alpine-autoinstall.sh /takeover/
echo "Extracting alpine linux mini rootfs tarball"
wget -O - https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-minirootfs-$ALPINEVER-x86_64.tar.gz | gunzip | tar xv -C /takeover/
cp ./reboot /takeover/bin/
cp ./poweroff /takeover/bin/
cd /takeover
echo "Preparing"
# copy needed files to have internet in chroot 
cp /etc/hosts /takeover/etc/
cp /etc/hostname /takeover/etc/
cp /etc/resolv.conf /takeover/etc/
# compile, then delete alpine sdk
chroot . /sbin/apk update
chroot . /sbin/apk upgrade
chroot . /sbin/apk add openssh-server gcc htop neofetch alpine-conf shadow busybox-static
chroot . /usr/bin/gcc /fakeinit.c -o /fakeinit
chroot . /sbin/apk del alpine-sdk
echo PermitRootLogin yes >> /takeover/etc/ssh/sshd_config
cp /takeover/bin/busybox.static /takeover/busybox
echo "Off we go!"
sh ./takeover.sh
