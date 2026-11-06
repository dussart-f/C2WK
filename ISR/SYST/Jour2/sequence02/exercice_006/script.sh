#!/bin/bash

DOVECOT_CONF_DIR="/etc/dovecot/conf.d"
QUOTA_CONF="$DOVECOT_CONF_DIR/90-quota.conf"
MAIL_CONF="$DOVECOT_CONF_DIR/10-mail.conf"


#configure pliugin quota
cat << 'EOF' > "$QUOTA_CONF"
plugin {
  # Définition de la règle de quota : ici une limite stricte de 10 Mo (très bas pour faciliter le test)
  quota = maildir:User quota:storage=10M

  quota_rule = *:storage=10M
  
  # Avertissement dans les logs lorsque l'utilisateur atteint 85% de sa capacité
  quota_warning = storage=85% duress 85
}
EOF


# 2. Ajout du plugin quota a la config
if grep -q "^mail_plugins =" "$MAIL_CONF"; then
  if ! grep -q "quota" "$MAIL_CONF"; then
    sed -i 's/^mail_plugins =.*/mail_plugins = $mail_plugins quota/' "$MAIL_CONF"
  fi
else
  # Si la ligne est commentée ou absente, on l'ajoute/l'active
  if grep -q "^#mail_plugins =" "$MAIL_CONF"; then
    sed -i 's/^#\?mail_plugins =.*/mail_plugins = quota/' "$MAIL_CONF"
  else
    echo "mail_plugins = quota" >> "$MAIL_CONF"
  fi
fi

# 3. Activation du dict-quota 
if ! grep -q "imap_quota" "$MAIL_CONF" && grep -q "mail_plugins" "$MAIL_CONF"; then
  sed -i 's/mail_plugins = \(.*\)/mail_plugins = \1 imap_quota/' "$MAIL_CONF"
fi

systemctl restart dovecot