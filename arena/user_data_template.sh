#!/bin/bash
# user_data_template.sh
# O script de deploy injeta o IP do banco aqui automaticamente.
DB_HOST="PLACEHOLDER_DB_IP" 
LB_DNS="PLACEHOLDER_LB_DNS"

echo "--- Setup Application Server ---"
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd git

# --- AREA DE OTIMIZACAO (TUNING BALANCEADO PARA LB) ---
# Aumentamos para 150 para garantir que não faltem vagas
echo "ServerLimit 150" >> /etc/httpd/conf/httpd.conf
echo "MaxRequestWorkers 150" >> /etc/httpd/conf/httpd.conf

# KeepAlive de 5s: Fundamental para o Load Balancer não ter que 
# reconectar a cada requisição, o que diminui a latência.
echo "KeepAlive On" >> /etc/httpd/conf/httpd.conf
echo "KeepAliveTimeout 5" >> /etc/httpd/conf/httpd.conf
# ------------------------------------------------------

systemctl start httpd
systemctl enable httpd
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html
wp core download --allow-root

# Configuração do Banco de Dados
wp config create --dbname=wordpress --dbuser=wp_user --dbpass=wp_pass --dbhost=$DB_HOST --allow-root

# --- CORREÇÃO DO ERRO 404 (Permalinks) ---
wp rewrite structure '/%postname%/' --hard --allow-root || true
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
# -----------------------------------------

# Ajuste final de URLs para o Load Balancer
if [ "$LB_DNS" != "PLACEHOLDER_LB_DNS" ]; then
    wp option update home "http://$LB_DNS" --allow-root
    wp option update siteurl "http://$LB_DNS" --allow-root
fi

chown -R apache:apache /var/www/html
systemctl restart httpd