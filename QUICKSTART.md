# 🚀 Guia de Início Rápido - Timeline API

Este guia fornece os passos essenciais para colocar a Timeline API em funcionamento rapidamente.

## 📋 Pré-requisitos

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) instalado
- [kubectl](https://kubernetes.io/docs/tasks/tools/) instalado
- [Helm 3.x](https://helm.sh/docs/intro/install/) instalado
- Conta Azure ativa

## ⚡ Início Rápido (5 passos)

### 1. Provisionar Infraestrutura Azure (15 min)

```bash
# Fazer login no Azure
az login

# Executar script de provisionamento
cd azure
./provision-infrastructure.sh
```

O script irá criar:
- Resource Group: `superintelligence-rg`
- Azure Container Registry: `superintelligenceacr`
- AKS Cluster: `superintelligence-aks` (2 nodes)

**Importante**: Anote as credenciais exibidas ao final!

### 2. Configurar GitHub Secrets (5 min)

Acesse: https://github.com/alexandrepedrosaai/superintelligence-historical-analysis/settings/secrets/actions

Adicione os seguintes secrets com os valores fornecidos pelo script:

| Secret Name | Descrição |
|-------------|-----------|
| `AZURE_CREDENTIALS` | JSON do Service Principal |
| `ACR_LOGIN_SERVER` | `superintelligenceacr.azurecr.io` |
| `ACR_USERNAME` | Username do ACR |
| `ACR_PASSWORD` | Password do ACR |
| `AKS_CLUSTER_NAME` | `superintelligence-aks` |
| `AKS_RESOURCE_GROUP` | `superintelligence-rg` |

### 3. Atualizar Workflow CI/CD (2 min)

O arquivo `.github/workflows/deploy.yml` precisa ser atualizado manualmente:

1. Acesse o repositório no GitHub
2. Navegue até `.github/workflows/deploy.yml`
3. Edite e substitua pelo conteúdo completo (disponível no repositório)
4. Faça commit

### 4. Configurar kubectl (1 min)

```bash
az aks get-credentials \
  --resource-group superintelligence-rg \
  --name superintelligence-aks
```

### 5. Instalar Helm Chart (5 min)

```bash
# Opção A: Script automatizado
./scripts/install-helm-chart.sh

# Opção B: Comando direto
helm install timeline-api helm/timeline-api \
  --namespace superintelligence \
  --create-namespace
```

## ✅ Verificação

Após a instalação, verifique se tudo está funcionando:

```bash
# Ver status dos pods
kubectl get pods -n superintelligence

# Ver serviços
kubectl get svc -n superintelligence

# Obter IP externo
EXTERNAL_IP=$(kubectl get svc timeline-api -n superintelligence -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "API disponível em: http://$EXTERNAL_IP"

# Testar health check
curl http://$EXTERNAL_IP/health

# Testar API
curl http://$EXTERNAL_IP/api/timeline
```

## 🎯 Endpoints Disponíveis

| Endpoint | Descrição |
|----------|-----------|
| `GET /health` | Health check |
| `GET /api/timeline` | Dados da timeline (JSON) |
| `GET /api/timeline/image` | Imagem PNG da timeline |
| `GET /api/narrative` | Narrativa textual |
| `GET /api/timeline/:date` | Evento específico |

## 🔧 Recursos Opcionais

### Instalar HTTPS com Ingress (10 min)

```bash
./scripts/install-ingress-https.sh
```

Depois configure seu DNS para apontar para o IP do Ingress.

### Instalar Monitoramento (10 min)

```bash
./scripts/install-monitoring.sh
```

Acesse Grafana no IP exibido (usuário: `admin`, senha: `admin`).

## 📚 Próximos Passos

- **Desenvolvimento Local**: Veja [CONTRIBUTING.md](CONTRIBUTING.md)
- **Helm Chart**: Veja [helm/README.md](helm/README.md)
- **Deployment Completo**: Veja [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Recursos Avançados**: Veja [docs/ADVANCED_FEATURES.md](docs/ADVANCED_FEATURES.md)

## 🆘 Problemas Comuns

### Pods não iniciam

```bash
kubectl describe pod -n superintelligence <pod-name>
kubectl logs -n superintelligence <pod-name>
```

### LoadBalancer não recebe IP

Aguarde alguns minutos. Se persistir:

```bash
kubectl describe svc timeline-api -n superintelligence
```

### Erro de autenticação no ACR

Recrie o secret:

```bash
kubectl create secret docker-registry acr-secret \
  --namespace=superintelligence \
  --docker-server=superintelligenceacr.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password>
```

## 💡 Comandos Úteis

```bash
# Ver todos os comandos disponíveis
make help

# Ver logs em tempo real
kubectl logs -n superintelligence -l app.kubernetes.io/name=timeline-api -f

# Escalar deployment
kubectl scale deployment timeline-api -n superintelligence --replicas=5

# Reiniciar deployment
kubectl rollout restart deployment/timeline-api -n superintelligence

# Port forward para acesso local
kubectl port-forward -n superintelligence svc/timeline-api 3000:80
```

## 🎉 Pronto!

Sua Timeline API está rodando no Azure Kubernetes Service!

Para mais informações, consulte a documentação completa no repositório.
