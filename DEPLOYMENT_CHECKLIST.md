# ✅ Checklist de Deployment - Timeline API

Use este checklist para garantir que todos os passos do deployment sejam executados corretamente.

## 📋 Pré-Deployment

### Ferramentas e Acesso

- [ ] Azure CLI instalado e atualizado (`az version`)
- [ ] kubectl instalado (`kubectl version --client`)
- [ ] Helm 3.x instalado (`helm version`)
- [ ] Acesso à conta Azure (`az login`)
- [ ] Acesso ao repositório GitHub
- [ ] Permissões de admin no repositório (para configurar secrets)

### Planejamento

- [ ] Definir região Azure (padrão: `eastus`)
- [ ] Definir tamanho do cluster (padrão: 2 nodes, Standard_DS2_v2)
- [ ] Definir nome do domínio (se usar Ingress)
- [ ] Revisar custos estimados no Azure

## 🏗️ Provisionamento de Infraestrutura

### Azure Resources

- [ ] Executar `./azure/provision-infrastructure.sh`
- [ ] Aguardar criação do Resource Group
- [ ] Aguardar criação do ACR (Azure Container Registry)
- [ ] Aguardar criação do AKS (Azure Kubernetes Service)
- [ ] Anotar credenciais exibidas ao final

### Validação

- [ ] Verificar Resource Group: `az group show -n superintelligence-rg`
- [ ] Verificar ACR: `az acr show -n superintelligenceacr`
- [ ] Verificar AKS: `az aks show -n superintelligence-aks -g superintelligence-rg`
- [ ] Verificar nodes: `kubectl get nodes`

## 🔐 Configuração de Secrets

### GitHub Secrets

Acesse: https://github.com/alexandrepedrosaai/superintelligence-historical-analysis/settings/secrets/actions

- [ ] `AZURE_CREDENTIALS` - JSON do Service Principal
- [ ] `ACR_LOGIN_SERVER` - `superintelligenceacr.azurecr.io`
- [ ] `ACR_USERNAME` - Username do ACR
- [ ] `ACR_PASSWORD` - Password do ACR
- [ ] `AKS_CLUSTER_NAME` - `superintelligence-aks`
- [ ] `AKS_RESOURCE_GROUP` - `superintelligence-rg`

### Validação

- [ ] Todos os secrets criados no GitHub
- [ ] Valores corretos (sem espaços extras)
- [ ] Testar workflow CI/CD com um commit

## 🔧 Configuração do Kubernetes

### kubectl

- [ ] Configurar kubectl: `az aks get-credentials --resource-group superintelligence-rg --name superintelligence-aks`
- [ ] Testar conexão: `kubectl cluster-info`
- [ ] Verificar contexto: `kubectl config current-context`

### Namespace

- [ ] Criar namespace: `kubectl create namespace superintelligence`
- [ ] Verificar: `kubectl get namespace superintelligence`

### Secrets do Kubernetes (se necessário)

- [ ] Criar secret do ACR (se não usar managed identity):
  ```bash
  kubectl create secret docker-registry acr-secret \
    --namespace=superintelligence \
    --docker-server=superintelligenceacr.azurecr.io \
    --docker-username=<username> \
    --docker-password=<password>
  ```

## 📦 Deployment da Aplicação

### Helm Chart

- [ ] Validar chart: `helm lint helm/timeline-api`
- [ ] Revisar valores: `cat helm/timeline-api/values.yaml`
- [ ] Customizar valores (se necessário): criar `my-values.yaml`
- [ ] Instalar chart: `./scripts/install-helm-chart.sh` ou `helm install timeline-api helm/timeline-api -n superintelligence`
- [ ] Aguardar pods ficarem prontos: `kubectl get pods -n superintelligence -w`

### Validação do Deployment

- [ ] Verificar pods: `kubectl get pods -n superintelligence`
- [ ] Verificar services: `kubectl get svc -n superintelligence`
- [ ] Verificar HPA: `kubectl get hpa -n superintelligence`
- [ ] Ver logs: `kubectl logs -n superintelligence -l app.kubernetes.io/name=timeline-api`

## 🌐 Acesso à Aplicação

### LoadBalancer

- [ ] Obter IP externo: `kubectl get svc timeline-api -n superintelligence`
- [ ] Aguardar IP ser atribuído (pode levar alguns minutos)
- [ ] Testar health check: `curl http://<EXTERNAL_IP>/health`
- [ ] Testar API: `curl http://<EXTERNAL_IP>/api/timeline`

### Endpoints

- [ ] `GET /health` - Retorna status OK
- [ ] `GET /api/timeline` - Retorna JSON com eventos
- [ ] `GET /api/timeline/image` - Retorna imagem PNG
- [ ] `GET /api/narrative` - Retorna narrativa textual

## 🔒 HTTPS e Ingress (Opcional)

