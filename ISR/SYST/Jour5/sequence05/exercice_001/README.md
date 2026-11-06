## Justification des Paramètres Clés

### 1. `Timeout`
* **Valeur choisie :** `10` (secondes)
* **Valeur par défaut :** `300` (secondes)
* **Justification :** La valeur par défaut de 300 secondes est excessivement élevée pour un usage web moderne. Elle maintient les connexions ouvertes trop longtemps face à des clients lents ou inactifs. Réduire ce délai à 10 secondes permet de libérer rapidement les ressources bloquées.

### 2. `KeepAlive`
* **Valeur choisie :** `On`
* **Justification :** Activer le mode KeepAlive permet de maintenir une connexion TCP ouverte pour plusieurs requêtes consécutives émanant du même client (par exemple, charger simultanément la structure HTML, les feuilles de style CSS et les scripts JS d'une page). Cela réduit considérablement la surcharge réseau et la latence liées à l'ouverture répétée de connexions TCP.

### 3. `MaxKeepAliveRequests`
* **Valeur choisie :** `500`
* **Valeur par défaut :** `100`
* **Justification :** Augmenter ce plafond de 100 à 500 autorise un même client à effectuer davantage de requêtes successives sur une seule connexion persistante. C'est particulièrement efficace pour les pages web riches en ressources statiques (images, icônes, scripts), évitant la multiplication inutile des handshakes TCP.

### 4. `MaxRequestWorkers`
* **Valeur choisie :** `150` (Ajustable selon la RAM disponible)
* **Justification :** Ce paramètre définit le nombre maximal de requêtes simultanées pouvant être traitées de front (via des processus ou des threads, selon le MPM utilisé). Fixer cette limite à 150 évite que le serveur ne s'effondre sous une surcharge soudaine en saturent complètement la mémoire vive (RAM).