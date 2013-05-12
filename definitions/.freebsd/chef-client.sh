#!/usr/local/bin/bash -ux

#INSTALLER=chef-client-install.sh
#CHEF_URL=http://dyn-vm.s3.amazonaws.com/chef/install.sh
#make sure /bin/bash exists for chef install
#ln -s /usr/local/bin/bash /bin/bash

#fetch -o /tmp/${INSTALLER} ${CHEF_URL} && chmod +x /tmp/${INSTALLER} && /tmp/${INSTALLER}

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
RUBY_VERSION=1.9.3
RUBY_DEFAULT_VER=1.9
EOT

#Off to rubygems to get first ruby running
cd /usr/ports/devel/ruby-gems
make install -DBATCH

#Need ruby iconv in order for chef to run
cd /usr/ports/converters/ruby-iconv
make install -DBATCH

/usr/local/bin/gem install chef --no-ri --no-rdoc
