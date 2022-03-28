#!/bin/sh

umount -f -l /old_root/dev
umount -f -l /old_root/sys
umount -f -l /old_root/proc
umount -f -l /old_root/usr/lib/systemd/systemd

# NOTES:
# add hostname to sysinit
# add localmount to sysinit
# add modules to sysinit
# add hwclock to sysinit
# add hwdrivers to sysinit
# add networking to boot
# add sshd to default

echo "WARNING: Please run this once you have ran the alpine-takeover script, if you didn't press CTRL+C"
echo "ANOTHER NOTE: Do not run this if you have a alpine install that you want to reinstall, and that your using a long name like (nvme, or vdaa) and so on"
sleep 10
echo "Alright let's start"

rm -rf /old_root/*

echo "Setup alpine but dont install it to a disk (or type none to the disk selection part"
echo "Also keep openssh and chronyd as default"
setup-alpine
echo "Now installing alpine"
setup-disk -s 0 -m sys -k lts -v /old_root
chroot /old_root /sbin/apk add grub-bios grub
mount -t proc proc /old_root/proc
mount -t devtmpfs dev /old_root/dev
mount -t sysfs sys /old_root/sys
chroot /old_root /sbin/apk fix
echo -e "auto lo\niface lo inet loopback\n\nauto eth0\niface eth0 inet dhcp" > /old_root/etc/network/interfaces
chroot /old_root /sbin/rc-update add hostname sysinit
chroot /old_root /sbin/rc-update add localmount sysinit
chroot /old_root /sbin/rc-update add modules sysinit
chroot /old_root /sbin/rc-update add hwclock sysinit
chroot /old_root /sbin/rc-update add hwdrivers sysinit
chroot /old_root /sbin/rc-update add networking boot
chroot /old_root /sbin/rc-update add sshd default || true
chroot /old_root /sbin/rc-update add chronyd || true
chroot /old_root /usr/sbin/grub-install $(df -h /old_root | grep /old_root | head -c 8)
echo "Cleaning up.."
umount -l /old_root/dev
umount -l /old_root/sys
umount -l /old_root/proc
echo "Done! You may now reboot."
