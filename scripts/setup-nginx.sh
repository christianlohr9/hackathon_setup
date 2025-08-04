#!/bin/bash
# scripts/setup-nginx.sh

cat > config/nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:8000;
    }
    
    upstream frontend {
        server frontend:3000;
    }
    
    upstream openwebui {
        server open-webui:8080;
    }
    
    upstream jupyter {
        server jupyterlab:8888;
    }

    server {
        listen 80;
        server_name _;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Backend API
        location /api/ {
            proxy_pass http://backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Open WebUI
        location /webui/ {
            proxy_pass http://openwebui/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Jupyter Lab
        location /jupyter/ {
            proxy_pass http://jupyter/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
EOF

mkdir -p config/nginx/sites-enabled

echo "✅ Reverse proxy configuration created"
