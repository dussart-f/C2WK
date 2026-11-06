#!/bin/bash


TARGET_USER="jdoe"
# Définition des limites (en blocs de 1 Ko) :
# Soft limit = 50 Mo (50000 Ko) -> Avertissement
# Hard limit = 100 Mo (100000 Ko) -> Blocage strict
SOFT_LIMIT=50000
HARD_LIMIT=100000

apt-get update -y
apt-get install -y quota


# Identification du point de montage contenant /home (ou /srv/samba)
MOUNT_POINT=$(df /home | awk 'NR==2 {print $6}')
echo "[INFO] Point de montage cible détecté : $MOUNT_POINT"

# Vérification si les quotas sont activés dans /etc/fstab pour ce point de montage
if ! grep -q "$MOUNT_POINT.*quota" /etc/fstab; then
  echo "[AVERTISSEMENT] Les options de quota ne sont peut-être pas activées dans /etc/fstab pour $MOUNT_POINT."
  echo "[INFO] Veuillez vous assurer que les options 'usrquota' (ou 'uquota') sont présentes dans /etc/fstab."
fi

# Remontage du système de fichiers pour prendre en compte les quotas (si nécessaire)
mount -o remount,usrquota "$MOUNT_POINT" 2>/dev/null

# Génération des fichiers de base de données des quotas (aquota.user / aquota.group)
quotacheck -cum "$MOUNT_POINT"
echo "[INFO] Fichiers de quotas initialisés."

# Activation des quotas
quotaon -av
echo "[INFO] Quotas activés avec succès."


if id "$TARGET_USER" &>/dev/null; then
  # Application des quotas : setquota -u <user> <soft_block> <hard_block> <soft_inode> <hard_inode> <filesystem>
  setquota -u "$TARGET_USER" "$SOFT_LIMIT" "$HARD_LIMIT" 0 0 "$MOUNT_POINT"
  echo "[SUCCÈS] Quotas définis pour $TARGET_USER : Soft=${SOFT_LIMIT}Ko, Hard=${HARD_LIMIT}Ko."
else
  echo "[ERREUR] L'utilisateur '$TARGET_USER' n'existe pas sur la machine." >&2
  exit 1
fi
