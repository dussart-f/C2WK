#!/bin/bash


# Liste des domaines concernés
DOMAINS=("site1.etna.nx" "site2.etna.nx" "site3.etna.nx")

for DOMAIN in "${DOMAINS[@]}"; do
    CONF_FILE="/etc/apache2/sites-available/${DOMAIN}.conf"
    WEB_DIR="/var/www/$DOMAIN"

    echo "Traitement pour : $DOMAIN"

    # Génération du Virtual Host intégrant les directives de logs
    cat <<EOF > "$CONF_FILE"
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot $WEB_DIR

    # Définition d'un format de log personnalisé (LogFormat)
    # Format de journal NCSA étandu/combiné modifié
    LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" custom_combined

    # Configuration des logs d'erreurs et d'accès séparés
    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_access.log custom_combined

    <Directory $WEB_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
    echo "    -> Fichier $CONF_FILE mis à jour avec les logs séparés."
done

# Vérification de la syntaxe de configuration Apache
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Rechargement d'Apache2..."
    systemctl reload apache2
    echo "Configuration des logs appliquée avec succès pour tous les sites !"
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi