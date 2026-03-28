# Helm Chart para Timeline API

Este diretório contém o Helm Chart para deployment da Timeline API no Kubernetes.

## Pré-requisitos

- Kubernetes cluster (AKS, EKS, GKE, ou local)
- Helm 3.x instalado
- kubectl configurado

## Instalação

### Instalação básica

```bash
helm install timeline-api ./helm/timeline-api \
  --namespace superintelligence \
  --create-namespace
```

### Instalação com valores personalizados

```bash
helm install timeline-api ./helm/timeline-api \
  --namespace superintelligence \
  --create-namespace \
  --set image.tag=v1.0.0 \
  --set replicaCount=3 \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=timeline-api.yourdomain.com
```

### Instalação com arquivo de valores

Crie um arquivo `my-values.yaml`:

```yaml
replicaCount: 3

image:
  tag: "v1.0.0"

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

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 15
  targetCPUUtilizationPercentage: 60
```

Instale com:

```bash
helm install timeline-api ./helm/timeline-api \
  --namespace superintelligence \
  --create-namespace \
  -f my-values.yaml
```

## Upgrade

```bash
helm upgrade timeline-api ./helm/timeline-api \
  --namespace superintelligence \
  -f my-values.yaml
```

## Rollback

```bash
# Ver histórico de releases
helm history timeline-api -n superintelligence

# Rollback para versão anterior
helm rollback timeline-api -n superintelligence

# Rollback para versão específica
helm rollback timeline-api 2 -n superintelligence
```

## Desinstalação

```bash
helm uninstall timeline-api -n superintelligence
```

## Valores Configuráveis

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| `replicaCount` | Número de réplicas | `2` |
| `image.repository` | Repositório da imagem | `superintelligenceacr.azurecr.io/superintelligence-timeline` |
| `image.tag` | Tag da imagem | `latest` |
| `image.pullPolicy` | Política de pull da imagem | `Always` |
| `service.type` | Tipo do serviço | `LoadBalancer` |
| `service.port` | Porta do serviço | `80` |
| `ingress.enabled` | Habilitar Ingress | `false` |
| `ingress.className` | Classe do Ingress | `nginx` |
| `resources.limits.cpu` | Limite de CPU | `500m` |
| `resources.limits.memory` | Limite de memória | `512Mi` |
| `autoscaling.enabled` | Habilitar HPA | `true` |
| `autoscaling.minReplicas` | Mínimo de réplicas | `2` |
| `autoscaling.maxReplicas` | Máximo de réplicas | `10` |

Para ver todos os valores disponíveis, consulte `values.yaml`.

## Exemplos de Uso

### Ambiente de Desenvolvimento

```bash
helm install timeline-api-dev ./helm/timeline-api \
  --namespace superintelligence-dev \
  --create-namespace \
  --set replicaCount=1 \
  --set autoscaling.enabled=false \
  --set env[0].name=NODE_ENV \
  --set env[0].value=development \
  --set env[1].name=LOG_LEVEL \
  --set env[1].value=debug
```

### Ambiente de Produção

```bash
helm install timeline-api-prod ./helm/timeline-api \
  --namespace superintelligence-prod \
  --create-namespace \
  --set replicaCount=3 \
  --set autoscaling.minReplicas=3 \
  --set autoscaling.maxReplicas=15 \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=1Gi \
  --set ingress.enabled=true
```

## Troubleshooting

### Ver status do release

```bash
helm status timeline-api -n superintelligence
```

### Ver valores aplicados

```bash
helm get values timeline-api -n superintelligence
```

### Ver manifests gerados

```bash
helm get manifest timeline-api -n superintelligence
```

### Testar template sem instalar

```bash
helm template timeline-api ./helm/timeline-api \
  --namespace superintelligence \
  -f my-values.yaml
```

### Validar chart

```bash
helm lint ./helm/timeline-api
```

## Documentação Adicional

- [Helm Documentation](https://helm.sh/docs/)
- [Best Practices](https://helm.sh/docs/chart_best_practices/)
