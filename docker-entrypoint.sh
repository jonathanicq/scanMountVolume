#!/bin/bash
set -e

# =============================================================================
# scanMountVolume - Docker Entrypoint Script
# =============================================================================
# This script runs when the container starts and ensures the correct branch
# is checked out based on the APP_ENV environment variable.
#
# Directory structure:
#   /opt/docker/scanMountVolume/scanMountVolume/code/   - Git repository (source)
#   /opt/docker/scanMountVolume/scanMountVolume/data/   - Persistent data
#   /opt/docker/scanMountVolume/scanMountVolume/logs/   - Application logs
#   /opt/docker/scanMountVolume/scanMountVolume/config/ - Configuration files
# =============================================================================

APP_BASE="/opt/docker/scanMountVolume/scanMountVolume"
CODE_DIR="$APP_BASE/code"
DATA_DIR="$APP_BASE/data"
LOGS_DIR="$APP_BASE/logs"
CONFIG_DIR="$APP_BASE/config"
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
# Ensure code directory exists and is clean
# -----------------------------------------------------------------------------
echo "[INFO] Preparing code directory: $CODE_DIR"
mkdir -p "$CODE_DIR"

# -----------------------------------------------------------------------------
# Initialize or update repository
# Handles all edge cases: empty dir, non-git dir with files, existing repo
# -----------------------------------------------------------------------------
cd "$CODE_DIR"

if [ -d "$CODE_DIR/.git" ]; then
    echo "[INFO] Repository exists, fetching updates..."
    git fetch origin
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" origin/"$BRANCH"
    git reset --hard origin/"$BRANCH"
    echo "[INFO] Updated to latest '$BRANCH' branch"
else
    # Check if directory has files (but no .git)
    if [ "$(ls -A "$CODE_DIR" 2>/dev/null)" ]; then
        echo "[WARN] Directory not empty but not a git repo. Cleaning..."
        rm -rf "$CODE_DIR"/*
        rm -rf "$CODE_DIR"/.[!.]* 2>/dev/null || true
    fi

    echo "[INFO] Cloning repository to $CODE_DIR..."
    cd /tmp
    rm -rf /tmp/repo_clone
    git clone --branch "$BRANCH" --single-branch "$GIT_REPO_URL" /tmp/repo_clone

    echo "[INFO] Moving code to $CODE_DIR..."
    mv /tmp/repo_clone/.git "$CODE_DIR/"
    mv /tmp/repo_clone/* "$CODE_DIR/" 2>/dev/null || true
    mv /tmp/repo_clone/.[!.]* "$CODE_DIR/" 2>/dev/null || true
    rm -rf /tmp/repo_clone

    cd "$CODE_DIR"
    git checkout "$BRANCH"
    echo "[INFO] Checked out '$BRANCH' branch successfully"
fi

# -----------------------------------------------------------------------------
# Ensure required directories exist (mkdir -p won't fail if they exist)
# -----------------------------------------------------------------------------
echo "[INFO] Ensuring application directories exist..."
mkdir -p "$DATA_DIR"
mkdir -p "$LOGS_DIR"
mkdir -p "$CONFIG_DIR"

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
echo "[INFO] Data:        $DATA_DIR"
echo "[INFO] Logs:        $LOGS_DIR"
echo "[INFO] Config:      $CONFIG_DIR"
echo "[INFO] Port:        ${APP_PORT:-8056}"
echo "[INFO] ============================================"

if [ -f "$CODE_DIR/scanmountvolume/main.py" ]; then
    echo "[INFO] Starting application..."
    cd "$CODE_DIR"
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
