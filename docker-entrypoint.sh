#!/bin/bash
set -e

# =============================================================================
# scanMountVolume - Docker Entrypoint Script
# =============================================================================
# This script runs when the container starts and ensures the correct branch
# is checked out based on the APP_ENV environment variable.
#
# Directory structure:
#   /opt/app  - Application code (cloned from git)
#   /app/data - Persistent data (Docker volume)
# =============================================================================

CODE_DIR="/opt/app"
DATA_DIR="/app/data"
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
if [ -d "$CODE_DIR/.git" ]; then
    echo "[INFO] Repository exists, fetching updates..."
    cd "$CODE_DIR"
    git fetch origin
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" origin/"$BRANCH"
    git reset --hard origin/"$BRANCH"
    echo "[INFO] Updated to latest '$BRANCH' branch"
else
    echo "[INFO] Cloning repository to $CODE_DIR..."
    rm -rf "$CODE_DIR" 2>/dev/null || true
    git clone --branch "$BRANCH" "$GIT_REPO_URL" "$CODE_DIR"
    echo "[INFO] Cloned '$BRANCH' branch successfully"
fi

# -----------------------------------------------------------------------------
# Install/update dependencies
# -----------------------------------------------------------------------------
cd "$CODE_DIR"
if [ -f "requirements.txt" ]; then
    echo "[INFO] Installing Python dependencies..."
    pip install --no-cache-dir -r requirements.txt
else
    echo "[WARN] No requirements.txt found, skipping dependency installation"
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
echo "[INFO] ============================================"
echo "[INFO] scanMountVolume"
echo "[INFO] ============================================"
echo "[INFO] Environment: $APP_ENV"
echo "[INFO] Branch:      $BRANCH"
echo "[INFO] Code:        $CODE_DIR"
echo "[INFO] Port:        ${APP_PORT:-8056}"
echo "[INFO] ============================================"

if [ -f "$CODE_DIR/scanmountvolume/main.py" ]; then
    echo "[INFO] Starting application..."
    exec uvicorn scanmountvolume.main:app \
        --host "${APP_HOST:-0.0.0.0}" \
        --port "${APP_PORT:-8056}" \
        --workers "${APP_WORKERS:-1}"
else
    echo "[WARN] Application not yet implemented"
    echo "[INFO] Container running - exec into it to develop:"
    echo "[INFO]   docker exec -it scanmountvolume bash"
    echo "[INFO]   cd $CODE_DIR"
    tail -f /dev/null
fi
