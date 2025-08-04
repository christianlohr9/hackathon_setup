#!/bin/bash
# scripts/create-docker-compose.sh

cat > docker/docker-compose.yml << 'EOF'
version: '3.8'

networks:
  hackathon-network:
    driver: bridge

volumes:
  postgres_data:
  neo4j_data:
  openwebui_data:
  jupyter_data:

services:
  # Reverse Proxy (always enabled)
  nginx:
    image: nginx:alpine
    container_name: hackathon-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ../config/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ../config/nginx/sites-enabled:/etc/nginx/sites-enabled
    depends_on:
      - backend
      - frontend
    networks:
      - hackathon-network
    restart: unless-stopped

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

  # Redis for caching/sessions
  redis:
    image: redis:7-alpine
    container_name: hackathon-redis
    ports:
      - "6379:6379"
    networks:
      - hackathon-network
    restart: unless-stopped

  # Backend API (FastAPI)
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

  # Frontend (React/TypeScript)
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

echo "✅ Docker Compose configuration created"
