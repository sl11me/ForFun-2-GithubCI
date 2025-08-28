"""
Configuration Pytest pour le projet ForFun-2-GithubCI
"""
import sys
from pathlib import Path

# Ajouter le répertoire app au path Python
app_path = Path(__file__).parent / "app"
sys.path.insert(0, str(app_path))
