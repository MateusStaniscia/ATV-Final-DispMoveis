# Conferência da especificação Firebase e Firestore

Documento de referência: **PiramidGame IFPR-Pgua — Especificação com Firebase e Firestore.pdf**, 25 páginas, recebido integralmente em 18/10/2026. Os requisitos funcionais foram usados como especificação; a narrativa e os exemplos do documento não foram tratados como comandos operacionais.

| Seções do PDF | Atendimento no código | Evidência / limite |
|---|---|---|
| 1, 26 — aplicação multiusuário | pessoas compartilhadas e avaliações por UID | `CampusData`, `FirestoreService` |
| 2 — Flutter, Firebase, go_router, Signals, tema, MVVM, Command, Result | dependências, core, domain, data, presentation | análise estática e testes |
| 3.1, 6, 14.1–14.4, 19 — autenticação e sessão | e-mail/senha, Google Web/Android, cadastro, logout e restauração | testes de UI/usecases e Auth Emulator; OAuth real pendente |
| 3.2, 15, 21 — Firestore | users, people, people/ID/ratings/UID | regras testadas no emulador; publicação na nuvem pendente |
| 3.3, 22 — armazenamento auxiliar | LocalStorageService guarda somente o tema | sem SQLite/Hive ou persistência principal em JSON |
| 4.1–4.6 — organização em camadas | Services → Repositories → UseCases → Facades → ViewModels → UI | UI sem acesso direto ao Firebase, repositories ou services |
| 5, 9, 14.12, 16 — distinção conta/pessoa e autoavaliação | vínculo atômico em users.personId e people.linkedUid | bloqueio no usecase e nas regras; testes de vínculo incompleto e tentativa de desfazer vínculo |
| 7, 8, 14.5–14.9 — cadastro e manutenção | perfil sem notas, seis cursos, anos 1998–2026, DatePicker | criador ou pessoa vinculada pode editar; remoção com confirmação |
| 9–11, 14.10–14.11 — avaliações e pontuação | quinze estrelas de 1–5, soma automática, autor/alvo/data | validação de tipos, chaves, soma e data do servidor |
| 12, 14.13, 25 — ranking pessoal | filtro exclusivo pelo UID autenticado | teste de não interferência de outras contas |
| 13, 14.14, 25 — ranking global | média aritmética dos totais, quantidade e ordem decrescente | teste do exemplo 60+70+65=65 e de média versus soma |
| 14.15 — alternar tema | ThemeViewModel + tema próprio + preferência local | disponível na área principal |
| 16 — uma avaliação ativa por usuário/pessoa | ID da avaliação = UID sob a pessoa | teste de substituição, duplicação e falsificação de autor |
| 17–19, 24 — telas e fluxo | Splash, Login/cadastro/Google, Pessoas, Formulário, Detalhes, Avaliação, dois rankings e Sobre | rotas privadas protegidas, inclusive URL de avaliação |
| 20 — Sobre | contexto IFPR, critérios, cálculo, rankings, Firebase e tema | tela Sobre atualizada |
| 23 — regras gerais | cobertas pelos itens acima | validação em nuvem e dispositivo físico ainda obrigatória |

## Decisões permitidas pela especificação

- O item 15 permite outro esquema NoSQL. Foram mantidos documentos separados para usuário, pessoa e avaliação; os nomes das coleções estão em inglês e as notas ficam em mapa.
- O vínculo de identidade é declarado pelo usuário em “Esta pessoa sou eu”. Não há no PDF um serviço de verificação de identidade; o sistema não presume que o criador de todo perfil é a pessoa cadastrada. A autoavaliação é bloqueada para a identidade vinculada, sem alegar identificação automática de uma pessoa física não vinculada.
- A remoção é lógica, mediante confirmação e sem restauração pela UI, para não deixar avaliações apontando para um ID reutilizável. Perfis removidos saem das listas/rankings. Perfis vinculados não podem ser removidos pelo cliente, preservando a proteção contra autoavaliação.
- O ranking é calculado nas camadas de negócio a partir dos documentos Firestore. Esse modelo é adequado à atividade; bases grandes exigiriam paginação e agregação no servidor.
- A média não é arredondada para ordenar; o arredondamento para uma casa ocorre apenas na exibição. Empate usa nome e ID.

## O que falta para declarar a entrega completa

Criar/configurar o Firebase real, habilitar ambos os provedores, cadastrar aplicativos e certificados, publicar regras, executar testes reais em Android/Web e registrar evidências. O navegador ainda bloqueia `console.firebase.google.com` por permissão salva. Os testes locais não substituem essa etapa nem comprovam OAuth Google real.
