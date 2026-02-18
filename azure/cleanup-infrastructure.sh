#!/bin/bash

# Script de limpeza da infraestrutura Azure
# ATENÇÃO: Este script irá DELETAR todos os recursos criados!

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

RESOURCE_GROUP="superintelligence-rg"

log_warn "=========================================="
log_warn "ATENÇÃO: OPERAÇÃO DESTRUTIVA!"
log_warn "=========================================="
echo ""
log_warn "Este script irá DELETAR permanentemente:"
echo "  - Resource Group: $RESOURCE_GROUP"
echo "  - Azure Container Registry"
echo "  - Azure Kubernetes Service"
echo "  - Todos os recursos associados"
echo ""
read -p "Tem certeza que deseja continuar? (digite 'yes' para confirmar): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    log_info "Operação cancelada."
    exit 0
fi

log_warn "Iniciando limpeza em 5 segundos... (Ctrl+C para cancelar)"
sleep 5

log_info "Deletando Resource Group: $RESOURCE_GROUP"
az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait

log_info "Comando de deleção enviado. A limpeza será executada em background."
log_info "Para verificar o status: az group show --name $RESOURCE_GROUP"
log_info "✅ Cleanup iniciado com sucesso!"
