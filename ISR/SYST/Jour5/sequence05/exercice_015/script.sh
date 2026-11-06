#!/bin/bash

DOMAIN="gitlab.etna.nx"
CONF_FILE="/etc/nginx/sites-available/$DOMAIN"
SSL_DIR="/etc/nginx/ssl"

BACKEND_URL="http://127.0.0.1:80" 


# Installation de Nginx
apt-get update
apt-get install -y nginx openssl

# Suppression de la configuration par défaut
rm -f /etc/nginx/sites-enabled/default

# Génération d'un certificat SSL auto-signé pour le reverse proxy
mkdir -p "$SSL_DIR"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$SSL_DIR/${DOMAIN}.key" \
  -out "$SSL_DIR/${DOMAIN}.crt" \
  -subj "/C=FR/ST=Ile-de-France/L=Paris/O=ETNA/CN=$DOMAIN"

chmod 600 "$SSL_DIR/${DOMAIN}.key"
chmod 644 "$SSL_DIR/${DOMAIN}.crt"

# Création du fichier de configuration Nginx pour le Reverse Proxy
cat <<EOF > "$CONF_FILE"
# Redirection automatique du trafic HTTP (Port 80) vers HTTPS (Port 443)
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$host\$request_uri;
}

# Configuration du serveur HTTPS (Port 443)
server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate $SSL_DIR/${DOMAIN}.crt;
    ssl_certificate_key $SSL_DIR/${DOMAIN}.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass $BACKEND_URL;
        
        # Transmission des en-têtes d'origine pour que le backend connaisse le client réel
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # Paramètres pour les WebSockets
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Gestion des timeouts pour les gros transferts ou requêtes lentes
        proxy_read_timeout 90s;
    }
}
EOF

# Activation du site via un lien symbolique vers sites-enabled
ln -sf "$CONF_FILE" /etc/nginx/sites-enabled/

# Test de la configuration Nginx et redémarrage du service
nginx -t

if [ $? -eq 0 ]; then
    echo "Configuration valide. Redémarrage de Nginx..."
    systemctl restart nginx
    echo "Nginx configuré avec succès en tant que Reverse Proxy pour $DOMAIN !"
else
    echo "Erreur de syntaxe détectée dans la configuration Nginx."
    exit 1
fi