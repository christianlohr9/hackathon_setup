#!/bin/bash
# Interactive Hackathon Setup Script
# Allows team to configure services based on challenge requirements

# Colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
RESET='\033[0m'

CONFIG_FILE="config.env"
TEMP_CONFIG=$(mktemp)

echo -e "${BLUE}🎛️  Hackathon Infrastructure Configuration${RESET}"
echo -e "${YELLOW}Configure your environment based on your challenge needs${RESET}"
echo ""

# Function to ask yes/no questions
ask_yes_no() {
    local question=$1
    local default=$2
    local response
    
    while true; do
        if [ "$default" = "true" ]; then
            echo -ne "${question} [Y/n]: "
        else
            echo -ne "${question} [y/N]: "
        fi
        
        read -r response
        case $response in
            [Yy]* ) echo "true"; return;;
            [Nn]* ) echo "false"; return;;
            "" ) echo "$default"; return;;
            * ) echo -e "${RED}Please answer yes or no.${RESET}";;
        esac
    done
}

# Function to ask for input with default
ask_input() {
    local question=$1
    local default=$2
    local response
    
    echo -ne "${question} [${default}]: "
    read -r response
    echo "${response:-$default}"
}

# Function to select from options
select_option() {
    local question=$1
    shift
    local options=("$@")
    
    echo -e "${question}"
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[$i]}"
    done
    
    while true; do
        echo -ne "Select option [1-${#options[@]}]: "
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            echo "${options[$((choice-1))]}"
            return
        else
            echo -e "${RED}Invalid selection. Please choose 1-${#options[@]}.${RESET}"
        fi
    done
}

echo -e "${BLUE}=== Deployment Configuration ===${RESET}"

# Deployment mode
DEPLOY_MODE=$(select_option "Choose deployment mode:" "docker-compose" "k8s")
echo "DEPLOY_MODE=$DEPLOY_MODE" > "$TEMP_CONFIG"

echo ""
echo -e "${BLUE}=== Challenge Type Detection ===${RESET}"

# Detect challenge type based on common patterns
echo -e "What type of challenge are you working on?"
CHALLENGE_TYPE=$(select_option "Select challenge type:" \
    "AI/LLM Challenge (OpenWebUI, Ollama, Vector DB)" \
    "Data Science/ML (Jupyter, PostgreSQL, PyTorch)" \
    "Graph Analytics (Neo4j, Graph RAG)" \
    "Full-Stack Web App (Frontend + Backend + DB)" \
    "API/Backend Only (FastAPI, Database)" \
    "Custom Configuration")

echo ""
echo -e "${BLUE}=== Core Services ===${RESET}"

# Core services based on challenge type
case $CHALLENGE_TYPE in
    "AI/LLM Challenge"*)
        ENABLE_DATABASE="true"
        ENABLE_BACKEND="true"
        ENABLE_FRONTEND="true"
        ENABLE_OPENWEBUI="true"
        ENABLE_JUPYTER="false"
        ENABLE_NEO4J="true"
        ;;
    "Data Science/ML"*)
        ENABLE_DATABASE="true"
        ENABLE_BACKEND="true"
        ENABLE_FRONTEND="false"
        ENABLE_OPENWEBUI="false"
        ENABLE_JUPYTER="true"
        ENABLE_NEO4J="false"
        ;;
    "Graph Analytics"*)
        ENABLE_DATABASE="true"
        ENABLE_BACKEND="true"
        ENABLE_FRONTEND="true"
        ENABLE_OPENWEBUI="false"
        ENABLE_JUPYTER="true"
        ENABLE_NEO4J="true"
        ;;
    "Full-Stack Web App"*)
        ENABLE_DATABASE="true"
        ENABLE_BACKEND="true"
        ENABLE_FRONTEND="true"
        ENABLE_OPENWEBUI="false"
        ENABLE_JUPYTER="false"
        ENABLE_NEO4J="false"
        ;;
    "API/Backend Only"*)
        ENABLE_DATABASE="true"
        ENABLE_BACKEND="true"
        ENABLE_FRONTEND="false"
        ENABLE_OPENWEBUI="false"
        ENABLE_JUPYTER="false"
        ENABLE_NEO4J="false"
        ;;
    *)
        # Custom configuration
        ENABLE_DATABASE=$(ask_yes_no "Enable Database (PostgreSQL + Redis)?" "true")
        ENABLE_BACKEND=$(ask_yes_no "Enable Backend API (FastAPI)?" "true")
        ENABLE_FRONTEND=$(ask_yes_no "Enable Frontend (React/TypeScript)?" "true")
        ENABLE_OPENWEBUI=$(ask_yes_no "Enable Open WebUI for LLM interactions?" "false")
        ENABLE_JUPYTER=$(ask_yes_no "Enable Jupyter Lab for data exploration?" "false")
        ENABLE_NEO4J=$(ask_yes_no "Enable Neo4j for Graph RAG?" "false")
        ;;
esac

# Always ask about reverse proxy and external access
ENABLE_REVERSE_PROXY=$(ask_yes_no "Enable reverse proxy (recommended)?" "true")

echo ""
echo -e "${BLUE}=== Database Configuration ===${RESET}"

if [ "$ENABLE_DATABASE" = "true" ]; then
    DB_TYPE=$(select_option "Choose database type:" "postgresql" "mysql" "mongodb")
    DB_NAME=$(ask_input "Database name" "hackathon_db")
    DB_USER=$(ask_input "Database user" "hackathon_user")
    
    # Generate random password
    DB_PASSWORD=$(openssl rand -base64 12 2>/dev/null || echo "hackathon_$(date +%s)")
    echo -e "${YELLOW}Generated database password: ${DB_PASSWORD}${RESET}"
else
    DB_TYPE="postgresql"
    DB_NAME="hackathon_db" 
    DB_USER="hackathon_user"
    DB_PASSWORD="hackathon_pass"
fi

echo ""
echo -e "${BLUE}=== External Access ===${RESET}"

ENABLE_TAILSCALE=$(ask_yes_no "Setup Tailscale for external access?" "false")
DOMAIN_NAME=$(ask_input "Domain name for services" "hackathon.local")

echo ""
echo -e "${BLUE}=== Resource Configuration ===${RESET}"

# Resource limits based on team size
echo -e "How many team members will be working simultaneously?"
TEAM_SIZE=$(select_option "Select team size:" "2-3 people (Light)" "4-5 people (Medium)" "6+ people (Heavy)")

case $TEAM_SIZE in
    *"Light"*)
        MEMORY_LIMIT_BACKEND="512m"
        MEMORY_LIMIT_FRONTEND="256m"
        MEMORY_LIMIT_DB="1g"
        ;;
    *"Medium"*)
        MEMORY_LIMIT_BACKEND="1g"
        MEMORY_LIMIT_FRONTEND="512m"
        MEMORY_LIMIT_DB="2g"
        ;;
    *"Heavy"*)
        MEMORY_LIMIT_BACKEND="2g"
        MEMORY_LIMIT_FRONTEND="1g"
        MEMORY_LIMIT_DB="4g"
        ;;
esac

# Additional services
echo ""
echo -e "${BLUE}=== Additional Services ===${RESET}"

ENABLE_MINIO=$(ask_yes_no "Enable MinIO for file storage?" "false")
ENABLE_MONITORING=$(ask_yes_no "Enable monitoring (Grafana/Prometheus)?" "false")

# Write configuration
cat >> "$TEMP_CONFIG" << EOF

# Core Services
ENABLE_DATABASE=$ENABLE_DATABASE
ENABLE_BACKEND=$ENABLE_BACKEND
ENABLE_FRONTEND=$ENABLE_FRONTEND
ENABLE_REVERSE_PROXY=$ENABLE_REVERSE_PROXY

# ML/AI Services
ENABLE_OPENWEBUI=$ENABLE_OPENWEBUI
ENABLE_JUPYTER=$ENABLE_JUPYTER
ENABLE_NEO4J=$ENABLE_NEO4J

# Additional Services
ENABLE_MINIO=$ENABLE_MINIO
ENABLE_MONITORING=$ENABLE_MONITORING

# Database Configuration
DB_TYPE=$DB_TYPE
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD

# External Access
ENABLE_TAILSCALE=$ENABLE_TAILSCALE
DOMAIN_NAME=$DOMAIN_NAME

# Resource Limits
MEMORY_LIMIT_BACKEND=$MEMORY_LIMIT_BACKEND
MEMORY_LIMIT_FRONTEND=$MEMORY_LIMIT_FRONTEND
MEMORY_LIMIT_DB=$MEMORY_LIMIT_DB

# Network
NETWORK_NAME=hackathon-network
EOF

# Generate docker-compose override based on configuration
echo ""
echo -e "${YELLOW}🔧 Generating optimized Docker Compose configuration...${RESET}"

create_docker_override() {
    cat > docker/docker-compose.override.yml << EOF
version: '3.8'

services:
EOF

    # Only include enabled services
    if [ "$ENABLE_DATABASE" = "false" ]; then
        cat >> docker/docker-compose.override.yml << EOF
  postgres:
    deploy:
      replicas: 0
  redis:
    deploy:
      replicas: 0
EOF
    fi

    if [ "$ENABLE_BACKEND" = "false" ]; then
        cat >> docker/docker-compose.override.yml << EOF
  backend:
    deploy:
      replicas: 0
EOF
    fi

    if [ "$ENABLE_FRONTEND" = "false" ]; then
        cat >> docker/docker-compose.override.yml << EOF
  frontend:
    deploy:
      replicas: 0
EOF
    fi

    if [ "$ENABLE_OPENWEBUI" = "false" ]; then
        cat >> docker/docker-compose.override.yml << EOF
  open-webui:
    deploy:
      replicas: 0
  ollama:
    deploy:
      replicas: 0
EOF
    fi

    if [ "$ENABLE_JUPYTER" = "false" ]; then
        cat >> docker/docker-compose.override.yml << EOF
  jupyterlab:
    deploy:
      replicas: 0
EOF
    fi

    if [ "$ENABLE_NEO4J" = "false" ]; then
        cat >> docker/docker-compose.override.yml << EOF
  neo4j:
    deploy:
      replicas: 0
EOF
    fi

    if [ "$ENABLE_MINIO" = "false" ]; then
        cat >> docker/docker-compose.override.yml << EOF
  minio:
    deploy:
      replicas: 0
EOF
    fi
}

create_docker_override

# Generate project structure based on configuration
echo ""
echo -e "${YELLOW}📁 Creating project structure...${RESET}"

create_project_structure() {
    # Backend structure
    if [ "$ENABLE_BACKEND" = "true" ]; then
        mkdir -p backend/{app,tests,scripts}
        mkdir -p backend/app/{api,core,models,services,utils}
        
        # Create basic FastAPI structure
        cat > backend/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
EOF

        cat > backend/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
redis==5.0.1
pydantic==2.5.0
pydantic-settings==2.1.0
python-multipart==0.0.6
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
httpx==0.25.2
pandas==2.1.4
numpy==1.24.4
scikit-learn==1.3.2
torch==2.1.1
transformers==4.36.2
langchain==0.0.350
openai==1.3.7
neo4j==5.15.0
pytest==7.4.3
pytest-asyncio==0.21.1
EOF

        cat > backend/app/main.py << 'EOF'
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os

app = FastAPI(title="Hackathon API", version="1.0.0")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class HealthResponse(BaseModel):
    status: str
    environment: str

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        environment=os.getenv("ENVIRONMENT", "development")
    )

@app.get("/")
async def root():
    return {"message": "Hackathon API is running!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF
    fi

    # Frontend structure
    if [ "$ENABLE_FRONTEND" = "true" ]; then
        mkdir -p frontend/{src,public,tests}
        mkdir -p frontend/src/{components,pages,services,utils,types}
        
        cat > frontend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

        cat > frontend/package.json << 'EOF'
{
  "name": "hackathon-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@types/node": "^20.10.0",
    "@types/react": "^18.2.42",
    "@types/react-dom": "^18.2.17",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.1",
    "react-scripts": "5.0.1",
    "typescript": "^5.3.2",
    "axios": "^1.6.2",
    "@mui/material": "^5.15.0",
    "@emotion/react": "^11.11.1",
    "@emotion/styled": "^11.11.0",
    "web-vitals": "^3.5.0"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

        cat > frontend/src/App.tsx << 'EOF'
import React, { useEffect, useState } from 'react';
import { Container, Typography, Card, CardContent, Button, Box } from '@mui/material';

interface HealthStatus {
  status: string;
  environment: string;
}

function App() {
  const [health, setHealth] = useState<HealthStatus | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkHealth();
  }, []);

  const checkHealth = async () => {
    try {
      const response = await fetch('/api/health');
      const data = await response.json();
      setHealth(data);
    } catch (error) {
      console.error('Health check failed:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="md" sx={{ mt: 4 }}>
      <Typography variant="h2" component="h1" gutterBottom align="center">
        🚀 Hackathon Frontend
      </Typography>
      
      <Card sx={{ mt: 4 }}>
        <CardContent>
          <Typography variant="h5" component="h2" gutterBottom>
            System Status
          </Typography>
          {loading ? (
            <Typography>Checking system health...</Typography>
          ) : health ? (
            <Box>
              <Typography color="success.main">
                ✅ Backend Status: {health.status}
              </Typography>
              <Typography>
                Environment: {health.environment}
              </Typography>
            </Box>
          ) : (
            <Typography color="error">
              ❌ Backend connection failed
            </Typography>
          )}
          
          <Button 
            variant="contained" 
            onClick={checkHealth} 
            sx={{ mt: 2 }}
          >
            Refresh Status
          </Button>
        </CardContent>
      </Card>

      <Card sx={{ mt: 4 }}>
        <CardContent>
          <Typography variant="h5" component="h2" gutterBottom>
            Quick Links
          </Typography>
          <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
            <Button variant="outlined" href="/api" target="_blank">
              API Documentation
            </Button>
            <Button variant="outlined" href="/webui" target="_blank">
              Open WebUI
            </Button>
            <Button variant="outlined" href="/jupyter" target="_blank">
              Jupyter Lab
            </Button>
          </Box>
        </CardContent>
      </Card>
    </Container>
  );
}

export default App;
EOF

        cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Hackathon Frontend Application" />
    <title>Hackathon App</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF
    fi
}

create_project_structure

# Create helpful scripts
echo ""
echo -e "${YELLOW}📜 Creating helper scripts...${RESET}"

mkdir -p scripts

# Git sync script
cat > scripts/git-sync.sh << 'EOF'
#!/bin/bash
# Sync with Git and restart services if needed

echo "🔄 Syncing with Git repository..."
git pull origin main

# Check if requirements changed
if git diff HEAD~1 HEAD --name-only | grep -q requirements.txt; then
    echo "📦 Requirements changed, rebuilding backend..."
    make stop-services
    docker-compose build backend
    make start-services
fi

# Check if package.json changed
if git diff HEAD~1 HEAD --name-only | grep -q package.json; then
    echo "📦 Dependencies changed, rebuilding frontend..."
    make stop-services
    docker-compose build frontend
    make start-services
fi

echo "✅ Sync complete!"
EOF

# Quick development script
cat > scripts/dev-mode.sh << 'EOF'
#!/bin/bash
# Start development environment with hot reload

echo "🔥 Starting development mode..."

# Start databases
docker-compose up -d postgres redis

# Start backend in development mode
cd backend && python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

# Start frontend in development mode
cd frontend && npm start &
FRONTEND_PID=$!

echo "✅ Development servers started!"
echo "Backend: http://localhost:8000"
echo "Frontend: http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop all services"

# Cleanup function
cleanup() {
    echo "🛑 Stopping development servers..."
    kill $BACKEND_PID $FRONTEND_PID
    docker-compose stop postgres redis
    exit 0
}

trap cleanup SIGINT SIGTERM

# Wait for processes
wait
EOF

# Database initialization script
cat > scripts/init-db.sh << 'EOF'
#!/bin/bash
# Initialize database with sample data

echo "🗄️  Initializing database..."

# Wait for database to be ready
until docker exec hackathon-postgres pg_isready -U hackathon_user -d hackathon_db; do
    echo "Waiting for database..."
    sleep 2
done

# Run database migrations
cd backend && python -m alembic upgrade head

echo "✅ Database initialized!"
EOF

chmod +x scripts/*.sh

# Move temporary config to actual config
mv "$TEMP_CONFIG" "$CONFIG_FILE"

echo ""
echo -e "${GREEN}✅ Configuration complete!${RESET}"
echo ""
echo -e "${BLUE}📋 Summary of your configuration:${RESET}"
echo -e "  Deployment mode: ${DEPLOY_MODE}"
echo -e "  Database: ${ENABLE_DATABASE} (${DB_TYPE})"
echo -e "  Backend API: ${ENABLE_BACKEND}"
echo -e "  Frontend: ${ENABLE_FRONTEND}"
echo -e "  Open WebUI: ${ENABLE_OPENWEBUI}"
echo -e "  Jupyter Lab: ${ENABLE_JUPYTER}"
echo -e "  Neo4j: ${ENABLE_NEO4J}"
echo -e "  External access: ${ENABLE_TAILSCALE}"
echo ""
echo -e "${YELLOW}Next steps:${RESET}"
echo -e "  1. Run ${GREEN}make start-services${RESET} to start your environment"
echo -e "  2. Run ${GREEN}make status${RESET} to check service status"
echo -e "  3. Run ${GREEN}make show-endpoints${RESET} to see all service URLs"
echo ""
echo -e "${BLUE}💡 Pro tips:${RESET}"
echo -e "  • Use ${GREEN}make git-sync${RESET} to sync with your repository"
echo -e "  • Use ${GREEN}make logs${RESET} to view service logs"
echo -e "  • Use ${GREEN}make backup${RESET} to backup your data"
echo -e "  • Configuration saved in ${CONFIG_FILE} - edit anytime!"