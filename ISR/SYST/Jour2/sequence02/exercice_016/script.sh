#!/bin/bash

DOMAIN="etna.nx"
ROUNDCUBE_DIR="/var/www/html/roundcube"
DB_CONFIG="$ROUNDCUBE_DIR/config/config.inc.php"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y apache2 php php-imap php-mbstring php-xml php-mysql php-sqlite3 php-intl php-json php-curl curl unzip


# Téléchargement de l'archive Roundcube (version complete)
ROUNDCUBE_VERSION="1.6.9" # Version stable courante
cd /tmp
wget -q "https://github.com/roundcube/roundcubemail/releases/download/${ROUNDCUBE_VERSION}/roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz"
tar -xzf "roundcubemail-${ROUNDCUBE_VERSION}-complete.tar.gz"
rm -rf "$ROUNDCUBE_DIR"
mv "roundcubemail-${ROUNDCUBE_VERSION}" "$ROUNDCUBE_DIR"


chown -R www-data:www-data "$ROUNDCUBE_DIR"
chmod -R 755 "$ROUNDCUBE_DIR"


# Copie du fichier de configuration par défaut
if [ -f "$ROUNDCUBE_DIR/config/config.inc.php.sample" ] && [ ! -f "$DB_CONFIG" ]; then
  cp "$ROUNDCUBE_DIR/config/config.inc.php.sample" "$DB_CONFIG"
fi

# Configuration automatique des paramètres IMAP (Dovecot) et SMTP (Postfix)
cat << EOF > "$DB_CONFIG"
<?php
$config = array();

/* Base de données (utilisation de SQLite par défaut pour la simplicité, ou MySQL) */
$config['db_dsnw'] = 'sqlite:///' . $ROUNDCUBE_DIR . '/logs/roundcube.sqlite?mode=0646';

/* Nom de l'hôte IMAP (Dovecot en local) */
$config['default_host'] = 'ssl://localhost';
$config['default_port'] = 993;

/* Nom de l'hôte SMTP (Postfix en local) */
$config['smtp_server'] = 'tls://localhost';
$config['smtp_port'] = 587;

/* Authentification automatique avec l'identifiant du mail */
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';

/* Nom du produit affiché sur la page de connexion */
$config['product_name'] = 'Webmail Roundcube - $DOMAIN';

/* Paramètres divers */
$config['temp_dir'] = '$ROUNDCUBE_DIR/temp';
$config['plugins'] = array(
    'archive',
    'zipdownload',
);
$config['language'] = 'fr_FR';
EOF

chown www-data:www-data "$DB_CONFIG"
chmod 640 "$DB_CONFIG"

echo "[+] Étape 5 : Redémarrage d'Apache..."
systemctl restart apache2
