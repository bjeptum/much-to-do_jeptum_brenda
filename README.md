# MuchToDo - Containerized Backend Application

A containerized Golang API application with MongoDB database, deployed using Docker Compose for local development and Kubernetes (Kind) for orchestration.

## Project Overview

- **Backend API**: Golang application running on port 8080
- **Database**: MongoDB 6.0 for data storage
- **Container Orchestration**: Kubernetes (Kind cluster)
- **Ingress**: NGINX Ingress Controller

## Project Structure

```
.
├── Dockerfile                 # Multi-stage Docker build
├── docker-compose.yml         # Local development setup
├── .dockerignore              # Docker build exclusions
├── kind-config.yaml           # Kind cluster configuration
├── kubernetes/                # Kubernetes manifests
│   ├── namespace.yaml
│   ├── ingress.yaml
│   ├── mongodb/
│   │   ├── mongodb-configmap.yaml
│   │   ├── mongodb-secret.yaml
│   │   ├── mongodb-pvc.yaml
│   │   ├── mongodb-deployment.yaml
│   │   └── mongodb-service.yaml
│   └── backend/
│       ├── backend-configmap.yaml
│       ├── backend-secret.yaml
│       ├── backend-deployment.yaml
│       └── backend-service.yaml
├── scripts/                   # Automation scripts
│   ├── docker-build.sh
│   ├── docker-run.sh
│   ├── k8s-deploy.sh
│   └── k8s-cleanup.sh
├── evidence/                  # Deployment screenshots
└── Server/MuchToDo/           # Application source code
```

## Prerequisites

- Docker
- Docker Compose
- Kind (Kubernetes in Docker)
- kubectl

## Phase 1: Docker Setup (Local Development)

### Build Docker Image

```bash
./scripts/docker-build.sh
```

Or manually:

```bash
docker build -t muchtodo-backend:latest .
```

### Run with Docker Compose

```bash
./scripts/docker-run.sh
```

Or manually:

```bash
docker compose up -d
```

### Verify Application

```bash
# Check running containers
docker ps

# Test health endpoint
curl http://localhost:8080/health

# View logs
docker compose logs -f
```

### Stop Docker Compose

```bash
docker compose down
```

## Phase 2: Kubernetes Deployment (Kind)

### Deploy to Kubernetes

```bash
./scripts/k8s-deploy.sh
```

This script will:
1. Create a Kind cluster named `muchtodo`
2. Build and load the Docker image into the cluster
3. Install NGINX Ingress Controller
4. Create the `muchtodo` namespace
5. Deploy MongoDB with persistent storage
6. Deploy the backend application (2 replicas)
7. Configure Ingress for external access

### Verify Kubernetes Deployment

```bash
# Check pods
kubectl get pods -n muchtodo

# Check services
kubectl get svc -n muchtodo

# Check deployments
kubectl get deployments -n muchtodo

# Check ingress
kubectl get ingress -n muchtodo

# Test application
curl http://localhost:8081/health
```

### View Logs

```bash
# Backend logs
kubectl logs -l app=backend -n muchtodo

# MongoDB logs
kubectl logs -l app=mongodb -n muchtodo
```

### Cleanup Kubernetes Resources

```bash
./scripts/k8s-cleanup.sh
```

## Application Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check endpoint |
| `/api/users` | GET/POST | User management |
| `/api/todos` | GET/POST | Todo operations |

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MONGO_URI` | MongoDB connection string | - |
| `DB_NAME` | Database name | `muchtodo` |
| `PORT` | Application port | `8080` |
| `JWT_SECRET_KEY` | JWT signing key | - |
| `JWT_EXPIRATION_HOURS` | Token expiration | `72` |

### Kubernetes Resources

- **MongoDB**: 1 replica with 1Gi persistent storage
- **Backend**: 2 replicas with health probes
- **Resource Limits**: CPU and memory limits configured

## Security Features

- Multi-stage Docker build with distroless image
- Non-root user in container
- Secrets for sensitive configuration
- Resource limits to prevent DoS

## Troubleshooting

### Docker Issues

```bash
# Rebuild without cache
docker build --no-cache -t muchtodo-backend:latest .

# Check container logs
docker logs muchtodo-backend
```

### Kubernetes Issues

```bash
# Describe pod for events
kubectl describe pod <pod-name> -n muchtodo

# Check pod logs
kubectl logs <pod-name> -n muchtodo

# Restart deployment
kubectl rollout restart deployment/backend-deployment -n muchtodo
```

## Author

Jeptum Brenda

## License

This project is for educational purposes as part of AltSchool Africa Semester 3 Assessment.
