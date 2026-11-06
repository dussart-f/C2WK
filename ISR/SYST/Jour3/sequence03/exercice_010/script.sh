#!/bin/bash


SOURCE_DIR="/srv/samba/"
BACKUP_DIR="/var/backups/samba/$(date +%Y-%m-%d_%H-%M-%S)"
LATEST_LINK="/var/backups/samba/latest"

mkdir -p "$BACKUP_DIR"

# Exécution de Rsync avec les options clés :
# -a (archive) : conserve les permissions, les propriétaires, les groupes, les timestamps
# -v (verbose) : affiche les détails
# --link-dest : permet de faire des sauvegardes incrémentielles/miroirs efficaces basées sur la dernière sauvegarde
RSYNC_OPTS="-aHv --delete"

if [ -d "$LATEST_LINK" ]; then
  rsync $RSYNC_OPTS --link-dest="$LATEST_LINK" "$SOURCE_DIR" "$BACKUP_DIR"
else
  rsync $RSYNC_OPTS "$SOURCE_DIR" "$BACKUP_DIR"
fi

if [ $? -eq 0 ]; then
  echo "[SUCCÈS] Sauvegarde effectuée avec succès dans : $BACKUP_DIR"

  rm -f "$LATEST_LINK"
  ln -s "$BACKUP_DIR" "$LATEST_LINK"
else
  echo "[ERREUR] Échec de la synchronisation Rsync." >&2
  exit 1
fi
