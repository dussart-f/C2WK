#!/bin/bash

apt update
apt install apache2

DOMAIN_NAME="monsite.local"
WEB_DIR="/var/www/html/monsite"

mkdir -p "$WEB_DIR"

cat <<EOF > "$WEB_DIR/index.html"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Bienvenue sur $DOMAIN_NAME</title>
</head>
<body>
    <h1>Fonctionne ! Le Virtual Host pour $DOMAIN_NAME est actif.</h1>
</body>
</html>
EOF

chown -R www-data:www-data "$WEB_DIR"
chmod -R 755 "$WEB_DIR"

VHOST_CONF="/etc/apache2/sites-available/$DOMAIN_NAME.conf"

cat <<EOF > "$VHOST_CONF"
<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    ServerAlias www.$DOMAIN_NAME
    DocumentRoot $WEB_DIR

    <Directory $WEB_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN_NAME-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN_NAME-access.log combined
</VirtualHost>
EOF

a2ensite "$DOMAIN_NAME.conf"

systemctl restart apache2

systemctl start apache2