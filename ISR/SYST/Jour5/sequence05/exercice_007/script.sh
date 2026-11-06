#!/bin/bash

DOMAIN="site1.etna.nx"
WEB_DIR="/var/www/$DOMAIN"
CONF_FILE="/etc/apache2/sites-available/${DOMAIN}.conf"

echo "Début de la configuration de la page 404 personnalisée pour $DOMAIN..."

# Création du fichier de la page 404 personnalisée
cat <<EOF > "$WEB_DIR/404.html"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Erreur 404 - Page non trouvée</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background-color: #f8f9fa; color: #333; }
        h1 { color: #dc3545; font-size: 50px; }
        p { font-size: 18px; }
        a { color: #007bff; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Oups ! Erreur 404</h1>
    <p>La page que vous recherchez sur <strong>$DOMAIN</strong> est introuvable.</p>
    <p><a href="/">Retourner à l'accueil</a></p>
</body>
</html>
EOF

# Attribution des bonnes permissions
chown www-data:www-data "$WEB_DIR/404.html"
chmod 644 "$WEB_DIR/404.html"

# Mise à jour de la configuration du Virtual Host pour intégrer ErrorDocument
# Si la directive ErrorDocument n'est pas déjà présente, on l'ajoute dans le bloc VirtualHost
if ! grep -q "ErrorDocument 404" "$CONF_FILE"; then
    # Insérer ErrorDocument juste avant la fin du bloc VirtualHost
    sed -i '/<\/VirtualHost>/i \    ErrorDocument 404 /404.html' "$CONF_FILE"
    echo "Directive ErrorDocument 404 ajoutée au fichier de configuration."
else
    echo "La directive ErrorDocument 404 est déjà présente dans la configuration."
fi

# Vérification de la syntaxe et rechargement d'Apache
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Rechargement d'Apache2..."
    systemctl reload apache2
    echo "Page d'erreur 404 personnalisée configurée avec succès pour $DOMAIN !"
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi