#!/bin/bash
# scripts/create-docker-compose.sh

# Load configuration
source config.env

# Check if backend/frontend Dockerfiles exist
BACKEND_EXISTS=false
FRONTEND_EXISTS=false

if [ -f "backend/Dockerfile" ]; then
    BACKEND_EXISTS=true
fi

if [ -f "frontend/Dockerfile" ]; then
    FRONTEND_EXISTS=true
fi

# Start generating docker-compose.yml
cat > docker/docker-compose.yml << EOF
networks:
  hackathon-network:
    driver: bridge

volumes:
  postgres_data:
  neo4j_data:
  openwebui_data:
  jupyter_data:

services:
EOF

# Add PostgreSQL (always enabled for database support)
if [ "${ENABLE_DATABASE:-true}" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: hackathon-postgres
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ../data/postgres:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    networks:
      - hackathon-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT_DB}

EOF
fi

# Add Redis (always enabled for caching)
cat >> docker/docker-compose.yml << EOF
  # Redis for caching/sessions
  redis:
    image: redis:7-alpine
    container_name: hackathon-redis
    ports:
      - "6379:6379"
    networks:
      - hackathon-network
    restart: unless-stopped

EOF

# Add Backend (if Dockerfile exists or use placeholder image)
if [ "${ENABLE_BACKEND:-true}" = "true" ]; then
if [ "$BACKEND_EXISTS" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
  # Backend API (FastAPI) - Custom Build
  backend:
    build:
      context: ../backend
      dockerfile: Dockerfile
    container_name: hackathon-backend
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@postgres:5432/${DB_NAME}
      REDIS_URL: redis://redis:6379
      ENVIRONMENT: hackathon
    volumes:
      - ../backend:/app
      - ../data/uploads:/app/uploads
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis
    networks:
      - hackathon-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT_BACKEND}

EOF
else
cat >> docker/docker-compose.yml << EOF
  # Backend API (FastAPI) - Placeholder
  backend:
    image: tiangolo/uvicorn-gunicorn-fastapi:python3.11
    container_name: hackathon-backend
    environment:
      DATABASE_URL: postgresql://${DB_USER}:${DB_PASSWORD}@postgres:5432/${DB_NAME}
      REDIS_URL: redis://redis:6379
      ENVIRONMENT: hackathon
    volumes:
      - ../data/uploads:/app/uploads
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis
    networks:
      - hackathon-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT_BACKEND}
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload

EOF
fi
fi

# Add Frontend (if enabled and Dockerfile exists)
if [ "${ENABLE_FRONTEND:-true}" = "true" ]; then
if [ "$FRONTEND_EXISTS" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
  # Frontend (React/TypeScript) - Custom Build
  frontend:
    build:
      context: ../frontend
      dockerfile: Dockerfile
    container_name: hackathon-frontend
    environment:
      REACT_APP_API_URL: http://backend:8000
    volumes:
      - ../frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - hackathon-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT_FRONTEND}

EOF
else
cat >> docker/docker-compose.yml << EOF
  # Frontend (React) - Placeholder
  frontend:
    image: nginx:alpine
    container_name: hackathon-frontend
    ports:
      - "3000:80"
    volumes:
      - ../config/nginx/default.html:/usr/share/nginx/html/index.html:ro
    networks:
      - hackathon-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: ${MEMORY_LIMIT_FRONTEND}

EOF
fi
fi

# Add Nginx reverse proxy (if enabled)
if [ "${ENABLE_REVERSE_PROXY:-true}" = "true" ]; then

cat >> docker/docker-compose.yml << EOF
  # Reverse Proxy (Nginx)
  nginx:
    image: nginx:alpine
    container_name: hackathon-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ../config/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ../config/nginx/sites-enabled:/etc/nginx/sites-enabled:ro
      - ../config/nginx/default.html:/usr/share/nginx/html/index.html:ro
EOF

# Add dependencies based on enabled services
DEPS_ADDED=false
if [ "${ENABLE_BACKEND:-true}" = "true" ] || [ "${ENABLE_FRONTEND:-true}" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
    depends_on:
EOF
    DEPS_ADDED=true
fi

if [ "${ENABLE_BACKEND:-true}" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
      - backend
EOF
fi

if [ "${ENABLE_FRONTEND:-true}" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
      - frontend
EOF
fi

cat >> docker/docker-compose.yml << EOF
    networks:
      - hackathon-network
    restart: unless-stopped

EOF
fi

# Add OpenWebUI (if enabled)
if [ "${ENABLE_OPENWEBUI:-false}" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
  # Open WebUI for LLM interactions
  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: hackathon-openwebui
    environment:
      OLLAMA_BASE_URL: http://ollama:11434
      WEBUI_SECRET_KEY: hackathon-secret-key
    volumes:
      - openwebui_data:/app/backend/data
    ports:
      - "8080:8080"
    networks:
      - hackathon-network
    restart: unless-stopped

  # Ollama for local LLM serving
  ollama:
    image: ollama/ollama:latest
    container_name: hackathon-ollama
    volumes:
      - ../data/ollama:/root/.ollama
    ports:
      - "11434:11434"
    networks:
      - hackathon-network
    restart: unless-stopped

EOF
fi

# Add Neo4j (if enabled)
if [ "${ENABLE_NEO4J:-false}" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
  # Neo4j for Graph RAG
  neo4j:
    image: neo4j:5-community
    container_name: hackathon-neo4j
    environment:
      NEO4J_AUTH: neo4j/hackathon123
      NEO4J_PLUGINS: '["apoc"]'
    volumes:
      - neo4j_data:/data
      - ../config/neo4j:/conf
    ports:
      - "7474:7474"
      - "7687:7687"
    networks:
      - hackathon-network
    restart: unless-stopped

EOF
fi

# Add Jupyter Lab (if enabled)
if [ "${ENABLE_JUPYTER:-false}" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
  # Jupyter Lab for data exploration
  jupyterlab:
    image: jupyter/datascience-notebook:latest
    container_name: hackathon-jupyter
    environment:
      JUPYTER_ENABLE_LAB: yes
      JUPYTER_TOKEN: hackathon
    volumes:
      - jupyter_data:/home/jovyan/work
      - ../data:/home/jovyan/data
    ports:
      - "8888:8888"
    networks:
      - hackathon-network
    restart: unless-stopped

EOF
fi

# Add MinIO (if enabled)
if [ "${ENABLE_MINIO:-false}" = "true" ]; then
cat >> docker/docker-compose.yml << EOF
  # MinIO for S3-compatible object storage
  minio:
    image: minio/minio:latest
    container_name: hackathon-minio
    environment:
      MINIO_ROOT_USER: hackathon
      MINIO_ROOT_PASSWORD: hackathon123
    volumes:
      - ../data/minio:/data
    ports:
      - "9000:9000"
      - "9001:9001"
    command: server /data --console-address ":9001"
    networks:
      - hackathon-network
    restart: unless-stopped

EOF
fi

echo "✅ Docker Compose configuration created"