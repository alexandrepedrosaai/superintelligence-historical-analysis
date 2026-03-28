# Guia de Contribuição

Obrigado por considerar contribuir para o projeto **Superintelligence Timeline API**! Este documento fornece diretrizes para contribuir de forma efetiva.

## Código de Conduta

Ao participar deste projeto, você concorda em manter um ambiente respeitoso e colaborativo.

## Como Contribuir

### Reportando Bugs

Se você encontrou um bug, por favor abra uma issue no GitHub incluindo:

- Descrição clara do problema
- Passos para reproduzir
- Comportamento esperado vs. comportamento atual
- Versão do Node.js e sistema operacional
- Logs relevantes

### Sugerindo Melhorias

Para sugerir uma nova funcionalidade ou melhoria:

1. Verifique se já não existe uma issue similar
2. Abra uma nova issue descrevendo:
   - O problema que a funcionalidade resolve
   - Como você imagina a solução
   - Exemplos de uso

### Pull Requests

1. **Fork o repositório** e crie sua branch a partir de `main`:
   ```bash
   git checkout -b feature/minha-funcionalidade
   ```

2. **Faça suas alterações** seguindo as convenções de código:
   - Use 2 espaços para indentação
   - Siga o estilo ESLint configurado
   - Adicione comentários quando necessário

3. **Adicione testes** para suas alterações:
   ```bash
   npm test
   ```

4. **Execute o linter**:
   ```bash
   npm run lint
   ```

5. **Commit suas alterações** seguindo o padrão Conventional Commits:
   ```bash
   git commit -m "feat: adiciona endpoint para filtrar timeline por sistema"
   ```

   Tipos de commit:
   - `feat`: Nova funcionalidade
   - `fix`: Correção de bug
   - `docs`: Alterações na documentação
   - `style`: Formatação, ponto e vírgula faltando, etc.
   - `refactor`: Refatoração de código
   - `test`: Adição ou correção de testes
   - `chore`: Tarefas de manutenção

6. **Push para sua branch**:
   ```bash
   git push origin feature/minha-funcionalidade
   ```

7. **Abra um Pull Request** no GitHub

### Checklist do Pull Request

Antes de submeter, verifique:

- [ ] O código segue o estilo do projeto
- [ ] Testes foram adicionados/atualizados
- [ ] Todos os testes passam
- [ ] A documentação foi atualizada (se necessário)
- [ ] O commit message segue o padrão Conventional Commits
- [ ] Não há conflitos com a branch `main`

## Desenvolvimento Local

### Setup Inicial

```bash
# Clone o repositório
git clone https://github.com/alexandrepedrosaai/superintelligence-historical-analysis.git
cd superintelligence-historical-analysis

# Instale dependências
npm install

# Execute testes
npm test

# Inicie em modo desenvolvimento
npm run dev
```

### Testando com Docker

```bash
# Build da imagem
docker build -t timeline-api:dev .

# Execute o container
docker run -p 3000:3000 timeline-api:dev
```

### Testando com Docker Compose

```bash
# Inicie todos os serviços
docker-compose up -d

# Veja os logs
docker-compose logs -f

# Pare os serviços
docker-compose down
```

## Estrutura do Projeto

```
.
├── src/                    # Código-fonte da aplicação
│   ├── data/              # Módulos de dados
│   ├── routes/            # Rotas da API
│   ├── services/          # Lógica de negócio
│   └── server.js          # Arquivo principal
├── tests/                 # Testes automatizados
├── k8s/                   # Manifests Kubernetes
├── helm/                  # Helm Charts
├── scripts/               # Scripts utilitários
├── azure/                 # Scripts de infraestrutura Azure
└── docs/                  # Documentação adicional
```

## Padrões de Código

### JavaScript/Node.js

- Use `const` e `let`, nunca `var`
- Use arrow functions quando apropriado
- Use async/await ao invés de callbacks
- Trate erros adequadamente
- Adicione JSDoc para funções públicas

Exemplo:

```javascript
/**
 * Gera visualização da timeline
 * @param {Object} options - Opções de configuração
 * @returns {Promise<Buffer>} Buffer da imagem PNG
 */
async function generateTimeline(options) {
  try {
    // Implementação
  } catch (error) {
    logger.error('Erro ao gerar timeline:', error);
    throw error;
  }
}
```

### Testes

- Um arquivo de teste por módulo
- Use nomes descritivos para os testes
- Siga o padrão AAA (Arrange, Act, Assert)

Exemplo:

```javascript
describe('GET /api/timeline', () => {
  it('should return timeline data with correct structure', async () => {
    // Arrange
    const expectedFields = ['date', 'system', 'act'];
    
    // Act
    const res = await request(app).get('/api/timeline');
    
    // Assert
    expect(res.statusCode).toBe(200);
    expect(res.body.data[0]).toHaveProperty(...expectedFields);
  });
});
```

## Versionamento

Este projeto segue o [Semantic Versioning](https://semver.org/):

- **MAJOR**: Mudanças incompatíveis na API
- **MINOR**: Novas funcionalidades compatíveis
- **PATCH**: Correções de bugs compatíveis

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença do projeto (MIT).

## Dúvidas?

Se tiver dúvidas sobre como contribuir, abra uma issue ou entre em contato com os mantenedores.

---

**Obrigado por contribuir!** 🚀
