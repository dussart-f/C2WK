#!/bin/bash

DOMAIN="site1.etna.nx"
WEB_DIR="/var/www/$DOMAIN"
SECURE_DIR="$WEB_DIR/admin"
CONF_FILE="/etc/apache2/sites-available/${DOMAIN}.conf"

# Création du répertoire protégé et d'un fichier de test
mkdir -p "$SECURE_DIR"
cat <<EOF > "$SECURE_DIR/index.html"
<!DOCTYPE html>
<html lang="fr">
<head><title>Zone Admin</title></head>
<body><h1>Zone d'administration (Confidentiel)</h1></body>
</html>
EOF


# Création du fichier .htaccess avec les restrictions
cat <<EOF > "$SECURE_DIR/.htaccess"
# Restriction d'accès au répertoire
<IfModule mod_authz_core.c>
    Require all denied
</IfModule>
<IfModule !mod_authz_core.c>
    Order deny,allow
    Deny from all
</IfModule>
EOF


# Attribution des permissions pour www-data
chown -R www-data:www-data "$SECURE_DIR"
chmod 644 "$SECURE_DIR/.htaccess"

# Vérification de la syntaxe et rechargement d'Apache
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Rechargement d'Apache2..."
    systemctl reload apache2
    echo "Accès restreint configuré avec succès ! Le dossier /admin est désormais bloqué."
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi