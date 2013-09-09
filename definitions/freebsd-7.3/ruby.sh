#!/usr/local/bin/bash -ux
# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
RUBY_VERSION=1.9.3
RUBY_DEFAULT_VER=1.9
EOT

cd /usr/ports/textproc/libyaml
make install -DBATCH

#Install Ruby 1.9
cd /usr/ports/lang/ruby19
make install -DBATCH

#Install rubygems
cd /usr/ports/devel/ruby-gems
make install -DBATCH

#Need ruby iconv in order for chef to run
cd /usr/ports/converters/ruby-iconv
make install -DBATCH
