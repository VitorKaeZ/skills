# skills

Minhas skills para agentes de código (Claude Code, Codex e outros que leem `SKILL.md`).

## Skills

| Skill | O que faz |
|---|---|
| [agent-guardrails](skills/agent-guardrails/SKILL.md) | Revisa ou projeta as proteções de um agente de IA: trifecta letal (Rule of Two), checklist em 8 camadas e relatório por severidade. |

## Instalar

```bash
git clone git@github.com:VitorKaeZ/skills.git
cd skills
./scripts/link-skills.sh
```

O script cria um symlink de cada pasta de `skills/` em `~/.claude/skills` e `~/.agents/skills`. Com isso, um `git pull` já atualiza as skills instaladas. Rode o script de novo depois de adicionar, renomear ou remover uma skill.

## Adicionar uma skill

1. Crie `skills/<nome-em-ingles>/SKILL.md` com o frontmatter `name` e `description`.
2. Material que só alguns casos usam vai em `skills/<nome>/references/`, apontado a partir do `SKILL.md`.
3. Adicione uma linha na tabela acima.
4. Rode `./scripts/link-skills.sh`.

O repositório é público: nada de nomes de clientes, IPs, domínios internos ou segredos dentro das skills.
