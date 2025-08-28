# 🔧 Guide de Dépannage - Erreur SSH

## 🚨 Erreur Rencontrée

```
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain
```

## 🔍 Diagnostic Étape par Étape

### **Étape 1 : Vérifier les Secrets GitHub**

#### **A. Secrets Requis**
Vérifiez que ces secrets sont configurés dans votre repository GitHub :

1. Allez dans **Settings** → **Secrets and variables** → **Actions**
2. Vérifiez la présence de :

| Secret | Statut | Action |
|--------|--------|--------|
| `DEPLOY_HOST` | ❌ Manquant | Ajouter l'IP du serveur |
| `DEPLOY_USER` | ❌ Manquant | Ajouter l'utilisateur SSH |
| `DEPLOY_SSH_KEY` | ❌ Manquant | Ajouter la clé privée |
| `GHCR_PAT` | ❌ Manquant | Ajouter le token GitHub |
| `GHCR_USERNAME` | ❌ Manquant | Ajouter le nom d'utilisateur |

#### **B. Vérifier le Contenu des Secrets**

**DEPLOY_HOST** :
```
✅ Format correct : 192.168.1.100 ou server.example.com
❌ Format incorrect : http://192.168.1.100 ou 192.168.1.100:22
```

**DEPLOY_USER** :
```
✅ Format correct : ubuntu, root, deploy
❌ Format incorrect : ubuntu@server ou ubuntu:password
```

**DEPLOY_SSH_KEY** :
```
✅ Format correct : 
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
...
-----END OPENSSH PRIVATE KEY-----

❌ Format incorrect : 
- Clé sans en-tête/fin
- Clé avec espaces supplémentaires
- Clé tronquée
```

### **Étape 2 : Tester la Clé SSH Localement**

#### **A. Utiliser la Clé Générée**
```bash
# Test avec la clé générée
ssh -i ~/.ssh/deploy_key -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@VOTRE_IP_SERVEUR

# Si ça marche, vous devriez voir :
# Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-88-generic x86_64)
```

#### **B. Vérifier le Format de la Clé**
```bash
# Vérifier que la clé est valide
ssh-keygen -l -f ~/.ssh/deploy_key

# Devrait afficher quelque chose comme :
# 256 SHA256:+rNVT++VcPilXjGSsvX3DQ/tOgpTqFIsoNaChhLQryc github-actions-deploy@test-server (ED25519)
```

### **Étape 3 : Configurer le Serveur Cible**

#### **A. Ajouter la Clé Publique**
```bash
# Sur le serveur cible, ajouter la clé publique
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFIJyw6R+7TPuqIx7kXT7F7Yg2haPk+Ls5MlFtpQ/QT7 github-actions-deploy@test-server" >> ~/.ssh/authorized_keys
```

#### **B. Vérifier les Permissions**
```bash
# Permissions correctes
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chown -R $USER:$USER ~/.ssh

# Vérifier
ls -la ~/.ssh/
# Devrait afficher :
# drwx------ 2 ubuntu ubuntu 4096 Jan 15 10:30 .
# -rw------- 1 ubuntu ubuntu  400 Jan 15 10:30 authorized_keys
```

#### **C. Vérifier la Configuration SSH**
```bash
# Vérifier que SSH accepte les clés publiques
sudo grep -i pubkey /etc/ssh/sshd_config
# Devrait afficher : PubkeyAuthentication yes

# Redémarrer SSH si nécessaire
sudo systemctl restart sshd
```

### **Étape 4 : Test de Connectivité**

#### **A. Test de Base**
```bash
# Test de ping
ping VOTRE_IP_SERVEUR

# Test de port SSH
telnet VOTRE_IP_SERVEUR 22
# ou
nc -zv VOTRE_IP_SERVEUR 22
```

#### **B. Test SSH Détaillé**
```bash
# Test avec verbose pour voir les détails
ssh -v -i ~/.ssh/deploy_key ubuntu@VOTRE_IP_SERVEUR

# Regardez les lignes qui contiennent :
# - "Offering public key"
# - "Server accepts key"
# - "Authentication succeeded"
```

### **Étape 5 : Problèmes Courants**

#### **Problème 1 : Clé Rejetée**
```
debug1: Offering public key: /home/runner/.ssh/id_rsa RSA SHA256:...
debug1: Server accepts key: /home/runner/.ssh/id_rsa RSA SHA256:...
debug1: Authentication succeeded
```

**Solution** : La clé est acceptée mais pas la bonne. Vérifiez que `DEPLOY_SSH_KEY` contient la bonne clé.

