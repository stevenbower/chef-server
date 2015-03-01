#!/bin/bash

apt-get update 
DEBIAN_FRONTEND=noninteractive apt-get install -y nano wget # https://github.com/docker/docker/issues/4032

# choose from: https://www.chef.io/download-open-source-chef-server-11/
# latest: www.opscode.com/chef/download-server?p=ubuntu&pv=12.04&m=x86_64&v=latest&prerelease=false&nightlies=false
# latest on 01 March 2015: https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.1.6-1_amd64.deb, it installs gem chef 11.12.2
cd /tmp && wget --content-disposition "http://www.opscode.com/chef/download-server?p=ubuntu&pv=12.04&m=x86_64&v=latest&prerelease=false&nightlies=false"
dpkg -i /tmp/chef-server*.deb