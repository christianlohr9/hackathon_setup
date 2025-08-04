# Hackathon Infrastructure Setup

This project provides automated infrastructure setup for hackathons with multiple preconfigured presets.

## [setup-ai]() Setup AI/LLM preset with OpenWebUI, Ollama, and Neo4j

```bash
./setup.sh ai
```

## [setup-datascience]() Setup Data Science preset with Jupyter, PostgreSQL, and MinIO

```bash
./setup.sh datascience
```

## [setup-webapp]() Setup Full-Stack Web App preset with React + FastAPI + Database

```bash
./setup.sh webapp
```

## [setup-api]() Setup API/Backend Only preset with FastAPI + Database

```bash
./setup.sh api
```

## [setup-graph]() Setup Graph Analytics preset with Neo4j + Jupyter

```bash
./setup.sh graph
```

## [dev-ai]() Start AI preset in development mode with hot reload

```bash
./setup.sh ai --dev
```

## [dev-datascience]() Start Data Science preset in development mode

```bash
./setup.sh datascience --dev
```

## [dev-webapp]() Start Web App preset in development mode

```bash
./setup.sh webapp --dev
```

## [status]() Show status of all running services

```bash
./setup.sh status
```

## [logs]() Show logs from all services (follow mode)

```bash
./setup.sh logs
```

## [endpoints]() Show all service endpoints and access information

```bash
./setup.sh endpoints
```

## [stop]() Stop all running services

```bash
./setup.sh stop
```

## [restart-ai]() Restart AI preset services

```bash
./setup.sh ai --restart
```

## [restart-webapp]() Restart Web App preset services

```bash
./setup.sh webapp --restart
```

## [clean]() Clean all containers and data (WARNING: destructive)

```bash
./setup.sh clean
```

## [check-deps]() Check if all prerequisites are installed

```bash
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found"
    echo "Please install Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running"
    echo "Please start Docker Desktop"
    exit 1
fi

echo "✅ All prerequisites met"
```

## [build-backend]() Build only the backend service

```bash
cd docker && docker compose build backend
```

## [build-frontend]() Build only the frontend service

```bash
cd docker && docker compose build frontend
```

## [build-all]() Build all services

```bash
cd docker && docker compose build
```

## [shell-backend]() Open a shell in the backend container

```bash
docker exec -it hackathon-backend /bin/bash
```

## [shell-postgres]() Open a psql shell in the PostgreSQL container

```bash
docker exec -it hackathon-postgres psql -U hackathon_user -d hackathon_db
```

## [shell-redis]() Open a redis-cli shell in the Redis container

```bash
docker exec -it hackathon-redis redis-cli
```

## [backup-db]() Backup PostgreSQL database

```bash
timestamp=$(date +%Y%m%d_%H%M%S)
docker exec hackathon-postgres pg_dump -U hackathon_user hackathon_db > "backup_${timestamp}.sql"
echo "Database backed up to backup_${timestamp}.sql"
```

## [test-services]() Test all service endpoints

```bash
echo "Testing services..."

if curl -s http://localhost/api/health > /dev/null; then
    echo "✅ Backend API: healthy"
else
    echo "❌ Backend API: not responding"
fi

if curl -s http://localhost > /dev/null; then
    echo "✅ Frontend: healthy"
else
    echo "❌ Frontend: not responding"
fi

if docker exec hackathon-postgres pg_isready -U hackathon_user > /dev/null 2>&1; then
    echo "✅ PostgreSQL: healthy"
else
    echo "❌ PostgreSQL: not responding"
fi

if docker exec hackathon-redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis: healthy"
else
    echo "❌ Redis: not responding"
fi
```

## [monitor]() Show resource usage of all containers

```bash
docker stats
```

## [update]() Pull latest images and restart services

```bash
cd docker
docker compose pull
docker compose up -d
```

## [enable-openwebui]() Enable OpenWebUI service

```bash
sed -i '' 's/ENABLE_OPENWEBUI=false/ENABLE_OPENWEBUI=true/' config.env
echo "✅ OpenWebUI enabled. Run 'm restart' to apply changes."
```

## [disable-openwebui]() Disable OpenWebUI service

```bash
sed -i '' 's/ENABLE_OPENWEBUI=true/ENABLE_OPENWEBUI=false/' config.env
echo "✅ OpenWebUI disabled. Run 'm restart' to apply changes."
```

## [enable-jupyter]() Enable Jupyter Lab service

```bash
sed -i '' 's/ENABLE_JUPYTER=false/ENABLE_JUPYTER=true/' config.env
echo "✅ Jupyter Lab enabled. Run 'm restart' to apply changes."
```

## [disable-jupyter]() Disable Jupyter Lab service

