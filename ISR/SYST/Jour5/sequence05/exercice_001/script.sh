#!/bin/bash


CONFIG_FILE="/etc/apache2/apache2.conf"


# Sauvegarde de la configuration d'origine
BACKUP_FILE="${CONFIG_FILE}.bak_$(date +%F_%T)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Sauvegarde crée : $BACKUP_FILE"

# Fonction pour mettre à jour ou ajouter un paramètre
update_param() {
    local param=$1
    local value=$2
    if grep -qE "^\s*#?\s*${param}\s+" "$CONFIG_FILE"; then
        sed -i -E "s/^\s*#?\s*(${param}\s+).*/\1${value}/" "$CONFIG_FILE"
        echo "[*] Paramètre $param mis à jour à : $value"
    else
        echo "$param $value" >> "$CONFIG_FILE"
        echo "[*] Paramètre $param ajouté avec la valeur : $value"
    fi
}

# Application des valeurs optimisées
update_param "Timeout" "10"
update_param "KeepAlive" "On"
update_param "MaxKeepAliveRequests" "500"
update_param "MaxRequestWorkers" "150"

# Test de la configuration Apache
echo "Vérification de la syntaxe de la configuration..."
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo "Syntaxe valide. Redémarrage d'Apache2..."
    systemctl restart apache2
    echo "Optimisation appliquée avec succès !"
else
    echo "Erreur de syntaxe détectée. Restauration de la configuration d'origine..."
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    exit 1
fi

