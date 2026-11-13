#!/bin/bash

# Liste des domaines à sécuriser avec Let's Encrypt (ajustez selon vos besoins)
DOMAINS=("gitlab.etna.nx" "blog.etna.nx")
ADMIN_EMAIL="admin@etna.nx"

echo "Début de l'installation et de la configuration de Let's Encrypt (Certbot)..."

# Installation de Certbot et du plugin Nginx
#apt-get update
#apt-get install -y certbot python3-certbot-nginx

# Boucle pour générer les certificats pour chaque domaine
for DOMAIN in "${DOMAINS[@]}"; do
    echo "[*] Demande d'un certificat Let's Encrypt pour : $DOMAIN"
    
    # L'option --redirect configure automatiquement la redirection HTTP -> HTTPS dans Nginx
    certbot --nginx \
        -d "$DOMAIN" \
        --non-interactive \
        --agree-tos \
        --email "$ADMIN_EMAIL" \
        --redirect
        
    if [ $? -eq 0 ]; then
        echo "Certificat obtenu et configuré avec succès pour $DOMAIN"
    else
        echo "Échec de l'obtention du certificat pour $DOMAIN (assurez-vous que le domaine est accessible et que le DNS pointe correctement)."
    fi
done

# Vérification et test du renouvellement automatique
echo "Vérification du service de renouvellement automatique..."

# Sur les systèmes modernes, Certbot installe un timer systemd ou une tâche cron.
if systemctl list-timers | grep -q certbot; then
    echo "[+] Le timer systemd de Certbot est actif. Les certificats seront renouvelés automatiquement."
else
    # Fallback : Ajout d'une tâche cron explicite si le timer n'est pas détecté
    CRON_JOB="0 3 * * * /usr/bin/certbot renew --quiet && systemctl reload nginx"
    (crontab -l 2>/dev/null | grep -q "certbot renew") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "[+] Tâche cron de renouvellement automatique configurée (tous les jours à 3h du matin)."
fi


echo "Configuration de Let's Encrypt terminée avec succès !"