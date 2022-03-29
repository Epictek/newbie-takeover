#!/bin/sh

# [[ "$(/busybox whoami)" == "root" ]] ||  echo "Please run as root."; exit 1

ALPINEVER="3.15.2"

echo "THIS WILL BREAK YOUR CLOUD SHELL (EDITOR, OPENING ANOTHER TAB) PLEASE RUN THIS IN SAFE MODE, IF YOU WISH NOT TO USE THIS SCRIPT PRESS CTRL+C"
sleep 15

# Based off some parts of this issue: https://github.com/marcan/takeover.sh/issues/5
echo "Here we go!"
# mount a temp filesystem (tmpfs)
mkdir /takeover || echo "Directory was made, no need to make it"
echo "Mounting the file system"
mount -t tmpfs tmpfs /takeover
# copy files for the takeover
echo "Extracting alpine linux mini rootfs tarball"
cd /takeover
wget -O - https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-minirootfs-$ALPINEVER-x86_64.tar.gz | gunzip | tar xv -C /takeover/
cp reboot /takeover/bin/
cp poweroff /takeover/bin/
echo "Preparing"
# copy needed files to have internet in chroot
cp /etc/hosts /takeover/etc/
cp /etc/hostname /takeover/etc/
cp /etc/resolv.conf /takeover/etc/
# compile, then delete alpine sdk
chroot . /sbin/apk update
chroot . /sbin/apk upgrade
chroot . /sbin/apk add htop neofetch alpine-conf shadow busybox-static
cp /takeover/bin/busybox.static /takeover/busybox
echo "Now breaking the shell!"
killall -SIGKILL containerd || true
killall -SIGKILL rsyslogd || true
killall -SIGKILL logger || true
killall -SIGKILL dockerd || true
killall -SIGKILL theia-proxy || true
killall -SIGKILL node || true
mount -n --move /dev /takeover/dev
mount -n --move /sys /takeover/sys
mount -n --move /proc /takeover/proc
mkdir /takeover/old_root
mkdir /takeover/httpd
echo -e "<!DOCTYPE HTML>\n<html><head></head><body><h1>Sorry, but the editor was removed.</h1></body></html>"
cd /takeover
export PATH="/bin:/sbin:/usr/bin:/usr/sbin"
./busybox pivot_root /takeover /takeover/old_root
./busybox httpd -p "0.0.0.0:3000" -h /httpd
echo "DONE, IF YOU WANT TO STOP CLOUD SHELL TYPE poweroff IN THE SHELL"
/bin/ash
sync; poweroff -f now
