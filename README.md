# CI/CD Docker + GitHub Actions = Suite de l'integration continue ForFun

Objectif : builder/ &pousser une image Docker sur Github, et déployer sur une VM

## Démarrage local
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r app/requirements.txt
pytest -q

docker build -t ghcr.io/<user>/<repo>:dev --build-arg APP_VERSION=local .
docker run -p 8000:8000 ghcr.io/<user>/<repo>:dev
# http://localhost:8000/health
