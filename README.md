# 🚀 ForFun-2-GithubCI - CI/CD avec GitHub Actions

Application Python FastAPI avec pipeline CI/CD complet utilisant GitHub Actions et déploiement automatique.

## 📋 Fonctionnalités

- ✅ **CI/CD Pipeline** : Build, test, et déploiement automatique
- ✅ **Docker** : Containerisation avec GitHub Container Registry
- ✅ **Tests Automatisés** : Pytest pour la validation
- ✅ **Déploiement SSH** : Déploiement automatique sur serveur distant
- ✅ **Monitoring** : Endpoints de santé et métriques

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Code Push     │───▶│  GitHub Actions  │───▶│  Serveur Cible  │
│   (main)        │    │  (CI/CD)         │    │  (Docker)       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │  GHCR Registry   │
                       │  (Docker Image)  │
                       └──────────────────┘
```

## 🚀 Démarrage Rapide

### **1. Configuration Locale**

```bash
# Cloner le repository
git clone https://github.com/votre-username/ForFun-2-GithubCI.git
cd ForFun-2-GithubCI

# Créer l'environnement virtuel
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# ou
.venv\Scripts\activate     # Windows

# Installer les dépendances
pip install -r app/requirements.txt

# Lancer les tests
pytest

# Démarrer l'application
python -m uvicorn app.main:app --reload
```

### **2. Configuration SSH pour Déploiement**

#### **A. Générer une Clé SSH Dédiée**

```bash
# Utiliser le script automatique
./scripts/generate-deploy-key.sh mon-serveur

# Ou manuellement
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N "" -C "github-actions-deploy"
```

#### **B. Configurer le Serveur Cible**

```bash
# Sur le serveur cible, ajouter la clé publique
echo "VOTRE_CLE_PUBLIQUE" >> ~/.ssh/authorized_keys

# Vérifier les permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

#### **C. Configurer GitHub Secrets**

Dans votre repository GitHub :
1. **Settings** → **Secrets and variables** → **Actions**
2. Ajoutez ces secrets :

| Secret | Description | Exemple |
|--------|-------------|---------|
| `DEPLOY_HOST` | IP du serveur de déploiement | `192.168.1.100` |
| `DEPLOY_USER` | Utilisateur SSH | `ubuntu` |
| `DEPLOY_SSH_KEY` | Clé privée SSH complète | Contenu de `~/.ssh/deploy_key` |
| `GHCR_PAT` | Token GitHub avec `read:packages` | `ghp_xxxxxxxxxxxx` |
| `GHCR_USERNAME` | Nom d'utilisateur GitHub | `votre-username` |

### **3. Déploiement**

#### **A. Déploiement Automatique (CI/CD)**

1. Poussez du code sur la branche `main`
2. Le workflow CI se lance automatiquement
3. L'image Docker est construite et poussée sur GHCR
4. Le déploiement peut être déclenché manuellement

#### **B. Déploiement Manuel**

1. Allez dans **Actions** → **Deploy**
2. Cliquez sur **Run workflow**
3. Entrez le tag de l'image (ex: `latest`)
4. Cliquez sur **Run workflow**

## 📁 Structure du Projet

```
ForFun-2-GithubCI/
├── .github/
│   └── workflows/
│       ├── ci.yml          # Pipeline CI (build, test, push)
│       └── deploy.yml      # Pipeline de déploiement
├── app/
│   ├── __init__.py
│   ├── main.py            # Application FastAPI
│   ├── requirements.txt   # Dépendances Python
│   └── tests/
│       └── test_health.py # Tests unitaires
├── scripts/
│   └── generate-deploy-key.sh  # Script de génération SSH
├── Dockerfile             # Configuration Docker
├── Makefile              # Commandes de développement
├── SSH_SETUP.md          # Guide de configuration SSH
├── GHCR_FIX.md           # Documentation des corrections
└── README.md             # Ce fichier
```

## 🔧 Workflows GitHub Actions

### **CI Workflow (`ci.yml`)**

