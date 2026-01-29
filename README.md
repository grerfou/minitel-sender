#  Minitel Text Sender - Production Ready

Programme robuste en C pour afficher du texte sur un Minitel 1B via ESP32, conçu pour tourner **9h/jour sur Raspberry Pi** sans crash.

## Fonctionnalités Production

### Robustesse
-  **Détection et reconnexion automatique** du port série
-  **Gestion propre des signaux** (SIGTERM, SIGINT, SIGHUP)
-  **Pas de fuite mémoire** - Safe pour usage 24/7
-  **Watchdog intégré** - Vérifie que le système est vivant
-  **Logs avec timestamps** - Debug facile
-  **Service systemd** - Démarrage automatique au boot
-  **Limites de ressources** - CPU et RAM contrôlés
-  **Retry automatique** - Max 5 tentatives avec backoff

### Fonctionnalités
-  Lecture de fichier texte
-  Boucle infinie ou mode one-shot
-  Vitesse configurable
-  Retour à la ligne automatique (10 caractères)
-  Logs détaillés dans `/tmp/minitel.log`

##  Installation Rapide (Raspberry Pi)

```bash
# Cloner le projet
git clone https://github.com/grerfou/minitel-sender.git
cd minitel-sender

# Installation automatique + service systemd
chmod +x install-rpi.sh
./install-rpi.sh

# Démarrer le service
sudo systemctl start minitel

# Voir les logs
journalctl -u minitel -f
```

**C'est tout !** Le programme tourne maintenant en arrière-plan et redémarrera automatiquement au boot.

##  Prérequis

### Matériel
- **Raspberry Pi** (testé sur Pi 3/4/5)
- **Minitel 1B** avec Minitel-ESP32 installé
- Câble USB

### Logiciel
- Raspberry Pi OS (Bullseye ou plus récent)
- GCC, Make (installés automatiquement)

##  Configuration

### 1. Préparer le Minitel
1. Flasher l'ESP32 avec [Minitel-ESP32](https://github.com/iodeo/Minitel-ESP32)
2. Configurer Telnet Pro en mode **Serial**
3. Appuyer sur **ESPACE** pour activer

### 2. Créer votre fichier texte

```bash
vim text.txt
```

Écrivez ce que vous voulez afficher (sans limite de taille).

### 3. Lancer

**Mode manuel (développement) :**
```bash
make run
```

**Mode production (service) :**
```bash
make install-service
make start-service
```

##  Gestion du Service

### Commandes systemd

```bash
# Démarrer
sudo systemctl start minitel

# Arrêter
sudo systemctl stop minitel

# Redémarrer
sudo systemctl restart minitel

# Voir le statut
sudo systemctl status minitel

# Activer au démarrage (déjà fait par install-rpi.sh)
sudo systemctl enable minitel

# Désactiver au démarrage
sudo systemctl disable minitel
```

### Voir les logs

```bash
# Logs système (journald)
journalctl -u minitel -f

# Logs applicatifs
tail -f /tmp/minitel.log

# Dernières 100 lignes
journalctl -u minitel -n 100
```

##  Options Avancées

### Arguments en ligne de commande

```bash
./minitel [OPTIONS]

Options:
  -f FILE     Fichier texte (défaut: text.txt)
  -d DELAY    Délai en µs (défaut: 1000)
  -p PORT     Port série (défaut: /dev/ttyUSB0)
  -o          Mode one-shot (affiche une fois)
  -l LOGFILE  Fichier de log (défaut: /tmp/minitel.log)
  -h          Aide

Exemples:
  ./minitel -f message.txt -d 2000
  ./minitel -o -f test.txt
  ./minitel -p /dev/ttyACM0
```

### Modifier le service

Éditer `/etc/systemd/system/minitel.service` :

```bash
sudo systemctl edit --full minitel
```

Exemple - changer le fichier et la vitesse :
```ini
ExecStart=/home/pi/minitel-sender/minitel -f custom.txt -d 2000
```

