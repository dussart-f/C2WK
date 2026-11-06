#!/bin/bash

DOMAIN="site1.etna.nx"
WEB_DIR="/var/www/$DOMAIN"
CONF_FILE="/etc/apache2/sites-available/${DOMAIN}.conf"


# Création du répertoire web et de la page HTML
mkdir -p "$WEB_DIR"
cat <<EOF > "$WEB_DIR/index.html"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Bienvenue sur $DOMAIN</title>
</head>
<body>
    <h1>Succès ! Le Virtual Host pour $DOMAIN fonctionne parfaitement.</h1>
    <p>Ce fichier est servi depuis le répertoire $WEB_DIR.</p>
</body>
</html>
EOF

# Attribution des permissions appropriées
chown -R www-data:www-data "$WEB_DIR"
chmod -R 755 "$WEB_DIR"

# Création du fichier de configuration du Virtual Host
cat <<EOF > "$CONF_FILE"
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $WEB_DIR

    <Directory $WEB_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_access.log combined
</VirtualHost>
EOF

#Activation du site avec a2ensite
a2ensite "${DOMAIN}.conf"

# Vérification de la syntaxe avec apache2ctl
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Rechargement d'Apache2..."
    systemctl reload apache2
    echo "[===] Virtual Host $DOMAIN configuré et activé avec succès !"
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi