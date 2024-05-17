Installing Lupa on Ubuntu 24.04 LTS
-----------------------------------


apt install ruby-full
apt install nginx
apt install python3-certbot-nginx

apt install postgresql

apt install ubuntu-dev-tools
apt install libpq-dev
apt install libyaml-dev

bundle install

chown -R :www-data /var/www
chmod g+s /var/www

adduser --system --shell /usr/sbin/nologin -g www-data rails
