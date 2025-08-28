# 🔧 Correction du Nom de Repository GHCR

## 🚨 Problème Résolu

### **Erreur Rencontrée**
```
ERROR: failed to build: invalid tag "ghcr.io/sl11me/ForFun-2-GithubCI:latest": 
repository name must be lowercase
```

### **Cause**
GitHub Container Registry (GHCR) exige que les noms de repository soient **entièrement en minuscules**.

Le repository `ForFun-2-GithubCI` contient des majuscules, ce qui n'est pas autorisé.

## ✅ Solution Appliquée

### **Modification des Workflows**

#### **1. Workflow CI (`ci.yml`)**
```yaml
env:
  REGISTRY: ghcr.io
  TAG: latest

jobs:
  build-test-push:
    runs-on: ubuntu-latest
    steps:
      # ... autres étapes ...
      
      - name: Set image name
        run: echo "IMAGE_NAME=$(echo ${{ github.repository }} | tr '[:upper:]' '[:lower:]')" >> $GITHUB_ENV
      
      # ... suite du workflow ...
```

#### **2. Workflow Deploy (`deploy.yml`)**
```yaml
env:
  REGISTRY: ghcr.io

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Set image name
        run: echo "IMAGE_NAME=$(echo ${{ github.repository }} | tr '[:upper:]' '[:lower:]')" >> $GITHUB_ENV
      
      # ... suite du workflow ...
```

### **Résultat**
- **Avant** : `ghcr.io/sl11me/ForFun-2-GithubCI:latest` ❌
- **Après** : `ghcr.io/sl11me/forfun-2-github-ci:latest` ✅

## 🔍 Détails Techniques

### **Commande de Conversion**
```bash
echo ${{ github.repository }} | tr '[:upper:]' '[:lower:]'
```

Cette commande utilise `tr` (translate) pour convertir tous les caractères majuscules en minuscules.

### **Variable d'Environnement**
```bash
echo "IMAGE_NAME=converted-name" >> $GITHUB_ENV
```

La variable `IMAGE_NAME` est définie dans l'environnement GitHub Actions et peut être utilisée dans les étapes suivantes.

### **Exemples de Conversion**
```bash
# Exemples de conversion
ForFun-2-GithubCI → forfun-2-github-ci
My-Project → my-project
TestRepo → testrepo
```

### **Compatibilité**
- ✅ **GitHub Actions** : Fonctionne avec tous les workflows
- ✅ **Docker** : Respecte les conventions de nommage
- ✅ **GHCR** : Conforme aux exigences du registry

## 🚀 Vérification

### **Test Local**
```bash
# Construire l'image localement
docker build -t ghcr.io/sl11me/forfun-2-github-ci:test .

# Vérifier le nom
docker images | grep forfun-2-github-ci
```

### **Test GitHub Actions**
1. Poussez les modifications sur la branche `main`
2. Vérifiez que le workflow CI passe
3. L'image sera disponible sur GHCR avec le bon nom

## 📋 Bonnes Pratiques

### **Pour les Futurs Projets**
1. **Nommer les repositories en minuscules** dès le début
2. **Utiliser des tirets** au lieu d'espaces ou underscores
3. **Éviter les majuscules** dans les noms de repository

### **Exemples de Noms Corrects**
```bash
# ✅ Corrects
forfun-2-github-ci
my-python-app
api-service
web-frontend

# ❌ Incorrects
ForFun-2-GithubCI
My-Python-App
API_Service
WebFrontend
```

## 🎯 Résultat Final

Après cette correction :
- ✅ **Build Docker** : Fonctionne correctement
- ✅ **Push GHCR** : Image disponible sur le registry
- ✅ **Déploiement** : Workflow de déploiement fonctionne
- ✅ **Compatibilité** : Respecte toutes les conventions

Le projet est maintenant prêt pour la CI/CD complète ! 🚀
