#!/bin/bash

################################################################################
# Script de Deployment One-Click - Timeline API
# 
# Este script automatiza todo o processo de deployment da Timeline API no Azure,
# desde o provisionamento de infraestrutura até a instalação da aplicação.
#
# Uso: ./deploy-one-click.sh
#
# Pré-requisitos:
# - Azure CLI instalado
# - Autenticado no Azure (az login)
# - Helm 3.x instalado
# - kubectl instalado
################################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações (edite conforme necessário)
RESOURCE_GROUP="${RESOURCE_GROUP:-superintelligence-rg}"
LOCATION="${LOCATION:-eastus}"
ACR_NAME="${ACR_NAME:-superintelligenceacr}"
AKS_NAME="${AKS_NAME:-superintelligence-aks}"
AKS_NODE_COUNT="${AKS_NODE_COUNT:-2}"
AKS_NODE_SIZE="${AKS_NODE_SIZE:-Standard_DS2_v2}"
NAMESPACE="${NAMESPACE:-superintelligence}"
RELEASE_NAME="${RELEASE_NAME:-timeline-api}"

# Funções auxiliares
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${BLUE}===================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================${NC}\n"
}

check_prerequisites() {
    log_step "Verificando Pré-requisitos"
    
    # Verificar Azure CLI
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI não está instalado. Instale com: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
        exit 1
    fi
    log_info "✓ Azure CLI instalado"
    
    # Verificar autenticação
    if ! az account show &> /dev/null; then
        log_error "Não autenticado no Azure. Execute: az login"
        exit 1
    fi
    log_info "✓ Autenticado no Azure"
    
    # Verificar Helm
    if ! command -v helm &> /dev/null; then
        log_error "Helm não está instalado. Instale com: curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
        exit 1
    fi
    log_info "✓ Helm instalado"
    
    # Verificar kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl não está instalado. Instale com: az aks install-cli"
        exit 1
    fi
    log_info "✓ kubectl instalado"
    
    log_info "Todos os pré-requisitos atendidos!"
}

provision_infrastructure() {
    log_step "Provisionando Infraestrutura Azure"
    
    # Criar Resource Group
    log_info "Criando Resource Group: $RESOURCE_GROUP"
    az group create --name $RESOURCE_GROUP --location $LOCATION --output table
    
    # Criar Azure Container Registry
    log_info "Criando Azure Container Registry: $ACR_NAME"
    az acr create \
        --resource-group $RESOURCE_GROUP \
        --name $ACR_NAME \
        --sku Basic \
        --location $LOCATION \
        --output table
    
    # Criar AKS Cluster
    log_info "Criando AKS Cluster: $AKS_NAME (isso pode levar 10-15 minutos)"
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $AKS_NAME \
        --node-count $AKS_NODE_COUNT \
        --node-vm-size $AKS_NODE_SIZE \
        --enable-managed-identity \
        --attach-acr $ACR_NAME \
        --generate-ssh-keys \
        --location $LOCATION \
        --output table
    
    log_info "✓ Infraestrutura provisionada com sucesso!"
}

configure_kubectl() {
    log_step "Configurando kubectl"
    
    log_info "Obtendo credenciais do AKS"
    az aks get-credentials \
        --resource-group $RESOURCE_GROUP \
        --name $AKS_NAME \
        --overwrite-existing
    
    log_info "Testando conexão com o cluster"
    kubectl cluster-info
    
    log_info "✓ kubectl configurado!"
}

build_and_push_image() {
    log_step "Construindo e Enviando Imagem Docker"
    
    # Obter login server do ACR
    ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)
    log_info "ACR Login Server: $ACR_LOGIN_SERVER"
    
    # Build da imagem usando ACR Tasks (não requer Docker local)
    log_info "Construindo imagem no Azure (ACR Tasks)"
    az acr build \
        --registry $ACR_NAME \
        --image superintelligence-timeline:latest \
        --image superintelligence-timeline:$(date +%Y%m%d-%H%M%S) \
        --file Dockerfile \
        .
    
    log_info "✓ Imagem construída e enviada para ACR!"
}

deploy_application() {
    log_step "Fazendo Deploy da Aplicação"
    
    # Criar namespace
    log_info "Criando namespace: $NAMESPACE"
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    
    # Obter ACR login server
    ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)
    
    # Instalar Helm Chart
    log_info "Instalando Helm Chart"
    helm upgrade --install $RELEASE_NAME helm/timeline-api \
        --namespace $NAMESPACE \
        --set image.repository=$ACR_LOGIN_SERVER/superintelligence-timeline \
        --set image.tag=latest \
        --wait \
        --timeout 10m
    
    log_info "✓ Aplicação deployada!"
}

