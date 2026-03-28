#!/bin/bash

# Script para instalar o Helm Chart da Timeline API
# Autor: Alexandre Pedrosa Guimarães
# Data: 2026-02-18

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Configurações
RELEASE_NAME="${RELEASE_NAME:-timeline-api}"
NAMESPACE="${NAMESPACE:-superintelligence}"
CHART_PATH="./helm/timeline-api"

log_info "=========================================="
log_info "Instalando Helm Chart: Timeline API"
log_info "=========================================="
echo ""

# Verificar pré-requisitos
log_info "Verificando pré-requisitos..."

if ! command -v helm &> /dev/null; then
    log_error "Helm não está instalado. Instale com:"
    echo "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    log_error "kubectl não está instalado ou não está no PATH"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    log_error "kubectl não está configurado. Configure com:"
    echo "az aks get-credentials --resource-group superintelligence-rg --name superintelligence-aks"
    exit 1
fi

log_info "✅ Pré-requisitos verificados"
echo ""

# Mostrar informações do cluster
log_info "Informações do cluster:"
kubectl cluster-info | head -2
echo ""

# Criar namespace se não existir
log_info "Criando namespace '$NAMESPACE' (se não existir)..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
echo ""

# Validar o chart
log_info "Validando Helm Chart..."
helm lint $CHART_PATH
echo ""

# Perguntar se deseja usar valores customizados
echo "Deseja usar um arquivo de valores customizado? (y/N)"
read -r USE_CUSTOM_VALUES

VALUES_FILE=""
if [[ "$USE_CUSTOM_VALUES" =~ ^[Yy]$ ]]; then
    echo "Digite o caminho do arquivo de valores:"
    read -r VALUES_FILE
    if [ ! -f "$VALUES_FILE" ]; then
        log_error "Arquivo não encontrado: $VALUES_FILE"
        exit 1
    fi
fi

# Verificar se o release já existe
if helm list -n $NAMESPACE | grep -q "^$RELEASE_NAME"; then
    log_warn "Release '$RELEASE_NAME' já existe no namespace '$NAMESPACE'"
    echo "Deseja fazer upgrade? (y/N)"
    read -r DO_UPGRADE
    
    if [[ "$DO_UPGRADE" =~ ^[Yy]$ ]]; then
        log_info "Fazendo upgrade do release..."
        if [ -n "$VALUES_FILE" ]; then
            helm upgrade $RELEASE_NAME $CHART_PATH \
                --namespace $NAMESPACE \
                -f $VALUES_FILE
        else
            helm upgrade $RELEASE_NAME $CHART_PATH \
                --namespace $NAMESPACE
        fi
    else
        log_info "Operação cancelada"
        exit 0
    fi
else
    # Instalar o chart
    log_info "Instalando Helm Chart..."
    if [ -n "$VALUES_FILE" ]; then
        helm install $RELEASE_NAME $CHART_PATH \
            --namespace $NAMESPACE \
            --create-namespace \
            -f $VALUES_FILE
    else
        helm install $RELEASE_NAME $CHART_PATH \
            --namespace $NAMESPACE \
            --create-namespace
    fi
fi

echo ""
log_info "✅ Helm Chart instalado com sucesso!"
echo ""

# Aguardar deployment estar pronto
log_info "Aguardando deployment estar pronto..."
kubectl rollout status deployment/$RELEASE_NAME -n $NAMESPACE --timeout=5m

echo ""
log_info "=========================================="
log_info "Status do Deployment"
log_info "=========================================="
echo ""

# Mostrar status dos recursos
log_info "Pods:"
kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/name=timeline-api"
echo ""

log_info "Services:"
kubectl get svc -n $NAMESPACE -l "app.kubernetes.io/name=timeline-api"
echo ""

log_info "HPA (se habilitado):"
kubectl get hpa -n $NAMESPACE -l "app.kubernetes.io/name=timeline-api" 2>/dev/null || echo "HPA não encontrado"
echo ""

# Obter IP externo do serviço
log_info "Obtendo IP externo do serviço..."
EXTERNAL_IP=""
for i in {1..30}; do
    EXTERNAL_IP=$(kubectl get svc $RELEASE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -n "$EXTERNAL_IP" ]; then
        break
    fi
    echo "Aguardando IP externo... ($i/30)"
    sleep 10
done

echo ""
log_info "=========================================="
log_info "Informações de Acesso"
log_info "=========================================="
echo ""

if [ -n "$EXTERNAL_IP" ]; then
    log_info "✅ IP Externo: $EXTERNAL_IP"
    echo ""
    echo "Endpoints disponíveis:"
    echo "  - Health Check: http://$EXTERNAL_IP/health"
    echo "  - Timeline Data: http://$EXTERNAL_IP/api/timeline"
    echo "  - Timeline Image: http://$EXTERNAL_IP/api/timeline/image"
    echo "  - Narrative: http://$EXTERNAL_IP/api/narrative"
    echo ""
    log_info "Testando health check..."
    sleep 10
    if curl -f -s "http://$EXTERNAL_IP/health" > /dev/null; then
        log_info "✅ API está respondendo!"
    else
        log_warn "API ainda não está respondendo. Aguarde alguns instantes."
    fi
else
    log_warn "Não foi possível obter o IP externo automaticamente."
    echo "Execute manualmente:"
    echo "kubectl get svc $RELEASE_NAME -n $NAMESPACE"
fi

echo ""
log_info "=========================================="
log_info "Comandos Úteis"
log_info "=========================================="
echo ""
echo "# Ver status do release"
echo "helm status $RELEASE_NAME -n $NAMESPACE"
echo ""
echo "# Ver valores aplicados"
echo "helm get values $RELEASE_NAME -n $NAMESPACE"
echo ""
echo "# Ver logs dos pods"
echo "kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=timeline-api --tail=100 -f"
echo ""
echo "# Fazer upgrade"
echo "helm upgrade $RELEASE_NAME $CHART_PATH -n $NAMESPACE"
echo ""
echo "# Rollback"
echo "helm rollback $RELEASE_NAME -n $NAMESPACE"
echo ""
echo "# Desinstalar"
echo "helm uninstall $RELEASE_NAME -n $NAMESPACE"
echo ""

log_info "Instalação concluída! 🚀"
