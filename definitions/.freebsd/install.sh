#!/bin/sh -xe

# Credit: http://www.aisecure.net/2011/05/01/root-on-zfs-freebsd-current/

NAME=$1
MAJOR_VER=$(uname -r | sed -E 's/^([0-9]+)\..*$/\1/')
ARCH=$(uname -p)

case "${MAJOR_VER}" in
"8")
  DISK_DEV=$(ls -1 /dev | grep ad | head -n1)
  BOOTPMBR_FILE=/mnt2/boot/pmbr
  BOOTCODE_FILE=/mnt2/boot/gptzfsboot
  export FTP_PASSIVE_MODE="YES"
  ;;
"9")
  DISK_DEV=ada0
  BOOTPMBR_FILE=/boot/pmbr
  BOOTCODE_FILE=/boot/gptzfsboot
  DIST_DIR=/usr/freebsd-dist
  ;;
esac

# create disks
gpart create -s gpt ${DISK_DEV}
gpart add -b 34 -s 94 -t freebsd-boot ${DISK_DEV}
gpart add -t freebsd-zfs -l disk0 ${DISK_DEV}
gpart bootcode -b ${BOOTPMBR_FILE} -p ${BOOTCODE_FILE} -i 1 ${DISK_DEV}

# align disks
gnop create -S 4096 /dev/gpt/disk0
zpool create -o altroot=/mnt -o cachefile=/tmp/zpool.cache zroot /dev/gpt/disk0.nop
zpool export zroot
gnop destroy /dev/gpt/disk0.nop
zpool import -o altroot=/mnt -o cachefile=/tmp/zpool.cache zroot

zpool set bootfs=zroot zroot
zfs set checksum=fletcher4 zroot

# set up zfs pools
zfs create zroot/usr
zfs create zroot/usr/home
zfs create zroot/var
zfs create -o compression=on   -o exec=on  -o setuid=off zroot/tmp
zfs create -o compression=lzjb             -o setuid=off zroot/usr/ports
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/distfiles
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/packages
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/usr/src
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/var/crash
zfs create                     -o exec=off -o setuid=off zroot/var/db
zfs create -o compression=lzjb -o exec=on  -o setuid=off zroot/var/db/pkg
zfs create                     -o exec=off -o setuid=off zroot/var/empty
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/var/log
zfs create -o compression=gzip -o exec=off -o setuid=off zroot/var/mail
zfs create                     -o exec=off -o setuid=off zroot/var/run
zfs create -o compression=lzjb -o exec=on  -o setuid=off zroot/var/tmp

# fixup
chmod 1777 /mnt/tmp
cd /mnt ; ln -s usr/home home
sleep 10
chmod 1777 /mnt/var/tmp

# Install the OS
case "${MAJOR_VER}" in
"8")
  cd /dist/8.*
  export DESTDIR=/mnt
  (cd base ; echo 'y' | ./install.sh)
  (cd kernels ; ./install.sh generic)
  (cd src ; ./install.sh all)
  [ "${ARCH}" = "amd64" ] && (cd lib32 ; ./install.sh)
  cd /mnt/boot
  cp -Rlp GENERIC/* /mnt/boot/kernel/
  ;;
"9")
  cd /usr/freebsd-dist
  cat base.txz | tar --unlink -xpJf - -C /mnt
  cat kernel.txz | tar --unlink -xpJf - -C /mnt
  cat src.txz | tar --unlink -xpJf - -C /mnt
  [ "${ARCH}" = "amd64" ] && cat lib32.txz | tar --unlink -xpJf - -C /mnt
  ;;
esac

# set up swap
zfs create -V 2G zroot/swap
zfs set org.freebsd:swap=on zroot/swap
zfs set checksum=off zroot/swap

cp /tmp/zpool.cache /mnt/boot/zfs/zpool.cache

sleep 25
# Enable required services
cat >> /mnt/etc/rc.conf << EOT
zfs_enable="YES"
hostname="${NAME}"
ifconfig_em0="dhcp"
sshd_enable="YES"
EOT

# Tune and boot from zfs
case "${ARCH}" in
"i386")
  # Increase kmem and arc max for i386 due less efficient addressing. This
  # should reduce the chance of a kernel panic during install or other heavy IO
  # tasks.
  KMEMSIZE="400M"
  KMEMMAX="400M"
  ARCMAX="80M"
  ;;
"amd64")
  # 64-bit platform tuning for performance on low-mem instances.
  KMEMSIZE="200M"
  KMEMMAX="200M"
  ARCMAX="40M"
  ;;
esac
cat >> /mnt/boot/loader.conf << EOT
zfs_load="YES"
vfs.root.mountfrom="zfs:zroot"
vm.kmem_size="${KMEMSIZE}"
vm.kmem_size_max="${KMEMMAX}"
vfs.zfs.arc_max="${ARCMAX}"
vfs.zfs.vdev.cache.size="5M"
EOT

# Enable swap
echo '/dev/gpt/swap0 none swap sw 0 0' > /mnt/etc/fstab

# Install a few requirements
[ "${MAJOR_VER}" = "8" ] && ( echo 'nameserver 8.8.8.8' > /etc/resolv.conf )
echo 'nameserver 8.8.8.8' > /mnt/etc/resolv.conf
export PACKAGESITE="http://ftp.freebsd.org/pub/FreeBSD/ports/${ARCH}/packages-${MAJOR_VER}-stable/Latest/"
pkg_add -C /mnt -r bash-static || /usr/bin/true
(
  cd /mnt/bin
  ln -s /usr/local/bin/bash bash
  pkg_add -C /mnt -r sudo || /usr/bin/true
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /mnt/usr/local/etc/sudoers
  rm /mnt/etc/resolv.conf
)

# Set up user accounts
zfs create zroot/usr/home/vagrant
chroot /mnt /bin/sh -c 'echo "vagrant" | pw useradd vagrant -h 0 -s /bin/csh -G wheel -d /home/vagrant -c "Vagrant User"'
chroot /mnt /bin/sh -c 'echo "vagrant" | pw usermod root'
chroot /mnt /bin/sh -c 'chown 1001:1001 /home/vagrant'

# unmount zfs
zfs unmount -f zroot

# Kill sysinstall instead of rebooting if we're in a fixit shell
[ "${MAJOR_VER}" = "8" ] && kill 1

# Reboot
reboot
