# Publicar a atualização

A implementação foi enviada ao GitHub em 18/10/2026, na branch [feat/firebase-auth-firestore](https://github.com/MateusStaniscia/ATV-Final-DispMoveis/tree/feat/firebase-auth-firestore). Em 19/10/2026, todas as alterações foram incorporadas à branch `main` por fast-forward e enviadas ao GitHub. A abertura automática de pull request retornou HTTP 403 pela integração; o envio da branch pelo Git foi concluído.

O PDF foi recebido novamente e lido integralmente em 18/10/2026. A adaptação está descrita em CONFORMIDADE.md. O Firebase real está configurado e o teste remoto passou em 18/10/2026.

## Cópia alternativa: pacote Git

Use o arquivo ATV-Final-DispMoveis-Firebase.bundle em um terminal normal do seu computador. Ele contém o histórico necessário e a branch com a atualização:

```powershell
git clone -b feat/firebase-auth-firestore .\ATV-Final-DispMoveis-Firebase.bundle ATV-Final-DispMoveis-Firebase
cd ATV-Final-DispMoveis-Firebase
git remote set-url origin https://github.com/MateusStaniscia/ATV-Final-DispMoveis.git
git push -u origin feat/firebase-auth-firestore
```

O merge da implementação para `main` já foi concluído em 19/10/2026. O README e docs/TESTES.md explicam o que foi alterado e testado.

## Opção 2: ZIP

Extraia ATV-Final-DispMoveis-Firebase.zip para abrir e executar o projeto. O ZIP contém o código completo e a documentação, sem caches, dependências baixadas ou credenciais.

## Estado da publicação

Firebase `piramidgame-ifpr-mstaniscia` configurado. Android/Web, Firestore Standard em São Paulo, Auth e-mail/senha e Google e regras publicados. O app usa a configuração real por padrão. Teste remoto concluído; detalhes em TESTES.md.

Pendências: login Google interativo, execução no Android da apresentação e confirmação da data definitiva pelo professor (13/10 ou 20/10/2026).
