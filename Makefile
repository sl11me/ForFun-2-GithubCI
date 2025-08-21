IMAGE=ghcr.io/sl11me/ci-cd-demo:latest

.PHONY: test build run push
test:
	python -m pytest -q

build:
	docker build -t $(IMAGE) --build-arg APP_VERSION=$$(git rev-parse --short HEAD) .

run:
	docker run --rm -p 8000:8000 $(IMAGE)

push:
	docker push $(IMAGE)
