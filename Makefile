# Makefile pour Minitel Text Sender (Production)

CC = gcc
CFLAGS = -Wall -Wextra -O2 -D_DEFAULT_SOURCE -D_POSIX_C_SOURCE=200809L
TARGET = minitel
SRC = minitel.c

GREEN  = \033[0;32m
YELLOW = \033[1;33m
NC     = \033[0m

all: $(TARGET)
	@echo "$(GREEN)✓ Compilation terminée !$(NC)"

$(TARGET): $(SRC)
	@echo "$(YELLOW)Compilation...$(NC)"
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)

# Tests de base
test: $(TARGET)
	@echo "$(YELLOW)Test du programme...$(NC)"
	./$(TARGET) -h

# Lancer en mode développement
run: $(TARGET)
	sudo ./$(TARGET)

# Lancer en mode one-shot
run-once: $(TARGET)
	sudo ./$(TARGET) -o

# Installer le service systemd
install-service: $(TARGET)
	@echo "$(YELLOW)Installation du service...${NC}"
	./install-rpi.sh

# Démarrer le service
start-service:
	sudo systemctl start minitel
	@echo "$(GREEN)✓ Service démarré${NC}"

# Arrêter le service
stop-service:
	sudo systemctl stop minitel
	@echo "$(GREEN)✓ Service arrêté${NC}"

# Voir le statut
status:
	sudo systemctl status minitel

# Voir les logs
logs:
	journalctl -u minitel -f

# Voir les logs applicatifs
logs-app:
	tail -f /tmp/minitel.log

# Redémarrer le service
restart-service:
	sudo systemctl restart minitel
	@echo "$(GREEN)✓ Service redémarré${NC}"

# Nettoyer
clean:
	rm -f $(TARGET)
	@echo "$(GREEN)✓ Nettoyé${NC}"

# Aide
help:
	@echo "$(GREEN)══════════════════════════════════════$(NC)"
	@echo "$(GREEN)  Minitel Sender - Production$(NC)"
	@echo "$(GREEN)══════════════════════════════════════$(NC)"
	@echo ""
	@echo "Commandes de développement:"
	@echo "  $(YELLOW)make$(NC)              - Compiler"
	@echo "  $(YELLOW)make run$(NC)          - Lancer manuellement"
	@echo "  $(YELLOW)make run-once$(NC)     - Lancer une fois"
	@echo "  $(YELLOW)make test$(NC)         - Tester"
	@echo ""
	@echo "Commandes de production:"
	@echo "  $(YELLOW)make install-service$(NC) - Installer comme service systemd"
	@echo "  $(YELLOW)make start-service$(NC)   - Démarrer le service"
	@echo "  $(YELLOW)make stop-service$(NC)    - Arrêter le service"
	@echo "  $(YELLOW)make restart-service$(NC) - Redémarrer le service"
	@echo "  $(YELLOW)make status$(NC)          - Voir le statut du service"
	@echo "  $(YELLOW)make logs$(NC)            - Voir les logs système"
	@echo "  $(YELLOW)make logs-app$(NC)        - Voir les logs applicatifs"
	@echo ""
	@echo "Autres:"
	@echo "  $(YELLOW)make clean$(NC)        - Nettoyer"
	@echo "  $(YELLOW)make help$(NC)         - Cette aide"
	@echo ""

.PHONY: all test run run-once install-service start-service stop-service status logs logs-app restart-service clean help
