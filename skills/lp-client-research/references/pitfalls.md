# Armadilhas

- **Maps em visualização limitada:** sem user agent de desktop o painel some (sem horário, 1 foto). Se `--user-agent` for ignorado com "daemon already running", feche a sessão e abra de novo.
- **"Ver fotos" não abre a galeria** no modo limitado; o botão "Foto de <nome>" (a foto de capa) abre o visor com "Avançar".
- **Fotos repetidas:** o Maps às vezes entrega a mesma foto duas vezes; compare com `cmp`.
- **Quadros de vídeo:** muitas fotos do Google são capas de vídeo com marca d'água do próprio perfil; servem para galeria, raramente para o topo.
- **API interna do Instagram** (`/api/v1/...`) responde 404 a partir da página; use a grade e as páginas de post.
- **Grade parando:** o Instagram carrega devagar no fim; aumente a espera e retome em vez de reabrir.
- **webp com extensão .jpg:** confira com `file` e renomeie.
- **Mesmo dono em dois negócios:** artes ou reels idênticos em dois perfis indicam o mesmo dono; não repita a mesma foto nas duas LPs sem perguntar.
- **Login do usuário:** o perfil persistente guarda a sessão dele; diga onde fica e ofereça apagar.
