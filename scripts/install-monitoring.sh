#!/bin/bash

# Script para instalar Prometheus e Grafana no AKS
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
log_info "Instalando Prometheus e Grafana"
log_info "=========================================="

# Verificar se kubectl está configurado
if ! kubectl cluster-info &> /dev/null; then
    log_warn "kubectl não está configurado. Execute 'az aks get-credentials' primeiro."
    exit 1
fi

# Adicionar repositórios Helm
log_info "Adicionando repositórios Helm..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Criar namespace para monitoramento
log_info "Criando namespace 'monitoring'..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Instalar kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
log_info "Instalando kube-prometheus-stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
    --set grafana.enabled=true \
    --set grafana.adminPassword=admin \
    --set grafana.service.type=LoadBalancer \
    --set prometheus.service.type=LoadBalancer \
    --set alertmanager.enabled=true

log_info "Aguardando Prometheus e Grafana estarem prontos..."
kubectl wait --namespace monitoring \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/name=grafana \
    --timeout=180s

# Obter IPs externos
log_info "Obtendo IPs externos..."
sleep 30

GRAFANA_IP=$(kubectl get svc prometheus-grafana -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
PROMETHEUS_IP=$(kubectl get svc prometheus-kube-prometheus-prometheus -n monitoring -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Aplicar ServiceMonitor
log_info "Aplicando ServiceMonitor para a aplicação..."
kubectl apply -f ../k8s/monitoring/servicemonitor.yaml

log_info "=========================================="
log_info "✅ Instalação concluída com sucesso!"
log_info "=========================================="
echo ""
log_info "Acessos:"
echo ""
echo "Grafana:"
echo "  URL: http://$GRAFANA_IP"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "Prometheus:"
echo "  URL: http://$PROMETHEUS_IP:9090"
echo ""
log_info "Próximos passos:"
echo "1. Acesse o Grafana e faça login"
echo "2. Importe o dashboard: k8s/monitoring/grafana-dashboard.json"
echo "3. Configure alertas conforme necessário"
echo "4. (Opcional) Configure Ingress para Grafana e Prometheus"
echo ""
log_info "Comandos úteis:"
echo "# Ver pods de monitoramento"
echo "kubectl get pods -n monitoring"
echo ""
echo "# Ver métricas do Prometheus"
echo "kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo ""
echo "# Acessar Grafana localmente"
echo "kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo ""
log_info "Documentação:"
echo "- Prometheus: https://prometheus.io/docs/"
echo "- Grafana: https://grafana.com/docs/"
echo "- kube-prometheus-stack: https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack"
