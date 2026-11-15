# Checklist de guardrails por camada

Cada controle recebe `tem` (arquivo:linha), `falta` ou `não se aplica` (motivo). Os códigos entre colchetes apontam para OWASP LLM Top 10 2025 (LLMxx) e OWASP Agentic Top 10 2026 (ASIxx).

## 1. Entrada

- [ ] **Origem rotulada**: cada pedaço de texto que entra no contexto carrega sua origem (usuário dono, cliente final, tool, documento, memória). [LLM01, ASI01]
- [ ] **Remetente permitido** onde o canal permite: lista de números, contas ou grupos aceitos para bots internos.
- [ ] **Limite de tamanho** por mensagem, anexo e transcrição antes de chegar ao modelo.
- [ ] **Mídia é entrada não confiável**: transcrição de áudio, OCR e descrição de imagem seguem o mesmo caminho do texto do cliente.
- [ ] **Classificador de injection** (opcional, ex.: Prompt Guard 2, LlamaFirewall) em canais públicos, como sinal e nunca como única barreira. Marque `não se aplica` em canais fechados.

## 2. Contexto

- [ ] **Regras centrais no código**, versionadas e testadas; o que o cliente ou tenant configura entra depois, marcado como dado, e perde em conflito.
- [ ] **Envelope de conteúdo externo**: resultado de tool não confiável volta embrulhado com o aviso *antes* do conteúdo (ex.: `{aviso, conteudo}`), dizendo que é informação e nunca instrução. Cobrir web, MCP de terceiro, RAG compartilhado, cards, eventos de agenda, e-mails, issues e PRs.
- [ ] **Memória marcada**: o que o agente lembra de sessões anteriores entra como anotação, nunca como instrução. Gravação de memória a partir de conteúdo externo pede confirmação (envenenamento de memória). [ASI06]
- [ ] **Sem segredos no prompt**: chaves, tokens e dados de outros tenants nunca entram no contexto, nem no system prompt.
- [ ] **Isolamento do RAG**: a busca filtra por tenant e visibilidade no banco, antes do ranking. O modelo não recebe o filtro como argumento.

## 3. Ações

- [ ] **Efeito por tool** (`READ`, `WRITE`, `DELETE`, `EXTERNAL`, `EXECUTE`) declarado junto da tool, não inferido pelo modelo. [ASI02]
- [ ] **Portão antes da execução**: política por efeito (`allow`, `ask`, `deny`) aplicada em código, por usuário ou tenant.
- [ ] **Taint determinístico**: depois que conteúdo não confiável entrou no turno, `EXTERNAL`, `DELETE` e `EXECUTE` sobem para `ask`, sem depender do revisor. (Rule of Two.)
- [ ] **Revisor como segunda camada** (opcional): um LLM julga autorização e risco com entrada estruturada (`user_messages` confiáveis, `tool_results` não confiáveis); falha ou saída fora do schema vira `ask`, nunca `allow`.
- [ ] **Escopo injetado pelo servidor**: tenant, conversa, destinatário e usuário vêm do contexto autenticado; a tool rejeita esses campos vindos do modelo.
- [ ] **Escrita condicional**: quando um humano tem a última palavra (valor de negócio, estágio do funil, status), a condição viaja com o UPDATE (`WHERE set_by IS NULL`), sem ler e escrever separado.
- [ ] **Transições perigosas bloqueadas**: ações que o cliente final pode induzir pela conversa ("me marca como fechado", "cancela a reunião do fulano") têm limites duros no código.
- [ ] **Argumentos validados** por schema (Zod, class-validator) antes de executar; valores com faixa (dinheiro, datas, quantidades) checados.
- [ ] **Handoff para humano** como tool sempre disponível, e caminho de saída quando o agente não sabe.

## 4. Saída

- [ ] **Saída estruturada por schema** (`response_format: json_schema` ou tool call), com enums e tamanhos validados depois. Recortar JSON por chaves é frágil.
- [ ] **Checagem antes de enviar ao cliente final**: canário secreto no system prompt (aparecer na saída bloqueia o envio e passa para humano), links só de domínios permitidos, limite de tamanho, formato do canal (ex.: sem markdown no WhatsApp). [LLM07]
- [ ] **Escape no destino**: texto do modelo que vira HTML, SQL, shell ou JSON-LD é escapado pelo template ou pela camada de dados. `set:html`, `innerHTML` e afins só com conteúdo escapado. [LLM05]
- [ ] **Sem invenção de fatos de negócio**: preço, prazo e disponibilidade só do prompt, da tool ou da conversa; lacuna vira "não tenho essa informação" ou `[completar]` no rascunho. [LLM09]

## 5. Consumo

- [ ] **Teto de passos** do loop de tools e de tools em paralelo; ao bater o teto, o loop fecha limpo com o que já tem. [LLM10]
- [ ] **Timeout** por chamada ao provedor e por tool.
- [ ] **Teto por ator**: limite de rodadas por contato, conversa ou usuário por janela. Um único ator nunca consegue drenar o orçamento do tenant inteiro.
- [ ] **Orçamento por tenant ou chave** aplicado no caminho da requisição, com degradação (modelo barato, humano) em vez de queda.
- [ ] **Teto de `max_tokens`** por chave ou rota.
- [ ] **Debounce** de mensagens em rajada no mesmo turno.

## 6. Identidade e isolamento

- [ ] **Chave por consumidor** com escopo (modelos e serviços permitidos); lista vazia nega tudo. [ASI03]
- [ ] **Subagentes com menos poder** que o agente pai, sem herdar todas as tools. [ASI07]
- [ ] **Credenciais de tool cifradas em repouso** e nunca devolvidas ao modelo nem ao front.
- [ ] **Execução de código em sandbox** sem rede e sem segredos, com tempo e memória limitados. [ASI05]

## 7. Infra das tools

- [ ] **SSRF**: URLs configuráveis (servidor MCP, webhook, "ler página") resolvem o DNS e recusam IPs privados, loopback, link-local (169.254.x) e redes internas do cluster, inclusive depois de redirect.
- [ ] **Cadastro de MCP só por admin**, com teste de conexão e lista das tools descobertas visível. [ASI04]
- [ ] **Fixar versão** de servidores MCP e pacotes de tools de terceiros; mudança na lista de tools de um MCP já aprovado pede nova aprovação.

## 8. Observabilidade e testes

- [ ] **Trilha de decisões**: cada ação com efeito registra quem pediu, o veredito do portão e o motivo.
- [ ] **PII mascarada** nos logs e na telemetria (CPF, telefone, e-mail, tokens).
- [ ] **Suíte de ataques** versionada (injection direta e indireta, vazamento de prompt, troca de papel, exfiltração por link), rodando no CI e obrigatória ao trocar de modelo. Ferramentas: promptfoo, garak, ou sondas A/B próprias com teste estatístico.
- [ ] **Alerta de anomalia**: pico de custo por ator, taxa de `deny` ou `ask` fora do normal, canário disparado.
