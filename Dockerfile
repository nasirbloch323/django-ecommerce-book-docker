# ─────────────────────────────────────────
# Stage 1: Builder
# ─────────────────────────────────────────
FROM python:3.10-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install dependencies into a local directory
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt


# ─────────────────────────────────────────
# Stage 2: Runtime
# ─────────────────────────────────────────
FROM python:3.10-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONPATH=/install/lib/python3.10/site-packages

WORKDIR /app

# Copy only the installed packages from builder (no gcc, no build tools)
COPY --from=builder /install /install

# Copy project source
COPY . .

# Collect static files
RUN PYTHONPATH=/install/lib/python3.10/site-packages python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
