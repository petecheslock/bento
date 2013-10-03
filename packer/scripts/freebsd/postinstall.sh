#!/usr/local/bin/bash -ux

#Set the time correctly
ntpdate -v -b in.pool.ntp.org

echo 'nameserver 8.8.8.8' > /etc/resolv.conf
setenv PACKAGESITE "http://ftp.freebsd.org/pub/FreeBSD/ports/amd64/packages-9-stable/Latest/"

pkg_add -r bash-static
pkg_add -r sudo
pkg_add -r curl
pkg_add -r virtio-kmod

cd /bin/
ln -s /usr/local/bin/bash bash

/bin/sh -c 'echo "vagrant" | pw useradd vagrant -h 0 -s /bin/csh -G wheel -d /home/vagrant -c "Vagrant User"'
/bin/sh -c 'echo "vagrant" | pw usermod root'
/bin/sh -c 'chown 1001:1001 /home/vagrant'

date > /etc/vagrant_box_build_time

# allow freebsd-update to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update > /tmp/freebsd-update
chmod +x /tmp/freebsd-update

# update FreeBSD
env PAGER=/bin/cat /tmp/freebsd-update fetch
env PAGER=/bin/cat /tmp/freebsd-update install

# allow portsnap to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/portsnap > /tmp/portsnap
chmod +x /tmp/portsnap

# change the vagrant users shell to bash
chsh -s bash vagrant

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
fetch -am -o authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# As sharedfolders are not in defaults ports tree
# We will use vagrant via NFS
# Enable NFS
echo 'rpcbind_enable="YES"' >> /etc/rc.conf
echo 'nfs_server_enable="YES"' >> /etc/rc.conf
echo 'mountd_flags="-r"' >> /etc/rc.conf

# Enable passwordless sudo
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers
# Restore correct su permissions
# I'll leave that up to the reader :)

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
WITHOUT_X11="YES"
EOT

echo 'vboxdrv_load="YES"' >> /boot/loader.conf
echo 'vboxnet_enable="YES"' >> /etc/rc.conf
echo 'vboxguest_enable="YES"' >> /etc/rc.conf
echo 'vboxservice_enable="YES"' >> /etc/rc.conf

cat >> /boot/loader.conf << EOT
virtio_load="YES"
virtio_pci_load="YES"
virtio_blk_load="YES"
if_vtnet_load="YES"
virtio_balloon_load="YES"
EOT

# sed -i.bak -Ee 's|/dev/ada?|/dev/vtbd|' /etc/fstab
echo 'ifconfig_vtnet0_name="em0"' >> /etc/rc.conf
echo 'ifconfig_vtnet1_name="em1"' >> /etc/rc.conf
echo 'ifconfig_vtnet2_name="em2"' >> /etc/rc.conf
echo 'ifconfig_vtnet3_name="em3"' >> /etc/rc.conf

pw groupadd vboxusers
pw groupmod vboxusers -m vagrant

#Set the package site to something sane
echo "export PACKAGESITE=http://ftp.freebsd.org/pub/FreeBSD/ports/amd64/packages-9-stable/Latest/" >> /etc/profile

echo "=============================================================================="
echo "NOTE: FreeBSD - Vagrant"
echo "When using this basebox you need to do some special stuff in your Vagrantfile"
echo "1) Enable HostOnly network"
echo "	 config.vm.network ...."
echo "2) Use nfs instead of shared folders"
echo '		config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)'
echo "============================================================================="

exit
