#!/bin/bash

# 🚀 Script de Test de Déploiement Complet
# Usage: ./scripts/test-deployment.sh [host] [user]

set -euo pipefail

# Configuration par défaut
DEFAULT_HOST="3.80.11.141"
DEFAULT_USER="ubuntu"
DEFAULT_KEY="$HOME/.ssh/deploy_key"

# Paramètres
HOST="${1:-$DEFAULT_HOST}"
USER="${2:-$DEFAULT_USER}"
KEY_PATH="${3:-$DEFAULT_KEY}"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Test de Déploiement Complet${NC}"
echo "=================================="
echo ""

echo -e "${BLUE}📋 Configuration:${NC}"
echo "  Host: $HOST"
echo "  User: $USER"
echo "  Key: $KEY_PATH"
echo ""

# Test 1: Connexion SSH
echo -e "${BLUE}🔐 Test 1: Connexion SSH${NC}"
echo "------------------------"
if ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$USER@$HOST" "echo 'SSH OK'" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Connexion SSH réussie${NC}"
else
    echo -e "${RED}❌ Échec de la connexion SSH${NC}"
    exit 1
fi

# Test 2: Docker
echo -e "${BLUE}🐳 Test 2: Docker${NC}"
echo "----------------"
if ssh -i "$KEY_PATH" "$USER@$HOST" "docker --version >/dev/null 2>&1"; then
    echo -e "${GREEN}✅ Docker disponible${NC}"
else
    echo -e "${RED}❌ Docker non disponible${NC}"
    exit 1
fi

# Test 3: Permissions Docker
echo -e "${BLUE}🔑 Test 3: Permissions Docker${NC}"
echo "------------------------"
if ssh -i "$KEY_PATH" "$USER@$HOST" "docker ps >/dev/null 2>&1"; then
    echo -e "${GREEN}✅ Permissions Docker OK${NC}"
else
    echo -e "${RED}❌ Pas de permissions Docker${NC}"
    exit 1
fi

# Test 4: Port 80
echo -e "${BLUE}🌐 Test 4: Port 80${NC}"
echo "----------------"
if ssh -i "$KEY_PATH" "$USER@$HOST" "sudo ss -tlnp | grep -q ':80 '"; then
    echo -e "${YELLOW}⚠️  Port 80 occupé - nginx détecté${NC}"
    echo "   Arrêt de nginx..."
    ssh -i "$KEY_PATH" "$USER@$HOST" "sudo systemctl stop nginx && sudo systemctl disable nginx"
    echo -e "${GREEN}✅ Nginx arrêté${NC}"
else
    echo -e "${GREEN}✅ Port 80 libre${NC}"
fi

# Test 5: Nettoyage des containers existants
echo -e "${BLUE}🧹 Test 5: Nettoyage${NC}"
echo "-------------------"
ssh -i "$KEY_PATH" "$USER@$HOST" "docker rm -f ci-cd-demo 2>/dev/null || true"
echo -e "${GREEN}✅ Containers nettoyés${NC}"

# Test 6: Simulation du déploiement
echo -e "${BLUE}🚀 Test 6: Simulation Déploiement${NC}"
echo "--------------------------------"
echo "Note: Ce test nécessite une image Docker valide"
echo "Pour un test complet, configurez d'abord les secrets GitHub"
echo ""

# Vérification finale
echo -e "${BLUE}📋 État Final du Serveur${NC}"
echo "------------------------"
ssh -i "$KEY_PATH" "$USER@$HOST" "
    echo '  Port 80: ' \$(sudo ss -tlnp | grep -q ':80 ' && echo 'Occupé' || echo 'Libre')
    echo '  Docker containers: ' \$(docker ps -q | wc -l) ' actifs'
    echo '  Docker images: ' \$(docker images -q | wc -l) ' locales'
    echo '  Nginx status: ' \$(sudo systemctl is-active nginx 2>/dev/null || echo 'Arrêté')
"

echo ""
echo -e "${GREEN}🎉 Serveur prêt pour le déploiement !${NC}"
echo ""
echo -e "${BLUE}📝 Prochaines étapes:${NC}"
echo "1. Configurez les secrets GitHub Actions :"
echo "   - DEPLOY_HOST: $HOST"
echo "   - DEPLOY_USER: $USER"
echo "   - DEPLOY_SSH_KEY: [clé privée]"
echo "   - GHCR_PAT: [token GitHub]"
echo "   - GHCR_USERNAME: [nom d'utilisateur GitHub]"
echo ""
echo "2. Lancez le workflow de déploiement :"
echo "   Actions → Deploy → Run workflow"
echo "   Option: stop_nginx = true (pour arrêter nginx)"
echo ""
echo "3. Vérifiez le déploiement :"
echo "   curl http://$HOST/health"
