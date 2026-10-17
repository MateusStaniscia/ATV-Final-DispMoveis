# Evidências e roteiro de validação

Data da execução local: **17/10/2026**, fuso America/Sao_Paulo.

## Resultados observados

| Verificação | Resultado |
|---|---|
| Flutter analyze | Aprovado, sem problemas |
| Flutter test | 26 testes aprovados |
| Firebase Emulator Suite | 20 testes aprovados, zero falhas |
| Build Web debug, modo emulador | Compilação concluída |
| Teste adicional Flutter em Chrome | Não concluído: o navegador abriu, mas o executor não recebeu a conexão esperada |
| Firebase real do aluno | Pendente: projeto ainda não criado |
| Build/execução em Android físico | Não executados neste ambiente |

Ambiente: Windows, Flutter 3.38.9, Dart 3.10.8, Node.js 24.14.1, Java 22.0.2, Firebase CLI 15.34.0 e Firestore Emulator 1.22.0. O workflow usa Node 22 e Java 21. Os pacotes estão fixados nos arquivos de lock.

## O que os testes verificam

**Flutter (26 casos):**
- Bloqueio das rotas privadas antes da restauração de sessão e para usuários anônimos.
- Acesso autenticado, saída e redirecionamento do login.
- Restauração da sessão, renovação de token sem recriar os dados e erro no stream.
- Validação de e-mail, confirmação de senha e mensagem de credenciais inválidas na UI.
- Serialização NoSQL, preservação das notas, validação e normalização dos alunos.
- Ranking decrescente e desempate alfabético.

**Firebase (20 casos):**
- Cadastro e login com o SDK conectado ao Authentication Emulator.
- Senha errada, cadastro duplicado, solicitação de recuperação e logout.
- Integração entre token da autenticação e acesso ao Firestore.
- CRUD completo e listagem dos próprios alunos.
- Proibição de acesso sem autenticação.
- Proibição de leitura, listagem, criação, edição e exclusão em outra conta.
- Rejeição de campos extras, campos ausentes, ID divergente, curso/ano inválidos, notas incompletas ou fora de 1 a 5.

Os avisos `PERMISSION_DENIED` nos testes negativos são esperados. Os testes exigem que essas operações falhem. Testes de regras são executados contra o emulador oficial, não apenas contra objetos simulados.

## Reproduzir

```sh
flutter pub get
flutter analyze
flutter test
npm ci
npm run test:firebase
flutter build web --debug --dart-define=USE_FIREBASE_EMULATORS=true
```

O projeto de teste é sempre `demo-piramid-game`. Nenhum teste deve apontar para o projeto real ou para dados pessoais.

## Roteiro obrigatório antes de apresentar ao professor

Execute estes passos no Firebase real depois da configuração descrita no README. Registre capturas do aplicativo e do console; não marque a validação como concluída antes de executá-la.

- [ ] Criar conta A e confirmar o usuário em Authentication.
- [ ] Cadastrar aluno fictício e localizar o documento em `users/UID_A/students`.
- [ ] Editar nome e notas; conferir a alteração no console.
- [ ] Reabrir o app e confirmar sessão restaurada e dados carregados da nuvem.
- [ ] Abrir a mesma conta em outro dispositivo/navegador e confirmar o registro.
- [ ] Fazer logout e tentar abrir diretamente `/home`, `/form`, `/detail/ID` e `/about`.
- [ ] Criar conta B: os alunos da conta A não devem aparecer.
- [ ] Testar senha incorreta e recuperação de senha por e-mail real.
- [ ] Desconectar a internet e confirmar que falhas não são anunciadas como sucesso.
- [ ] Reconectar, atualizar e excluir o aluno; conferir a exclusão no console.
- [ ] Executar no Android utilizado na apresentação.
- [ ] Confirmar com o professor qual data foi definida: 13/10 ou 20/10.

## Limite da evidência

Os testes locais provam o comportamento coberto no ambiente de teste. Eles não comprovam criação, configuração, disponibilidade nem regras publicadas em um projeto Firebase real. Não foi realizada migração dos registros antigos de SQLite.