```bash
sed -i '' 's/ENABLE_JUPYTER=true/ENABLE_JUPYTER=false/' config.env
echo "✅ Jupyter Lab disabled. Run 'm restart' to apply changes."
```

## [enable-neo4j]() Enable Neo4j service

```bash
sed -i '' 's/ENABLE_NEO4J=false/ENABLE_NEO4J=true/' config.env
echo "✅ Neo4j enabled. Run 'm restart' to apply changes."
```

## [disable-neo4j]() Disable Neo4j service

```bash
sed -i '' 's/ENABLE_NEO4J=true/ENABLE_NEO4J=false/' config.env
echo "✅ Neo4j disabled. Run 'm restart' to apply changes."
```

## [enable-minio]() Enable MinIO service

```bash
sed -i '' 's/ENABLE_MINIO=false/ENABLE_MINIO=true/' config.env
echo "✅ MinIO enabled. Run 'm restart' to apply changes."
```

## [disable-minio]() Disable MinIO service

```bash
sed -i '' 's/ENABLE_MINIO=true/ENABLE_MINIO=false/' config.env
echo "✅ MinIO disabled. Run 'm restart' to apply changes."
```

## [enable-frontend]() Enable React frontend service

```bash
sed -i '' 's/ENABLE_FRONTEND=false/ENABLE_FRONTEND=true/' config.env
echo "✅ Frontend enabled. Run 'm restart' to apply changes."
```

## [disable-frontend]() Disable React frontend service

```bash
sed -i '' 's/ENABLE_FRONTEND=true/ENABLE_FRONTEND=false/' config.env
echo "✅ Frontend disabled. Run 'm restart' to apply changes."
```

## [show-config]() Show current service configuration

```bash
echo "🔧 Current Service Configuration:"
echo ""
grep "ENABLE_" config.env | while read line; do
    service=$(echo $line | cut -d'=' -f1 | sed 's/ENABLE_//')
    status=$(echo $line | cut -d'=' -f2)
    if [ "$status" = "true" ]; then
        echo "✅ $service: enabled"
    else
        echo "❌ $service: disabled"
    fi
done
```

## [config-datascience]() Configure for Data Science (Jupyter + MinIO, no OpenWebUI/Neo4j)

```bash
sed -i '' 's/ENABLE_OPENWEBUI=true/ENABLE_OPENWEBUI=false/' config.env
sed -i '' 's/ENABLE_NEO4J=true/ENABLE_NEO4J=false/' config.env
sed -i '' 's/ENABLE_JUPYTER=false/ENABLE_JUPYTER=true/' config.env
sed -i '' 's/ENABLE_MINIO=false/ENABLE_MINIO=true/' config.env
echo "✅ Configured for Data Science: Jupyter + MinIO enabled, OpenWebUI + Neo4j disabled"
echo "Run 'm restart' to apply changes."
```

## [config-minimal]() Minimal configuration (only Backend + Database)

```bash
sed -i '' 's/ENABLE_OPENWEBUI=true/ENABLE_OPENWEBUI=false/' config.env
sed -i '' 's/ENABLE_NEO4J=true/ENABLE_NEO4J=false/' config.env
sed -i '' 's/ENABLE_JUPYTER=true/ENABLE_JUPYTER=false/' config.env
sed -i '' 's/ENABLE_MINIO=true/ENABLE_MINIO=false/' config.env
sed -i '' 's/ENABLE_FRONTEND=true/ENABLE_FRONTEND=false/' config.env
echo "✅ Minimal configuration: Only Backend + Database + Redis"
echo "Run 'm restart' to apply changes."
```

## [config-fullstack]() Full-stack web configuration (Frontend + Backend + Database)

```bash
sed -i '' 's/ENABLE_OPENWEBUI=true/ENABLE_OPENWEBUI=false/' config.env
sed -i '' 's/ENABLE_NEO4J=true/ENABLE_NEO4J=false/' config.env
sed -i '' 's/ENABLE_JUPYTER=true/ENABLE_JUPYTER=false/' config.env
sed -i '' 's/ENABLE_MINIO=true/ENABLE_MINIO=false/' config.env
sed -i '' 's/ENABLE_FRONTEND=false/ENABLE_FRONTEND=true/' config.env
echo "✅ Full-stack configuration: Frontend + Backend + Database + Redis"
echo "Run 'm restart' to apply changes."
```

## [restart]() Restart services with current configuration

```bash
./setup.sh ai --restart
```

## [interactive-config]() Interactive service configuration

