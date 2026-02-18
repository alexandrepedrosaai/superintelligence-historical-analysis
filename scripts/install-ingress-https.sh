#!/bin/bash

# Script para instalar NGINX Ingress Controller e cert-manager no AKS
# Autor: Alexandre Pedrosa Guimarães
# Data: 2026-02-18

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

log_info "=========================================="
log_info "Instalando NGINX Ingress Controller e cert-manager"
log_info "=========================================="

# Verificar se kubectl está configurado
if ! kubectl cluster-info &> /dev/null; then
    log_warn "kubectl não está configurado. Execute 'az aks get-credentials' primeiro."
    exit 1
fi

# Adicionar repositórios Helm
log_info "Adicionando repositórios Helm..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Instalar NGINX Ingress Controller
log_info "Instalando NGINX Ingress Controller..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --create-namespace \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local

log_info "Aguardando NGINX Ingress Controller estar pronto..."
kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s

# Instalar cert-manager
log_info "Instalando cert-manager..."
helm upgrade --install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --set installCRDs=true \
    --set nodeSelector."kubernetes\.io/os"=linux

log_info "Aguardando cert-manager estar pronto..."
kubectl wait --namespace cert-manager \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=webhook \
    --timeout=120s

# Aplicar ClusterIssuers
log_info "Aplicando ClusterIssuers do Let's Encrypt..."
kubectl apply -f ../k8s/base/cluster-issuer.yaml

# Obter IP externo do Ingress Controller
log_info "Obtendo IP externo do Ingress Controller..."
EXTERNAL_IP=""
for i in {1..30}; do
    EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -n "$EXTERNAL_IP" ]; then
        break
    fi
    echo "Aguardando IP externo... ($i/30)"
    sleep 10
done

if [ -z "$EXTERNAL_IP" ]; then
    log_warn "Não foi possível obter o IP externo. Verifique manualmente:"
    log_warn "kubectl get svc ingress-nginx-controller -n ingress-nginx"
else
    log_info "=========================================="
    log_info "✅ Instalação concluída com sucesso!"
    log_info "=========================================="
    echo ""
    log_info "IP Externo do Ingress Controller: $EXTERNAL_IP"
    echo ""
    log_info "Próximos passos:"
    echo "1. Configure um registro DNS A apontando para: $EXTERNAL_IP"
    echo "   Exemplo: timeline-api.yourdomain.com -> $EXTERNAL_IP"
    echo ""
    echo "2. Edite k8s/base/ingress.yaml e substitua:"
    echo "   - timeline-api.yourdomain.com pelo seu domínio"
    echo ""
    echo "3. Edite k8s/base/cluster-issuer.yaml e substitua:"
    echo "   - your-email@example.com pelo seu email"
    echo ""
    echo "4. Aplique o Ingress:"
    echo "   kubectl apply -f k8s/base/ingress.yaml"
    echo ""
    echo "5. Verifique o certificado SSL:"
    echo "   kubectl get certificate -n superintelligence"
    echo "   kubectl describe certificate timeline-api-tls -n superintelligence"
    echo ""
    log_info "Documentação:"
    echo "- NGINX Ingress: https://kubernetes.github.io/ingress-nginx/"
    echo "- cert-manager: https://cert-manager.io/docs/"
fi
