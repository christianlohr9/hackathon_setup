# 🚀 Hackathon Infrastructure Setup

**Schnelle, automatisierte Infrastruktur für Hackathons**

## 🚀 Installation

```bash
# 1. Repository klonen
git clone https://github.com/christianlohr9/hackathon_setup.git

# 2. In das Verzeichnis wechseln
cd hackathon_setup

# 3. Optional: Makedown installieren für erweiterte Commands
pip install makedown
```

## 🎯 Schnellstart

### Option 1: Direkter Start mit setup.sh
```bash
./setup.sh ai         # AI/LLM Challenge
./setup.sh datascience # Data Science/ML
./setup.sh webapp      # Full-Stack Web App
./setup.sh api         # API/Backend Only
./setup.sh graph       # Graph Analytics
./setup.sh mlops       # MLOps Stack (MLflow + Jupyter)
./setup.sh demo        # Complete Demo Stack (All-in-One)
```

### Option 2: Mit Makedown (empfohlen)
```bash
# Installation von Makedown (macOS)
pip install makedown

# Dann können Sie verwenden:
makedown setup-ai      # oder kurz: m setup-ai
makedown setup-webapp  # oder kurz: m setup-webapp
makedown setup-mlops   # oder kurz: m setup-mlops
makedown setup-demo    # oder kurz: m setup-demo
makedown dev-ai        # Development Mode
makedown status        # Service Status
```

## 📋 Voraussetzungen

