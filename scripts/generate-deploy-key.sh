#!/bin/bash

# 🔐 Script de Génération de Clé SSH pour Déploiement
# Usage: ./scripts/generate-deploy-key.sh [nom_serveur]

set -euo pipefail

# Configuration
KEY_NAME="deploy_key"
SSH_DIR="$HOME/.ssh"
SERVER_NAME="${1:-default-server}"

echo "🔐 Génération de clé SSH pour déploiement GitHub Actions"
echo "========================================================"

# Vérifier si la clé existe déjà
if [ -f "$SSH_DIR/$KEY_NAME" ]; then
    echo "⚠️  La clé $KEY_NAME existe déjà."
    read -p "Voulez-vous la remplacer ? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Génération annulée"
        exit 1
    fi
    rm -f "$SSH_DIR/$KEY_NAME" "$SSH_DIR/$KEY_NAME.pub"
fi

# Créer le répertoire SSH si nécessaire
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Générer la clé SSH
echo "🔑 Génération de la clé SSH..."
ssh-keygen -t ed25519 -f "$SSH_DIR/$KEY_NAME" -N "" -C "github-actions-deploy@$SERVER_NAME"

# Définir les bonnes permissions
chmod 600 "$SSH_DIR/$KEY_NAME"
chmod 644 "$SSH_DIR/$KEY_NAME.pub"

echo "✅ Clé SSH générée avec succès !"
echo ""

# Afficher les informations
echo "📋 INFORMATIONS DE CONFIGURATION"
echo "================================"
echo ""

echo "🔑 Clé publique (à ajouter sur le serveur):"
echo "--------------------------------------------"
cat "$SSH_DIR/$KEY_NAME.pub"
echo ""

echo "🔐 Clé privée (à copier dans GitHub Secrets):"
echo "----------------------------------------------"
cat "$SSH_DIR/$KEY_NAME"
echo ""

echo "📝 Instructions de configuration:"
echo "================================"
echo ""

echo "1️⃣  SUR LE SERVEUR CIBLE:"
echo "   - Copiez la clé publique ci-dessus"
echo "   - Ajoutez-la à ~/.ssh/authorized_keys:"
echo "     echo 'CLÉ_PUBLIQUE_CI_DESSUS' >> ~/.ssh/authorized_keys"
echo "   - Vérifiez les permissions:"
echo "     chmod 700 ~/.ssh"
echo "     chmod 600 ~/.ssh/authorized_keys"
echo ""

echo "2️⃣  DANS GITHUB REPOSITORY:"
echo "   - Allez dans Settings → Secrets and variables → Actions"
echo "   - Ajoutez ces secrets:"
echo "     • DEPLOY_HOST: IP du serveur"
echo "     • DEPLOY_USER: nom d'utilisateur SSH"
echo "     • DEPLOY_SSH_KEY: clé privée ci-dessus"
echo "     • GHCR_PAT: token GitHub avec permissions read:packages"
echo "     • GHCR_USERNAME: votre nom d'utilisateur GitHub"
echo ""

echo "3️⃣  TEST DE CONNEXION:"
echo "   - Testez localement:"
echo "     ssh -i $SSH_DIR/$KEY_NAME user@server-ip"
echo "   - Ou lancez le workflow GitHub Actions"
echo ""

echo "🎯 Configuration terminée !"
echo "Le déploiement automatique est maintenant prêt. 🚀"
