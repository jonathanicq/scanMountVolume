# =============================================================================
# scanMountVolume - Dockerfile
# =============================================================================
# Automatically pulls correct branch based on APP_ENV:
#   - production → master branch
#   - development → dev branch
#
# Directory structure:
#   /opt/docker/scanMountVolume/scanMountVolume/code/   - Git repository (source)
#   /opt/docker/scanMountVolume/scanMountVolume/data/   - Persistent data
#   /opt/docker/scanMountVolume/scanMountVolume/logs/   - Application logs
#   /opt/docker/scanMountVolume/scanMountVolume/config/ - Configuration files
# =============================================================================

FROM python:3.11-slim AS base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Create all application directories (using mkdir -p to prevent errors)
RUN mkdir -p /opt/docker/scanMountVolume/scanMountVolume/code \
             /opt/docker/scanMountVolume/scanMountVolume/data \
             /opt/docker/scanMountVolume/scanMountVolume/logs \
             /opt/docker/scanMountVolume/scanMountVolume/config

WORKDIR /opt/docker/scanMountVolume/scanMountVolume/code

# =============================================================================
# Production stage
# =============================================================================
FROM base AS production

# Copy entrypoint script
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/

# Set default environment
ENV APP_ENV=production \
    APP_HOST=0.0.0.0 \
    APP_PORT=8056 \
    APP_WORKERS=4

EXPOSE 8056

# Health check (disabled until app is implemented)
# HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
#     CMD curl -f http://localhost:${APP_PORT}/health || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]

# =============================================================================
# Development stage
# =============================================================================
FROM base AS development

# Install development dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/

# Set default environment for development
ENV APP_ENV=development \
    APP_HOST=0.0.0.0 \
    APP_PORT=8056 \
    APP_WORKERS=1 \
    APP_DEBUG=true

EXPOSE 8056

# Health check disabled until app is implemented
# HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
#     CMD curl -f http://localhost:${APP_PORT}/health || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
