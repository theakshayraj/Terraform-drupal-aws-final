#!/bin/bash -e

main() {
  #Installing PHP v7.4 and its dependencies
  sudo yum update -y
  sudo yum install -y git
  #   sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  sudo amazon-linux-extras install epel -y
  sudo yum install -y amazon-linux-extras
  
  sudo amazon-linux-extras enable php7.4
  sudo yum clean metadata
  sudo yum install -y php-cli php-pdo php-fpm php-json php-mysqlnd
  #   sudo yum install -y php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,gettext,bcmath,json,xml,fpm,intl,zip,imap}
  sudo yum install -y php-dom php-gd php-simplexml php-xml php-opcache php-mbstring php-pgsql
  
  php --version

  # Installing MariaDB
  sudo amazon-linux-extras install -y mariadb10.5
  # sudo systemctl enable --now mariadb

  #Installing nginx
  sudo amazon-linux-extras install -y nginx1
  sudo systemctl start nginx
  sudo systemctl status nginx
  sudo systemctl enable nginx

  # Installing Amazon Cloudwatch Agent
  sudo yum install -y amazon-cloudwatch-agent

  # Downloading Drupal package and setting it up
  cd /tmp && wget https://ftp.drupal.org/files/projects/drupal-8.9.17.tar.gz
  pwd
  sudo tar -zxvf *tar*.gz -C /usr/share/nginx/html/ 
  cd /usr/share/nginx/html/
  sudo mv drupal-* drupal
  pwd
  sudo chown -R nginx:nginx /usr/share/nginx/html/
  sudo chmod -R 755 /usr/share/nginx/html/

  # Installing Composer and setting up drush
  cd /usr/share/nginx/html/drupal/
  sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  sudo php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
  sudo php composer-setup.php
  pwd
  sudo ./composer.phar require --dev drush/drush --no-interaction
}

ami(){
        echo $2
}


if [ -z "$1" ]
then
        main
else
        ami
fi

