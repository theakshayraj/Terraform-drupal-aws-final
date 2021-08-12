#!/bin/bash
sudo yum update -y
sudo mkdir -p /usr/share/nginx/html/data

sudo systemctl restart nfs-utils
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "${efs_dns_name}":/  /usr/share/nginx/html/data

sudo echo "'${efs_dns_name}':/ /usr/share/nginx/html/data nfs4 defaults,_netdev 0 0"  | sudo tee /etc/fstab
sudo chmod go+rw /usr/share/nginx/html/data

# Removing Nginx default configuration
sudo rm /etc/nginx/nginx.*

# Setting up Nginx configuration for Drupal
echo "user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events
{
  worker_connections 1024;
}

http
{
  log_format main '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';

  access_log /var/log/nginx/access.log main;

  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 4096;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  # Load modular configuration files from the /etc/nginx/conf.d directory.
  # See http://nginx.org/en/docs/ngx_core_module.html#include
  # for more information.
  include /etc/nginx/conf.d/*.conf;

  server
  {
    listen 80;
    listen [::]:80;
    server_name _;
    root /usr/share/nginx/html/data;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;

    location = /favicon.ico
    {
      log_not_found off;
      access_log off;
    }

    location = /robots.txt
    {
      allow all;
      log_not_found off;
      access_log off;
    }

    location ~ \..*/.*\.php$
    {
      return 403;
    }

    location ~ ^/sites/.*/private/
    {
      return 403;
    }

    location ~ (^|/)\.
    {
      return 403;
    }

    location /
    {
      # This is cool because no php is touched for static content
      try_files '$uri' @rewrite;
    }

    location @rewrite
    {
      # You have 2 options here
      # For D7 and above:
      # Clean URLs are handled in drupal_environment_initialize().
      rewrite ^ /index.php;
      # For Drupal 6 and bwlow:
      # Some modules enforce no slash (/) at the end of the URL
      #rewrite ^/(.*)$ /index.php?q='$1';
    }

    location ~ \.php$
    {
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      include fastcgi_params;
      fastcgi_param SCRIPT_FILENAME '$request_filename';
      fastcgi_intercept_errors on;
      fastcgi_pass unix:/tmp/phpfpm.sock;
    }

    location ~ ^/sites/.*/files/styles/
    {
      try_files '$uri' @rewrite;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$
    {
      expires max;
      log_not_found off;
    }
  }
}" | sudo tee /etc/nginx/nginx.conf

sudo systemctl restart nginx

# Setting up the database
DBNAME="drupal"
host=$(echo "${rds_endpt}" | cut -d':' -f1)
DBEXISTS=$(sudo mysql -h "$host" -u ${master_user} -p${master_pass} --batch --skip-column-names -e "SHOW DATABASES LIKE '"$DBNAME"';" | grep "$DBNAME" > /dev/null; echo "$?")

if [ $DBEXISTS -ne 0 ];then
  sudo mv /usr/share/nginx/html/drupal/* /usr/share/nginx/html/data 
  sudo mysql -h "$host" -P 3306 -u ${master_user} -p${master_pass} -e "CREATE DATABASE IF NOT EXISTS drupal;CREATE USER IF NOT EXISTS '${sql_user}'@'%' IDENTIFIED BY '${sql_pass}'; GRANT ALL  ON drupal.* TO ${sql_user}@'%' WITH GRANT OPTION;FLUSH PRIVILEGES;"
  cd /usr/share/nginx/html/data
  # sudo chmod -R 777 sites/default/files/
  sudo ./vendor/bin/drush site-install standard --db-url=mysql://${sql_user}:${sql_pass}@"$host"/drupal --site-name=Example --account-name=${drupal_user} --account-pass=${drupal_pass} --yes
  sudo chmod 755 sites/ themes/ profiles/ modules/ vendor/ core/
  # sudo ./vendor/bin/drush -y config-set system.performance css.preprocess 0
  # sudo ./vendor/bin/drush -y config-set system.performance js.preprocess 0
  sudo ./composer.phar require 'drupal/prometheus_exporter:1.x-dev@dev' --no-interaction
  sudo sed -i 's/false/true/g' modules/contrib/prometheus_exporter/config/install/prometheus_exporter.settings.yml
  sudo ./vendor/bin/drush en prometheus_exporter -y
  sudo ./vendor/bin/drush en prometheus_exporter_token_access -y

fi

sudo systemctl restart nginx

# sudo yum install -y amazon-cloudwatch-agent
sudo aws s3 cp s3://grafana-files-sg/cw-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo mkdir -p /usr/share/collectd
sudo touch /usr/share/collectd/types.db
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl restart amazon-cloudwatch-agent

sudo touch /home/ec2-user/Completed.txt
