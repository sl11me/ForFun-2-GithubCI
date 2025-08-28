#!/bin/bash

# 🔧 Script de Test de Connexion SSH
# Usage: ./scripts/test-ssh-connection.sh [host] [user] [key_path]

set -euo pipefail

# Configuration par défaut
DEFAULT_HOST=""
DEFAULT_USER="ubuntu"
DEFAULT_KEY="$HOME/.ssh/deploy_key"

# Paramètres
HOST="${1:-$DEFAULT_HOST}"
USER="${2:-$DEFAULT_USER}"
KEY_PATH="${3:-$DEFAULT_KEY}"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Test de Connexion SSH${NC}"
echo "=================================="

# Vérifier les paramètres
if [ -z "$HOST" ]; then
    echo -e "${RED}❌ Erreur: HOST manquant${NC}"
    echo "Usage: $0 <host> [user] [key_path]"
    echo "Exemple: $0 3.80.11.141 ubuntu ~/.ssh/deploy_key"
    exit 1
fi

echo -e "${BLUE}📋 Configuration:${NC}"
echo "  Host: $HOST"
echo "  User: $USER"
echo "  Key: $KEY_PATH"
echo ""

# Vérifier que la clé existe
if [ ! -f "$KEY_PATH" ]; then
    echo -e "${RED}❌ Erreur: Clé SSH introuvable: $KEY_PATH${NC}"
    echo "Générez une clé avec: ./scripts/generate-deploy-key.sh"
    exit 1
fi

# Vérifier les permissions de la clé
KEY_PERMS=$(stat -c "%a" "$KEY_PATH" 2>/dev/null || stat -f "%Lp" "$KEY_PATH")
if [ "$KEY_PERMS" != "600" ]; then
    echo -e "${YELLOW}⚠️  Attention: Permissions de la clé incorrectes ($KEY_PERMS)${NC}"
    echo "Correction automatique..."
    chmod 600 "$KEY_PATH"
    echo -e "${GREEN}✅ Permissions corrigées${NC}"
fi

echo -e "${BLUE}🔍 Tests de Connectivité${NC}"
echo "------------------------"

# Test 1: Ping
echo -n "1. Test de ping vers $HOST... "
if ping -c 1 "$HOST" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${RED}❌ ÉCHEC${NC}"
    echo "   Vérifiez que le serveur est accessible"
fi

# Test 2: Port SSH
echo -n "2. Test du port SSH (22)... "
if nc -z -w5 "$HOST" 22 2>/dev/null; then
    echo -e "${GREEN}✅ OK${NC}"
else
    echo -e "${RED}❌ ÉCHEC${NC}"
    echo "   Vérifiez que SSH est actif sur le serveur"
fi

# Test 3: Format de la clé
echo -n "3. Vérification du format de la clé... "
if ssh-keygen -l -f "$KEY_PATH" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ OK${NC}"
    KEY_FINGERPRINT=$(ssh-keygen -l -f "$KEY_PATH" | awk '{print $2}')
    echo "   Fingerprint: $KEY_FINGERPRINT"
else
    echo -e "${RED}❌ ÉCHEC${NC}"
    echo "   La clé SSH n'est pas valide"
    exit 1
fi

echo ""
echo -e "${BLUE}🔐 Test de Connexion SSH${NC}"
echo "---------------------------"

# Test 4: Connexion SSH
echo -n "4. Test de connexion SSH... "
if ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o BatchMode=yes "$USER@$HOST" "echo 'SSH connection successful!'" 2>/dev/null; then
    echo -e "${GREEN}✅ CONNEXION RÉUSSIE !${NC}"
    echo ""
    echo -e "${GREEN}🎉 Configuration SSH correcte !${NC}"
    echo ""
    echo -e "${BLUE}📋 Informations du serveur:${NC}"
    ssh -i "$KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$USER@$HOST" "
        echo '  OS: ' \$(cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2)
        echo '  Hostname: ' \$(hostname)
        echo '  User: ' \$(whoami)
        echo '  Uptime: ' \$(uptime -p)
        echo '  Memory: ' \$(free -h | grep Mem | awk '{print \$2}')
        echo '  Disk: ' \$(df -h / | tail -1 | awk '{print \$4}') 'libre'
    "
else
    echo -e "${RED}❌ ÉCHEC DE CONNEXION${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Diagnostic:${NC}"
    echo "1. Vérifiez que la clé publique est dans ~/.ssh/authorized_keys sur le serveur"
    echo "2. Vérifiez les permissions: chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
    echo "3. Vérifiez que l'utilisateur '$USER' existe sur le serveur"
    echo "4. Testez manuellement: ssh -i $KEY_PATH $USER@$HOST"
    echo ""
    echo -e "${BLUE}📖 Consultez TROUBLESHOOTING.md pour plus de détails${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Tous les tests sont passés !${NC}"
echo ""
echo -e "${BLUE}📝 Prochaines étapes:${NC}"
echo "1. Configurez les secrets GitHub Actions :"
echo "   - DEPLOY_HOST: $HOST"
echo "   - DEPLOY_USER: $USER"
echo "   - DEPLOY_SSH_KEY: $(cat "$KEY_PATH")"
echo ""
echo "2. Testez le workflow GitHub Actions"
echo "3. Déployez votre application !"
