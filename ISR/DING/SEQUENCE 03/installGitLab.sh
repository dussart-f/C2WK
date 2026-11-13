#!/bin/bash

DOMAIN="gitlab.etna.nx"
EXTERNAL_URL="https://$DOMAIN"

echo "Mise à jour du système et installation des dépendances"
sudo apt-get update
sudo apt-get install -y curl ca-certificates perl postfix openssh-server

echo "Ajout du dépôt officiel GitLab"
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

echo "Installation de GitLab CE"
# On définit la variable d'environnement EXTERNAL_URL pour que l'installateur configure automatiquement gitlab.rb
sudo EXTERNAL_URL="$EXTERNAL_URL" apt-get install -y gitlab-ce

echo "Configuration SSL pour le Virtual Host HTTPS"
# Création du dossier pour les certificats SSL (parfait pour un domaine local/interne .nx)
sudo mkdir -p /etc/gitlab/ssl
sudo chmod 700 /etc/gitlab/ssl

# Génération d'un certificat auto-signé
if [ ! -f /etc/gitlab/ssl/${DOMAIN}.crt ]; then
    echo "Génération d'un certificat SSL auto-signé pour ${DOMAIN}..."
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/gitlab/ssl/${DOMAIN}.key \
        -out /etc/gitlab/ssl/${DOMAIN}.crt \
        -subj "/CN=${DOMAIN}"
    
    sudo chmod 600 /etc/gitlab/ssl/${DOMAIN}.key
    sudo chmod 644 /etc/gitlab/ssl/${DOMAIN}.crt
fi

# Configuration des chemins des certificats dans /etc/gitlab/gitlab.rb si ce n'est pas déjà fait
if ! grep -q "nginx['ssl_certificate']" /etc/gitlab/gitlab.rb; then
    sudo bash -c "cat >> /etc/gitlab/gitlab.rb << 'EOF'

# Configuration HTTPS personnalisée
nginx['ssl_certificate'] = \"/etc/gitlab/ssl/${DOMAIN}.crt\"
nginx['ssl_certificate_key'] = \"/etc/gitlab/ssl/${DOMAIN}.key\"
EOF"
fi

echo "Application de la configuration"
sudo gitlab-ctl reconfigure

echo "Installation terminée avec succès !"
echo "Vous pouvez accéder à GitLab sur : $EXTERNAL_URL"
echo "Le mot de passe root initial se trouve dans : /etc/gitlab/initial_root_password"