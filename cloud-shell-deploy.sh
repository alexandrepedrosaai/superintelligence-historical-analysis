#!/bin/bash
set -e

# ============================================================================
# Azure Cloud Shell Deployment Script
# ============================================================================
# This script automates the deployment of the Timeline API to Azure AKS.
# Run this script in Azure Cloud Shell: https://shell.azure.com
# ============================================================================

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║   Timeline API - Azure AKS Deployment Script                    ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# --- Configuration ---
RESOURCE_GROUP="${RESOURCE_GROUP:-superintelligence-rg}"
LOCATION="${LOCATION:-eastus}"
ACR_NAME="${ACR_NAME:-superintelligenceacr$(openssl rand -hex 4)}"
AKS_NAME="${AKS_NAME:-superintelligence-aks}"
IMAGE_NAME="${IMAGE_NAME:-timeline-api}"
IMAGE_TAG="${IMAGE_TAG:-v1.0.0}"

echo "📋 Deployment Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Location: $LOCATION"
echo "   ACR Name: $ACR_NAME"
echo "   AKS Name: $AKS_NAME"
echo "   Image: $IMAGE_NAME:$IMAGE_TAG"
echo ""

# --- Confirmation ---
read -p "Continue with deployment? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 1
fi

# --- Step 1: Create Resource Group ---
echo ""
echo "📦 Step 1/7: Creating Resource Group..."
if az group show --name $RESOURCE_GROUP &>/dev/null; then
    echo "✓ Resource Group already exists: $RESOURCE_GROUP"
else
    az group create --name $RESOURCE_GROUP --location $LOCATION --output table
    echo "✓ Resource Group created: $RESOURCE_GROUP"
fi

# --- Step 2: Create ACR ---
echo ""
echo "🐳 Step 2/7: Creating Azure Container Registry..."
if az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
    echo "✓ ACR already exists: $ACR_NAME"
else
    az acr create \
      --resource-group $RESOURCE_GROUP \
      --name $ACR_NAME \
      --sku Basic \
      --admin-enabled true \
      --output table
    echo "✓ ACR created: $ACR_NAME"
fi

# --- Step 3: Create AKS ---
echo ""
echo "☸️  Step 3/7: Creating Azure Kubernetes Service..."
echo "   (This may take 10-15 minutes...)"
if az aks show --name $AKS_NAME --resource-group $RESOURCE_GROUP &>/dev/null; then
    echo "✓ AKS already exists: $AKS_NAME"
else
    az aks create \
      --resource-group $RESOURCE_GROUP \
      --name $AKS_NAME \
      --node-count 2 \
      --enable-managed-identity \
      --generate-ssh-keys \
      --output table
    echo "✓ AKS created: $AKS_NAME"
fi

# --- Step 4: Attach ACR to AKS ---
echo ""
echo "🔗 Step 4/7: Attaching ACR to AKS..."
az aks update \
  --name $AKS_NAME \
  --resource-group $RESOURCE_GROUP \
  --attach-acr $ACR_NAME \
  --output table
echo "✓ ACR attached to AKS"

# --- Step 5: Build and Push Docker Image ---
echo ""
echo "🏗️  Step 5/7: Building and pushing Docker image..."
az acr build \
  --registry $ACR_NAME \
  --image $IMAGE_NAME:$IMAGE_TAG \
  --file Dockerfile \
  . \
  --output table
echo "✓ Docker image built and pushed: $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"

# --- Step 6: Get AKS Credentials ---
echo ""
echo "🔑 Step 6/7: Configuring kubectl..."
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --overwrite-existing
echo "✓ kubectl configured"

# --- Step 7: Deploy with Helm ---
echo ""
echo "🚀 Step 7/7: Deploying application with Helm..."
helm install timeline-api helm/timeline-api/ \
  --namespace superintelligence \
  --create-namespace \
  --set image.repository=$ACR_NAME.azurecr.io/$IMAGE_NAME \
  --set image.tag=$IMAGE_TAG
echo "✓ Application deployed"

# --- Verify Deployment ---
echo ""
echo "✅ Deployment Complete!"
echo ""
echo "📊 Checking deployment status..."
kubectl get pods -n superintelligence

echo ""
echo "🌐 Getting service information..."
echo "   (The external IP may take a few minutes to appear)"
kubectl get service timeline-api -n superintelligence

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║   Deployment Summary                                             ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "Resource Group: $RESOURCE_GROUP"
echo "ACR: $ACR_NAME.azurecr.io"
echo "AKS: $AKS_NAME"
echo "Image: $ACR_NAME.azurecr.io/$IMAGE_NAME:$IMAGE_TAG"
echo ""
echo "To get the external IP address:"
echo "  kubectl get service timeline-api -n superintelligence"
echo ""
echo "To view logs:"
echo "  kubectl logs -n superintelligence -l app=timeline-api"
echo ""
echo "To delete all resources:"
echo "  az group delete --name $RESOURCE_GROUP --yes --no-wait"
echo ""
