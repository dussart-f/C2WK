#!/bin/bash

DOMAIN="site1.etna.nx"
WEB_DIR="/var/www/$DOMAIN"
CERT_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"
CERT_FILE="$CERT_DIR/${DOMAIN}.crt"
KEY_FILE="$KEY_DIR/${DOMAIN}.key"
CONF_FILE="/etc/apache2/sites-available/${DOMAIN}-ssl.conf"


# Activation du module SSL d'Apache2
a2enmod ssl

# Génération d'un certificat auto-signé avec OpenSSL (valide 365 jours)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=ETNA/CN=$DOMAIN"

# Sécurisation des permissions de la clé privée
chmod 600 "$KEY_FILE"

# Création du fichier de configuration du Virtual Host HTTPS (port 443)
cat <<EOF > "$CONF_FILE"
<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot $WEB_DIR

    SSLEngine on
    SSLCertificateFile $CERT_FILE
    SSLCertificateKeyFile $KEY_FILE

    <Directory $WEB_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_ssl_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_ssl_access.log combined
</VirtualHost>
EOF

# Activation du Virtual Host avec a2ensite
a2ensite "${DOMAIN}-ssl.conf"

# Vérification de la syntaxe et rechargement
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Rechargement d'Apache2..."
    systemctl reload apache2
    echo "HTTPS activé avec succès pour $DOMAIN !"
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi