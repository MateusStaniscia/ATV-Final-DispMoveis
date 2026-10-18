# PirâmidGame IFPR-Pgua — Firebase

Aplicativo Flutter de Dispositivos Móveis, atualizado conforme a especificação de 25 páginas enviada em 18/10/2026. Pessoas são compartilhadas entre contas; avaliações pertencem ao avaliador. Cada pessoa tem ranking global por média e cada usuário tem seu ranking pessoal.

**Situação:** implementação atualizada, 40 testes Flutter e 35 testes Firebase aprovados, com compilações Android e Web concluídas. A criação do Firebase real, a configuração OAuth Google e a demonstração na nuvem continuam pendentes de acesso ao console. Não confunda o modo emulador com o banco remoto exigido para a entrega. Consulte [CONFORMIDADE](docs/CONFORMIDADE.md) e [TESTES](docs/TESTES.md).

## Funcionalidades

- E-mail/senha: criar conta, entrar, recuperar senha e sair.
- Google: popup na Web e Google Sign-In nativo no Android, integrado ao Firebase Authentication.
- Splash durante a inicialização, restauração de sessão pelo SDK e proteção central com go_router.
- Pessoas: nome, apelido, curso selecionável, turma de 1998 a 2026 e DatePicker.
- Avaliação separada do cadastro, com 15 critérios de 1 a 5 estrelas e total automático de 15 a 75.
- Uma avaliação por usuário/pessoa, editável sem criar duplicatas.
- Vínculo “Esta pessoa sou eu”, protegido no Firestore. A própria pessoa vinculada não pode ser avaliada pelo usuário.
- Ranking Pessoal: apenas minhas notas. Ranking Global: média de todos os totais e quantidade de avaliações.
- Tema claro/escuro em SharedPreferences, sem armazenar pessoas, avaliações ou senhas localmente.

## Arquitetura

`UI → ViewModel/Command/Signals → Facade → UseCases/Result → Repository → Services → Firebase`

`domain` não importa Firebase nem Flutter. `AuthService`, `ProfileService`, `FirestoreService` e `LocalStorageService` concentram os acessos externos. Repositórios convertem dados/erros para entidades e Result. O ChangeNotifier da autenticação serve apenas de ponte para o GoRouter; o estado é mantido em Signals.

## Modelo NoSQL

```text
users/{uid}
  name, email, photo, provider, personId (null ou perfil vinculado)
people/{personId}
  name, nickname, course, year, birthDate (Timestamp)
  createdBy, linkedUid (null ou UID), active
people/{personId}/ratings/{evaluatorUid}
  evaluatorUid, personId, scores (mapa com 15 inteiros)
  total (soma validada nas regras), date (timestamp do servidor)
```

O ID do documento de avaliação é o UID do avaliador: uma conta não consegue criar uma segunda avaliação para a mesma pessoa. Pessoas e avaliações são legíveis por usuários autenticados para compor o ranking global; o perfil de autenticação em `users` é privado. Cada avaliação só pode ser gravada/excluída por seu autor.

O vínculo é autodeclarado, único e permanente no aplicativo. A gravação atômica vincula conta e pessoa e remove eventual avaliação anterior daquela conta sobre si mesma. As regras impedem desfazer o vínculo ou continuar se avaliando. Isso não verifica identidade civil nem detecta cadastros duplicados de uma mesma pessoa física.

Quem cadastrou ou quem está vinculado pode editar o perfil. Só o criador pode remover pessoa sem vínculo. A remoção é lógica e definitiva na interface: `active=false`, preservando referências e avaliações históricas, mas excluindo a pessoa dos dois rankings e impedindo novas avaliações. O usuário confirma a operação antes de executá-la.

Os dados da versão anterior em SQLite ou em `users/{uid}/students` não são migrados automaticamente. A nova estrutura separa perfis e avaliações, evitando atribuir notas antigas ao usuário errado.

## Rodar e testar sem Firebase real

Flutter 3.38.9 / Dart 3.10.8, Node 22+, Java 21+; Android SDK 36 e mínimo 24. Kotlin 2.4.21 acompanha o Firebase Android atual.

```sh
flutter pub get
npm ci
npm run emulators
# Em outro terminal:
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```

Projeto descartável `demo-piramid-game`, Auth 9099, Firestore 8080, painel 4000. As portas escutam apenas loopback. O emulador Android usa 10.0.2.2; Web usa 127.0.0.1. O aplicativo identifica esse modo com a faixa EMULADOR e o bloqueia em release. O Google nativo precisa da configuração OAuth real; emuladores não comprovam o login Google real.

```sh
flutter analyze
flutter test
npm run test:firebase
flutter build web --debug --dart-define=USE_FIREBASE_EMULATORS=true
flutter build apk --debug --dart-define=USE_FIREBASE_EMULATORS=true
```

## Firebase real — configuração necessária

1. Criar o projeto e o Firestore `(default)`, edição Standard, com acesso restrito.
2. Ativar Authentication por **E-mail/senha** e **Google**, definindo o e-mail de suporte solicitado pelo console.
3. Registrar Web e Android. Pacote Android: `br.edu.ifpr.pgua.piramid_game`.
4. Registrar SHA-1 e SHA-256 da assinatura usada no Android (debug durante desenvolvimento; assinatura da entrega quando diferente).
5. Copiar `config/firebase.example.json` para arquivos locais por plataforma, por exemplo `config/firebase.web.local.json` e `config/firebase.android.local.json`.

| Campo | Web | Android (`google-services.json`) |
|---|---|---|
| FIREBASE_PROJECT_ID | projectId | project_info.project_id |
| FIREBASE_API_KEY | apiKey | client correspondente: api_key[0].current_key |
| FIREBASE_APP_ID | appId | client_info.mobilesdk_app_id |
| FIREBASE_MESSAGING_SENDER_ID | messagingSenderId | project_number como string |
| GOOGLE_WEB_CLIENT_ID | não utilizado no popup | OAuth client_id do tipo Web (client_type 3), mesmo projeto |

O Android inicializa Firebase explicitamente; o Google Sign-In recebe `serverClientId` pelo último campo. Ele precisa do **ID OAuth Web**, mesmo quando o app executa no Android. Não use o client_id Android nesse campo. Nunca inclua chaves privadas ou contas de serviço no aplicativo.

6. Publicar regras e índices com a conta autorizada:

```sh
npx firebase login
npx firebase deploy --only firestore:rules,firestore:indexes --project SEU_PROJECT_ID
flutter run -d chrome --dart-define-from-file=config/firebase.web.local.json
flutter build apk --release --dart-define-from-file=config/firebase.android.local.json
```

7. Conferir domínios autorizados em Authentication, incluindo o domínio Web utilizado. Validar login Google, persistência após reiniciar, duas contas e outro dispositivo antes da entrega.

O projeto usa assinatura debug também no build release para instalação didática. Uma publicação na loja exige assinatura própria. Sem configuração real, o app exibe instruções de configuração. As operações de dados exigem conexão com o servidor; não anunciam gravações offline como sucesso.

Datas informadas: 13/10 ou 20/10/2026; a data definitiva depende da confirmação do professor.
