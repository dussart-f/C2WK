#!/bin/bash

WEB_DIR="/var/www/blog.etna.nx"
PLUGIN_SLUG="wordfence"

# Vérification de la présence de wp-cli
if ! command -v wp &> /dev/null; then
    echo "Erreur : WP-CLI n'est pas installé. Veuillez l'installer avant d'exécuter ce script." >&2
    exit 1
fi

# Se placer dans le répertoire racine de WordPress
cd "$WEB_DIR" || { echo "[-] Erreur : Le répertoire $WEB_DIR est introuvable." >&2; exit 1; }

# Installation et activation du plugin de sécurité (Wordfence)
wp plugin install "$PLUGIN_SLUG" --activate --allow-root


# Configuration des options de sécurité de base via WP-CLI)
wp option update wf_enable_live_traffic "off" --allow-root
wp option update wordfence_alert_email "admin@blog.etna.nx" --allow-root

# Durcissement des permissions système 
# Protéger le fichier de configuration contre l'écriture
if [ -f "wp-config.php" ]; then
    chmod 440 wp-config.php
fi

# Sécuriser les dossiers d'uploads et interdire l'exécution de scripts si nécessaire
chown -R www-data:www-data "$WEB_DIR"

echo "Vous pouvez vous connecter à l'interface d'administration pour finaliser les réglages spécifiques de Wordfence."