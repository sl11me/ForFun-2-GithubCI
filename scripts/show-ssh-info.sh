#!/bin/bash

# 📋 Script d'Affichage des Informations SSH
# Usage: ./scripts/show-ssh-info.sh

set -euo pipefail

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔐 Informations SSH pour Configuration GitHub Actions${NC}"
echo "========================================================"
echo ""

# Vérifier que la clé existe
if [ ! -f "$HOME/.ssh/deploy_key" ]; then
    echo -e "${YELLOW}⚠️  Clé SSH introuvable. Génération...${NC}"
    ./scripts/generate-deploy-key.sh
fi

echo -e "${GREEN}✅ Clé SSH trouvée${NC}"
echo ""

echo -e "${BLUE}📋 1. CLÉ PUBLIQUE (à ajouter sur le serveur)${NC}"
echo "----------------------------------------"
echo "Copiez cette ligne et ajoutez-la à ~/.ssh/authorized_keys sur votre serveur :"
echo ""
cat "$HOME/.ssh/deploy_key.pub"
echo ""
echo ""

echo -e "${BLUE}📋 2. CLÉ PRIVÉE (pour GitHub Secrets)${NC}"
echo "----------------------------------------"
echo "Copiez tout le contenu ci-dessous dans le secret DEPLOY_SSH_KEY :"
echo ""
cat "$HOME/.ssh/deploy_key"
echo ""
echo ""

echo -e "${BLUE}📋 3. SECRETS GITHUB À CONFIGURER${NC}"
echo "----------------------------------------"
echo "Dans votre repository GitHub :"
echo "Settings → Secrets and variables → Actions"
echo ""
echo "Ajoutez ces secrets :"
echo ""
echo -e "${YELLOW}DEPLOY_HOST${NC}"
echo "  Valeur : L'IP de votre serveur (ex: 192.168.1.100)"
echo ""
echo -e "${YELLOW}DEPLOY_USER${NC}"
echo "  Valeur : L'utilisateur SSH (ex: ubuntu)"
echo ""
echo -e "${YELLOW}DEPLOY_SSH_KEY${NC}"
echo "  Valeur : La clé privée ci-dessus (tout le contenu)"
echo ""
echo -e "${YELLOW}GHCR_PAT${NC}"
echo "  Valeur : Token GitHub avec permissions read:packages"
echo ""
echo -e "${YELLOW}GHCR_USERNAME${NC}"
echo "  Valeur : Votre nom d'utilisateur GitHub"
echo ""

echo -e "${BLUE}📋 4. COMMANDES À EXÉCUTER SUR LE SERVEUR${NC}"
echo "----------------------------------------"
echo "Sur votre serveur cible, exécutez :"
echo ""
echo "1. Ajouter la clé publique :"
echo "   echo \"$(cat "$HOME/.ssh/deploy_key.pub")\" >> ~/.ssh/authorized_keys"
echo ""
echo "2. Vérifier les permissions :"
echo "   chmod 700 ~/.ssh"
echo "   chmod 600 ~/.ssh/authorized_keys"
echo ""
echo "3. Tester la connexion :"
echo "   ssh -i ~/.ssh/deploy_key ubuntu@VOTRE_IP"
echo ""

echo -e "${BLUE}📋 5. TEST LOCAL${NC}"
echo "----------------------------------------"
echo "Une fois configuré, testez avec :"
echo ""
echo "   ./scripts/test-ssh-connection.sh VOTRE_IP ubuntu"
echo ""

echo -e "${GREEN}🎯 Configuration terminée !${NC}"
echo "Le déploiement automatique sera bientôt opérationnel ! 🚀"
