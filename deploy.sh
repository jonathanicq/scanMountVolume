#!/bin/bash
# =============================================================================
# scanMountVolume - Deployment Script
# =============================================================================
# Usage:
#   ./deploy.sh              # Interactive mode (asks for environment)
#   ./deploy.sh production   # Deploy in production mode
#   ./deploy.sh development  # Deploy in development mode
#   ./deploy.sh stop         # Stop all containers
#   ./deploy.sh restart      # Restart containers
#   ./deploy.sh logs         # View container logs
#   ./deploy.sh status       # Check container status
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------
print_header() {
    echo ""
    echo -e "${BLUE}=============================================================================${NC}"
    echo -e "${BLUE}  scanMountVolume - Deployment Script${NC}"
    echo -e "${BLUE}=============================================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# -----------------------------------------------------------------------------
# Check Prerequisites
# -----------------------------------------------------------------------------
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi

    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi

    print_success "All prerequisites met"
}

# -----------------------------------------------------------------------------
# Setup Environment File
# -----------------------------------------------------------------------------
setup_env_file() {
    if [ ! -f ".env" ]; then
        print_warn ".env file not found"

        if [ -f ".env.example" ]; then
            print_info "Creating .env from .env.example..."
            cp .env.example .env
            print_warn "Please edit .env file with your configuration before continuing"
            print_info "Opening .env for editing..."

            # Try to open with available editor
            if command -v nano &> /dev/null; then
                nano .env
            elif command -v vim &> /dev/null; then
                vim .env
            elif command -v vi &> /dev/null; then
                vi .env
            else
                print_warn "No editor found. Please manually edit .env file"
                print_info "Press Enter after editing .env file..."
                read -r
            fi
        else
            print_error ".env.example not found. Cannot create .env file."
            exit 1
        fi
    fi

    # Source environment file
    set -a
    source .env
    set +a

    print_success "Environment file loaded"
}

# -----------------------------------------------------------------------------
# Select Environment
# -----------------------------------------------------------------------------
select_environment() {
    local env_choice="$1"

    if [ -z "$env_choice" ]; then
        echo ""
        echo "Select deployment environment:"
        echo "  1) production  - Uses 'master' branch, optimized settings"
        echo "  2) development - Uses 'dev' branch, debug enabled"
        echo ""
        read -p "Enter choice [1/2]: " env_choice
    fi

    case "$env_choice" in
        1|production|prod)
            APP_ENV="production"
            ;;
        2|development|dev)
            APP_ENV="development"
            ;;
        *)
            print_error "Invalid choice. Please select 1 (production) or 2 (development)"
            exit 1
            ;;
    esac

    # Update .env file with selected environment
    if grep -q "^APP_ENV=" .env; then
        sed -i "s/^APP_ENV=.*/APP_ENV=$APP_ENV/" .env
    else
        echo "APP_ENV=$APP_ENV" >> .env
    fi

    print_info "Environment set to: $APP_ENV"
}

# -----------------------------------------------------------------------------
# Build and Start Containers
# -----------------------------------------------------------------------------
build_and_start() {
    print_info "Building Docker image for $APP_ENV environment..."

    # Determine which docker-compose command to use
    if docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        COMPOSE_CMD="docker-compose"
    fi

    # Build with target based on environment
    print_info "Building image..."
    $COMPOSE_CMD build --build-arg APP_ENV="$APP_ENV"

    print_info "Starting containers..."
    $COMPOSE_CMD up -d

    # Wait for container to be healthy
    print_info "Waiting for container to be ready..."
    sleep 5

    # Check container status
    if $COMPOSE_CMD ps | grep -q "Up"; then
        print_success "Container started successfully!"
    else
        print_error "Container failed to start. Check logs with: ./deploy.sh logs"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Stop Containers
# -----------------------------------------------------------------------------
stop_containers() {
    print_info "Stopping containers..."

    if docker compose version &> /dev/null; then
        docker compose down
    else
        docker-compose down
    fi

    print_success "Containers stopped"
}

# -----------------------------------------------------------------------------
# Restart Containers
# -----------------------------------------------------------------------------
restart_containers() {
    print_info "Restarting containers..."

    if docker compose version &> /dev/null; then
        docker compose restart
    else
        docker-compose restart
    fi

    print_success "Containers restarted"
}

# -----------------------------------------------------------------------------
# Show Logs
# -----------------------------------------------------------------------------
show_logs() {
    print_info "Showing container logs (Ctrl+C to exit)..."

    if docker compose version &> /dev/null; then
        docker compose logs -f
    else
        docker-compose logs -f
    fi
}

# -----------------------------------------------------------------------------
# Show Status
# -----------------------------------------------------------------------------
show_status() {
    print_info "Container status:"
    echo ""

    if docker compose version &> /dev/null; then
        docker compose ps
    else
        docker-compose ps
    fi

    echo ""

    # Show environment info
    if [ -f ".env" ]; then
        set -a
        source .env
        set +a

        echo -e "${BLUE}Environment:${NC} $APP_ENV"
        echo -e "${BLUE}Branch:${NC} $([ "$APP_ENV" = "production" ] && echo "master" || echo "dev")"
        echo -e "${BLUE}Web URL:${NC} http://localhost:${APP_PORT:-8056}"
    fi
}

# -----------------------------------------------------------------------------
# Print Final Information
# -----------------------------------------------------------------------------
print_final_info() {
    local branch=$([ "$APP_ENV" = "production" ] && echo "master" || echo "dev")

    echo ""
    echo -e "${GREEN}=============================================================================${NC}"
    echo -e "${GREEN}  Deployment Complete!${NC}"
    echo -e "${GREEN}=============================================================================${NC}"
    echo ""
    echo -e "  ${BLUE}Environment:${NC}  $APP_ENV"
    echo -e "  ${BLUE}Git Branch:${NC}   $branch"
    echo -e "  ${BLUE}Web URL:${NC}      http://localhost:${APP_PORT:-8056}"
    echo ""
    echo -e "  ${YELLOW}Commands:${NC}"
    echo "    ./deploy.sh logs     - View logs"
    echo "    ./deploy.sh status   - Check status"
    echo "    ./deploy.sh restart  - Restart containers"
    echo "    ./deploy.sh stop     - Stop containers"
    echo ""
}

# -----------------------------------------------------------------------------
# Main Script
# -----------------------------------------------------------------------------
main() {
    print_header

    case "${1:-}" in
        stop)
            stop_containers
            ;;
        restart)
            restart_containers
            ;;
        logs)
            show_logs
            ;;
        status)
            show_status
            ;;
        production|prod|development|dev)
            check_prerequisites
            setup_env_file
            select_environment "$1"
            build_and_start
            print_final_info
            ;;
        "")
            check_prerequisites
            setup_env_file
            select_environment ""
            build_and_start
            print_final_info
            ;;
        *)
            echo "Usage: $0 [production|development|stop|restart|logs|status]"
            echo ""
            echo "Commands:"
            echo "  production   Deploy in production mode (master branch)"
            echo "  development  Deploy in development mode (dev branch)"
            echo "  stop         Stop all containers"
            echo "  restart      Restart containers"
            echo "  logs         View container logs"
            echo "  status       Check container status"
            echo ""
            echo "Run without arguments for interactive mode."
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
