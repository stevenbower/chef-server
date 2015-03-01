#!/bin/bash -xe

sysctl -w kernel.shmmax=17179869184 # for postgres
chef-server-ctl start

if [ x"$(hostname)" != x"$(grep server_name /etc/chef-server/chef-server-running.json | sed 's/.*\"\(.*\)\".*\"\(.*\)\".*/\2/')" ]; then
    echo "Hostname changed, chef-server must be reconfigured"
    chef-server-ctl reconfigure
fi

tail -F /opt/chef-server/embedded/service/*/log/current
