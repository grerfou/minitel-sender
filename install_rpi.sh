#!/bin/bash
# Script d'installation pour Raspberry Pi

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Minitel Sender${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Vérifier qu'on est sur un Raspberry Pi
if [ ! -f /proc/device-tree/model ]; then
    echo -e "${YELLOW}Attention: Ce script est optimisé pour Raspberry Pi${NC}"
fi

# Installer les dépendances
echo -e "${YELLOW}Installation des dépendances...${NC}"
sudo apt update
sudo apt install -y build-essential

# Compiler
echo -e "${YELLOW}Compilation...${NC}"
make clean
make

# Permissions port série
echo -e "${YELLOW}Configuration des permissions...${NC}"
sudo usermod -a -G dialout $USER
sudo usermod -a -G tty $USER

# Créer le fichier de log
sudo touch /tmp/minitel.log
sudo chown $USER:$USER /tmp/minitel.log

# Installer le service systemd
echo -e "${YELLOW}Installation du service systemd...${NC}"
sudo cp minitel.service /etc/systemd/system/
sudo sed -i "s|/home/pi|$HOME|g" /etc/systemd/system/minitel.service
sudo sed -i "s|User=pi|User=$USER|g" /etc/systemd/system/minitel.service
sudo sed -i "s|Group=pi|Group=$USER|g" /etc/systemd/system/minitel.service

sudo systemctl daemon-reload
sudo systemctl enable minitel.service

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation terminée !${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Commandes disponibles:"
echo -e "  ${GREEN}sudo systemctl start minitel${NC}   - Démarrer le service"
echo -e "  ${GREEN}sudo systemctl stop minitel${NC}    - Arrêter le service"
echo -e "  ${GREEN}sudo systemctl status minitel${NC}  - Voir le statut"
echo -e "  ${GREEN}journalctl -u minitel -f${NC}       - Voir les logs en temps réel"
echo -e "  ${GREEN}tail -f /tmp/minitel.log${NC}       - Voir les logs applicatifs"
echo ""
echo -e "${YELLOW}Note: Déconnectez-vous et reconnectez-vous pour que les permissions prennent effet${NC}"
echo ""
