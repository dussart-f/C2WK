#!/bin/bash


DOSSIER_SORTIE="./rapports_systeme"
DATE_JOUR=$(date "+%Y-%m-%d")
RAPPORT_FICHIER="$DOSSIER_SORTIE/rapport_redemarrages_$DATE_JOUR.txt"

# Création du dossier de destination s'il n'existe pas
mkdir -p "$DOSSIER_SORTIE"


{
    echo "================================================================="
    echo "       RAPPORT DES REDÉMARRAGES DE SERVICES - 24 DERNIÈRES HEURES  "
    echo "       Date d'analyse : $(date)                                  "
    echo "================================================================="
    echo ""

    echo "--- [Services ayant redémarré ou démarré au cours des dernières 24h ] ---"
    echo ""

    # Utilisation de journalctl pour cibler les messages de démarrage/redémarrage de services sur 24h
    # On filtre les unités de type .service et on extrait les noms uniques
    SERVICES_DETECTES=$(journalctl --since "24 hours ago" -u "*.service" --no-pager -o cat | grep -E "Started|Stopping|Restarting" | awk '{print $2}' | grep "\.service" | sort -u)

    if [ -z "$SERVICES_DETECTES" ]; then
        echo "Aucun redémarrage de service majeur détecté sur les dernières 24 heures."
    else
        # Tableau ou boucle pour inspecter chaque service détecté
        for service in $SERVICES_DETECTES; do
            echo "-----------------------------------------------------------------"
            echo " Service concerné : $service"
            echo "-----------------------------------------------------------------"
            
            # Récupération d'informations détaillées via systemctl
            STATUT_ACTUEL=$(systemctl is-active "$service" 2>/dev/null)
            ACTIF_DEPUIS=$(systemctl show "$service" --property=ActiveEnterTimestamp 2>/dev/null | cut -d= -f2)
            DESCRIPTION=$(systemctl show "$service" --property=Description 2>/dev/null | cut -d= -f2)
            PID_PRINCIPAL=$(systemctl show "$service" --property=MainPID 2>/dev/null | cut -d= -f2)

            echo "  - Description   : ${DESCRIPTION:-N/A}"
            echo "  - État actuel   : ${STATUT_ACTUEL:-Inconnu}"
            echo "  - Actif depuis  : ${ACTIF_DEPUIS:-N/A}"
            echo "  - PID principal : ${PID_PRINCIPAL:-N/A}"

            # Nombre d'occurrences de démarrage dans le journal sur les 24h
            NB_DEMARRAGES=$(journalctl --since "24 hours ago" -u "$service" --no-pager | grep -E "Started" | wc -l)
            echo "  - Nb d'activations (24h) : $NB_DEMARRages"
            echo ""
        done
    fi

    echo "================================================================="
    echo " Fin du rapport de redémarrage des services."
    echo "================================================================="

} | tee "$RAPPORT_FICHIER"

echo ""
echo "Rapport généré avec succès : $RAPPORT_FICHIER"