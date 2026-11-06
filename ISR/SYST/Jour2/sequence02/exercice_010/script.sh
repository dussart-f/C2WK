#!/bin/bash


POSTFIX_MASTER="/etc/postfix/master.cf"
POSTFIX_MAIN="/etc/postfix/main.cf"


export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y clamav clamav-daemon clamav-freshclam libnet-ldap-perl amavisd-new


systemctl stop clamav-freshclam
# Mise à jour manuelle des bases de virus (si possible)
freshclam --quiet || true

# Démarrage et activation des services ClamAV
systemctl start clamav-freshclam
systemctl start clamav-daemon
systemctl enable clamav-daemon


cat << 'EOF' >> "$POSTFIX_MASTER"

# --- Intégration de ClamAV pour Postfix ---
clamav unix - n n - - pipe
  flags=Rq user=clamav argv=/usr/bin/clamdscan --no-summary -i -
EOF

mkdir -p /etc/amavis/conf.d/
cat << 'EOF' > "$AMAVIS_CONF"
use strict;

@bypass_spam_checks_maps = (
   \%bypass_spam_checks, \@bypass_spam_checks_acl, \$bypass_spam_checks_re);

@bypass_virus_checks_maps = (
   \%bypass_virus_checks, \@bypass_virus_checks_acl, \$bypass_virus_checks_re);

1;
EOF

# S'assurer que l'utilisateur clamav peut être lu par amavis (ajout au groupe clamav)
usermod -aG clamav amavis
usermod -aG amavis clamav

postconf -u content_filter 2>/dev/null || true

# Redirection vers Amavisd sur le port 10024
postconf -e "content_filter = smtp-amavis:[127.0.0.1]:10024"
postconf -e "max_use = 10"

# Ajout du service smtp-amavis et du point de réinjection dans master.cf
if ! grep -q "smtp-amavis" "$POSTFIX_MASTER"; then
  cat << 'EOF' >> "$POSTFIX_MASTER"

# --- Configuration Amavisd ---
smtp-amavis unix - - n - 2 smtp
  -o smtp_data_done_timeout=1200
  -o smtp_send_xforward_command=yes
  -o disable_dns_lookups=yes
  -o max_use=20

127.0.0.1:10025 inet n - n - - smtpd
  -o content_filter=
  -o local_recipient_maps=
  -o relay_recipient_maps=
  -o smtpd_restriction_classes=
  -o smtpd_delay_reject=no
  -o smtpd_client_restrictions=permit_mynetworks,reject
  -o smtpd_helo_restrictions=
  -o smtpd_sender_restrictions=
  -o smtpd_recipient_restrictions=permit_mynetworks,reject
  -o mynetworks_style=host
  -o mynetworks=127.0.0.0/8
  -o strict_rfc821_envelopes=yes
  -o smtpd_error_sleep_time=0
  -o smtpd_soft_error_limit=0
  -o smtpd_hard_error_limit=0
  -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks
EOF
fi

systemctl restart spamassassin
systemctl restart clamav-daemon
systemctl restart amavis
systemctl restart postfix