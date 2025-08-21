from fastapi import FastAPI
import os

app = FastAPI(title="ci-cd-demo")

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/version")
def version():
    # injectée par Docker ARG/ENV lors du build
    return {"version": os.getenv("APP_VERSION","dev")}
