#!/bin/bash -xe

chef-server-ctl start
tail -F /opt/chef-server/embedded/service/*/log/current
