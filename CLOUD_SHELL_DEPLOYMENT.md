# 🚀 Azure Cloud Shell Deployment Guide

This guide provides a complete step-by-step process to deploy the **superintelligence-historical-analysis** application to Azure Kubernetes Service (AKS) using only the Azure Cloud Shell.

**Estimated Time**: 25-35 minutes

## Prerequisites

- An Azure account with an active subscription.
- Access to the Azure Cloud Shell: https://shell.azure.com

## Step 1: Launch Cloud Shell and Clone Repository

1.  **Open Azure Cloud Shell**: Navigate to [shell.azure.com](https://shell.azure.com) and log in with your organizational Azure account.

2.  **Clone the repository**:
    ```bash
    git clone https://github.com/alexandrepedrosaai/superintelligence-historical-analysis.git
    cd superintelligence-historical-analysis
    ```

## Step 2: Configure Environment Variables

This step sets up environment variables to ensure consistency throughout the deployment process.

```bash
# --- Configuration ---
export RESOURCE_GROUP="superintelligence-rg"
export LOCATION="eastus"
export ACR_NAME="superintelligenceacr$(openssl rand -hex 4)"
export AKS_NAME="superintelligence-aks"
export IMAGE_NAME="timeline-api"
export IMAGE_TAG="v1.0.0"

# --- Display configuration ---
echo "Configuration set:"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Location: $LOCATION"
echo "- ACR Name: $ACR_NAME"
echo "- AKS Name: $AKS_NAME"
echo "- Image: $IMAGE_NAME:$IMAGE_TAG"
```

## Step 3: Provision Azure Infrastructure

This step creates the necessary Azure resources: a Resource Group, an Azure Container Registry (ACR), and an Azure Kubernetes Service (AKS) cluster.

1.  **Create a Resource Group**:
    ```bash
    az group create --name $RESOURCE_GROUP --location $LOCATION
    ```

2.  **Create an Azure Container Registry (ACR)**:
    ```bash
    az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true
    ```

3.  **Create an Azure Kubernetes Service (AKS) Cluster**:
    *This step can take 10-15 minutes.*
    ```bash
    az aks create \
      --resource-group $RESOURCE_GROUP \
      --name $AKS_NAME \
      --node-count 2 \
      --enable-managed-identity \
      --generate-ssh-keys
    ```

4.  **Attach ACR to AKS**: This allows AKS to pull images from your container registry.
    ```bash
    az aks update --name $AKS_NAME --resource-group $RESOURCE_GROUP --attach-acr $ACR_NAME
    ```

## Step 4: Build and Push Docker Image

Now, we will build the Docker image for the application and push it to the ACR you just created.

1.  **Log in to ACR**:
    ```bash
    az acr login --name $ACR_NAME
    ```

2.  **Build the Docker image**:
    *This step uses ACR Tasks to build the image directly in Azure, which is faster and more efficient than building locally in Cloud Shell.*
    ```bash
    az acr build \
      --registry $ACR_NAME \
      --image $IMAGE_NAME:$IMAGE_TAG \
      --file Dockerfile \
      .
    ```

## Step 5: Deploy Application to AKS

With the infrastructure ready and the image in the registry, it's time to deploy the application to Kubernetes using the Helm chart.

1.  **Get AKS Credentials**: Configure `kubectl` to connect to your new Kubernetes cluster.
    ```bash
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME
    ```

2.  **Verify Kubernetes Connection**:
    ```bash
    kubectl get nodes
    ```
    *You should see two nodes with a "Ready" status.*

3.  **Install the Helm Chart**:
    *This command installs the application, creates the necessary Kubernetes resources (Deployment, Service, HPA, etc.), and configures it to use the image from your ACR.*
    ```bash
    helm install timeline-api helm/timeline-api/ \
      --namespace superintelligence \
      --create-namespace \
      --set image.repository=$ACR_NAME.azurecr.io/$IMAGE_NAME \
      --set image.tag=$IMAGE_TAG
    ```

## Step 6: Verify the Deployment

Let's check if the application was deployed successfully and get the public IP address to access it.

1.  **Check the status of the pods**:
    ```bash
    kubectl get pods -n superintelligence -w
    ```
    *Wait until the `timeline-api` pods are in the `Running` state. Press `Ctrl+C` to exit the watch.*

2.  **Get the public IP address of the service**:
    ```bash
    kubectl get service timeline-api -n superintelligence
    ```
    *Look for the `EXTERNAL-IP` address. It might take a few minutes to appear.*

3.  **Access the application**:
    Once you have the external IP, you can access the API endpoints:
    - **Health Check**: `http://<EXTERNAL-IP>:3000/health`
    - **Timeline JSON**: `http://<EXTERNAL-IP>:3000/api/timeline`
    - **Timeline Image**: `http://<EXTERNAL-IP>:3000/api/timeline/image`

## Step 7: Cleanup (Optional)

To delete all the resources created in this guide and avoid ongoing charges, run the following command:

```bash
# WARNING: This will delete the entire resource group and all its contents.
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

---

**Congratulations! You have successfully deployed the application to Azure Kubernetes Service using Cloud Shell!** 🚀
