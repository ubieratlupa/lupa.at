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

groupadd editors

useradd jakob -g editors -s /usr/sbin/nologin
useradd ortolf -g editors -s /usr/sbin/nologin
useradd friederike -g editors -s /usr/sbin/nologin
useradd paul -g editors -s /usr/sbin/nologin
useradd kerstin -g editors -s /usr/sbin/nologin
useradd tina -g editors -s /usr/sbin/nologin

sudo -u postgres psql
CREATE ROLE editors WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
CREATE USER jakob WITH PASSWORD '' IN ROLE editors;
CREATE USER ortolf WITH PASSWORD '' IN ROLE editors;
CREATE USER friederike WITH PASSWORD '' IN ROLE editors;
CREATE USER paul WITH PASSWORD '' IN ROLE editors;
CREATE USER kerstin WITH PASSWORD '' IN ROLE editors;
CREATE USER tina WITH PASSWORD '' IN ROLE editors;
CREATE ROLE rails WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;
create database lupa_production;
\q

sudo -u postgres psql lupa_production <lupa_production.sql