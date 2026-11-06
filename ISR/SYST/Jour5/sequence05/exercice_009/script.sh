#!/bin/bash

STATUS_CONF="/etc/apache2/mods-available/status.conf"


# Activation du module status
a2enmod status

# Configuration de la page /server-status et activation d'ExtendedStatus
cat <<EOF > "$STATUS_CONF"
<Location /server-status>
    SetHandler server-status
    
    # Active les statistiques détaillées (utilisation CPU, requêtes en cours, etc.)
    ExtendedStatus On

    # Sécurité : Restreindre l'accès au serveur local (localhost)
    Require local
    
    # Pour autoriser un sous-réseau spécifique ou une IP particulière:
    # IP de ma Machine Admin
    Require ip 192.168.1.10/24
</Location>
EOF

# Vérification de la syntaxe et rechargement d'Apache
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Configuration valide. Rechargement d'Apache2..."
    systemctl reload apache2
    echo "mod_status configuré avec succès !"
    echo "Vous pouvez consulter les performances en local via : http://localhost/server-status"
else
    echo "Erreur de syntaxe détectée dans la configuration."
    exit 1
fi