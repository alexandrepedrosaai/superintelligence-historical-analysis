#!/bin/bash

# Script para build e teste da imagem Docker localmente

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

cd "$(dirname "$0")/.."

IMAGE_NAME="superintelligence-timeline"
IMAGE_TAG="test"
CONTAINER_NAME="timeline-api-test"

log_info "Building Docker image..."
docker build -t $IMAGE_NAME:$IMAGE_TAG .

log_info "Imagem criada com sucesso!"
docker images | grep $IMAGE_NAME

log_info "Iniciando container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p 3000:3000 \
    -e NODE_ENV=production \
    $IMAGE_NAME:$IMAGE_TAG

log_info "Aguardando container iniciar..."
sleep 10

log_info "Verificando logs do container..."
docker logs $CONTAINER_NAME

log_info "Testando health check..."
curl -f http://localhost:3000/health || log_warn "Health check falhou!"

log_info "Testando endpoint de timeline..."
curl -s http://localhost:3000/api/timeline | jq '.count'

log_info "Testando geração de imagem..."
curl -s http://localhost:3000/api/timeline/image -o timeline-docker-test.png
ls -lh timeline-docker-test.png

log_info "Parando e removendo container..."
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

log_info "✅ Teste do Docker concluído com sucesso!"
echo ""
log_info "Para executar manualmente:"
echo "  docker run -p 3000:3000 $IMAGE_NAME:$IMAGE_TAG"
