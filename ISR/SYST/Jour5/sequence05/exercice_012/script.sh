#!/bin/bash

DOMAIN="wiki.etna.nx"
WEB_DIR="/var/www/$DOMAIN"
SSL_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"
CONF_FILE="/etc/apache2/sites-available/${DOMAIN}-ssl.conf"
HTTP_CONF="/etc/apache2/sites-available/${DOMAIN}.conf"

DB_NAME="mediawiki_db"
DB_USER="mediawiki_user"
DB_PASS="MediaWikiSecurePass2026!"

# Mise à jour et installation de LAMP et de MediaWiki
apt-get update
apt-get install -y apache2 mariadb-server php libapache2-mod-php \
    php-mysql php-xml php-mbstring php-intl php-gd mediawiki

# Configuration de la base de données MariaDB
mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Préparation du répertoire Web
mkdir -p "$WEB_DIR"
# Création d'un lien symbolique vers les fichiers du paquet mediawiki
if [ -d "/var/lib/mediawiki" ]; then
    rm -rf "$WEB_DIR"/*
    ln -s /var/lib/mediawiki/* "$WEB_DIR/"
fi

chown -R www-data:www-data "$WEB_DIR"
chmod -R 755 "$WEB_DIR"

# Génération d'un certificat SSL auto-signé
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$KEY_DIR/${DOMAIN}.key" \
  -out "$SSL_DIR/${DOMAIN}.crt" \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=ETNA/CN=$DOMAIN"

chmod 600 "$KEY_DIR/${DOMAIN}.key"
chmod 644 "$SSL_DIR/${DOMAIN}.crt"

# Activation des modules Apache nécessaires
a2enmod ssl rewrite

# Création du Virtual Host HTTPS
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

# Création du Virtual Host HTTP pour redirection vers HTTPS
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

# Vérification de la configuration et rechargement d'Apache
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Redémarrage d'Apache2..."
    systemctl restart apache2
    echo "[===] MediaWiki configuré avec succès !"
    echo "[*] Rendez-vous sur https://$DOMAIN pour finaliser l'installation Web (création du compte admin et connexion à la base de données)."
    echo "[*] Identifiants de la base de données à renseigner lors de l'assistant Web :"
    echo "    - Base de données : $DB_NAME"
    echo "    - Utilisateur : $DB_USER"
    echo "    - Mot de passe : $DB_PASS"
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi