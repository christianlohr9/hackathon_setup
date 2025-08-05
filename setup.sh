#!/bin/bash
# Hackathon Infrastructure Setup Script
# Automatisierte Preset-basierte Konfiguration

set -e

# Colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"

# Show usage
show_usage() {
    echo -e "${BLUE}🚀 Hackathon Infrastructure Setup${RESET}"
    echo ""
    echo -e "${YELLOW}Usage:${RESET}"
    echo "  ./setup.sh <preset> [options]"
    echo ""
    echo -e "${YELLOW}Available Presets:${RESET}"
    echo -e "  ${GREEN}ai${RESET}         - AI/LLM Challenge (OpenWebUI, Ollama, Neo4j)"
    echo -e "  ${GREEN}datascience${RESET} - Data Science/ML (Jupyter, PostgreSQL, MinIO)"
    echo -e "  ${GREEN}webapp${RESET}      - Full-Stack Web App (React + FastAPI + DB)"
    echo -e "  ${GREEN}api${RESET}         - API/Backend Only (FastAPI + Database)"
    echo -e "  ${GREEN}graph${RESET}       - Graph Analytics (Neo4j + Jupyter)"
    echo -e "  ${GREEN}mlops${RESET}       - MLOps Stack (MLflow, Jupyter, FastAPI + DB)"
    echo -e "  ${GREEN}demo${RESET}        - Complete Demo Stack (MLflow, Jupyter, Streamlit + API)"
    echo -e "  ${GREEN}custom${RESET}      - Use existing config.env"
    echo ""
    echo -e "${YELLOW}Management Commands:${RESET}"
    echo -e "  ${GREEN}status${RESET}      - Show service status"
    echo -e "  ${GREEN}logs${RESET}        - Show service logs"
    echo -e "  ${GREEN}endpoints${RESET}   - Show service URLs"
    echo -e "  ${GREEN}stop${RESET}        - Stop all services"
    echo -e "  ${GREEN}clean${RESET}       - Clean all containers and data"
    echo -e "  ${GREEN}check-deps${RESET}  - Check if all prerequisites are installed"
    echo ""
    echo -e "${YELLOW}Options:${RESET}"
    echo -e "  ${CYAN}--start-only${RESET}  - Only start services (don't reconfigure)"
    echo -e "  ${CYAN}--stop${RESET}        - Stop services"
    echo -e "  ${CYAN}--restart${RESET}     - Restart services"
    echo -e "  ${CYAN}--dev${RESET}         - Development mode with hot reload"
    echo ""
    echo -e "${YELLOW}Examples:${RESET}"
    echo "  ./setup.sh ai                    # Setup and start AI preset"
    echo "  ./setup.sh datascience --dev     # Data Science in dev mode"
    echo "  ./setup.sh webapp --restart      # Restart web app services"
}

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${RESET}"
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker not found${RESET}"
        echo -e "${YELLOW}Please install Docker Desktop: https://www.docker.com/products/docker-desktop${RESET}"
        exit 1
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose not found${RESET}"
        echo -e "${YELLOW}Please install Docker Compose${RESET}"
        exit 1
    fi
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker daemon is not running${RESET}"
        echo -e "${YELLOW}Please start Docker Desktop${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites met${RESET}"
}

# Create directories
create_directories() {
    echo -e "${YELLOW}📁 Creating directory structure...${RESET}"
    mkdir -p docker k8s data logs config frontend backend scripts
    mkdir -p data/postgres data/neo4j data/uploads data/minio
    mkdir -p config/nginx config/jupyter config/openwebui
    mkdir -p logs
}

# Generate configuration based on preset
create_preset_config() {
    local preset=$1
    echo -e "${YELLOW}📝 Creating $preset configuration...${RESET}"
    
    # Generate unique password
    local db_password="${preset}_$(date +%s)_$(openssl rand -hex 4 2>/dev/null || echo $(date +%s))"
    
    cat > "$CONFIG_FILE" << EOF
# Hackathon Infrastructure Configuration
# Preset: $preset
# Generated: $(date)

# Deployment Mode
DEPLOY_MODE=docker-compose

# Network
NETWORK_NAME=hackathon-network
DOMAIN_NAME=hackathon.local

# Database Configuration
DB_TYPE=postgresql
DB_NAME=hackathon_db
DB_USER=hackathon_user
DB_PASSWORD=$db_password

# External Access
ENABLE_TAILSCALE=false
EOF

    case $preset in
        "ai")
            cat >> "$CONFIG_FILE" << EOF

# Core Services
ENABLE_DATABASE=true
ENABLE_BACKEND=true
ENABLE_FRONTEND=true
ENABLE_REVERSE_PROXY=true

# ML/AI Services
ENABLE_OPENWEBUI=true
ENABLE_JUPYTER=false
ENABLE_NEO4J=true

# Additional Services
ENABLE_MINIO=false
ENABLE_MONITORING=false
ENABLE_REDIS=true

