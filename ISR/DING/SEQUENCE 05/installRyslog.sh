sudo apt update
sudo apt install -y rsyslog

sudo bash -c "cat << 'EOF' > /etc/rsyslog.d/40-rsyslog-client.conf
# Redirection de tous les logs locaux vers le serveur centralisé en TCP (ou UDP)
*.* @@192.168.20.100:514

EOF"

sudo systemctl restart rsyslog
sudo systemctl enable rsyslog