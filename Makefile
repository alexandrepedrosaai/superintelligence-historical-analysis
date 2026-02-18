.PHONY: help install test lint dev build run stop clean deploy logs status

# Variáveis
DOCKER_IMAGE = superintelligence-timeline
DOCKER_TAG = latest
NAMESPACE = superintelligence

help: ## Mostra esta mensagem de ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Instala dependências Node.js
	npm install

test: ## Executa testes automatizados
	npm test

test-watch: ## Executa testes em modo watch
	npm run test:watch

lint: ## Executa linter no código
	npm run lint

dev: ## Inicia servidor em modo desenvolvimento
	npm run dev

build: ## Constrói imagem Docker
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

run: ## Executa container Docker localmente
	docker run -d --name timeline-api -p 3000:3000 $(DOCKER_IMAGE):$(DOCKER_TAG)

stop: ## Para container Docker
	docker stop timeline-api || true
	docker rm timeline-api || true

compose-up: ## Inicia ambiente com Docker Compose
	docker-compose up -d

compose-down: ## Para ambiente Docker Compose
	docker-compose down

compose-logs: ## Mostra logs do Docker Compose
	docker-compose logs -f

clean: ## Remove arquivos temporários e containers
	rm -rf node_modules coverage *.log
	docker-compose down -v || true
	docker rmi $(DOCKER_IMAGE):$(DOCKER_TAG) || true

# Comandos Kubernetes
k8s-apply: ## Aplica manifests Kubernetes
	kubectl apply -k k8s/base

k8s-delete: ## Remove recursos Kubernetes
	kubectl delete -k k8s/base

deploy: ## Deploy completo no AKS
	@echo "Aplicando manifests..."
	kubectl apply -k k8s/base
	@echo "Aguardando rollout..."
	kubectl rollout status deployment/timeline-api -n $(NAMESPACE)
	@echo "Deploy concluído!"

logs: ## Mostra logs dos pods
	kubectl logs -n $(NAMESPACE) -l app=timeline-api --tail=100 -f

status: ## Mostra status dos recursos
	@echo "=== Pods ==="
	kubectl get pods -n $(NAMESPACE)
	@echo "\n=== Services ==="
	kubectl get svc -n $(NAMESPACE)
	@echo "\n=== HPA ==="
	kubectl get hpa -n $(NAMESPACE)

scale: ## Escala deployment (uso: make scale REPLICAS=3)
	kubectl scale deployment/timeline-api -n $(NAMESPACE) --replicas=$(REPLICAS)

restart: ## Reinicia deployment
	kubectl rollout restart deployment/timeline-api -n $(NAMESPACE)

port-forward: ## Port forward para acesso local (porta 3000)
	kubectl port-forward -n $(NAMESPACE) svc/timeline-api-service 3000:80

# Comandos Azure
azure-provision: ## Provisiona infraestrutura Azure
	cd azure && ./provision-infrastructure.sh

azure-cleanup: ## Remove infraestrutura Azure
	cd azure && ./cleanup-infrastructure.sh

# Comandos de monitoramento
install-ingress: ## Instala NGINX Ingress e cert-manager
	cd scripts && ./install-ingress-https.sh

install-monitoring: ## Instala Prometheus e Grafana
	cd scripts && ./install-monitoring.sh

# Comandos de desenvolvimento
test-local: ## Testa aplicação localmente
	./scripts/test-local.sh

test-docker: ## Testa imagem Docker
	./scripts/test-docker.sh

# Comandos de CI/CD
ci-build: ## Simula build do CI
	docker build --target builder -t $(DOCKER_IMAGE):builder .
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

ci-test: ## Simula testes do CI
	npm ci
	npm test
	npm run lint

ci-scan: ## Escaneia vulnerabilidades com Trivy
	trivy image $(DOCKER_IMAGE):$(DOCKER_TAG)
