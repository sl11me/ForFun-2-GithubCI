IMAGE=ghcr.io/$(sl11me)/ci-cd-demo:latest

.PHONY: help install test run build clean

help: ## Afficher l'aide
	@echo "Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Installer les dépendances
	python -m venv .venv
	.venv/bin/pip install -r app/requirements.txt

test: ## Exécuter les tests
	python -m pytest app/tests/ -v

test-coverage: ## Exécuter les tests avec couverture
	python -m pytest app/tests/ --cov=app --cov-report=html

run: ## Lancer l'application en local
	python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

build: ## Construire l'image Docker
	docker build -t ghcr.io/$(shell git config user.name)/forfun-githubci:dev --build-arg APP_VERSION=local .

run-docker: ## Lancer l'application avec Docker
	docker run -p 8000:8000 ghcr.io/$(shell git config user.name)/forfun-githubci:dev

clean: ## Nettoyer les fichiers temporaires
	find . -type d -name __pycache__ -delete
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache
	rm -rf htmlcov
