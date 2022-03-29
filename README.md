# Newbie takeover.sh

A script to completely take over a running Linux system remotely, allowing you
to log into an in-memory rescue environment, unmount the original root
filesystem, and do anything you want, all without rebooting. Replace one distro
with another without touching a physical console.

However you can also use it in a TTY.

## WARNING WARNING WARNING WARNING

This is experimental. Do not use this script if you don't understand exactly
how it works. Do not use this script on any system you care about. Do not use
this script on any system you expect to be up. Do not run this script unless
you can afford to get physical access to fix a botched takeover. If anything
goes wrong, your system will most likely panic. Unless you have balls to do that

That said, this script will not (itself) make any permanent changes to your
existing root filesystem (assuming you run it from a tmpfs), so as long as you
can remotely reboot your box using an out-of-band mechanism, you *should* be OK.
But don't blame me if it eats your dog.

This script does not have any provisions for exiting *out* of the new
environment back into something sane. You *will* have to reboot when you're
done. If you get anything wrong, your machine won't boot. Tough luck.

This is (sort of) a guide for newbies. 

## Compatibility

This script is designed for init systems that support the `telinit u` command, If the command doesn't work or exist it will try the openrc method or the systemctl one

You should always test this in a VM first. You can grab a tarball of your live
root filesystem, extract it into a VM image, get your VM up and running (boot
loader setup is left as an exercise for the reader), then try the process there
and see if it works. Hint: `mount --bind / /mnt` will get you a view of your
root filesystem on `/mnt` without any other filesystems that are mounted on top.

## Usage

You need to decide on what environment you want. I recommend
[Alpine Linux mini rootfs tarball](https://alpinelinux.org/), which is bare bones linux rootfs tarball and will be using in this guide.

Requirements: 
The GCC compiler,
Wget,
Tar,
Gunzip,
Free time,
And some water.

# You should use the alpine takeover script if you need a fast switch to ram way

The fast way to run this: `git clone https://tinyurl.com/newbie-takeover a; cd a; ./alpine-takeover.sh`
# Or you can use this command if you are using cloud shell in safe mode

`git clone https://tinyurl.com/newbie-takeover a; cd a; ./alpine-takeover-cloudshell.sh`

# 
1. Create a directory `/takeover` on your target system and mount a temp filesystem to it by using this command, $`mount -t tmpfs tmpfs /takeover`
2. Download and Extract the rootfs tarball to the /takeover directory using this command, $`wget -O - https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/x86_64/alpine-minirootfs-3.15.2-x86_64.tar.gz | gunzip | tar xv` Also note you need to be in the takeover directory in order to do that
3. Compile fakeinit.c using $`gcc --output /takeover/fakeinit ./fakeinit.c`
4. Copy the takeover.sh script to the /takeover directory
5. Make sure to have a static copy of busybox with the name "busybox" in the takeover directory from lets say [The offical busybox web](https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64)
6. Now run the script and be *VERY* careful using $`sh /takeover/takeover.sh` and follow the steps on screen.
# Will continue making it better to understand


If everything worked, congratulations! You may now use your new SSH session
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
