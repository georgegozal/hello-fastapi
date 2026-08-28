import os

from fastapi import FastAPI

app = FastAPI(title="hello-fastapi")

APP_VERSION = os.environ.get("APP_VERSION", "dev")


@app.get("/")
def root():
    return {"service": "hello-fastapi", "version": APP_VERSION}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/version")
def version():
    return {"version": APP_VERSION}
