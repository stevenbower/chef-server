#!/bin/bash -xe

sysctl -w kernel.shmmax=17179869184
hostname=`hostname`

mkdir -p /var/opt/chef-server/nginx/etc/
mkdir -p /etc/chef-server/

if [ -z "$CHEF_PORT"  ]; then 
    # set default
    CHEF_PORT="443"
fi

cat > /var/opt/chef-server/nginx/etc/chef_https_lb.conf << EOL
server {
  listen $CHEF_PORT;
  server_name $hostname;
  access_log /var/log/chef-server/nginx/access.log opscode;

  ssl on;
  ssl_certificate /var/opt/chef-server/nginx/ca/${hostname}.crt;
  ssl_certificate_key /var/opt/chef-server/nginx/ca/${hostname}.key;

  ssl_session_timeout 5m;

  ssl_protocols SSLv3 TLSv1;
  ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA;
  ssl_prefer_server_ciphers on;

  root /var/opt/chef-server/nginx/html;

  client_max_body_size 250m;

  proxy_set_header Host \$host:\$server_port;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto https;
  proxy_pass_request_headers on;
  proxy_connect_timeout   1;
  proxy_send_timeout      300;
  proxy_read_timeout      300;

  error_page 404 =404 /404.html;
  error_page 503 =503 /503.json;

  location /nginx_status {
    stub_status on;
    access_log   off;
    allow 127.0.0.1;
    deny all;
    }

  # added after chef server installation, to make keys
  # available through curl -Ok https://IP:CHEF_PORT/knife_admin_key.tar.gz
  location /knife_admin_key.tar.gz {
    default_type application/zip;
    alias /etc/chef-server/knife_admin_key.tar.gz;
  }

  location /version {
    types { }
    default_type text/plain;
    alias /opt/chef-server/version-manifest.txt;
  }

  location /docs {
    index index.html ;
    alias /opt/chef-server/docs;
  }

  # bookshelf
  location ~ "/bookshelf/{0,1}.*$" {
    proxy_pass http://bookshelf;
  }

  location ~ "^/(?:stylesheets|javascripts|images|facebox|css|favicon|robots|humans)/{0,1}.*$" {
    if (\$http_x_chef_version ~* "^(\d+\.\d+?)\..+$") {
      error_page 400 =400 /400-chef_client_manage.json;
      return 400;
    }
    proxy_pass http://chef_server_webui;
    proxy_pass_request_headers off;
    proxy_cache webui-cache;
    proxy_cache_valid 200 302 300m;
    proxy_cache_valid 404 1m;
  }

 location = /_status {
    proxy_pass http://erchef/_status;
  }

 location = /_status/ {
    proxy_pass http://erchef/_status;
  }

  location / {
    set \$my_upstream erchef;
    if (\$http_x_ops_userid = "") {
      set \$my_upstream chef_server_webui;
    }
    proxy_redirect http://\$my_upstream /;
    proxy_pass http://\$my_upstream;
  }
}
EOL
cat > /etc/chef-server/chef-server.rb << EOL
nginx['ssl_port'] = $CHEF_PORT
EOL

chef-server-ctl reconfigure
# is not the next command involved in the previous one?
chef-server-ctl restart nginx 

LOG_FILE="/var/log/chef_first_run.log"
touch $LOG_FILE
chef-server-ctl status >> $LOG_FILE