#### **Problème 2 : Aucune Clé Offert**
```
debug1: Offering public key: /home/runner/.ssh/id_rsa RSA SHA256:...
debug1: No more authentication methods to try.
```

**Solution** : La clé n'est pas configurée. Vérifiez le secret `DEPLOY_SSH_KEY`.

#### **Problème 3 : Connexion Refusée**
```
ssh: connect to host VOTRE_IP_SERVEUR port 22: Connection refused
```

**Solution** : 
- Vérifiez que le serveur est démarré
- Vérifiez le firewall : `sudo ufw status`
- Vérifiez que SSH écoute : `sudo netstat -tlnp | grep :22`

#### **Problème 4 : Permission Denied**
```
Permission denied (publickey).
```

**Solution** :
- Vérifiez que la clé publique est dans `~/.ssh/authorized_keys`
- Vérifiez les permissions : `chmod 600 ~/.ssh/authorized_keys`
- Vérifiez l'utilisateur : `whoami` sur le serveur

### **Étape 6 : Workflow de Test**

#### **A. Workflow de Test Simple**
Créez un workflow de test temporaire :

```yaml
name: Test SSH Connection

on:
  workflow_dispatch:

jobs:
  test-ssh:
    runs-on: ubuntu-latest
    steps:
      - name: Test SSH
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          key: ${{ secrets.DEPLOY_SSH_KEY }}
          script: |
            echo "✅ SSH Connection successful!"
            whoami
            pwd
            hostname
```

#### **B. Debug des Secrets**
```yaml
- name: Debug Secrets
  run: |
    echo "Host: ${{ secrets.DEPLOY_HOST }}"
    echo "User: ${{ secrets.DEPLOY_USER }}"
    echo "Key exists: ${{ secrets.DEPLOY_SSH_KEY != '' && 'YES' || 'NO' }}"
    echo "Key length: ${#DEPLOY_SSH_KEY}"
  env:
    DEPLOY_SSH_KEY: ${{ secrets.DEPLOY_SSH_KEY }}
```

## 🎯 Checklist de Résolution

### **✅ Configuration GitHub**
- [ ] `DEPLOY_HOST` : IP correcte du serveur
- [ ] `DEPLOY_USER` : utilisateur SSH valide
- [ ] `DEPLOY_SSH_KEY` : clé privée complète et valide
- [ ] `GHCR_PAT` : token GitHub avec permissions
- [ ] `GHCR_USERNAME` : nom d'utilisateur GitHub

### **✅ Configuration Serveur**
- [ ] Clé publique dans `~/.ssh/authorized_keys`
- [ ] Permissions correctes (700 pour `.ssh`, 600 pour `authorized_keys`)
- [ ] SSH service actif
- [ ] Firewall configuré pour le port 22
- [ ] Utilisateur SSH existant

### **✅ Tests Locaux**
- [ ] Test de connectivité réseau
- [ ] Test SSH avec la clé
- [ ] Vérification du format de la clé
- [ ] Test des permissions

### **✅ Workflow GitHub Actions**
- [ ] Workflow de test SSH réussi
- [ ] Diagnostic des secrets OK
- [ ] Connexion SSH établie
- [ ] Déploiement fonctionnel

## 🚀 Commandes de Test Rapide

### **Test Complet en Une Commande**
```bash
#!/bin/bash
HOST="$1"
USER="$2"
KEY="$3"

echo "Testing SSH connection to $USER@$HOST..."
ssh -i "$KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$USER@$HOST" "echo 'SSH connection successful!'" && echo "✅ Success" || echo "❌ Failed"
```

### **Vérification Automatique**
```bash
# Vérifier tous les éléments
echo "=== SSH Key Check ==="
ssh-keygen -l -f ~/.ssh/deploy_key

echo "=== Server Connectivity ==="
ping -c 1 VOTRE_IP_SERVEUR

echo "=== SSH Port Check ==="
nc -zv VOTRE_IP_SERVEUR 22

echo "=== SSH Connection Test ==="
ssh -i ~/.ssh/deploy_key -o ConnectTimeout=5 ubuntu@VOTRE_IP_SERVEUR "echo 'Connection OK'"
```

## 📞 Support

Si le problème persiste après avoir suivi ce guide :

1. **Vérifiez les logs** : `ssh -v -i ~/.ssh/deploy_key user@server`
2. **Testez localement** : Assurez-vous que la connexion SSH fonctionne
3. **Vérifiez les secrets** : Contrôlez le contenu des secrets GitHub
4. **Consultez la documentation** : `SSH_SETUP.md` pour la configuration complète

**Le problème SSH sera résolu en suivant ces étapes ! 🔧**
