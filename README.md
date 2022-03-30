# Newbie takeover.sh

A script to completely take over a running Linux system remotely, allowing you
to log into an in-memory rescue environment, unmount the original root
filesystem, and do anything you want, all without rebooting. Replace one distro
with another without touching a physical console.

However you can also use it in a TTY.

## WARNING WARNING WARNING WARNING

This is SUPER MESSY, if it breaks something do not blame me.

# Usage

Requirements: tar, gunzip, wget
-
For arch linux: `pacman -Sy tar gzip wget git`
-
For debian/ubuntu: `apt update; apt install gzip wget git tar`

---- 

You should use the alpine takeover script if you need a fast switch to ram way

The fast way to run this: `git clone https://tinyurl.com/newbie-takeover a; cd a; ./alpine-takeover.sh`

----

Or you can use this command if you are using cloud shell in safe mode

`git clone https://tinyurl.com/newbie-takeover a; cd a; sh ./alpine-takeover-cloudshell.sh`

----


If everything worked, congratulations! You may now use your new SSH/shell session
to kill any remaining old daemons (`kill -9` is recommended to make sure they
don't try to do anything silly during shutdown), and then unmount all
filesystems under `/old_root`, including `/old_root` itself. You may want to
first copy `/old_root/lib/modules` into your new tmpfs in case you need any old
kernel modules.

You are now running entirely from RAM and should be able to do as you please.
Note that you may still have to clean up LVM volumes (`dmsetup` is your friend)
and similar before you can safely repartition your disk and install Gentoo
Linux, which is of course the whole reason you're doing this crazy thing to
begin with. 

When you're done, unmount all filesystems, `sync`, then `reboot -f` or `echo b >
/proc/sysrq-trigger` and cross your fingers.

## Screenshots of it working

Alpine Linux on cloud shell without containers or chroot
![image](https://user-images.githubusercontent.com/89206182/160626217-c8679c0d-ac24-4f6a-a6bd-ee923bdd53c2.png)

Or Alpine Linux running on a virtual machine that had arch linux on it
![image](https://user-images.githubusercontent.com/89206182/160627223-dbb5d0d9-839c-4b17-989e-fb5ea455fe5f.png)

## TO DO:
[] Try on docker containers (and make a script for it)
-
[] Try on android (and make a script for it)



## Compatibility

This script is designed for init systems that support the `telinit u` command, If the command doesn't work or exist it will try the openrc method or the systemctl one

You should always test this in a VM first. You can grab a tarball of your live
root filesystem, extract it into a VM image, get your VM up and running (boot
loader setup is left as an exercise for the reader), then try the process there
and see if it works. Hint: `mount --bind / /mnt` will get you a view of your
root filesystem on `/mnt` without any other filesystems that are mounted on top.

## Further reading

I've been pointed to
[this StackExchange answer](http://unix.stackexchange.com/questions/226872/how-to-shrink-root-filesystem-without-booting-a-livecd/227318#227318)
which details how to manually perform a similar process, but using a subset of
the existing root filesystem instead of a rescue filesystem. This allows you
to keep (a new copy of) the existing init system running, as well as essential
daemons, and then go back to the original root filesystem once you're done. This
is a more useful version if, for example, you want to resize the original root
filesystem or re-configure disk partitions, but not actually install a different
distro, and you want to avoid rebooting at all.

`takeover.sh` could be extended to support re-execing a new init once you're
done. This could be used to switch to a *new* distro entirely without
rebooting, as long as you're happy using the old kernel. If you're interested,
pull requests welcome :-).
