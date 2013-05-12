#!/usr/local/bin/bash -ux

# allow freebsd-update to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update > /tmp/freebsd-update
chmod +x /tmp/freebsd-update

# update FreeBSD
PAGER=/bin/cat /tmp/freebsd-update fetch
PAGER=/bin/cat /tmp/freebsd-update install

# allow portsnap to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/portsnap > /tmp/portsnap
chmod +x /tmp/portsnap

# reduce the ports we extract to a minimum
cat >> /etc/portsnap.conf << EOT
REFUSE accessibility arabic archivers astro audio benchmarks biology cad
REFUSE chinese comms databases deskutils distfiles dns editors finance french
REFUSE games german graphics hebrew hungarian irc japanese java korean
REFUSE mail math multimedia net net-im net-mgmt net-p2p news packages palm
REFUSE polish ports-mgmt portuguese print russian science sysutils ukrainian
REFUSE vietnamese www x11 x11-clocks x11-drivers x11-fm x11-fonts x11-servers
REFUSE x11-themes x11-toolkits x11-wm
EOT

# get new ports
/tmp/portsnap fetch extract

# build packages for sudo and bash
pkg_delete -af
cd /usr/ports/security/sudo
make -DBATCH package-recursive clean
cd /usr/ports/shells/bash-static
make -DBATCH package clean
cd /usr/ports/ftp/curl
make -DBATCH package clean

# change the vagrant users shell to bash
chsh -s bash vagrant

# Set the package site to something sane
MAJOR_VER=$(uname -r | sed -E 's/^([0-9]+)\..*$/\1/')
ARCH=$(uname -p)
#sed -i '' -E "s%^([^#].*):setenv=%\1:setenv=PACKAGESITE=ftp\\\c//ftp.freebsd.org/pub/FreeBSD/ports/${ARCH}/packages-${MAJOR_VER}-stable/Latest/,%" /etc/login.conf
#cap_mkdb /etc/login.conf
echo "export PACKAGESITE=http://ftp.freebsd.org/pub/FreeBSD/ports/${ARCH}/packages-${MAJOR_VER}-stable/Latest/" >> /etc/profile
echo "setenv PACKAGESITE http://ftp.freebsd.org/pub/FreeBSD/ports/${ARCH}/packages-${MAJOR_VER}-stable/Latest/" >> /etc/csh.cshrc
