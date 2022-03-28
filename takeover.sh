#!/bin/sh
set -e

TO=/takeover
OLD_INIT=$(readlink /proc/1/exe)
PORT=2222

cd "$TO"

if [ ! -e fakeinit ]; then
    ./busybox echo "Please compile fakeinit.c first"
    exit 1
fi

./busybox echo "WARNING: THIS WILL TAKEOVER THE SYSTEM, ARE YOU SURE? THEN TYPE OK IN ALL CAPS"
./busybox echo -n "> "
read a
if [ "$a" != "OK" ] ; then
    exit 1
fi

./busybox echo "Please set the root password"
./busybox echo "Also don't forget to install ssh server on the takeover rootfs if your using a VPS or a headless device (like a server)" 

./busybox chroot . /bin/passwd || ./busybox echo "Trying /usr/bin/passwd"; ./busybox chroot . /usr/bin/passwd

./busybox echo "Setting up target filesystem..."
./busybox rm -f etc/mtab
./busybox ln -s /proc/mounts etc/mtab
./busybox mkdir -p old_root

./busybox echo "Mounting pseudo-filesystems..."
./busybox mount -t tmpfs tmp tmp
./busybox mount -t proc proc proc
./busybox mount -t sysfs sys sys
if ! ./busybox mount -t devtmpfs dev dev; then
    ./busybox mount -t tmpfs dev dev
    ./busybox cp -a /dev/* dev/
    ./busybox rm -rf dev/pts
    ./busybox mkdir dev/pts
fi
./busybox mount --bind /dev/pts dev/pts

TTY="$(./busybox tty)"

./busybox echo "Checking and switching TTY..."

exec <"$TO/$TTY" >"$TO/$TTY" 2>"$TO/$TTY"

./busybox echo "Preparing init..."
./busybox cat >tmp/${OLD_INIT##*/} <<EOF
#!${TO}/busybox sh

exec <"${TO}/${TTY}" >"${TO}/${TTY}" 2>"${TO}/${TTY}"
cd "${TO}"

./busybox echo "Init takeover successful"
./busybox echo "Pivoting root..."
./busybox mount --make-rprivate /
./busybox pivot_root . old_root
./busybox echo "Chrooting and running init..."
exec ./busybox chroot . /fakeinit
EOF
./busybox chmod +x tmp/${OLD_INIT##*/}

./busybox echo "Starting secondary sshd (or maybe not)"

./busybox chroot . /usr/bin/ssh-keygen -A || echo "Not starting SSH"
./busybox chroot . /usr/sbin/sshd -p $PORT -o PermitRootLogin=yes || true

./busybox echo "You should SSH into the secondary sshd now or wait if your using a TTY and not a SSH shell."
./busybox echo "About to take over init. This script will now pause for a few seconds."
./busybox echo "If the takeover was successful, you will see output from the new init."
./busybox echo "You may then kill the remnants of this session and any remaining"
./busybox echo "processes (includes ones from the old init) from your new SSH session, and umount the old root filesystem."

./busybox mount --bind tmp/${OLD_INIT##*/} ${OLD_INIT}

telinit u || systemctl daemon-reexec || openrc-shutdown --reexec || echo 'Not taking over the init'; true

echo "Changing PATH for the script"
# Since export is a standard SH command (built into the shell) We don't need to call it from busybox (it doesn't have the export applet anyway..)
# Also there's a benefit since it will let us seamlessly use the shell
export PATH="/bin:/sbin:/usr/bin:/usr/sbin"
./busybox echo 'Make sure to run this command if you want to continue using the TTY: export PATH="/bin:/sbin:/usr/bin:/usr/sbin"'
./busybox echo "ALSO ANOTHER WARNING: DO NOT RUN THE EXIT COMMAND IF YOUR USING TTY"

./busybox sleep 10

./busybox echo "Cleaning up (for systemd)"
killall -SIGKILL systemd || true
killall -SIGKILL systemd-networkd || true
killall -SIGKILL systemd-logind || true
killall -SIGKILL systemd-journald || true
killall -SIGKILL systemd-udevd || true
killall -SIGKILL NetworkManager || true
killall -SIGKILL ModemManager || true
killall -SIGKILL dbus-daemon || true
killall -SIGKILL cron || true
killall -SIGKILL polkitd || true
killall -SIGKILL rsyslogd || true
killall -SIGKILL dhcpcd || true


/bin/ash
