# =============================================================================
# scanMountVolume - Dockerfile
# =============================================================================
# Multi-stage build for optimized production image
# Automatically pulls correct branch based on APP_ENV:
#   - production → master branch
#   - development → dev branch
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
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Create non-root user for security
RUN useradd --create-home --shell /bin/bash appuser

# =============================================================================
# Production stage
# =============================================================================
FROM base AS production

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set default environment
ENV APP_ENV=production \
    APP_HOST=0.0.0.0 \
    APP_PORT=8056 \
    APP_WORKERS=4

# Expose port
EXPOSE 8056

# Change ownership and switch to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/health || exit 1

# Entrypoint handles git clone/pull based on APP_ENV
ENTRYPOINT ["docker-entrypoint.sh"]

# =============================================================================
# Development stage
# =============================================================================
FROM base AS development

# Install development dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set default environment for development
ENV APP_ENV=development \
    APP_HOST=0.0.0.0 \
    APP_PORT=8056 \
    APP_WORKERS=1 \
    APP_DEBUG=true

# Expose port
EXPOSE 8056

# For development, we might want to run as root for easier debugging
# In production, always use non-root user

ENTRYPOINT ["docker-entrypoint.sh"]