verify_deployment() {
    log_step "Verificando Deployment"
    
    log_info "Status dos Pods:"
    kubectl get pods -n $NAMESPACE
    
    log_info "\nStatus dos Services:"
    kubectl get svc -n $NAMESPACE
    
    log_info "\nAguardando IP externo do LoadBalancer..."
    EXTERNAL_IP=""
    for i in {1..30}; do
        EXTERNAL_IP=$(kubectl get svc $RELEASE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
        if [ -n "$EXTERNAL_IP" ]; then
            break
        fi
        echo "Aguardando... ($i/30)"
        sleep 10
    done
    
    if [ -n "$EXTERNAL_IP" ]; then
        log_info "\n✓ IP Externo: $EXTERNAL_IP"
        echo ""
        echo "Endpoints disponíveis:"
        echo "  - Health Check: http://$EXTERNAL_IP/health"
        echo "  - Timeline Data: http://$EXTERNAL_IP/api/timeline"
        echo "  - Timeline Image: http://$EXTERNAL_IP/api/timeline/image"
        echo "  - Narrative: http://$EXTERNAL_IP/api/narrative"
        echo ""
        
        # Testar health check
        log_info "Testando health check..."
        sleep 10
        if curl -f -s "http://$EXTERNAL_IP/health" > /dev/null; then
            log_info "✓ API está respondendo!"
        else
            log_warn "API ainda não está respondendo. Aguarde alguns instantes."
        fi
    else
        log_warn "Não foi possível obter o IP externo automaticamente."
        echo "Execute: kubectl get svc $RELEASE_NAME -n $NAMESPACE"
    fi
}

install_optional_features() {
    log_step "Recursos Opcionais"
    
    echo "Deseja instalar recursos opcionais?"
    echo "1) NGINX Ingress + HTTPS (cert-manager)"
    echo "2) Monitoramento (Prometheus + Grafana)"
    echo "3) Ambos"
    echo "4) Pular"
    read -p "Escolha (1-4): " choice
    
    case $choice in
        1)
            log_info "Instalando NGINX Ingress + cert-manager..."
            ./scripts/install-ingress-https.sh
            ;;
        2)
            log_info "Instalando Prometheus + Grafana..."
            ./scripts/install-monitoring.sh
            ;;
        3)
            log_info "Instalando NGINX Ingress + cert-manager..."
            ./scripts/install-ingress-https.sh
            log_info "Instalando Prometheus + Grafana..."
            ./scripts/install-monitoring.sh
            ;;
        4)
            log_info "Pulando recursos opcionais"
            ;;
        *)
            log_warn "Opção inválida. Pulando recursos opcionais."
            ;;
    esac
}

save_deployment_info() {
    log_step "Salvando Informações do Deployment"
    
    DEPLOYMENT_INFO_FILE="deployment-info.txt"
    
    cat > $DEPLOYMENT_INFO_FILE << EOF
================================================================================
INFORMAÇÕES DO DEPLOYMENT - Timeline API
================================================================================
Data: $(date)

AZURE RESOURCES:
- Resource Group: $RESOURCE_GROUP
- Location: $LOCATION
- ACR Name: $ACR_NAME
- AKS Name: $AKS_NAME

KUBERNETES:
- Namespace: $NAMESPACE
- Release Name: $RELEASE_NAME
- Context: $(kubectl config current-context)

ENDPOINTS:
$(kubectl get svc $RELEASE_NAME -n $NAMESPACE 2>/dev/null || echo "Service não encontrado")

COMANDOS ÚTEIS:
- Ver pods: kubectl get pods -n $NAMESPACE
- Ver logs: kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=timeline-api -f
- Ver status: helm status $RELEASE_NAME -n $NAMESPACE
- Escalar: kubectl scale deployment $RELEASE_NAME -n $NAMESPACE --replicas=5
- Upgrade: helm upgrade $RELEASE_NAME helm/timeline-api -n $NAMESPACE

CLEANUP:
Para remover todos os recursos:
  az group delete --name $RESOURCE_GROUP --yes --no-wait

================================================================================
EOF
    
    log_info "Informações salvas em: $DEPLOYMENT_INFO_FILE"
    cat $DEPLOYMENT_INFO_FILE
}

# Main execution
main() {
    log_step "🚀 Deployment One-Click - Timeline API"
    
    echo "Este script irá:"
    echo "1. Verificar pré-requisitos"
    echo "2. Provisionar infraestrutura Azure (Resource Group, ACR, AKS)"
    echo "3. Configurar kubectl"
    echo "4. Construir e enviar imagem Docker"
    echo "5. Fazer deploy da aplicação com Helm"
    echo "6. Verificar deployment"
    echo ""
    read -p "Deseja continuar? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deployment cancelado"
        exit 0
    fi
    
    check_prerequisites
    provision_infrastructure
    configure_kubectl
    build_and_push_image
    deploy_application
    verify_deployment
    install_optional_features
    save_deployment_info
    
    log_step "✅ Deployment Completo!"
    log_info "Sua Timeline API está rodando no Azure Kubernetes Service!"
}

# Executar
main "$@"
