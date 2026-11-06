#!/bin/bash

mkdir -p /Goinfre
chmod 777 /Goinfre

while IFS=: read -r groupe _ gid _; do

    repertoire="/Goinfre/$groupe"

    mkdir -p "$repertoire"

    chown "root:$groupe" "$repertoire"

    chmod 770 "$repertoire"

    echo "Répertoire créé : $repertoire (propriétaire : root, groupe : $groupe, permissions : 770)"

done < /etc/group
