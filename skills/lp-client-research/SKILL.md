---
name: lp-client-research
description: Coleta material real de um cliente (fotos, endereço, horário, avaliações, serviços, cores) no perfil do Google e no Instagram e deixa tudo pronto para preencher uma landing page. Use quando o cliente não mandou fotos ou textos, quando pedirem "procure imagens do cliente", "pegue as fotos do Instagram/Google", ou para preparar o formulário de uma LP.
---

# LP client research

Regra que não se negocia: **só material publicado pelo próprio cliente** (ou por quem ele marcou) nos perfis dele. Nunca gerar, editar ou "melhorar" imagem, nunca usar banco de imagens, nunca inventar fato (preço, prazo, prêmio, número de clientes). O que não aparece nos perfis vira pergunta para o cliente.

## Entradas

Nome do negócio, link do perfil do Google (maps.app.goo.gl/...) e @ do Instagram. Opcional: WhatsApp, link do Tintim, ID do GTM, endereço. Se faltar o link do Google, busque "<nome> <cidade>" no Maps.

## Passos

Crie `~/projects/<slug>_lp/` com `assets/google_profile/`, `assets/instagram/`, `form/`. Use `scripts/` desta skill; todos recebem caminhos por argumento.

### 1. Perfil do Google

O agent-browser padrão cai na "visualização limitada" do Maps (1 foto, sem horário). Abra com `scripts/browser.sh` (user agent de Chrome desktop + `--disable-blink-features=AutomationControlled`).

- Leia do painel: nome exato, categoria, nota e nº de avaliações, endereço, telefone, atributos ("empresa de empreendedoras" etc.).
- Horário: `aria-label` dos itens com "feira|sábado|domingo".
- Fotos: clique em "Foto de <nome>" e avance com "Avançar" coletando URLs `lh3.googleusercontent.com/(grass-cs|gps-cs)/…`; troque o sufixo por `=w4096-h4096-k-no` para baixar em tamanho cheio. Sem login o visor mostra ~10 fotos.
- Fotos de avaliação (botões "Foto N na avaliação de X") são de clientes: registre o autor.
- Avaliações: aba "Avaliações", textos em `[data-review-id]`. Guarde nome + texto completo; trecho cortado só serve cortado no fim de uma frase.

Pronto quando: `assets/google_profile/` tem as fotos com nomes descritivos (`owner_storefront.jpg`, `review_<autor>_<assunto>.jpg`) e as notas de dados estão no README.

### 2. Instagram

Sem login: só os 12 posts mais recentes; destaques e posts antigos pedem login. Para o perfil inteiro, peça ao usuário para entrar na conta dele numa janela `--headed` com perfil persistente (`scripts/browser.sh --headed --profile ~/.config/agent-browser/profiles/instagram`). A senha é digitada por ele no navegador, nunca no chat.

1. `scripts/ig-grid.sh <usuario> <saida.json>`: rola a grade e junta todos os posts (código, tipo, miniatura, alt). Se parar antes do total do perfil, rode de novo com `resume`.
2. `scripts/contact-sheet.py <saida.json> <pasta>`: baixa as miniaturas e monta folhas de contato. Olhe as folhas e escolha; reels só dão capa de 361×640, então prefira posts (`p`).
3. `scripts/ig-post.sh <pasta> <codigo>...`: abre cada post e baixa a imagem cheia (ignora URLs `s640x640`, que são a grade de "mais posts"), percorrendo carrosséis pelo botão "Avançar". Pausas de alguns segundos entre posts para não forçar a conta do usuário.

O `alt` diz o autor ("Photo by X" / "Photo shared by X"). Post de outra conta é **colab**: profissional ou influencer; anote, porque precisa do OK dela.

Leia também as **artes** do perfil (listas de serviços, "sem horário marcado", endereço "antigo", agenda online): são a melhor fonte de fatos.

Pronto quando: `assets/instagram/full/` tem as escolhidas em resolução cheia e `all_posts.json` guarda a origem de cada uma.

### 3. Fotos por seção do formulário

Monte `form/photos/<NN_secao>/<slot>.webp` com `scripts/prepare-photos.py <raiz> <plano.py>`: reduz para no máximo 2400 px e 1,45 MB (limite do formulário), em webp, e põe as opções em `alternatives/<slot>_alt_<post>.webp`, também otimizadas.

Critérios: topo com ≥1920 px no lado maior e assunto principal do negócio; galeria com 4 serviços diferentes; "Sobre" com o espaço, a fachada ou a equipe; "Você merece" com foto emocional (noiva, resultado). Gere `form/photos/README.md` com seção, arquivo, o que mostra e **quem publicou** (link do post). O logo quase nunca existe limpo nos perfis: peça o PNG.

### 4. Respostas do formulário

Escreva `form/client.json` seguindo o schema do projeto da LP e valide com ele antes de tudo. Depois gere `form/form_answers.md` na ordem das telas, com cada valor num bloco ```text para copiar, e no topo uma lista "Confirmar antes de enviar" com tudo que é dedução (horário estranho, endereço divergente entre Google e artes, cores escolhidas, direitos de imagem, depoimentos cortados).

Textos: só fatos vistos. Bio do Instagram vira título/apoio; destaques e artes viram serviços; avaliações com nome viram depoimentos (seção fica desligada se não houver o mínimo pedido); frase de urgência sem escassez falsa. Cores tiradas do letreiro, logo ou artes. O ID do GTM vai no campo próprio; nunca cole o script.

### 5. Fechar

- Feche o navegador (`agent-browser close --all`) e qualquer servidor local: RAM curta derruba o Chrome do usuário.
- README do cliente com dados, avaliações, tabela de fotos e o que falta pedir.
- Avise o que não deu para ver (fotos do Google além das ~10, destaques sem login) e as fotos que precisam de autorização.

Detalhes e armadilhas em [references/pitfalls.md](references/pitfalls.md).
