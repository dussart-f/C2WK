#!/bin/bash

DOMAIN="blog.etna.nx"
WEB_DIR="/var/www/$DOMAIN"
SSL_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"
CONF_FILE="/etc/apache2/sites-available/${DOMAIN}-ssl.conf"
HTTP_CONF="/etc/apache2/sites-available/${DOMAIN}.conf"

DB_NAME="wordpress_db"
DB_USER="wordpress_user"
DB_PASS="WordPressSecurePass2026!"


# Installation de LAMP, curl, wget et unzip
apt-get update
apt-get install -y apache2 mariadb-server php libapache2-mod-php \
    php-mysql php-xml php-mbstring php-curl php-gd wget unzip curl

# Installation de WP-CLI (outil en ligne de commande pour WordPress)
if ! command -v wp &> /dev/null; then
    echo "[+] Installation de WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Configuration de la base de données MySQL / MariaDB
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Téléchargement et installation de WordPress via WP-CLI
mkdir -p "$WEB_DIR"
cd "$WEB_DIR" || exit 1

wp core download --allow-root

# Configuration automatique du fichier wp-config.php
wp config create --dbname="$DB_NAME" --dbuser="$DB_USER" --dbpass="$DB_PASS" --dbhost="localhost" --allow-root

# Attribution des permissions adaptées pour www-data
chown -R www-data:www-data "$WEB_DIR"
find "$WEB_DIR" -type d -exec chmod 755 {} \;
find "$WEB_DIR" -type f -exec chmod 644 {} \;

# Génération d'un certificat SSL auto-signé
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$KEY_DIR/${DOMAIN}.key" \
  -out "$SSL_DIR/${DOMAIN}.crt" \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=ETNA/CN=$DOMAIN"

chmod 600 "$KEY_DIR/${DOMAIN}.key"
chmod 644 "$SSL_DIR/${DOMAIN}.crt"

# Activation des modules Apache nécessaires
a2enmod ssl rewrite

# Création du Virtual Host HTTPS (Port 443)
cat <<EOF > "$CONF_FILE"
<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot $WEB_DIR

    SSLEngine on
    SSLCertificateFile $SSL_DIR/${DOMAIN}.crt
    SSLCertificateKeyFile $KEY_DIR/${DOMAIN}.key

    <Directory $WEB_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_access.log combined
</VirtualHost>
EOF

# Création du Virtual Host HTTP pour redirection vers HTTPS (Port 80)
cat <<EOF > "$HTTP_CONF"
<VirtualHost *:80>
    ServerName $DOMAIN
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)\$ https://%{HTTP_HOST}\$1 [R=301,L]
</VirtualHost>
EOF

# Activation des Virtual Hosts
a2ensite "${DOMAIN}.conf"
a2ensite "${DOMAIN}-ssl.conf"

# Vérification de la syntaxe et rechargement d'Apache
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Redémarrage d'Apache2..."
    systemctl restart apache2
    echo "WordPress configuré et sécurisé avec succès !"
    echo "Rendez-vous sur https://$DOMAIN pour finaliser l'installation graphique (titre du site, compte admin, etc.)."
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi