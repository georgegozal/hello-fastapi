# Start from an existing image instead of building an OS from scratch —
# "slim" is a smaller Debian variant with just enough to run Python.
FROM python:3.12-slim

WORKDIR /app

# Copy and install dependencies BEFORE copying the app code. Docker caches
# each instruction as its own layer and only re-runs a layer (and every
# layer after it) if its inputs changed. App code changes far more often
# than requirements.txt does, so this ordering means most rebuilds skip
# the slow `pip install` step entirely and reuse the cached layer.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# ARG = a build-time-only value (set via `docker build --build-arg ...` or
# Compose's `build.args`). ENV = a runtime value baked permanently into the
# image. Copying the ARG into an ENV here is how the running container
# "remembers" what version/commit it was built from — see GET /version in
# app/main.py.
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

# Images run as root by default. Create an unprivileged user and switch to
# it before CMD runs, so the actual app process — and anything that could
# ever exploit it — doesn't have root inside the container.
RUN groupadd --gid 1000 app && \
    useradd --uid 1000 --gid app --no-create-home --shell /usr/sbin/nologin app && \
    chown -R app:app /app
USER app

# Documents which port the app listens on. This alone does NOT publish the
# port to the host — that's what docker-compose.yml's `ports:` does.
EXPOSE 8000

# Docker itself will periodically hit this URL from inside the container
# and mark it "unhealthy" in `docker ps` if it stops responding — separate
# from, and in addition to, whatever nginx does when proxying to it.
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