### Instalação

- [ ] Executar: `./scripts/install-ingress-https.sh`
- [ ] Aguardar NGINX Ingress Controller estar pronto
- [ ] Aguardar cert-manager estar pronto

### Configuração DNS

- [ ] Obter IP do Ingress: `kubectl get svc -n ingress-nginx`
- [ ] Criar registro A no DNS apontando para o IP
- [ ] Aguardar propagação DNS (pode levar até 48h)

### Habilitar Ingress no Helm

- [ ] Atualizar `values.yaml` ou criar `my-values.yaml`:
  ```yaml
  ingress:
    enabled: true
    hosts:
      - host: timeline-api.yourdomain.com
        paths:
          - path: /
            pathType: Prefix
    tls:
      - secretName: timeline-api-tls
        hosts:
          - timeline-api.yourdomain.com
  ```
- [ ] Fazer upgrade: `helm upgrade timeline-api helm/timeline-api -n superintelligence -f my-values.yaml`

### Validação

- [ ] Verificar Ingress: `kubectl get ingress -n superintelligence`
- [ ] Verificar certificado: `kubectl get certificate -n superintelligence`
- [ ] Testar HTTPS: `curl https://timeline-api.yourdomain.com/health`

## 📊 Monitoramento (Opcional)

### Instalação

- [ ] Executar: `./scripts/install-monitoring.sh`
- [ ] Aguardar Prometheus estar pronto
- [ ] Aguardar Grafana estar pronto

### Acesso

- [ ] Obter IP do Grafana: `kubectl get svc -n monitoring grafana`
- [ ] Acessar: `http://<GRAFANA_IP>:3000`
- [ ] Login: usuário `admin`, senha `admin`
- [ ] Importar dashboard da Timeline API

### Validação

- [ ] Prometheus coletando métricas
- [ ] Dashboard do Grafana exibindo dados
- [ ] Alertas configurados (se necessário)

## 🔄 CI/CD Pipeline

### Workflow

- [ ] Atualizar `.github/workflows/deploy.yml` (manualmente)
- [ ] Fazer commit e push
- [ ] Verificar workflow executando: https://github.com/alexandrepedrosaai/superintelligence-historical-analysis/actions

### Validação

- [ ] Build da imagem Docker bem-sucedido
- [ ] Push para ACR bem-sucedido
- [ ] Deploy no AKS bem-sucedido
- [ ] Pods atualizados com nova versão

## 🧪 Testes

### Testes Locais

- [ ] Executar testes: `npm test`
- [ ] Verificar cobertura: `npm run test:coverage`
- [ ] Todos os testes passando

### Testes no Cluster

- [ ] Health check respondendo
- [ ] API retornando dados corretos
- [ ] Imagens sendo geradas
- [ ] Performance aceitável (latência < 500ms)

## 📈 Monitoramento Pós-Deployment

### Métricas

- [ ] CPU usage dos pods
- [ ] Memory usage dos pods
- [ ] Taxa de requisições
- [ ] Taxa de erros
- [ ] Latência média

### Logs

- [ ] Configurar agregação de logs (se necessário)
- [ ] Verificar logs de erro
- [ ] Configurar alertas

## 🔐 Segurança

### Revisão

- [ ] Secrets não expostos em logs ou código
- [ ] RBAC configurado corretamente
- [ ] Network policies (se necessário)
- [ ] Pod security policies
- [ ] Imagens escaneadas por vulnerabilidades

## 📚 Documentação

### Atualização

- [ ] README.md atualizado com informações de acesso
- [ ] Documentar IP/domínio da aplicação
- [ ] Documentar credenciais de acesso (em local seguro)
- [ ] Criar runbook para operações comuns

## 🎯 Validação Final

### Checklist de Produção

- [ ] Aplicação acessível via IP externo ou domínio
- [ ] HTTPS funcionando (se configurado)
- [ ] Monitoramento ativo
- [ ] Logs sendo coletados
- [ ] Backup configurado (se necessário)
- [ ] Alertas configurados
- [ ] Documentação completa
- [ ] Equipe treinada

### Performance

- [ ] Load testing realizado
- [ ] Autoscaling testado
- [ ] Limites de recursos adequados
- [ ] Tempo de resposta aceitável

### Disaster Recovery

- [ ] Plano de rollback documentado
- [ ] Backup de configurações
- [ ] Procedimento de restore testado

## 📞 Contatos e Suporte

- [ ] Documentar contatos da equipe
- [ ] Documentar escalação de incidentes
- [ ] Configurar canais de comunicação (Slack, Teams, etc.)

## ✅ Deployment Completo!

Quando todos os itens estiverem marcados, seu deployment está completo e a aplicação está pronta para produção!

---

**Data do Deployment**: _________________

**Responsável**: _________________

**Assinatura**: _________________
