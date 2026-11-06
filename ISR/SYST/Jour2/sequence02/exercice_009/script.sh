#!/bin/bash

POSTFIX_MAIN="/etc/postfix/main.cf"
POSTGREY_DEFAULT="/etc/default/postgrey"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y postgrey

# Ajuster les délais de greylisting 
if [ -f "$POSTGREY_DEFAULT" ]; then
  # Postgrey écoute le socket local
  if grep -q "^POSTGREY_OPTS=" "$POSTGREY_DEFAULT"; then
    sed -i 's|^POSTGREY_OPTS=.*|POSTGREY_OPTS="--inet=10023 --delay=300"|' "$POSTGREY_DEFAULT"
  else
    echo 'POSTGREY_OPTS="--inet=10023 --delay=300"' >> "$POSTGREY_DEFAULT"
  fi
fi

systemctl restart postgrey

# Récupérer les restrictions de destinataires actuelles ou ajouter postgrey dans smtpd_recipient_restrictions
CURRENT_RESTRICTIONS=$(postconf -h smtpd_recipient_restrictions)


# On ajoute le contrôle de politique de greylisting avant les refus définitifs
NEW_RESTRICTIONS=$(echo "$CURRENT_RESTRICTIONS" | sed 's/reject_unauth_destination/check_policy_service inet:127.0.0.1:10023, reject_unauth_destination/')

if [ "$NEW_RESTRICTIONS" = "$CURRENT_RESTRICTIONS" ]; then
# Si la substitution n'a pas fonctionné, on l'ajoute proprement à la fin des restrictions autorisées
postconf -e "smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, check_policy_service inet:127.0.0.1:10023, reject_unauth_destination"
else
postconf -e "smtpd_recipient_restrictions = $NEW_RESTRICTIONS"
fi


systemctl restart postfix