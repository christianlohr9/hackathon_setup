#!/bin/bash
# scripts/create-k8s-manifests.sh

cat > k8s/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: hackathon
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: hackathon-config
  namespace: hackathon
data:
  DB_NAME: hackathon_db
  DB_USER: hackathon_user
  ENVIRONMENT: hackathon
---
apiVersion: v1
kind: Secret
metadata:
  name: hackathon-secrets
  namespace: hackathon
type: Opaque
stringData:
  DB_PASSWORD: hackathon_pass
  REDIS_URL: redis://redis:6379
EOF

cat > k8s/postgres.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: hackathon
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        env:
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: hackathon-config
              key: DB_NAME
        - name: POSTGRES_USER
          valueFrom:
            configMapKeyRef:
              name: hackathon-config
              key: DB_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: hackathon-secrets
              key: DB_PASSWORD
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: hackathon
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
EOF

echo "✅ Kubernetes manifests created"
