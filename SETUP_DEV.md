# 🚀 Guide de Développement - ForFun-2-GithubCI

## 🔧 Configuration de l'Environnement de Développement

### **Installation Recommandée**

```bash
# 1. Créer l'environnement virtuel
python3 -m venv .venv

# 2. Activer l'environnement
source .venv/bin/activate  # macOS/Linux
# ou
.venv\Scripts\activate     # Windows

# 3. Installer en mode développement (RECOMMANDÉ)
pip install -e .
```

### **Alternative Simple**

```bash
# Installation rapide avec Makefile
make install-dev
```

## 🧪 Exécution des Tests

### **Problème Résolu : ModuleNotFoundError**

Le problème `ModuleNotFoundError: No module named 'app'` est résolu grâce à :

1. **Installation en mode développement** : `pip install -e .`
2. **Fichiers `__init__.py`** dans les packages
3. **Configuration Pytest** dans `pyproject.toml`

### **Commandes de Test**

```bash
# Tous les tests
make test
# ou
python -m pytest app/tests/ -v

# Test spécifique
python -m pytest app/tests/test_health.py -v

# Tests avec couverture
make test-coverage
```

## 🏃‍♂️ Lancement de l'Application

```bash
# Mode développement avec rechargement automatique
make run
# ou
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Avec Docker
make build
make run-docker
```

## 📁 Structure du Projet

```
ForFun-2-GithubCI/
├── app/
│   ├── __init__.py          # Package Python
│   ├── main.py              # Application FastAPI
│   ├── requirements.txt     # Dépendances
│   └── tests/
│       ├── __init__.py      # Package tests
│       └── test_health.py   # Tests unitaires
├── .venv/                   # Environnement virtuel
├── pyproject.toml          # Configuration projet
├── conftest.py             # Configuration Pytest
├── Makefile                # Commandes utiles
└── README.md               # Documentation
```

## 🔍 Pourquoi `pip install -e .` ?

### **Mode Développement (`-e`)**
- ✅ Le package est installé en mode "éditable"
- ✅ Les modifications du code sont immédiatement disponibles
- ✅ Pas besoin de réinstaller après chaque modification
- ✅ Les imports fonctionnent depuis n'importe où

### **Avantages**
```bash
# Avant (problématique)
import sys
sys.path.insert(0, '/path/to/project')
from app.main import health

# Après (propre)
from app.main import health  # Fonctionne partout !
```

## 🛠️ Commandes Utiles

```bash
# Afficher l'aide
make help

# Nettoyer les fichiers temporaires
make clean

# Vérifier l'installation
python -c "from app.main import health; print('OK')"

# Lister les packages installés
pip list
```

## 🚨 Dépannage

### **Si les tests ne passent pas :**
```bash
# Réinstaller en mode développement
pip install -e . --force-reinstall

# Vérifier l'environnement
which python
pip list | grep forfun
```

### **Si l'environnement virtuel est corrompu :**
```bash
# Supprimer et recréer
rm -rf .venv
make install-dev
```

## 🎯 Bonnes Pratiques

1. **Toujours utiliser l'environnement virtuel**
2. **Installer en mode développement** : `pip install -e .`
3. **Exécuter les tests avant chaque commit**
4. **Utiliser le Makefile** pour les commandes courantes
5. **Documenter les nouvelles dépendances** dans `requirements.txt`
