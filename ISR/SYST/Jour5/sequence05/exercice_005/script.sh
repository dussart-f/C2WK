#!/bin/bash

# Liste des sites à configurer
DOMAINS=("site2.etna.nx" "site3.etna.nx")


for DOMAIN in "${DOMAINS[@]}"; do
    WEB_DIR="/var/www/$DOMAIN"
    CONF_FILE="/etc/apache2/sites-available/${DOMAIN}.conf"

    echo ""
    echo "Configuration pour le site : $DOMAIN"

    # Création du répertoire web et de la page HTML distincte
    mkdir -p "$WEB_DIR"
    cat <<EOF > "$WEB_DIR/index.html"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Bienvenue sur $DOMAIN</title>
</head>
<body>
    <h1>Page officielle de $DOMAIN</h1>
    <p>Ce contenu unique est servi depuis le répertoire <strong>$WEB_DIR</strong>.</p>
</body>
</html>
EOF
    echo "    -> Répertoire et fichier index.html créés dans $WEB_DIR"

    # Attribution des permissions pour le serveur web
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
    echo "    -> Fichier de configuration créé dans $CONF_FILE"

    # Activation du site avec a2ensite
    a2ensite "${DOMAIN}.conf"
    echo "    -> Virtual Host activé avec a2ensite."
done

# Vérification de la syntaxe et rechargement global d'Apache
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Rechargement d'Apache2..."
    systemctl reload apache2
    echo "Tous les Virtual Hosts ont été configurés et activés avec succès !"
else
    echo "Erreur de syntaxe détectée dans les configurations."
    exit 1
fi