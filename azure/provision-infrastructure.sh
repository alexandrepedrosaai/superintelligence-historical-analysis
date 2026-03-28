#!/bin/bash

# Script de provisionamento de infraestrutura Azure para AKS
# Autor: Alexandre Pedrosa Guimarães
# Data: 2026-02-18

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Configurações
RESOURCE_GROUP="superintelligence-rg"
LOCATION="eastus"
ACR_NAME="superintelligenceacr"
AKS_CLUSTER_NAME="superintelligence-aks"
AKS_NODE_COUNT=2
AKS_NODE_SIZE="Standard_B2s"
AKS_K8S_VERSION="1.29"

log_info "Iniciando provisionamento da infraestrutura Azure..."

# Verificar se Azure CLI está instalado
if ! command -v az &> /dev/null; then
    log_error "Azure CLI não encontrado. Instale: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar login no Azure
log_info "Verificando autenticação Azure..."
if ! az account show &> /dev/null; then
    log_warn "Não autenticado. Executando login..."
    az login
fi

# Exibir assinatura atual
SUBSCRIPTION=$(az account show --query name -o tsv)
log_info "Assinatura ativa: $SUBSCRIPTION"

# Criar Resource Group
log_info "Criando Resource Group: $RESOURCE_GROUP"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --tags "project=superintelligence" "environment=production" "managed-by=script"

# Criar Azure Container Registry
log_info "Criando Azure Container Registry: $ACR_NAME"
az acr create \
    --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku Standard \
    --admin-enabled true \
    --location $LOCATION \
    --tags "project=superintelligence"

# Obter credenciais do ACR
log_info "Obtendo credenciais do ACR..."
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query passwords[0].value -o tsv)

log_info "ACR Login Server: $ACR_LOGIN_SERVER"
log_info "ACR Username: $ACR_USERNAME"

# Criar AKS Cluster
log_info "Criando AKS Cluster: $AKS_CLUSTER_NAME (isso pode levar vários minutos...)"
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --node-count $AKS_NODE_COUNT \
    --node-vm-size $AKS_NODE_SIZE \
    --kubernetes-version $AKS_K8S_VERSION \
    --enable-managed-identity \
    --attach-acr $ACR_NAME \
    --generate-ssh-keys \
    --enable-addons monitoring \
    --network-plugin azure \
    --network-policy azure \
    --load-balancer-sku standard \
    --vm-set-type VirtualMachineScaleSets \
    --enable-cluster-autoscaler \
    --min-count 1 \
    --max-count 5 \
    --location $LOCATION \
    --tags "project=superintelligence" "environment=production"

# Obter credenciais do AKS
log_info "Obtendo credenciais do AKS..."
az aks get-credentials \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --overwrite-existing

# Verificar conexão com cluster
log_info "Verificando conexão com cluster..."
kubectl cluster-info
kubectl get nodes

# Criar Service Principal para GitHub Actions
log_info "Criando Service Principal para GitHub Actions..."
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SP_NAME="sp-superintelligence-github"

SP_JSON=$(az ad sp create-for-rbac \
    --name $SP_NAME \
    --role contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
    --sdk-auth)

# Exibir informações para configuração do GitHub
log_info "=========================================="
log_info "CONFIGURAÇÃO DO GITHUB SECRETS"
log_info "=========================================="
echo ""
log_info "Configure os seguintes secrets no GitHub:"
echo ""
echo "AZURE_CREDENTIALS:"
echo "$SP_JSON"
echo ""
echo "ACR_LOGIN_SERVER: $ACR_LOGIN_SERVER"
echo "ACR_USERNAME: $ACR_USERNAME"
echo "ACR_PASSWORD: $ACR_PASSWORD"
echo "AKS_CLUSTER_NAME: $AKS_CLUSTER_NAME"
echo "AKS_RESOURCE_GROUP: $RESOURCE_GROUP"
echo ""
log_info "=========================================="

# Salvar configurações em arquivo
CONFIG_FILE="azure-config.txt"
cat > $CONFIG_FILE <<EOF
# Configurações da Infraestrutura Azure
# Gerado em: $(date)

RESOURCE_GROUP=$RESOURCE_GROUP
LOCATION=$LOCATION
ACR_NAME=$ACR_NAME
ACR_LOGIN_SERVER=$ACR_LOGIN_SERVER
ACR_USERNAME=$ACR_USERNAME
ACR_PASSWORD=$ACR_PASSWORD
AKS_CLUSTER_NAME=$AKS_CLUSTER_NAME
AKS_NODE_COUNT=$AKS_NODE_COUNT
AKS_NODE_SIZE=$AKS_NODE_SIZE
SUBSCRIPTION_ID=$SUBSCRIPTION_ID

# Service Principal (para GitHub Actions)
AZURE_CREDENTIALS=$SP_JSON
EOF

log_info "Configurações salvas em: $CONFIG_FILE"
log_warn "ATENÇÃO: Este arquivo contém informações sensíveis. Não commite no Git!"

# Criar namespace no Kubernetes
log_info "Criando namespace 'superintelligence' no cluster..."
kubectl create namespace superintelligence --dry-run=client -o yaml | kubectl apply -f -

# Criar secret do ACR no Kubernetes
log_info "Criando secret do ACR no Kubernetes..."
kubectl create secret docker-registry acr-secret \
    --namespace=superintelligence \
    --docker-server=$ACR_LOGIN_SERVER \
    --docker-username=$ACR_USERNAME \
    --docker-password=$ACR_PASSWORD \
    --dry-run=client -o yaml | kubectl apply -f -

log_info "=========================================="
log_info "✅ Provisionamento concluído com sucesso!"
log_info "=========================================="
echo ""
log_info "Próximos passos:"
echo "1. Configure os GitHub Secrets conforme mostrado acima"
echo "2. Faça commit e push do código para o repositório"
echo "3. O GitHub Actions iniciará automaticamente o deploy"
echo "4. Monitore o deployment: kubectl get pods -n superintelligence"
echo "5. Obtenha o IP público: kubectl get svc -n superintelligence"
echo ""
log_info "Para limpar os recursos: ./cleanup-infrastructure.sh"
