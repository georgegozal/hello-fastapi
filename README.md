# hello-fastapi

Tiny FastAPI sample app (`/`, `/health`, `/version`) used as one of the two
apps in the [cicd-lab](https://github.com/georgegozal/cicd-lab) CI/CD
learning pipeline. On every push to `main`, `.github/workflows/build-and-push.yml`
builds this Dockerfile, pushes to `ghcr.io/georgegozal/hello-fastapi`, and
notifies a deploy-agent webhook to redeploy it.

Run locally:
```bash
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Run in Docker:
```bash
docker build --build-arg APP_VERSION=manual-test -t hello-fastapi:test .
docker run --rm -p 8000:8000 hello-fastapi:test
```
