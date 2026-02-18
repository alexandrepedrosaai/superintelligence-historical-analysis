#!/bin/bash

# Script para testar a aplicação localmente

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

log_info "Instalando dependências..."
npm install

log_info "Iniciando servidor..."
npm start &
SERVER_PID=$!

log_info "Aguardando servidor iniciar..."
sleep 5

log_info "Testando endpoints..."

echo ""
log_info "1. Health check:"
curl -s http://localhost:3000/health | jq '.'

echo ""
log_info "2. Root endpoint:"
curl -s http://localhost:3000/ | jq '.'

echo ""
log_info "3. Timeline data:"
curl -s http://localhost:3000/api/timeline | jq '.data[0]'

echo ""
log_info "4. Narrative:"
curl -s http://localhost:3000/api/narrative | jq '.narrative' | head -5

echo ""
log_info "5. Timeline image (salvando em timeline-test.png):"
curl -s http://localhost:3000/api/timeline/image -o timeline-test.png
if [ -f timeline-test.png ]; then
    log_info "✅ Imagem salva com sucesso!"
    ls -lh timeline-test.png
else
    log_warn "❌ Falha ao salvar imagem"
fi

echo ""
log_info "Parando servidor..."
kill $SERVER_PID

log_info "✅ Testes concluídos!"
