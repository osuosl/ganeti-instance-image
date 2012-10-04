# ganeti-instance-image

This is a guest OS definition for [Ganeti](http://code.google.com/p/ganeti). It
will install a Linux-based image using either a tarball, filesystem dump, or a
qemu-img disk image file. This definition also allows for manual creation of an
instance by simply setting only the disks up and allowing you to boot via the
install cd manually.  The goal of this instance is to allow fast and flexible
installation of instances without the need for external tools such as
debootstrap.

## Installation

In order to install this package from source, you need to determine what options
ganeti itself has been configured with. If ganeti was built directly from
source, then the only place it looks for OS definitions is `/srv/ganeti/os`,
and you need to install the OS under it:

    ./configure --prefix=/usr --localstatedir=/var \
      --sysconfdir=/etc \
      --with-os-dir=/srv/ganeti/os
    make && make install

If ganeti was installed from a package, its default OS path should already
include /usr/share/ganeti/os, so you can just run:

    ./configure -prefix=/usr --localstatedir=/var \
      --sysconfdir=/etc
    make && make install

Note that you need to repeat this procedure on all nodes of the cluster.

The actual path that ganeti has been installed with can be determined by looking
for a file named `_autoconf.py` under a ganeti directory in the python modules
tree (e.g.  `/usr/lib/python2.4/site-packages/ganeti/_autoconf.py`). In this
file, a variable named `OS_SEARCH_PATH` will list all the directories in
which ganeti will look for OS definitions.

## Configuration of instance creation

The kind of instance created can be customized via a settings file. This file
may or may not be installed by default, as the instance creation will work
without it. The creation scripts will look for it in
`$sysconfdir/default/ganeti-instance-image`, so if you have run configure with
the parameter `--sysconfdir=/etc`, the final filename will be
`/etc/default/ganeti-instance-image`.

The following settings will be examined in this file:

* `CDINSTALL`:  If 'yes' only setup disks for a cd based install or manual
                installation via other means. It will not deploy any images or
                create any partitions. (default: no)
* `SWAP`:       Create a swap partition (tarball only) (default: yes)
* `SWAP_SIZE`:  Manually set the default swap partition size in MB (default: size
                of instance memory)
* `FILESYSTEM`: Set which filesystem to format the disks as. Currently only
                supports ext3 or ext4. (default: ext3)
* `FDISK`:      Select either "parted" or "sfdisk" as the fdisk program to use
                when creating partitions. (default: sfdisk)
* `KERNEL_ARGS`: Add additional kernel boot parameters to an instance. This
                currently only works on booting a kernel from inside.
* `IMAGE_NAME`: Name for the image to use. Generally they will have names similar
                to: centos-5.4, debian-5.0, etc. The naming is free form
                depending on what you name the file itself.
* `IMAGE_TYPE`: Create instance by either using a gzipped tarball, file system
                dump, or an image created by qemu-img. Accepts either 'tarball',
                'dump', or 'qemu'.  (default: dump).
* `IMAGE_DIR`:  Override default location for images.
                (default: `$localstatedir/cache/ganeti-instance-image`)
* `NOMOUNT`:    Do not try to mount volume (typically used if it is not a linux
                partition).  Accepts either 'yes' or 'no'. This option is useful
                for installing Windows images for example. (default: no)
* `OVERLAY`:    Overlay of files to be copied to the instance after OS
                installation. This is useful for situations where you want to
                copy instance specific configs such as resolv.conf.
* `ARCH`:       Define the architecture of the image to use. Accepts either 'x86'
                or 'x86_64'.
* `CUSTOMIZE_DIR`: A directory containing customization script for the instance.
                (by default $sysconfdir/ganeti/instance-image/hooks) See
                "Customization of the instance" below.
* `IMAGE_DEBUG`: Enable verbose output for instance scripts. Enable by either
                using "1" or "yes"  (default: no )

Note that the settings file is important on the node that the instance is
installed on, not the cluster master. This is indeed not a very good model of
using this OS but currently the OS interface in ganeti is limiting.

## Creation of Deployment Images

There are three types that are supported for deploying images.

* tarball
* dump
* qemu image

### Tarball

Tarball based images are quite simply a tarball of a working system. An good
example use case for this is deploying a Gentoo instance using a stage4 tarball.
The only requirement is that the tarball is gzipped instead of bzip2 for speed.
If you wish use a kernel inside of the VM instead of externally, make sure that
a working kernel, grub config are install in the tarball. Enable the 'grub'
custom script to install the grub boot image during installation.

### Qemu Images

NOTE: qemu images will create a partition of the exact same size as it was
originally created with. So if you create a 4GB image and created a new instance
of 10G it will create a partition that is only 4GB and leave the rest as "free".

To create a new qemu based disk image, you will need to able the `CDINSTALL`
option and install the VM using the distro's provided installation medium. It is
not recommended to build images on systems outside of ganeti (such as libvirt)
as we have encountered issues with systems segfaulting.

Once the instance has been created, boot the instance and point it to the
install medium:

  gnt-instance start -H cdrom_image_path=path/to/iso/ubuntu-9.10.iso, \
    boot_order=cdrom instance-name

Once the base image has been installed, ensure you have the acpid package
installed so that ganeti can shutdown the VM properly. Once you are happy with
your base image, shutdown the VM, activate the disks,  and create the disk
image using qemu-img. Its recommended you use qcow2 with compression to reduce
the amount of disk space used:

    # activate disks
    gnt-instance activate-disks instance-name
    # create image
    qemu-img convert -c -f host_device /dev/drbd1 \
       -O qcow2 $IMAGE_DIR/ubuntu-9.10-x86_64.img

Note: Older versions of qemu-img may not support the `host_device` format so
use `raw` instead which should work in theory.

### Dump

The last, and most efficient type of disk image is creating filesystem dumps
using the dump command. The advantage with using dumps is that its much faster
to deploy using it, and it also has built-in compression. The disadvantage is
that you need to install grub manually which might be an issue on some operating
systems. We currently fully support grub 1 and have partial support with grub2.
After the new instance has booted, you will need to run `update-grub` and reboot
the VM to get the new settings. We currently cannot run `update-grub` during the
install because of an upstream grub2 issue.

You will need to create images for both the boot and root partition (if you
include a boot partition).

Create a base image for an instance just like its described in Qemu Images. Make
sure the instance is shutdown and then issue the following commands (assuming
the activated disk is drbd1)::

    dump -0 -q -z9 -f ${IMAGE_DIR}/${IMAGE_NAME}-${ARCH}-boot.dump \
      /dev/mapper/drbdq-1

    dump -0 -q -z9 -f ${IMAGE_DIR}/${IMAGE_NAME}-${ARCH}-root.dump \
      /dev/mapper/drbdq-3

### Partition Layout

Currently the partition layout is locked into a specific way in order to make it
work more elegantly with ganeti. We might change this to be more flexible in the
future, however you *must* use the following layout otherwise ganeti will not
install the VM correctly. Currently the following partition layout is assumed:

    With swap:
    /dev/$disk1    /boot
    /dev/$disk2    swap
    /dev/$disk3    /

    Without swap:
    /dev/$disk1    /boot
    /dev/$disk2    /

NOTE: If you have `kernel_path` set, /boot will not be created and all partition
numbers will go up by one. For example:

    With swap:
    /dev/$disk1    swap
    /dev/$disk2    /

    Without swap:
    /dev/$disk1    /

### Image Naming

The naming convention that is used is the following:

* tarball:    `$IMAGE_NAME-$ARCH.tar.gz`
* dump:       `$IMAGE_NAME-$ARCH-boot.dump` `$IMAGE_NAME-$ARCH-root.dump`
* qemu-img:   `$IMAGE_NAME-$ARCH.img`

### Useful Scripts

There are a set of useful scripts located in /usr/share/ganeti/os/image/tools
that you are welcome to use. These scripts are all intended to be run on the
master node::

    mount-disks $instance_name
    umount-disks $instance_name

This will mount or umount an instance to `/tmp/${instance_name}_root`

A utility script named `ganeti-image` will enable you to quickly create an image
of the operating system from the master node. It will execute a script on the
remote host if the instance resides on a remote host. Below is the help output.

    ganeti-image [-d PATH] [-n NAME] [-a ARCH] -t TYPE -i INSTANCE

    Create an image of a ganeti instance using either a tarball, dump, or qemu
    image..

    -t TYPE       Type of image, either: tarball, dump, or qemu-img
    -d PATH       Path of where to put the image
    -i INSTANCE   Name of the instance
    -n NAME       Name of the image
    -a ARCH       Architecture of the image

    This utility must be used on the master node. All optional args will
    have defaults if you do not set them.

The previous image scripts are now deprecated and will be removed in a future
release.

## Customization of the instance

If run-parts is in the os create script, and the `CUSTOMIZE_DIR` (by default
$sysconfdir/ganeti/instance-image/hooks, /etc/ganeti/instance-image/hooks if you
configured the os with --sysconfdir=/etc) directory exists any executable whose
name matches the run-parts execution rules (quoting run-parts(8): the names must
consist entirely of upper and lower case letters, digits, underscores, and
hyphens) is executed to allow further personalization of the installation. The
following environment variables are passed, in addition to the ones ganeti
passes to the OS scripts:

    TARGET:     directory in which the filesystem is mounted
    BLOCKDEV:   ganeti block device
    ROOT_DEV:   device in which the root (/) filesystem resides (the one mounted
                in TARGET)
    BOOT_DEV:   device in which the boot (/boot) filesystem resides
    IMAGE_TYPE: type of image being used (tarball, qemu, dump)

The scripts in `CUSTOMIZE_DIR` can exit with an error code to signal an error in
the instance creation, should they fail.

The scripts in `CUSTOMIZE_DIR` should not start any long-term processes or
daemons using this directory, otherwise the installation will fail because it
won't be able to umount the filesystem from the directory, and hand the instance
back to Ganeti.

### Included Custom Scripts

This OS definition includes three optional customization scripts that are
disabled by default. They are not required but are useful.

### Grub

When enabled, this can setup three things:

- Install grub into the MBR
- Setup serial access to grub
- Add optional kernel boot parameters

In general, the MBR will only be installed if you're not using a qemu image
type, or the `kernel_path` parameter is empty or initiating an import.  There is
currently partial support for install a grub2 MBR (which Ubuntu Karmic and newer
requires).

If `serial_console` is `True` then this script will try to enable serial support
for grub.

### Interfaces

When enabled, it would try to setup networking for eth0 and enable DHCP. It
assumes you already have a DHCP client installed on the guest OS. This currently
supports the following operating systems:

- Redhat (CentOS/Fedora)
- Debian/Ubuntu
- Gentoo
- OpenSUSE

If you need to set a static ip for instances, you can do that by creating
several files in a manner described below.

Subnets:

Create a file in `/etc/ganeti/instance-image/networks/subnets` that has a useful
name such as `vlan42`. This file will describe subnet routing information such
as the netmask, gateway, and dns. The following is an example:

      NETMASK="255.255.255.0"
      GATEWAY="192.168.1.1"
      DNS_DOMAIN="example.org"
      DNS_SEARCH="example.org example.net"
      DNS_SERVERS="8.8.8.8 4.4.4.4"

Instance:

Create a file in `/etc/ganeti/instance-image/networks/instances` and name it the
FQDN of the instance. The file will describe the IP address for the instance and
which subnet it resides on. For example, we could create a file named
`myinstance.osuosl.org` and have the following in it:

      ADDRESS=192.168.1.100
      SUBNET=vlan42

### SSH

When enabled, it will clear out any generated ssh keys that the image may have
so that each instance have *unique* host keys. Currently its disabled for
Debian/Ubuntu since the keys won't be regenerated via the init script. We plan
to fix this manually at some point in the future.

### Overlays

When enabled it will copy a directory of files recursively into the instance.
This is quite useful for site specific configurations such as resolv.conf.
Create a directory in `/etc/ganeit/instance-image/overlays/` and copy files as
needed into it. Treat the directory as the root of the filesystem. Set `OVERLAY`
for the variant as the name of the directory. This directory needs to exist on
all nodes in order to work.

vi: set tw=80 ft=markdown :