# Resource Limits
MEMORY_LIMIT_BACKEND=1g
MEMORY_LIMIT_FRONTEND=512m
MEMORY_LIMIT_DB=2g
EOF
            ;;
        "datascience")
            cat >> "$CONFIG_FILE" << EOF

# Core Services
ENABLE_DATABASE=true
ENABLE_BACKEND=true
ENABLE_FRONTEND=false
ENABLE_REVERSE_PROXY=true

# ML/AI Services
ENABLE_OPENWEBUI=false
ENABLE_JUPYTER=true
ENABLE_NEO4J=false

# Additional Services
ENABLE_MINIO=true
ENABLE_MONITORING=false
ENABLE_REDIS=true

# Resource Limits
MEMORY_LIMIT_BACKEND=1g
MEMORY_LIMIT_FRONTEND=256m
MEMORY_LIMIT_DB=4g
EOF
            ;;
        "webapp")
            cat >> "$CONFIG_FILE" << EOF

# Core Services
ENABLE_DATABASE=true
ENABLE_BACKEND=true
ENABLE_FRONTEND=true
ENABLE_REVERSE_PROXY=true

# ML/AI Services
ENABLE_OPENWEBUI=false
ENABLE_JUPYTER=false
ENABLE_NEO4J=false

# Additional Services
ENABLE_MINIO=false
ENABLE_MONITORING=false
ENABLE_REDIS=true

# Resource Limits
MEMORY_LIMIT_BACKEND=512m
MEMORY_LIMIT_FRONTEND=512m
MEMORY_LIMIT_DB=1g
EOF
            ;;
        "api")
            cat >> "$CONFIG_FILE" << EOF

# Core Services
ENABLE_DATABASE=true
ENABLE_BACKEND=true
ENABLE_FRONTEND=false
ENABLE_REVERSE_PROXY=true

# ML/AI Services
ENABLE_OPENWEBUI=false
ENABLE_JUPYTER=false
ENABLE_NEO4J=false

# Additional Services
ENABLE_MINIO=false
ENABLE_MONITORING=false
ENABLE_REDIS=true

# Resource Limits
MEMORY_LIMIT_BACKEND=1g
MEMORY_LIMIT_FRONTEND=256m
MEMORY_LIMIT_DB=2g
EOF
            ;;
        "graph")
            cat >> "$CONFIG_FILE" << EOF

# Core Services
ENABLE_DATABASE=true
ENABLE_BACKEND=true
ENABLE_FRONTEND=true
ENABLE_REVERSE_PROXY=true

# ML/AI Services
ENABLE_OPENWEBUI=false
ENABLE_JUPYTER=true
ENABLE_NEO4J=true

# Additional Services
ENABLE_MINIO=false
ENABLE_MONITORING=false
ENABLE_REDIS=true

# Resource Limits
MEMORY_LIMIT_BACKEND=1g
MEMORY_LIMIT_FRONTEND=512m
MEMORY_LIMIT_DB=2g
EOF
            ;;
        "mlops")
            cat >> "$CONFIG_FILE" << EOF

# Core Services
ENABLE_DATABASE=true
ENABLE_BACKEND=true
ENABLE_FRONTEND=false
ENABLE_REVERSE_PROXY=true

# ML/AI Services
ENABLE_OPENWEBUI=false
ENABLE_JUPYTER=true
ENABLE_NEO4J=false
ENABLE_MLFLOW=true

# Additional Services
ENABLE_MINIO=false
ENABLE_MONITORING=false
ENABLE_REDIS=true

# Resource Limits
MEMORY_LIMIT_BACKEND=1g
MEMORY_LIMIT_FRONTEND=256m
MEMORY_LIMIT_DB=2g
EOF
            ;;
        "demo")
            cat >> "$CONFIG_FILE" << EOF

# Core Services
ENABLE_DATABASE=true
ENABLE_BACKEND=true
ENABLE_FRONTEND=false
ENABLE_REVERSE_PROXY=true

# ML/AI Services
ENABLE_OPENWEBUI=false
ENABLE_JUPYTER=true
ENABLE_NEO4J=false
ENABLE_MLFLOW=true
ENABLE_STREAMLIT=true

# Additional Services
ENABLE_MINIO=false
ENABLE_MONITORING=false
ENABLE_REDIS=true

# Resource Limits
MEMORY_LIMIT_BACKEND=1g
MEMORY_LIMIT_FRONTEND=256m
MEMORY_LIMIT_DB=2g
EOF
            ;;
        *)
            echo -e "${RED}❌ Unknown preset: $preset${RESET}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Configuration created: $CONFIG_FILE${RESET}"
}

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo -e "${GREEN}✅ Configuration loaded${RESET}"
    else
        echo -e "${RED}❌ Configuration file not found: $CONFIG_FILE${RESET}"
        exit 1
    fi
}

# Generate Docker Compose files
generate_docker_compose() {
    echo -e "${YELLOW}🐳 Generating Docker Compose configuration...${RESET}"
    
    # Create main docker-compose.yml by sourcing the existing script
    if [ -f "$SCRIPT_DIR/scripts/create-docker-compose.sh" ]; then
        cd "$SCRIPT_DIR" && bash scripts/create-docker-compose.sh
    else
        echo -e "${RED}❌ Docker Compose generation script not found${RESET}"
        exit 1
    fi
}

