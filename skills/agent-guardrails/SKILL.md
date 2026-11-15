---
name: agent-guardrails
description: Guardrails e proteções para agentes de IA e apps com LLM. Use ao projetar, revisar ou auditar um agente, um bot de atendimento, um loop de tools, um servidor MCP, RAG ou um gateway de LLM; quando aparecer prompt injection, conteúdo não confiável, aprovação de ações, custo descontrolado ou vazamento de prompt.
---

# Agent guardrails

Premissa: prompt injection não tem solução. Filtros e avisos no prompt reduzem a taxa de ataque, mas um atacante adaptativo fura todos ("The Attacker Moves Second", 2025). A proteção que segura é **arquitetura em código**: o que o agente consegue fazer, com quais dados, e quem aprova. Prompt é a última camada, nunca a única.

## Passos

### 1. Mapear a trifecta

Para cada sessão do agente, marque quais das três propriedades ela tem (Agents Rule of Two, Meta):

- **[A] Entrada não confiável**: qualquer texto que não foi escrito pelo usuário dono da sessão. Mensagem de cliente final, página web, resultado de MCP de terceiro, documento do RAG subido por outra pessoa, card, convite de agenda, e-mail, transcrição de áudio, imagem.
- **[B] Dados sensíveis**: dados de outros usuários ou tenants, credenciais, PII, dados financeiros, sistemas internos.
- **[C] Agir para fora ou mudar estado**: enviar mensagem, chamar API externa, apagar, executar código, gravar em dado compartilhado, abrir URL controlada pelo modelo (exfiltração por querystring conta).

Pronto quando: cada sessão (não cada produto) tem as letras marcadas, e cada tool está classificada por **efeito**: `READ`, `WRITE`, `DELETE`, `EXTERNAL`, `EXECUTE`.

Sessão com A+B+C é a **trifecta letal**. Ela exige um portão determinístico (passo 2, camada Ações) ou a remoção de uma das letras. Exemplos de remoção: o agente que lê a web não tem as tools de envio; o bot do cliente final só enxerga a própria conversa.

### 2. Aplicar o checklist por camada

Abra [references/checklist.md](references/checklist.md) e passe por **todas** as camadas: Entrada, Contexto, Ações, Saída, Consumo, Identidade e isolamento, Infra das tools, Observabilidade e testes. Para cada controle, registre um dos três: `tem` (com arquivo:linha), `falta` ou `não se aplica` (com o motivo).

Pronto quando: todo controle das oito camadas tem um desses três estados. Um controle sem estado é revisão incompleta.

### 3. Priorizar e reportar

Ordene o que `falta` por risco real:

1. **Crítico**: trifecta letal sem portão determinístico; o modelo escolhe tenant, conversa ou destinatário; segredo ou dado de outro tenant alcançável pelo contexto.
2. **Alto**: consumo sem teto por ator (um contato ou chave drena o orçamento de todos); conteúdo não confiável entrando sem marcação; resposta enviada ao cliente final sem nenhuma checagem.
3. **Médio**: SSRF em URL configurável de tool ou MCP; saída estruturada recortada à mão em vez de schema; falta de suíte de ataques.
4. **Baixo**: endurecimentos de defesa em profundidade.

Para cada item, entregue: o problema em uma frase, o cenário concreto de ataque ou falha, e a correção mínima, preferindo uma regra em código a uma frase no prompt.

Pronto quando: cada `falta` tem severidade, cenário e correção, e o relatório começa pelos críticos.

## Princípios

- **Determinístico vence probabilístico.** Um revisor LLM é bom como segunda camada, mas a regra que importa ("depois de ler conteúdo externo, ação `EXTERNAL` pede confirmação") mora em código.
- **Contaminação por sessão.** Assim que um resultado não confiável entra no turno, a sessão fica *tainted* até o fim. A permissão das ações seguintes cai de nível, independente do que o modelo diga.
- **Autorização vem só do usuário.** Mensagens do usuário autorizam; resultados de tool são evidência e nunca ampliam o que foi autorizado.
- **O modelo nunca escolhe o escopo.** Tenant, usuário, conversa e destinatário vêm do contexto autenticado, injetados pelo servidor, fora dos argumentos da tool.
- **Mínima agência.** Capacidade que o agente não precisa é superfície de ataque. Cada tool com o menor escopo possível.
- **Degradar em vez de cair.** Orçamento estourado troca o modelo por um mais barato ou passa para um humano. Silêncio total é falha de produto.
- **Medir, não supor.** Toda defesa de prompt é medida por modelo. Trocar de modelo exige rodar a suíte de ataques de novo.

Fontes e leitura: [references/sources.md](references/sources.md).
