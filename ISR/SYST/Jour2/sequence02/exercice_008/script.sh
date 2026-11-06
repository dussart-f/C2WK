#!/bin/bash

SPAMASSASSIN_DEFAULT="/etc/default/spamassassin"
POSTFIX_MASTER="/etc/postfix/master.cf"
POSTFIX_MAIN="/etc/postfix/main.cf"

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y spamassassin spamc


# Activer le service dans /etc/default/spamassassin
if [ -f "$SPAMASSASSIN_DEFAULT" ]; then
  sed -i 's/^ENABLED=0/ENABLED=1/' "$SPAMASSASSIN_DEFAULT"
  sed -i 's/^#ENABLED=1/ENABLED=1/' "$SPAMASSASSIN_DEFAULT"
  # S'assurer que le démon tourne avec un utilisateur dédié et met à jour les règles
  sed -i 's/^OPTIONS=.*/OPTIONS="--create-prefs --max-children 5 --helper-home-dir /var/lib/spamassassin"/' "$SPAMASSASSIN_DEFAULT"
fi

systemctl restart spamassassin

# 1. Ajout du filtre de contenu (content_filter) dans main.cf si ce n'est pas déjà fait
if ! grep -q "content_filter = spamassassin" "$POSTFIX_MAIN"; then
  postconf -e "content_filter = spamassassin:dummy"
fi

# 2. Ajout du service spamassassin dans master.cf
cat << 'EOF' >> "$POSTFIX_MASTER"

# --- filtre SpamAssassin ---
spamassassin unix - n n - - pipe
  flags=Rq user=debian-spamd argv=/usr/bin/spamc -f -e /usr/sbin/sendmail -oi -f ${sender} ${recipient}
EOF

systemctl restart postfix