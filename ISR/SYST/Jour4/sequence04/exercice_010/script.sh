#!/bin/bash


DOSSIER_SORTIE="./rapports_demarrage"
DATE_JOUR=$(date "+%Y-%m-%d")
RAPPORT_FICHIER="$DOSSIER_SORTIE/rapport_demarrage_$DATE_JOUR.txt"

# Création du dossier de destination s'il n'existe pas
mkdir -p "$DOSSIER_SORTIE"


{
    echo "================================================================="
    echo "       RAPPORT D'ANALYSE DES ERREURS DE DÉMARRAGE                "
    echo "       Date d'analyse : $(date)                                  "
    echo "================================================================="
    echo ""

    # Fichiers temporaires pour chaque catégorie
    TEMP_ALL=$(mktemp)
    TEMP_NET=$(mktemp)
    TEMP_DISK=$(mktemp)
    TEMP_KERN=$(mktemp)

    # Récupération de tous les messages d'erreur ou d'alerte du noyau au démarrage
    # On filtre sur les niveaux d'alerte du noyau ou les mots-clés error/fail
    dmesg --level=err,crit,warn -T > "$TEMP_ALL" 2>/dev/null || dmesg > "$TEMP_ALL"

    # Classification : Erreurs Réseau (net, eth, wifi, ip, link)
    grep -i -E "net|eth|wifi|ip|link|dhcp|ipv4|ipv6" "$TEMP_ALL" > "$TEMP_NET"

    # Classification : Erreurs Stockage / Disques (disk, sd, nvme, ext4, btrfs, mount, scsi)
    grep -i -E "disk|sd|nvme|ext4|btrfs|mount|scsi|partition|fs" "$TEMP_ALL" > "$TEMP_DISK"

    # Classification : Erreurs Matériel & Noyau (acpi, cpu, irq, fault, pci, memory, segfault)
    grep -i -E "acpi|cpu|irq|fault|pci|memory|ram|segfault|bios|firmware" "$TEMP_ALL" > "$TEMP_KERN"

    echo "--- [ ERREURS LIÉES AU RÉSEAU ] ---"
    if [ -s "$TEMP_NET" ]; then
        cat "$TEMP_NET"
    else
        echo "Aucune erreur réseau détectée au démarrage."
    fi
    echo ""

    echo "--- [ ERREURS DE STOCKAGE ET SYSTÈMES DE FICHIERS ] ---"
    if [ -s "$TEMP_DISK" ]; then
        cat "$TEMP_DISK"
    else
        echo "Aucune erreur de stockage détectée au démarrage."
    fi
    echo ""

    echo "--- [ ERREURS MATÉRIELLES ET DU NOYAU (ACPI / CPU / PCI) ] ---"
    if [ -s "$TEMP_KERN" ]; then
        cat "$TEMP_KERN"
    else
        echo "Aucune erreur matérielle ou du noyau critique détectée."
    fi
    echo ""

    echo "================================================================="
    echo " Fin du rapport de démarrage."
    echo "================================================================="

    # Nettoyage des fichiers temporaires
    rm -f "$TEMP_ALL" "$TEMP_NET" "$TEMP_DISK" "$TEMP_KERN"

} | tee "$RAPPORT_FICHIER"

echo ""
echo "Rapport de démarrage généré avec succès : $RAPPORT_FICHIER"