# Publicar a atualização

A implementação foi enviada ao GitHub em 18/10/2026, na branch [feat/firebase-auth-firestore](https://github.com/MateusStaniscia/ATV-Final-DispMoveis/tree/feat/firebase-auth-firestore). A branch `main` permanece sem alteração. A abertura automática de pull request retornou HTTP 403 pela integração; o envio da branch pelo Git foi concluído.

A integração com um projeto Firebase real e a conferência da especificação PDF ainda estão pendentes. O PDF recebido em 18/10 estava vazio (0 bytes), portanto não foi possível verificar seus requisitos.

## Cópia alternativa: pacote Git

Use o arquivo ATV-Final-DispMoveis-Firebase.bundle em um terminal normal do seu computador. Ele contém o histórico necessário e a branch com a atualização:

```powershell
git clone -b feat/firebase-auth-firestore .\ATV-Final-DispMoveis-Firebase.bundle ATV-Final-DispMoveis-Firebase
cd ATV-Final-DispMoveis-Firebase
git remote set-url origin https://github.com/MateusStaniscia/ATV-Final-DispMoveis.git
git push -u origin feat/firebase-auth-firestore
```

Depois, abra um pull request da branch feat/firebase-auth-firestore para main no GitHub. O README e docs/TESTES.md explicam o que foi alterado e testado.

## Opção 2: ZIP

Extraia ATV-Final-DispMoveis-Firebase.zip para abrir e executar o projeto. O ZIP contém o código completo e a documentação, sem caches, dependências baixadas ou credenciais.

## Pendências da atividade

- Criar o projeto Firebase, ativar Authentication por e-mail/senha e criar Firestore.
- Preencher a configuração local da plataforma conforme README.md.
- Publicar as regras de segurança e testar o aplicativo com dados fictícios no Firebase real.
- Validar no Android usado na apresentação.
- Confirmar a data definitiva com o professor: possibilidades informadas de 13/10 ou 20/10/2026.

Não há comprovação de funcionamento na nuvem antes desses passos. Foram aprovados 26 testes Flutter e 20 testes nos emuladores oficiais, além da análise estática e compilação Web.
