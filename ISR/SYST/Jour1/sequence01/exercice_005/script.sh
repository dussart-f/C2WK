#!/bin/bash


a2enmod userdir
systemctl restart apache2

{
echo "<IfModule mod_userdir.c>"
echo "    UserDir disabled root"
echo "    UserDir www"
echo ""
echo "    <Directory /home/*/www>"
echo "        AllowOverride None"
echo "        Options -Indexes -ExecCGI -Includes"
echo "        Require method GET HEAD"
echo "    </Directory>"
echo "</IfModule>"
} > "/etc/apache2/mods-available/userdir.conf"

# Parcourir les utilisateurs du système (UID >= 1000, hors nobody)
getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1, $6}' | 
while read -r username userhome;
do
    if [ -d "$userhome" ]; then
        echo "Traitement pour l'utilisateur : $username ($userhome)"
        
        pub_dir="$userhome/www"
        mkdir -p "$pub_dir"
        
        # Création d'un fichier HTML de test simple
        cat <<EOF > "$pub_dir/index.html"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Espace personnel de $username</title>
</head>
<body>
    <h1>Bienvenue sur l'espace personnel de $username !</h1>
    <p>Si vous lisez cette page, la configuration d'Apache Userdir fonctionne correctement.</p>
</body>
</html>
EOF

        # Ajustement des droits
        # Le dossier home doit être traversable (permissions d'exécution pour les autres)
        chmod o+x "$userhome"
        # Propriété et permissions du dossier public_html et de son contenu
        chown -R "$username:$username" "$pub_dir"
        chmod 755 "$pub_dir"
        chmod 644 "$pub_dir/index.html"

        # Test HTTP local
        echo "Test de l'accès HTTP pour l'utilisateur : $username"
        response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/~$username/)
        
        if [ "$response" -eq 200 ]; then
            echo "[SUCCÈS] Test HTTP réussi (Code 200) pour http://localhost/~$username/"
        else
            echo "[AVERTISSEMENT] Le test HTTP a retourné le code : $response"
        fi
    fi
done