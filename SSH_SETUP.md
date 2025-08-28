# 🔐 Configuration SSH pour Déploiement GitHub Actions

## 🚨 Problème d'Authentification SSH

### **Erreur Rencontrée**
```
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain
```

### **Cause**
L'authentification SSH échoue car :
1. **Clé SSH manquante** ou mal configurée
2. **Permissions incorrectes** sur la clé
3. **Clé publique** non ajoutée au serveur cible
4. **Secrets GitHub** mal configurés

## ✅ Solution Complète

### **Étape 1 : Générer une Clé SSH Dédiée**

```bash
# Générer une nouvelle clé SSH pour le déploiement
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N "" -C "github-actions-deploy"

# Vérifier la génération
ls -la ~/.ssh/deploy_key*
```

### **Étape 2 : Configurer le Serveur Cible**

#### **A. Ajouter la Clé Publique au Serveur**
```bash
# Copier la clé publique
cat ~/.ssh/deploy_key.pub

# Sur le serveur cible, ajouter à ~/.ssh/authorized_keys
echo "VOTRE_CLE_PUBLIQUE_ICI" >> ~/.ssh/authorized_keys
```

#### **B. Vérifier les Permissions sur le Serveur**
```bash
# Permissions correctes pour SSH
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa  # si vous en avez une

# Vérifier le propriétaire
ls -la ~/.ssh/
```

#### **C. Tester la Connexion Locale**
```bash
# Test de connexion avec la clé
ssh -i ~/.ssh/deploy_key username@your-server-ip

# Si ça marche, vous devriez voir le prompt du serveur
```

### **Étape 3 : Configurer les Secrets GitHub**

#### **A. Récupérer la Clé Privée**
```bash
# Afficher la clé privée (à copier dans GitHub Secrets)
cat ~/.ssh/deploy_key
```

#### **B. Ajouter les Secrets dans GitHub**

Allez dans votre repository GitHub :
1. **Settings** → **Secrets and variables** → **Actions**
2. Ajoutez ces secrets :

| Secret Name | Valeur |
|-------------|--------|
| `DEPLOY_HOST` | IP ou hostname du serveur (ex: `192.168.1.100`) |
| `DEPLOY_USER` | Nom d'utilisateur SSH (ex: `ubuntu`) |
| `DEPLOY_SSH_KEY` | **Contenu complet** de la clé privée (`~/.ssh/deploy_key`) |
| `GHCR_PAT` | Token GitHub avec permissions `read:packages` |
| `GHCR_USERNAME` | Votre nom d'utilisateur GitHub |

### **Étape 4 : Vérifier la Configuration**

#### **A. Test de Connexion GitHub Actions**
```yaml
# Ajouter cette étape de test dans deploy.yml
- name: Test SSH Connection
  uses: appleboy/ssh-action@v1.2.0
  with:
    host: ${{ secrets.DEPLOY_HOST }}
    username: ${{ secrets.DEPLOY_USER }}
    key: ${{ secrets.DEPLOY_SSH_KEY }}
    script: |
      echo "✅ Connexion SSH réussie !"
      whoami
      pwd
      hostname
```

#### **B. Vérifier les Variables d'Environnement**
```yaml
# Ajouter cette étape pour déboguer
- name: Debug Secrets
  run: |
    echo "Host: ${{ secrets.DEPLOY_HOST }}"
    echo "User: ${{ secrets.DEPLOY_USER }}"
    echo "Key length: ${#DEPLOY_SSH_KEY}"
    echo "Key starts with: ${DEPLOY_SSH_KEY:0:50}..."
  env:
    DEPLOY_SSH_KEY: ${{ secrets.DEPLOY_SSH_KEY }}
```

## 🔧 Dépannage Avancé

### **Problème 1 : Permissions Refused**
```bash
# Sur le serveur, vérifier les permissions
sudo chown -R $USER:$USER ~/.ssh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### **Problème 2 : Clé Rejetée**
```bash
# Vérifier le format de la clé
ssh-keygen -l -f ~/.ssh/deploy_key.pub

# Régénérer si nécessaire
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N ""
```

### **Problème 3 : Serveur Non Accessible**
```bash
# Test de connectivité
ping $DEPLOY_HOST
telnet $DEPLOY_HOST 22

# Vérifier le firewall
sudo ufw status
sudo iptables -L
```

### **Problème 4 : Utilisateur SSH Incorrect**
```bash
# Vérifier les utilisateurs autorisés
cat /etc/passwd | grep $DEPLOY_USER

# Créer l'utilisateur si nécessaire
sudo adduser $DEPLOY_USER
sudo usermod -aG sudo $DEPLOY_USER
```

## 📋 Checklist de Vérification

### **✅ Avant le Déploiement**
- [ ] Clé SSH générée (`deploy_key`)
- [ ] Clé publique ajoutée au serveur (`authorized_keys`)
- [ ] Permissions correctes sur le serveur
- [ ] Test de connexion local réussi
- [ ] Secrets GitHub configurés
- [ ] Serveur accessible depuis Internet

### **✅ Configuration GitHub**
- [ ] `DEPLOY_HOST` : IP/hostname correct
- [ ] `DEPLOY_USER` : utilisateur SSH valide
- [ ] `DEPLOY_SSH_KEY` : clé privée complète
- [ ] `GHCR_PAT` : token avec permissions packages
- [ ] `GHCR_USERNAME` : nom d'utilisateur GitHub

### **✅ Test Final**
- [ ] Workflow de test SSH réussi
- [ ] Déploiement complet fonctionnel
- [ ] Application accessible sur le serveur

## 🚀 Commandes Utiles

### **Génération Rapide de Clé**
```bash
# Générer et configurer en une commande
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N "" && \
echo "Clé publique à ajouter au serveur:" && \
cat ~/.ssh/deploy_key.pub && \
echo -e "\nClé privée pour GitHub Secrets:" && \
cat ~/.ssh/deploy_key
```

### **Test de Connexion Automatique**
```bash
# Script de test complet
#!/bin/bash
HOST="$1"
USER="$2"
KEY="$3"

echo "Testing SSH connection to $USER@$HOST..."
ssh -i "$KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$USER@$HOST" "echo 'SSH connection successful!'"
```

## 🎯 Résultat Attendu

Après cette configuration :
- ✅ **Connexion SSH** : Authentification réussie
- ✅ **Déploiement** : Workflow GitHub Actions fonctionnel
- ✅ **Sécurité** : Clé SSH dédiée et sécurisée
- ✅ **Maintenance** : Configuration documentée et reproductible

Le déploiement automatique est maintenant prêt ! 🚀
