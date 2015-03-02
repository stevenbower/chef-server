#!/bin/bash

apt-get update 
DEBIAN_FRONTEND=noninteractive apt-get install -y wget  # https://github.com/docker/docker/issues/4032

# choose from: https://www.chef.io/download-open-source-chef-server-11/
# latest: www.opscode.com/chef/download-server?p=ubuntu&pv=12.04&m=x86_64&v=latest&prerelease=false&nightlies=false
#cd /tmp && wget --content-disposition "http://www.opscode.com/chef/download-server?p=ubuntu&pv=12.04&m=x86_64&v=latest&prerelease=false&nightlies=false"
cd /tmp && wget --content-disposition "http://archive.ai-traders.com/lab/1.0/cookbooks/ai_chef_server/files/chef-server_11.1.6-1_amd64.deb"
dpkg -i /tmp/chef-server*.deb

sysctl -w kernel.shmmax=17179869184
/opt/chef-server/embedded/bin/runsvdir-start & 
# maybe '/opt/chef-server/embedded/bin/runsvdir-start &' is the same as 'chef-server-ctl start', but 'docker build' fails with 'chef-server-ctl start'
# configure now as much as possible
chef-server-ctl reconfigure

LOG_FILE="/var/log/chef_first_run.log"
touch $LOG_FILE
chef-server-ctl status >> $LOG_FILE
chef-server-ctl stop

mv /scripts/run_chef_server.sh /usr/bin/run_chef_server.sh
chmod 755 /usr/bin/run_chef_server.sh