```bash
echo "🔧 Interactive Service Configuration"
echo ""

current_openwebui=$(grep "ENABLE_OPENWEBUI" config.env | cut -d'=' -f2)
echo "OpenWebUI currently: $current_openwebui"
read -p "Enable OpenWebUI? (y/n): " openwebui_choice
if [[ $openwebui_choice =~ ^[Yy]$ ]]; then
    sed -i '' 's/ENABLE_OPENWEBUI=.*/ENABLE_OPENWEBUI=true/' config.env
else
    sed -i '' 's/ENABLE_OPENWEBUI=.*/ENABLE_OPENWEBUI=false/' config.env
fi

current_jupyter=$(grep "ENABLE_JUPYTER" config.env | cut -d'=' -f2)
echo "Jupyter currently: $current_jupyter"
read -p "Enable Jupyter Lab? (y/n): " jupyter_choice
if [[ $jupyter_choice =~ ^[Yy]$ ]]; then
    sed -i '' 's/ENABLE_JUPYTER=.*/ENABLE_JUPYTER=true/' config.env
else
    sed -i '' 's/ENABLE_JUPYTER=.*/ENABLE_JUPYTER=false/' config.env
fi

current_neo4j=$(grep "ENABLE_NEO4J" config.env | cut -d'=' -f2)
echo "Neo4j currently: $current_neo4j"
read -p "Enable Neo4j? (y/n): " neo4j_choice
if [[ $neo4j_choice =~ ^[Yy]$ ]]; then
    sed -i '' 's/ENABLE_NEO4J=.*/ENABLE_NEO4J=true/' config.env
else
    sed -i '' 's/ENABLE_NEO4J=.*/ENABLE_NEO4J=false/' config.env
fi

current_minio=$(grep "ENABLE_MINIO" config.env | cut -d'=' -f2)
echo "MinIO currently: $current_minio"
read -p "Enable MinIO? (y/n): " minio_choice
if [[ $minio_choice =~ ^[Yy]$ ]]; then
    sed -i '' 's/ENABLE_MINIO=.*/ENABLE_MINIO=true/' config.env
else
    sed -i '' 's/ENABLE_MINIO=.*/ENABLE_MINIO=false/' config.env
fi

current_frontend=$(grep "ENABLE_FRONTEND" config.env | cut -d'=' -f2)
echo "Frontend currently: $current_frontend"
read -p "Enable Frontend? (y/n): " frontend_choice
if [[ $frontend_choice =~ ^[Yy]$ ]]; then
    sed -i '' 's/ENABLE_FRONTEND=.*/ENABLE_FRONTEND=true/' config.env
else
    sed -i '' 's/ENABLE_FRONTEND=.*/ENABLE_FRONTEND=false/' config.env
fi

echo ""
echo "✅ Configuration updated! New settings:"
makedown show-config
echo ""
read -p "Restart services now? (y/n): " restart_choice
if [[ $restart_choice =~ ^[Yy]$ ]]; then
    ./setup.sh ai --restart
fi
```

## [help]() Show detailed help information

```bash
cat << 'HELP'
🚀 Hackathon Infrastructure Setup

Available Presets:
  ai         - AI/LLM Challenge (OpenWebUI, Ollama, Neo4j)
  datascience - Data Science/ML (Jupyter, PostgreSQL, MinIO)
  webapp     - Full-Stack Web App (React + FastAPI + DB)
  api        - API/Backend Only (FastAPI + Database)
  graph      - Graph Analytics (Neo4j + Jupyter)

Setup Commands:
  m setup-ai              # Setup AI preset
  m dev-ai                # Start AI preset in dev mode
  m setup-datascience     # Setup Data Science preset
  m setup-webapp          # Setup Web App preset

Service Configuration:
  m show-config           # Show current services
  m interactive-config    # Interactive configuration
  m config-datascience    # Configure for Data Science
  m config-minimal        # Minimal setup (Backend only)
  m config-fullstack      # Full-stack web setup
  
Individual Services:
  m enable-openwebui      # Enable OpenWebUI
  m disable-openwebui     # Disable OpenWebUI
  m enable-jupyter        # Enable Jupyter Lab
  m disable-jupyter       # Disable Jupyter Lab
  m enable-neo4j          # Enable Neo4j
  m disable-neo4j         # Disable Neo4j
  m enable-minio          # Enable MinIO
  m disable-minio         # Disable MinIO

Management Commands:
  m status                # Show service status
  m logs                  # Show service logs
  m endpoints             # Show service URLs
  m stop                  # Stop all services
  m restart               # Restart with current config
  m clean                 # Clean everything (destructive)

Development Commands:
  m build-backend         # Build backend only
  m shell-backend         # Shell into backend container
  m test-services         # Test all endpoints
  m backup-db             # Backup database

For more commands, run: makedown --help

Example Workflows:
  # Data Science only
  m setup-ai
  m config-datascience
  m restart

  # Minimal Backend API
  m setup-api
  m config-minimal
  m restart
HELP
```