#!/bin/bash
set -e

# =============================================================================
# scanMountVolume - Docker Entrypoint Script
# =============================================================================
# This script runs when the container starts and ensures the correct branch
# is checked out based on the APP_ENV environment variable.
#
# Directory structure (all inside git repo):
#   /opt/app/                  - Git repository root
#   /opt/app/data/             - Persistent data (volume mount)
#   /opt/app/logs/             - Application logs (volume mount)
#   /opt/app/config/           - Configuration files (volume mount)
#   /opt/app/scanmountvolume/  - Application source code
# =============================================================================

CODE_DIR="/opt/app"
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
# Initialize or update repository
# Uses git init method to work with pre-existing volume-mounted directories
# -----------------------------------------------------------------------------
cd "$CODE_DIR"

if [ -d "$CODE_DIR/.git" ]; then
    echo "[INFO] Repository exists, fetching updates..."
    git fetch origin
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" origin/"$BRANCH"
    git reset --hard origin/"$BRANCH"
    echo "[INFO] Updated to latest '$BRANCH' branch"
else
    echo "[INFO] Initializing repository in $CODE_DIR..."
    git init
    git remote add origin "$GIT_REPO_URL"
    echo "[INFO] Fetching from remote..."
    git fetch origin
    git checkout -b "$BRANCH" origin/"$BRANCH"
    echo "[INFO] Checked out '$BRANCH' branch successfully"
fi

# -----------------------------------------------------------------------------
# Ensure required subdirectories exist
# These may already exist from volume mounts
# -----------------------------------------------------------------------------
echo "[INFO] Ensuring application directories exist..."
mkdir -p "$CODE_DIR/data"
mkdir -p "$CODE_DIR/logs"
mkdir -p "$CODE_DIR/config"

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
echo "[INFO] Data:        $CODE_DIR/data"
echo "[INFO] Logs:        $CODE_DIR/logs"
echo "[INFO] Config:      $CODE_DIR/config"
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
