# 🚀 Hackathon Infrastructure Setup

Standardisiertes Setup für Data Science Teams mit Docker/Kubernetes Support.

## 📥 Setup & Installation

### 1. Repository klonen
```bash
git clone https://github.com/christianlohr9/hackathon_setup.git
cd hackathon_setup
```

### 2. Erste Einrichtung
```bash
# Prüfe Systemvoraussetzungen
make detect-platform

# Stelle sicher, dass Docker installiert ist
# macOS: Docker Desktop von https://www.docker.com/products/docker-desktop
# Ubuntu: Docker wird automatisch installiert
```

## 🎯 Features

- **Modulare Services**: Aktiviere nur was du brauchst
- **Schnelle Einrichtung**: Ein Command für komplette Umgebung
- **Multi-Deployment**: Docker Compose oder Kubernetes
- **External Access**: Tailscale Integration für Remote-Zugriff
- **Developer-Friendly**: Hot-Reload, Logs, Status-Monitoring

## 📦 Verfügbare Services

### Core Stack
- **Backend**: FastAPI mit Python
- **Frontend**: React/TypeScript mit Material-UI
- **Database**: PostgreSQL + Redis
- **Reverse Proxy**: Nginx mit automatischem Routing

### ML/AI Services
- **Open WebUI**: LLM Interface (Ollama Integration)
- **Jupyter Lab**: Data Science Notebooks
- **Neo4j**: Graph Database für RAG
- **MinIO**: S3-kompatible Object Storage

### Development Tools
- **Hot Reload**: Automatische Code-Updates
- **Monitoring**: Service Status Dashboard
- **Git Sync**: Automatische Repository-Synchronisation

## 🚀 Schnellstart

### Option 1: Schnellstart mit Defaults
```bash
make quick-start
```

### Option 2: Individuelle Konfiguration
```bash
# 1. Umgebung initialisieren
make init

# 2. Services interaktiv konfigurieren
make interactive-config

# 3. Services starten
make start-services

# 4. Status prüfen und Endpoints anzeigen
make status
make show-endpoints
```

### 🎯 Für Team-Leads
```bash
# 1. Repository Setup (einmalig vom Team-Lead)
make init
make interactive-config
git add . && git commit -m "Configure hackathon environment"
git push

# 2. Andere Teammitglieder
git pull
make start-services
```

## 🎛️ Challenge-basierte Konfiguration

Das System erkennt automatisch deinen Challenge-Type und konfiguriert entsprechende Services:

### AI/LLM Challenge
- ✅ Open WebUI + Ollama
- ✅ Neo4j für Graph RAG
- ✅ FastAPI Backend
- ✅ React Frontend

### Data Science/ML
- ✅ Jupyter Lab
- ✅ PostgreSQL
- ✅ PyTorch/Pandas/Scikit-learn
- ✅ FastAPI für Model Serving

### Graph Analytics
- ✅ Neo4j Graph Database
- ✅ Jupyter für Analysis
- ✅ Backend für Graph APIs

### Full-Stack Web App
- ✅ Complete MERN-ähnlicher Stack
- ✅ PostgreSQL Database
- ✅ FastAPI Backend
- ✅ React Frontend

## 🌐 Service Endpoints

Nach dem Start sind folgende Services verfügbar:

| Service | URL | Credentials |
|---------|-----|-------------|
| Frontend | http://localhost | - |
| Backend API | http://localhost/api | - |
| Open WebUI | http://localhost/webui | - |
| Jupyter Lab | http://localhost/jupyter | Token: `hackathon` |
| Neo4j Browser | http://localhost:7474 | neo4j/hackathon123 |
| MinIO Console | http://localhost:9001 | hackathon/hackathon123 |
| PostgreSQL | localhost:5432 | hackathon_user/[auto-generated] |

## 🛠️ Development Workflow

### Lokale Entwicklung
```bash
# Backend development
make dev-backend

# Frontend development  
make dev-frontend

# Full development mode
./scripts/dev-mode.sh
```

### Git Integration
```bash
# Sync with repository
make git-sync

# Development mode mit Git-Sync
./scripts/git-sync.sh
```

### Database Management
```bash
# Initialize database
./scripts/init-db.sh

# Backup data
make backup

# Clean restart
make clean && make start-services
```

## 🔧 Konfiguration

### config.env
Hauptkonfigurationsdatei - automatisch generiert durch `make interactive-config`:

```bash
# Deployment Mode
DEPLOY_MODE=docker-compose

# Services
ENABLE_DATABASE=true
ENABLE_BACKEND=true
ENABLE_FRONTEND=true
ENABLE_OPENWEBUI=true
ENABLE_JUPYTER=false
ENABLE_NEO4J=true

# Database
DB_TYPE=postgresql
DB_NAME=hackathon_db
DB_USER=hackathon_user
DB_PASSWORD=auto-generated

# Resources
MEMORY_LIMIT_BACKEND=1g
MEMORY_LIMIT_FRONTEND=512m
MEMORY_LIMIT_DB=2g
```

### Manuelle Anpassung
```bash
# Service ein-/ausschalten
sed -i 's/ENABLE_JUPYTER=false/ENABLE_JUPYTER=true/' config.env

# Neustart mit neuer Konfiguration
make stop-services && make start-services
```

## 🔍 Troubleshooting

### Service Status prüfen
```bash
make status
make logs
```

### Häufige Probleme

**Docker nicht installiert:**
```bash
make setup-docker
```

**Services starten nicht:**
```bash
# Check Docker daemon
sudo systemctl start docker

# Check resource limits
docker system df
```

**Database Connection Issues:**
```bash
# Reset database
docker-compose down -v
make start-services
```

**Port Conflicts:**
```bash
# Check port usage
sudo netstat -tulpn | grep :8000

# Modify ports in docker-compose.yml
```

## 🚀 Advanced Features

### Kubernetes Deployment
```bash
# Switch to Kubernetes
sed -i 's/DEPLOY_MODE=docker-compose/DEPLOY_MODE=k8s/' config.env
make setup-k8s
make start-services
```

### External Access (Tailscale)
```bash
make tailscale-setup
```

### Monitoring
```bash
# Enable monitoring stack
sed -i 's/ENABLE_MONITORING=false/ENABLE_MONITORING=true/' config.env
make start-services
```

## 📁 Projekt-Struktur

```
hackathon-infra/
├── Makefile                 # Hauptkonfiguration
├── config.env              # Service-Konfiguration
├── docker/
│   ├── docker-compose.yml  # Service-Definitionen
│   └── docker-compose.override.yml
├── k8s/                     # Kubernetes Manifests
├── backend/                 # FastAPI Application
├── frontend/                # React Application  
├── config/                  # Service-Konfigurationen
├── data/                    # Persistent Data
├── logs/                    # Service Logs
└── scripts/                 # Helper Scripts
```

## 💡 Best Practices

### Team Workflow
1. **Ein Team-Mitglied** führt `make init` und `make interactive-config` aus
2. **Konfiguration committen**: `git add config.env && git commit -m "Setup hackathon environment"`
3. **Andere Team-Mitglieder**: `git pull && make start-services`

### Development
- Nutze `make dev-backend` und `make dev-frontend` für lokale Entwicklung
- Committe regelmäßig und nutze `make git-sync`
- Teste verschiedene Service-Kombinationen vor dem Hackathon

### Performance
- Passe Memory-Limits in `config.env` an deine VM an
- Deaktiviere nicht benötigte Services
- Nutze `make backup` vor größeren Änderungen

## 🆘 Support Commands

```bash
make help              # Alle verfügbaren Commands
make quick-start       # Schnellstart mit defaults
make full-stack        # Alle Services aktivieren
make clean             # Komplette Bereinigung
make test              # Tests ausführen
```

## 🎉 Ready for Hackathon!

Nach erfolgreichem Setup hast du:

✅ **Vollständige Entwicklungsumgebung** in < 5 Minuten  
✅ **Modulare Services** je nach Challenge-Type  
✅ **External Access** für Demos  
✅ **Git Integration** für Team-Collaboration  
✅ **Monitoring & Logs** für Debugging  
✅ **Backup & Recovery** für Datensicherheit  

**Viel Erfolg beim Hackathon! 🏆**