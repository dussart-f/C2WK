#!/bin/bash

# Installation des outils de surveillance (htop, netstat/ss, procps)
apt-get update
apt-get install -y htop net-tools procps


# Création d'un tableau de bord CLI personnalisé pour Apache
DASHBOARD_SCRIPT="/usr/local/bin/apache-dashboard"

cat << 'EOF' > "$DASHBOARD_SCRIPT"
#!/bin/bash
clear
echo "=========================================================="
echo "          TABLEAU DE BORD DE MONITORING APACHE2           "
echo "=========================================================="
echo ""

echo "État du service Apache2 :"
systemctl is-active apache2 --quiet && echo "    -> Statut : ACTIF (Running)" || echo "    -> STATUT : INACTIF (Stopped)"
echo ""

echo "Consommation globale des processus Apache (www-data) :"
ps -u www-data -o pid,%cpu,%rss,cmd --sort=-%cpu | head -n 10
echo ""

echo "Connexions réseau actives sur le serveur (Ports 80 & 443) :"
netstat -tunlp | grep -E '(:80|:443)'
echo ""

EOF


# Attribution des droits d'exécution au tableau de bord
chmod +x "$DASHBOARD_SCRIPT"

# Pour lancer votre tableau de bord à tout moment en tapant : apache-dashboard
# sinon htop -u www-data pourait être une bonne alternative