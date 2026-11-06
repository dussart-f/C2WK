#!/bin/bash


EXPEDITEUR="Johnny.Silverhand@samurai.secret.btc"
DESTINATAIRE="root@etna.nx"
DOMAIN_HELO="je-le-trouve-beau-mon-domain.local"


(
    sleep 1
    echo "EHLO $DOMAIN_HELO"
    sleep 1
    echo "MAIL FROM:<$EXPEDITEUR>"
    sleep 1
    echo "RCPT TO:<$DESTINATAIRE>"
    sleep 1
    echo "DATA"
    sleep 1

    echo "Subject: ETNA — Il est temps de faire du bruit"
    echo "From: Johnny Silverhand 2077 <$EXPEDITEUR>"
    echo "To: L'administrateur courageux <$DESTINATAIRE>"
    echo "X-Spam-Checker-Score: 999.9 (Totalement legit promis juré craché)"
    echo ""
    echo "Johnny Silverhand à l'appareil."
    echo ""
    echo "On m'a parlé de votre petite institution. Des futurs netrunners, des codeurs en devenir, des cerveaux capables de remodeler le monde à coups de lignes de code."
    echo "Pas mal."
    echo "Mais j'ai une question pour vous : vous formez des gens capables de suivre le système, ou des gens capables de le faire exploser quand il le mérite ?"
    echo ""
    echo "Parce que le monde n'a pas besoin d'un énième développeur qui se contente de corriger des bugs dans une machine qui tourne déjà de travers. Il a besoin de personnes qui osent remettre en question les règles, pirater les conventions et construire quelque chose qui leur ressemble."
    echo "Alors, ETNA, si vous êtes prêts à accueillir une nouvelle génération de rebelles du numérique, faites passer le message."
    echo ""
    echo "Le futur ne se demande pas."
    echo "Il se code."
    echo ""
    echo "Wake the fuck up, samurai."
    echo "Johnny Silverhand"
    echo "Rockeur. Terroriste pour certains. Légende pour les autres."
    echo "."
    sleep 1
    echo "QUIT"
    sleep 1
) | telnet 127.0.0.1 25