# Start services
start_services() {
    echo -e "${BLUE}🚀 Starting hackathon services...${RESET}"
    
    cd "$SCRIPT_DIR/docker"
    
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        docker compose up -d
    fi
    
    echo -e "${GREEN}✅ Services started successfully!${RESET}"
    show_endpoints
}

# Stop services
stop_services() {
    echo -e "${RED}🛑 Stopping hackathon services...${RESET}"
    
    cd "$SCRIPT_DIR/docker"
    
    if command -v docker-compose &> /dev/null; then
        docker-compose down
    else
        docker compose down
    fi
    
    echo -e "${GREEN}✅ Services stopped${RESET}"
}

# Show service status
show_status() {
    echo -e "${BLUE}📊 Service Status${RESET}"
    
    cd "$SCRIPT_DIR/docker"
    
    if command -v docker-compose &> /dev/null; then
        docker-compose ps
    else
        docker compose ps
    fi
}

# Show service logs
show_logs() {
    echo -e "${BLUE}📜 Service Logs${RESET}"
    
    cd "$SCRIPT_DIR/docker"
    
    if command -v docker-compose &> /dev/null; then
        docker-compose logs --tail=50 -f
    else
        docker compose logs --tail=50 -f
    fi
}

# Show service endpoints
show_endpoints() {
    echo ""
    echo -e "${GREEN}🌐 Service Endpoints:${RESET}"
    echo -e "  ${CYAN}Frontend:${RESET}     http://localhost"
    echo -e "  ${CYAN}Backend API:${RESET}  http://localhost/api"
    
    if [ "${ENABLE_OPENWEBUI:-false}" = "true" ]; then
        echo -e "  ${CYAN}Open WebUI:${RESET}   http://localhost/webui"
    fi
    
    if [ "${ENABLE_JUPYTER:-false}" = "true" ]; then
        echo -e "  ${CYAN}Jupyter Lab:${RESET}  http://localhost/jupyter (token: hackathon)"
    fi
    
    if [ "${ENABLE_NEO4J:-false}" = "true" ]; then
        echo -e "  ${CYAN}Neo4j:${RESET}        http://localhost:7474 (neo4j/hackathon123)"
    fi
    
    if [ "${ENABLE_MINIO:-false}" = "true" ]; then
        echo -e "  ${CYAN}MinIO:${RESET}        http://localhost:9001 (hackathon/hackathon123)"
    fi
    
    echo -e "  ${CYAN}PostgreSQL:${RESET}   localhost:5432 (${DB_USER:-hackathon_user}/${DB_PASSWORD:-[check config.env]})"
    echo ""
}

# Clean all containers and data
clean_all() {
    echo -e "${RED}🧹 Cleaning up hackathon environment...${RESET}"
    echo -e "${YELLOW}This will delete all containers and data!${RESET}"
    read -p "Are you sure? [y/N] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$SCRIPT_DIR/docker"
        
        if command -v docker-compose &> /dev/null; then
            docker-compose down -v --remove-orphans
        else
            docker compose down -v --remove-orphans
        fi
        
        docker system prune -f
        rm -rf "$SCRIPT_DIR/data" "$SCRIPT_DIR/logs"
        create_directories
        
        echo -e "${GREEN}✅ Cleanup complete${RESET}"
    else
        echo -e "${YELLOW}Cleanup cancelled${RESET}"
    fi
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    local command=$1
    local option=${2:-}
    
    case $command in
        "ai"|"datascience"|"webapp"|"api"|"graph"|"mlops"|"demo")
            case $option in
                "--stop")
                    load_config
                    stop_services
                    ;;
                "--start-only")
                    load_config
                    start_services
                    ;;
                "--restart")
                    load_config
                    stop_services
                    sleep 2
                    start_services
                    ;;
                "--dev")
                    echo -e "${YELLOW}🔥 Starting development mode...${RESET}"
                    check_prerequisites
                    create_directories
                    create_preset_config $command
                    load_config
                    generate_docker_compose
                    start_services
                    echo -e "${CYAN}💡 Development mode: Use Ctrl+C to stop services${RESET}"
                    show_logs
                    ;;
                *)
                    echo -e "${BLUE}🚀 Setting up $command preset...${RESET}"
                    check_prerequisites
                    create_directories
                    create_preset_config $command
                    load_config
                    generate_docker_compose
                    start_services
                    ;;
            esac
            ;;
        "custom")
            if [ ! -f "$CONFIG_FILE" ]; then
                echo -e "${RED}❌ No config.env found. Create one first or use a preset.${RESET}"
                exit 1
            fi
            load_config
            generate_docker_compose
            start_services
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "endpoints")
            load_config
            show_endpoints
            ;;
        "stop")
            stop_services
            ;;
        "clean")
            clean_all
            ;;
        "--check-deps"|"check-deps")
            check_prerequisites
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${RESET}"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"