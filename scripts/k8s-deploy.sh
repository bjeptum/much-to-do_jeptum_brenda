#!/bin/bash

kind create cluster --name muchtodo --config kind-config.yaml

docker build -t muchtodo-backend:latest .
kind load docker-image muchtodo-backend:latest --name muchtodo

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/mongodb/ -n muchtodo
kubectl apply -f kubernetes/backend/ -n muchtodo
kubectl apply -f kubernetes/ingress.yaml -n muchtodo

echo "Deployment complete. Access at http://localhost/health"