Puis recharger :
```bash
sudo systemctl daemon-reload
sudo systemctl restart minitel
```

##  Monitoring

### Vérifier que ça tourne

```bash
# Voir si le processus existe
ps aux | grep minitel

# Voir l'uptime du service
systemctl status minitel | grep Active

# Voir la consommation mémoire/CPU
top -p $(pgrep minitel)
```

### Statistiques

```bash
# Nombre de redémarrages
journalctl -u minitel | grep "Démarrage" | wc -l

# Derniers crashs
journalctl -u minitel | grep "ERROR\|FATAL"

# Uptime total
systemctl show minitel --property=ActiveEnterTimestamp
```

##  Dépannage

### Le service ne démarre pas

```bash
# Voir l'erreur exacte
sudo systemctl status minitel
journalctl -u minitel -n 50

# Vérifier les permissions
ls -l /dev/ttyUSB0
groups  # Vérifier que dialout est présent

# Test manuel
sudo ./minitel -o
```

### Port série non trouvé

```bash
# Lister les ports disponibles
ls -l /dev/tty*

# Vérifier que l'ESP32 est connecté
dmesg | grep tty

# Modifier le port dans le service
sudo systemctl edit --full minitel
# Changer: -p /dev/ttyACM0 (ou autre port)
```

### Le programme crash après X heures

```bash
# Voir les logs au moment du crash
journalctl -u minitel --since "2 hours ago"

# Vérifier la mémoire disponible
free -h

# Augmenter la limite mémoire dans le service
sudo systemctl edit --full minitel
# Modifier: MemoryMax=100M
```

### Caractères bizarres sur le Minitel

- Vérifier que Telnet Pro est en mode Serial à **4800 bauds**
- Vérifier le câblage ESP32 ↔ Minitel
- Redémarrer l'ESP32

##  Performance

Testé sur Raspberry Pi 4 :
- **CPU** : < 1% en moyenne
- **RAM** : ~2 MB
- **Uptime** : 9h/jour stable
- **Reconnexion** : < 5 secondes

Limites configurées dans le service :
- `MemoryMax=50M` - Maximum 50 MB de RAM
- `CPUQuota=50%` - Maximum 50% d'un cœur CPU

##  Sécurité

Le service systemd inclut :
- `NoNewPrivileges=true` - Pas d'escalade de privilèges
- `PrivateTmp=true` - /tmp isolé
- Utilisateur non-root (`pi` par défaut)
- Limites de ressources strictes

##  Structure du Projet

```
minitel-sender/
├── minitel.c           # Code source robuste
├── Makefile            # Build et gestion service
├── minitel.service     # Fichier systemd
├── install-rpi.sh      # Script d'installation
├── text.txt            # Fichier texte exemple
├── README.md           # Cette doc
├── LICENSE             # MIT License
└── .gitignore          # Fichiers à ignorer
```

##  Tests

```bash
# Test de compilation
make test

# Test one-shot
make run-once

# Test avec un autre fichier
echo "TEST 123" > test.txt
sudo ./minitel -f test.txt -o

# Test de robustesse (débrancher/rebrancher USB)
make start-service
# Débrancher ESP32
# Attendre 10s
# Rebrancher
# Vérifier les logs: tail -f /tmp/minitel.log
```

##  Ressources

- [Minitel-ESP32 par iodeo](https://github.com/iodeo/Minitel-ESP32)
- [Spécifications Minitel 1B](http://543210.free.fr/TV/stum1b.pdf)
- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)
- [systemd Man Page](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

##  Changelog

### v2.0.0 (Production)
-  Reconnexion automatique
-  Gestion des signaux
-  Service systemd
-  Logs avec timestamps
-  Watchdog intégré
-  Tests de robustesse 9h

### v1.0.0 (Initial)
- Envoi basique de fichier texte
- Boucle infinie

##  Licence


##  Auteur

**Creative Coding 2026**

##  Remerciements

- **iodeo** pour Minitel-ESP32
- La communauté Raspberry Pi
- Tous les contributeurs

---
