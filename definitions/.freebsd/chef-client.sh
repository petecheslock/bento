#!/bin/sh -x

INSTALLER=chef-client-install.sh
CHEF_URL=http://dyn-vm.s3.amazonaws.com/chef/install.sh
#make sure /bin/bash exists for chef install
ln -s /usr/local/bin/bash /bin/bash

fetch -o /tmp/${INSTALLER} ${CHEF_URL} && chmod +x /tmp/${INSTALLER} && /tmp/${INSTALLER}
