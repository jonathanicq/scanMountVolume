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
    # Repository exists, update it
    echo "[INFO] Repository exists, fetching updates..."
    cd "$APP_DIR"
    git fetch origin
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" origin/"$BRANCH"
    git pull origin "$BRANCH"
    echo "[INFO] Updated to latest '$BRANCH' branch"
elif [ -d "$APP_DIR" ] && [ "$(ls -A $APP_DIR 2>/dev/null)" ]; then
    # Directory exists but is not a git repo - clean and clone
    echo "[INFO] Directory exists but is not a git repository"
    echo "[INFO] Cleaning directory and cloning fresh..."
    rm -rf "$APP_DIR"/* "$APP_DIR"/.[!.]* 2>/dev/null || true
    cd "$APP_DIR"
    git clone --branch "$BRANCH" "$GIT_REPO_URL" .
    echo "[INFO] Cloned '$BRANCH' branch successfully"
else
    # Directory doesn't exist or is empty - clone
    echo "[INFO] Cloning repository..."
    mkdir -p "$APP_DIR"
    cd "$APP_DIR"
    git clone --branch "$BRANCH" "$GIT_REPO_URL" .
    echo "[INFO] Cloned '$BRANCH' branch successfully"
fi

# -----------------------------------------------------------------------------
# Install/update dependencies
# -----------------------------------------------------------------------------
cd "$APP_DIR"
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
echo "[INFO] Starting scanMountVolume on port ${APP_PORT:-8056}..."
echo "[INFO] Environment: $APP_ENV | Branch: $BRANCH"

# Check if main.py exists before starting
if [ -f "scanmountvolume/main.py" ]; then
    exec uvicorn scanmountvolume.main:app \
        --host "${APP_HOST:-0.0.0.0}" \
        --port "${APP_PORT:-8056}" \
        --workers "${APP_WORKERS:-1}"
else
    echo "[WARN] Application not yet implemented (scanmountvolume/main.py not found)"
    echo "[INFO] Container will stay running for development..."
    echo "[INFO] Repository cloned successfully to $APP_DIR"
    echo "[INFO] You can exec into the container to develop"
    # Keep container running
    tail -f /dev/null
fi
