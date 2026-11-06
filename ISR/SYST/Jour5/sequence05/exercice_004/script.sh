#!/bin/bash

DOMAIN="site1.etna.nx"
HTTP_CONF="/etc/apache2/sites-available/${DOMAIN}.conf"

echo "Début de la configuration de la redirection HTTP vers HTTPS pour $DOMAIN..."

# Activation du module rewrite d'Apache2 (nécessaire pour mod_rewrite)

a2enmod rewrite

# Mise à jour du Virtual Host HTTP (Port 80) pour forcer la redirection
cat <<EOF > "$HTTP_CONF"
<VirtualHost *:80>
    ServerName $DOMAIN

    # Utilisation de mod_rewrite pour rediriger tout le trafic HTTP vers HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)\$ https://%{HTTP_HOST}\$1 [R=301,L]

    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_redirect_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_redirect_access.log combined
</VirtualHost>
EOF


# S'assurer que le Virtual Host HTTP est bien activé
a2ensite "${DOMAIN}.conf"

# Vérification de la syntaxe et rechargement d'Apache
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Rechargement d'Apache2..."
    systemctl reload apache2
    echo "Redirection HTTP -> HTTPS configurée et activée avec succès pour $DOMAIN !"
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi