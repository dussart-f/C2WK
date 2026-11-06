
#!/bin/bash

FICHIER_CSV="groupes.csv"

if [[ ! -f "$FICHIER_CSV" ]]; then
    echo "Erreur : fichier $FICHIER_CSV introuvable."
    exit 1
fi

tail -n +2 "$FICHIER_CSV" |
while IFS=',' read -r utilisateur groupes; do

    # Vérifier que l'utilisateur existe
    if ! id "$utilisateur" &>/dev/null; then
        echo "Attention : utilisateur $utilisateur inexistant."
        continue
    fi

    # Découper la liste des groupes
    IFS=';' read -ra liste_groupes <<< "$groupes"

    for groupe in "${liste_groupes[@]}"; do

        [[ -z "$groupe" ]] && continue

        # Créer le groupe s'il n'existe pas
        if ! getent group "$groupe" >/dev/null; then
            if groupadd "$groupe"; then
                echo "Groupe créé : $groupe"
            else
                echo "Erreur lors de la création du groupe $groupe"
                continue
            fi
        fi

        # Ajouter l'utilisateur au groupe sans supprimer
        # ses autres appartenances secondaires
        if gpasswd -a "$utilisateur" "$groupe"; then
            echo "$utilisateur ajouté au groupe $groupe"
        else
            echo "Erreur : impossible d'ajouter $utilisateur à $groupe"
        fi

    done

done
