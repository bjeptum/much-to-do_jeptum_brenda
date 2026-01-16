#!/bin/bash
set -e

echo "=== Creating Kind cluster ==="
kind create cluster --name muchtodo --config kind-config.yaml

echo "=== Building Docker image ==="
docker build -t muchtodo-backend:latest .
kind load docker-image muchtodo-backend:latest --name muchtodo

echo "=== Installing NGINX Ingress Controller ==="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/kind/deploy.yaml

echo "=== Waiting for Ingress Controller to be ready ==="
sleep 10  # Give it time to create the pods first
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "=== Creating muchtodo namespace ==="
kubectl apply -f kubernetes/namespace.yaml

echo "=== Deploying MongoDB ==="
kubectl apply -f kubernetes/mongodb/ -n muchtodo

echo "=== Deploying Backend ==="
kubectl apply -f kubernetes/backend/ -n muchtodo

echo "=== Waiting for ingress webhook to be ready ==="
sleep 10  # Wait for admission webhook to be ready

echo "=== Creating Ingress ==="
# Retry ingress creation up to 5 times
for i in {1..5}; do
  kubectl apply -f kubernetes/ingress.yaml -n muchtodo && break
  echo "Ingress creation failed, retrying in 5 seconds... (attempt $i/5)"
  sleep 5
done

echo "=== Waiting for pods to be ready ==="
kubectl wait --namespace muchtodo \
  --for=condition=ready pod \
  --selector=app=mongodb \
  --timeout=120s || true

kubectl wait --namespace muchtodo \
  --for=condition=ready pod \
  --selector=app=backend \
  --timeout=120s || true

echo ""
echo "=== Deployment Status ==="
kubectl get pods -n muchtodo
echo ""
echo "Deployment complete. Access at http://localhost:8081/health"