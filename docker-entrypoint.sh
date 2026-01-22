#!/bin/bash
set -e

# =============================================================================
# scanMountVolume - Docker Entrypoint Script
# =============================================================================
# This script runs when the container starts and ensures the correct branch
# is checked out based on the APP_ENV environment variable.
# =============================================================================

APP_DIR="/app"
GIT_REPO_URL="${GIT_REPO_URL:-https://github.com/jonathanicq/scanMountVolume.git}"

# -----------------------------------------------------------------------------
# Determine branch based on environment
# -----------------------------------------------------------------------------
if [ "$APP_ENV" = "production" ]; then
    BRANCH="master"
    echo "[INFO] Production environment detected - using 'master' branch"
elif [ "$APP_ENV" = "development" ]; then
    BRANCH="dev"
    echo "[INFO] Development environment detected - using 'dev' branch"
else
    BRANCH="dev"
    echo "[WARN] APP_ENV not set or invalid ('$APP_ENV') - defaulting to 'dev' branch"
fi

# -----------------------------------------------------------------------------
# Clone or update repository
# -----------------------------------------------------------------------------
if [ -d "$APP_DIR/.git" ]; then
    echo "[INFO] Repository exists, fetching updates..."
    cd "$APP_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
    echo "[INFO] Updated to latest '$BRANCH' branch"
else
    echo "[INFO] Cloning repository..."
    git clone --branch "$BRANCH" "$GIT_REPO_URL" "$APP_DIR"
    echo "[INFO] Cloned '$BRANCH' branch successfully"
fi

# -----------------------------------------------------------------------------
# Install/update dependencies
# -----------------------------------------------------------------------------
cd "$APP_DIR"
if [ -f "requirements.txt" ]; then
    echo "[INFO] Installing Python dependencies..."
    pip install --no-cache-dir -r requirements.txt
fi

# -----------------------------------------------------------------------------
# Run database migrations (if Alembic is configured)
# -----------------------------------------------------------------------------
if [ -f "alembic.ini" ]; then
    echo "[INFO] Running database migrations..."
    alembic upgrade head || echo "[WARN] Migrations skipped or failed"
fi

# -----------------------------------------------------------------------------
# Start the application
# -----------------------------------------------------------------------------
echo "[INFO] Starting scanMountVolume on port ${APP_PORT:-8056}..."
echo "[INFO] Environment: $APP_ENV | Branch: $BRANCH"

exec uvicorn scanmountvolume.main:app \
    --host "${APP_HOST:-0.0.0.0}" \
    --port "${APP_PORT:-8056}" \
    --workers "${APP_WORKERS:-1}"