```yaml
# Déclencheurs
on:
  push: [main]
  pull_request:

# Étapes
1. Checkout du code
2. Setup Python 3.12
3. Installation des dépendances
4. Exécution des tests
5. Login GHCR
6. Build et push Docker image
```

### **Deploy Workflow (`deploy.yml`)**

```yaml
# Déclencheurs
on:
  workflow_dispatch:  # Manuel

# Étapes
1. Diagnostic des secrets
2. Test de connexion SSH
3. Installation Docker (si nécessaire)
4. Login GHCR
5. Pull de l'image
6. Déploiement du container
```

## 🐳 Docker

### **Build Local**

```bash
# Construire l'image
docker build -t forfun-app .

# Lancer le container
docker run -p 8000:8000 forfun-app

# Tester l'application
curl http://localhost:8000/health
```

### **Images GHCR**

Les images sont automatiquement publiées sur :
```
ghcr.io/votre-username/forfun-2-github-ci:latest
ghcr.io/votre-username/forfun-2-github-ci:sha-commit
```

## 🧪 Tests

### **Tests Locaux**

```bash
# Installer les dépendances de test
pip install pytest

# Lancer les tests
pytest

# Avec couverture
pytest --cov=app

# Tests en mode verbose
pytest -v
```

### **Tests dans CI**

Les tests sont automatiquement exécutés dans le pipeline CI avec :
- ✅ Validation de la syntaxe
- ✅ Tests unitaires
- ✅ Vérification des endpoints

## 📊 Endpoints API

### **Endpoints Disponibles**

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/` | GET | Page d'accueil |
| `/health` | GET | Statut de santé |
| `/version` | GET | Version de l'application |
| `/docs` | GET | Documentation Swagger |

### **Exemple de Réponse**

```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "uptime": "2h 15m 30s"
}
```

## 🔍 Monitoring

### **Vérification de Santé**

```bash
# Test local
curl http://localhost:8000/health

# Test sur le serveur déployé
curl http://votre-serveur-ip/health
```

### **Logs Docker**

```bash
# Voir les logs du container
docker logs ci-cd-demo

# Suivre les logs en temps réel
docker logs -f ci-cd-demo
```

## 🛠️ Développement

### **Commandes Makefile**

```bash
# Afficher l'aide
make help

# Installer les dépendances
make install

# Lancer les tests
make test

# Démarrer l'application
make run

# Construire l'image Docker
make build

# Nettoyer
make clean
```

### **Variables d'Environnement**

```bash
# Configuration de développement
export APP_ENV=development
export DEBUG=true
export PORT=8000
```

## 🚨 Dépannage

### **Problèmes Courants**

#### **1. Erreur SSH**
```
ssh: handshake failed: ssh: unable to authenticate
```
**Solution** : Vérifiez la configuration SSH dans `SSH_SETUP.md`

#### **2. Erreur Docker Build**
```
ERROR: failed to build: invalid tag
```
**Solution** : Vérifiez `GHCR_FIX.md` pour les conventions de nommage

#### **3. Tests qui Échouent**
```
ModuleNotFoundError: No module named 'app'
```
**Solution** : Installez le projet en mode développement
```bash
pip install -e .
```

### **Logs de Débogage**

```bash
# Activer les logs détaillés
export PYTHONPATH=.
pytest -v --tb=long

# Logs Docker détaillés
docker logs ci-cd-demo --tail 100
```

## 📚 Documentation Supplémentaire

- 📖 **[SSH_SETUP.md](SSH_SETUP.md)** : Configuration SSH complète
- 🔧 **[GHCR_FIX.md](GHCR_FIX.md)** : Corrections des problèmes GHCR
- 🐳 **[Dockerfile](Dockerfile)** : Configuration Docker
- ⚙️ **[Makefile](Makefile)** : Commandes de développement

## 🤝 Contribution

1. Fork le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 🎯 Statut du Projet

- ✅ **CI/CD Pipeline** : Fonctionnel
- ✅ **Tests Automatisés** : Implémentés
- ✅ **Déploiement SSH** : Configuré
- ✅ **Documentation** : Complète
- ✅ **Monitoring** : En place

**Le projet est prêt pour la production ! 🚀**
