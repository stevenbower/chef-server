# chef-server

chef-server is running Chef server 11.1.6-1_amd64 on an Ubuntu Trusty 14.04 LTS

This is a fork of: [c-buisson/chef-server](https://github.com/c-buisson/chef-server) but I took run_chef_server.sh from [tmc/dockerfiles](https://github.com/tmc/dockerfiles/tree/master/chef-server).

## Usage
```
$ docker run --privileged --name chef_server -d -p 443:443 xmik/chef_server:0.0.1
```


