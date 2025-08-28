#!/bin/bash

# 🚀 Script de Test de Préparation au Déploiement
# Usage: ./scripts/test-deployment-ready.sh [host] [user]

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

echo -e "${BLUE}🚀 Test de Préparation au Déploiement${NC}"
echo "============================================="
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

# Test 2: Docker installé
echo -e "${BLUE}🐳 Test 2: Docker${NC}"
echo "----------------"
DOCKER_VERSION=$(ssh -i "$KEY_PATH" "$USER@$HOST" "docker --version 2>/dev/null || echo 'NOT_FOUND'")
if [[ "$DOCKER_VERSION" != "NOT_FOUND" ]]; then
    echo -e "${GREEN}✅ Docker installé: $DOCKER_VERSION${NC}"
else
    echo -e "${RED}❌ Docker non installé${NC}"
    exit 1
fi

# Test 3: Permissions Docker
echo -e "${BLUE}🔑 Test 3: Permissions Docker${NC}"
echo "------------------------"
if ssh -i "$KEY_PATH" "$USER@$HOST" "docker ps >/dev/null 2>&1"; then
    echo -e "${GREEN}✅ Permissions Docker OK${NC}"
else
    echo -e "${RED}❌ Pas de permissions Docker${NC}"
    echo "   Exécutez: sudo usermod -aG docker $USER"
    exit 1
fi

# Test 4: Port 80 disponible
echo -e "${BLUE}🌐 Test 4: Port 80${NC}"
echo "----------------"
if ssh -i "$KEY_PATH" "$USER@$HOST" "sudo netstat -tlnp | grep :80 >/dev/null 2>&1 || echo 'FREE'"; then
    echo -e "${GREEN}✅ Port 80 disponible${NC}"
else
    echo -e "${YELLOW}⚠️  Port 80 peut être occupé${NC}"
fi

# Test 5: Espace disque
echo -e "${BLUE}💾 Test 5: Espace disque${NC}"
echo "-------------------"
DISK_SPACE=$(ssh -i "$KEY_PATH" "$USER@$HOST" "df -h / | tail -1 | awk '{print \$4}'")
echo -e "${GREEN}✅ Espace libre: $DISK_SPACE${NC}"

# Test 6: Mémoire disponible
echo -e "${BLUE}🧠 Test 6: Mémoire${NC}"
echo "----------------"
MEMORY=$(ssh -i "$KEY_PATH" "$USER@$HOST" "free -h | grep Mem | awk '{print \$2}'")
echo -e "${GREEN}✅ Mémoire totale: $MEMORY${NC}"

# Test 7: Système d'exploitation
echo -e "${BLUE}🐧 Test 7: Système d'exploitation${NC}"
echo "--------------------------------"
OS_INFO=$(ssh -i "$KEY_PATH" "$USER@$HOST" "cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2")
echo -e "${GREEN}✅ OS: $OS_INFO${NC}"

echo ""
echo -e "${BLUE}📋 Informations du serveur:${NC}"
echo "------------------------"
ssh -i "$KEY_PATH" "$USER@$HOST" "
    echo '  Hostname: ' \$(hostname)
    echo '  Uptime: ' \$(uptime -p)
    echo '  Load average: ' \$(uptime | awk -F'load average:' '{print \$2}')
    echo '  Docker containers: ' \$(docker ps -q | wc -l) ' actifs'
    echo '  Docker images: ' \$(docker images -q | wc -l) ' locales'
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
echo ""
echo "3. Vérifiez le déploiement :"
echo "   curl http://$HOST/health"