### Erforderlich
- **Docker Desktop** (für macOS: [Download](https://www.docker.com/products/docker-desktop))
- **Git**

### Optional aber empfohlen
- **Makedown** für erweiterte Commands:
  ```bash
  # Installation über pip
  pip install makedown
  
  # Oder über Homebrew (falls verfügbar)
  brew install makedown
  
  # Test der Installation
  makedown --help
  ```

### Automatische Prüfung
```bash
# Prüfung aller Voraussetzungen
./setup.sh --check-deps

# Oder mit Makedown (falls installiert)
makedown check-deps
```

> **💡 Hinweis**: Alle Funktionen sind sowohl über `./setup.sh` als auch über `makedown` verfügbar. Makedown bietet zusätzliche Entwickler-Commands und eine bessere Übersicht. Wenn Sie Makedown nicht installieren möchten, können Sie alle grundlegenden Funktionen weiterhin über `./setup.sh` nutzen.

### 🚀 Sofort loslegen (ohne Makedown Installation)
Nach dem Klonen können Sie direkt starten:
```bash
# Nach git clone und cd hackathon_setup

# Prerequisites prüfen
./setup.sh check-deps

# AI Preset starten
./setup.sh ai

# Status prüfen
./setup.sh status

# Services anzeigen
./setup.sh endpoints
```

**Nach erfolgreichem Start:**
- 🌐 **Frontend**: http://localhost (Übersichtsseite mit allen Services)
- 🤖 **OpenWebUI**: http://localhost:8080 (LLM Chat Interface)
- 📊 **Neo4j**: http://localhost:7474 (Graph Database, Login: neo4j/hackathon123)
- ⚡ **API**: http://localhost:8000/docs (Interactive API Documentation)

## 📋 Verfügbare Presets

### 🤖 AI/LLM Challenge
**Perfekt für**: KI-Anwendungen, Chatbots, RAG-Systeme
```bash
./setup.sh ai
```
**Enthält**: OpenWebUI, Ollama, Neo4j, PostgreSQL, FastAPI

### 📊 Data Science/ML
**Perfekt für**: Machine Learning, Data Analysis, Visualisierung
```bash
./setup.sh datascience
```
**Enthält**: Jupyter Lab, PostgreSQL, MinIO, PyTorch, FastAPI

### 🌐 Full-Stack Web App
**Perfekt für**: Web-Anwendungen, SaaS-Prototypen
```bash
./setup.sh webapp
```
**Enthält**: React Frontend, FastAPI Backend, PostgreSQL

### ⚡ API/Backend Only
**Perfekt für**: Microservices, REST APIs, Mobile Backends
```bash
./setup.sh api
```
**Enthält**: FastAPI, PostgreSQL, Redis, Swagger UI

### 🕸️ Graph Analytics
**Perfekt für**: Netzwerkanalyse, Knowledge Graphs, Empfehlungssysteme
```bash
./setup.sh graph
```
**Enthält**: Neo4j, Jupyter Lab, PostgreSQL, FastAPI

### 🧪 MLOps Stack
**Perfekt für**: ML Experiment Tracking, Model Management
```bash
./setup.sh mlops
```
**Enthält**: MLflow, Jupyter Lab, PostgreSQL, FastAPI, Redis

### 🎬 Complete Demo Stack
**Perfekt für**: Präsentationen, Live-Demos, Vollständige Showcases
```bash
./setup.sh demo
```
**Enthält**: MLflow, Jupyter Lab, Streamlit, PostgreSQL, FastAPI, Redis

## 🎛️ Services Individuell Konfigurieren

### Schritt-für-Schritt: Services An-/Abschalten

#### 1. Grundsetup erstellen
```bash
# Wählen Sie ein Basis-Preset (z.B. AI)
makedown setup-ai
# oder ohne Makedown: ./setup.sh ai
```

#### 2. Aktuelle Konfiguration anzeigen
```bash
makedown show-config
```

#### 3. Services nach Bedarf anpassen
```bash
# Für Data Science (Jupyter + MinIO, ohne OpenWebUI/Neo4j)
makedown config-datascience

# Oder einzeln:
makedown disable-openwebui     # OpenWebUI ausschalten
makedown disable-neo4j         # Neo4j ausschalten
makedown enable-jupyter        # Jupyter einschalten
makedown enable-minio          # MinIO einschalten
```

#### 4. Änderungen übernehmen
```bash
makedown restart
```

### 🧪 Dry Run Beispiele

#### Beispiel 1: Nur Data Science mit XGBoost
```bash
# Nach git clone und cd hackathon_setup

# 1. Setup (funktioniert bereits!)
makedown setup-ai
makedown show-config           # Zeigt: OpenWebUI✅, Neo4j✅, Jupyter❌, MinIO❌

# 2. Für Data Science konfigurieren
makedown config-datascience   # Automatisch: OpenWebUI❌, Neo4j❌, Jupyter✅, MinIO✅
makedown show-config          # Überprüfen: Jupyter✅, MinIO✅

# 3. Services mit neuer Konfiguration neu starten
makedown restart              # Startet nur Jupyter + MinIO + Database

# 4. Zugriff auf Services
# Jupyter Lab: http://localhost:8888 (Token: hackathon)
# MinIO: http://localhost:9001 (hackathon/hackathon123)
```

#### Beispiel 2: Minimales Backend für API-Entwicklung
```bash
# Nach git clone und cd hackathon_setup

# 1. Setup
makedown setup-api
makedown show-config           # Zeigt aktuelle Services

# 2. Auf minimal reduzieren
makedown config-minimal        # Nur Backend + Database + Redis
makedown show-config           # Überprüfen: Frontend❌, alle ML-Services❌

# 3. Anwenden
makedown restart               # Startet nur Backend + Database + Redis
```

#### Beispiel 3: Interaktive Konfiguration
```bash
# Nach git clone und cd hackathon_setup

# Schritt-für-Schritt durch alle Services
makedown interactive-config    # Fragt jeden Service einzeln ab
```

### 📋 Verfügbare Service-Commands

#### Vorkonfigurierte Setups
```bash
makedown config-datascience    # Jupyter + MinIO (für ML/Data Science)
makedown config-minimal        # Nur Backend + Database
makedown config-fullstack      # Frontend + Backend + Database
```

#### Einzelne Services
```bash
makedown enable-openwebui      # OpenWebUI einschalten
makedown disable-openwebui     # OpenWebUI ausschalten
makedown enable-jupyter        # Jupyter Lab einschalten
makedown disable-jupyter       # Jupyter Lab ausschalten
makedown enable-neo4j          # Neo4j einschalten
makedown disable-neo4j         # Neo4j ausschalten
makedown enable-minio          # MinIO einschalten
makedown disable-minio         # MinIO ausschalten
makedown enable-frontend       # React Frontend einschalten
makedown disable-frontend      # React Frontend ausschalten
```

#### Status und Kontrolle
```bash
makedown show-config           # Aktuelle Service-Konfiguration anzeigen
makedown restart               # Services mit aktueller Konfiguration neu starten
makedown status                # Status aller laufenden Services
makedown stop                  # Alle Services stoppen
```

### 🔄 Typischer Workflow

1. **Initial Setup**: `makedown setup-ai` (oder anderes Preset)
2. **Konfiguration prüfen**: `makedown show-config`
3. **Services anpassen**: `makedown config-datascience` (oder einzeln)
4. **Konfiguration bestätigen**: `makedown show-config`
5. **Services starten**: `makedown restart`
6. **Status prüfen**: `makedown status`

> **💡 Tipp**: Mit `makedown show-config` können Sie jederzeit sehen, welche Services aktiviert sind, bevor Sie `makedown restart` ausführen.

## 🎛️ Erweiterte Optionen

### Services einzeln steuern (ohne Makedown)
```bash
./setup.sh ai --start-only      # Nur starten, nicht konfigurieren
./setup.sh ai --stop            # Services stoppen
./setup.sh ai --restart         # Neu starten
```

### Status und Logs
```bash
./setup.sh status               # Alle Services anzeigen
./setup.sh logs                 # Live-Logs anzeigen
./setup.sh endpoints            # URLs aller Services
```

### Entwicklermodus
```bash
./setup.sh ai --dev             # Development Mode mit Hot Reload
```

## 🌐 Service Endpoints

Nach erfolgreichem Start sind folgende Services verfügbar:

| Service | URL | Credentials | Status |
|---------|-----|-------------|--------|
| **Frontend** | http://localhost | - | ✅ Läuft |
| **Backend API** | http://localhost:8000 | - | ✅ Läuft |
| **API Docs** | http://localhost:8000/docs | - | ✅ Verfügbar |
| **OpenWebUI** | http://localhost:8080 | - | ✅ Läuft |
| **Neo4j Browser** | http://localhost:7474 | neo4j/hackathon123 | ✅ Läuft |
| **Jupyter Lab** | http://localhost:8888 | Token: `hackathon` | ⚙️ Wenn aktiviert |
| **MinIO Console** | http://localhost:9001 | hackathon/hackathon123 | ⚙️ Wenn aktiviert |
| **MLflow UI** | http://localhost:5000 | - | ⚙️ Wenn aktiviert |
| **Streamlit Demo** | http://localhost:8501 | - | ⚙️ Wenn aktiviert |
| **PostgreSQL** | localhost:5432 | hackathon_user/[siehe config.env] | ✅ Läuft |
| **Redis** | localhost:6379 | - | ✅ Läuft |

> **🎉 Erfolgreich gestartet!** Das Frontend ist unter http://localhost erreichbar und zeigt eine Übersicht aller Services.

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