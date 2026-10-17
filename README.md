# PirâmidGame - Firebase

Aplicativo Flutter para cadastrar alunos do IFPR - Campus Paranaguá, atribuir notas de 1 a 5 em 15 critérios e calcular um ranking. Segunda parte da atividade de Dispositivos Móveis: autenticação e banco remoto NoSQL.

**Situação da entrega:** código integrado ao Firebase e testes locais documentados em [docs/TESTES.md](docs/TESTES.md). Ainda é necessário criar o projeto Firebase do aluno e validar na nuvem e em um dispositivo Android. Emuladores não substituem a demonstração do banco remoto para o professor.

## O que mudou

- Firebase Authentication: cadastro, login por e-mail/senha, recuperação de senha e logout.
- Restauração e renovação de sessão pelo SDK; sem salvar senhas/tokens em preferências próprias.
- Proteção central das rotas de alunos, ranking, formulário, detalhes e sobre.
- Cloud Firestore para criar, consultar, editar e excluir alunos, com dados separados por conta.
- Regras do Firestore bloqueiam usuários anônimos, acesso a outra conta e documentos inválidos.
- Estado dos alunos recriado ao mudar de conta; repositórios ficam vinculados ao UID original.
- Tema claro/escuro mantido em SharedPreferences. Dados antigos do SQLite **não são migrados automaticamente**.
- Botão para atualizar dados e mensagens de erro em português. Consultas exigem servidor e gravações usam transações, sem anunciar gravações offline como concluídas.

## Executar com os emuladores (sem conta Firebase)

Requisitos: Flutter 3.38.9 / Dart 3.10.8 ou versão compatível, Node.js 22+, Java 21+ e Chrome para o teste web. Android usa SDK mínimo 23.

```sh
flutter pub get
npm ci
npm run emulators
```

Em outro terminal, na raiz do projeto:

```sh
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```

Para Android, substitua `chrome` pelo ID obtido em `flutter devices`. O emulador Android usa automaticamente `10.0.2.2`; Web usa `127.0.0.1`. A comunicação HTTP é liberada somente no manifesto Android de debug. Não gere release com emuladores.

Os emuladores usam o projeto fictício `demo-piramid-game`, Authentication na porta 9099, Firestore na 8080 e painel em [localhost:4000](http://localhost:4000). São iniciados em loopback, sem exposição à rede. As contas e os dados são descartáveis e não ficam na nuvem. Links de recuperação de senha aparecem no terminal do emulador; não há envio real de e-mail.

## Conectar ao seu Firebase real

1. No [Firebase Console](https://console.firebase.google.com/), crie um projeto. Google Analytics é opcional e não é utilizado pelo aplicativo.
2. Em **Authentication > Sign-in method**, ative **E-mail/senha**.
3. Em **Firestore Database**, crie o banco **(default)**, edição Standard, escolhendo a região adequada. Inicie com acesso restrito e publique as regras deste repositório.
4. Registre os aplicativos que vai executar:
   - Android: pacote `br.edu.ifpr.pgua.piramid_game`.
   - Web: registre um aplicativo Web. Use a configuração desse aplicativo ao executar no Chrome.
5. Copie `config/firebase.example.json` para `config/firebase.json` e preencha os quatro campos com os valores **da plataforma usada**. O arquivo real está no `.gitignore`.

| Campo no JSON | Configuração Web | Arquivo Android google-services.json |
|---|---|---|
| FIREBASE_PROJECT_ID | projectId | project_info.project_id |
| FIREBASE_API_KEY | apiKey | client correspondente: api_key[0].current_key |
| FIREBASE_APP_ID | appId | client correspondente: client_info.mobilesdk_app_id |
| FIREBASE_MESSAGING_SENDER_ID | messagingSenderId | project_info.project_number (como string) |

O aplicativo inicializa Firebase explicitamente a partir desses valores. Para Authentication e Firestore usados aqui, não é necessário inserir uma conta de serviço nem chave privada. Escolha o bloco Android cujo `package_name` corresponde ao aplicativo. Para usar duas plataformas, mantenha, por exemplo, `config/firebase.web.local.json` e `config/firebase.android.local.json`.

6. Publique as regras com sua conta:

```sh
npx firebase login
npx firebase deploy --only firestore:rules,firestore:indexes --project SEU_PROJECT_ID
```

7. Inicie sem a opção de emuladores:

```sh
flutter run -d chrome --dart-define-from-file=config/firebase.json
# Android: use a configuração Android e o ID exibido por flutter devices
flutter run -d ID_DO_DISPOSITIVO --dart-define-from-file=config/firebase.android.local.json
```

8. Para o build Android de entrega:

```sh
flutter build apk --release --dart-define-from-file=config/firebase.android.local.json
```

O projeto original usa assinatura debug também no build release; serve para instalação didática, mas deve ser substituída por assinatura própria antes de publicar na loja. Se o console solicitar domínios autorizados para uso web/links de autenticação, adicione o domínio usado em Authentication > Settings > Authorized domains.

Sem configuração, o aplicativo apresenta uma tela explicativa em vez de acessar um projeto de exemplo. O Firebase gerencia a persistência de login. O app depende de internet para operações com alunos.

## Modelo NoSQL e arquitetura

```text
users/{uid}/students/{studentId}
  id: string (igual ao ID do documento)
  name: string
  course: INFO | MEC | MAMB | PROD | TADS | TGA
  year: int (1998 a 2026, conforme a atividade original)
  nickname: string
  birthDate: string ISO 8601
  scores: mapa com os 15 critérios, cada valor inteiro entre 1 e 5
```

Não são usadas tabelas, joins ou chaves estrangeiras. `users/{uid}` funciona como caminho de organização; não é necessário criar um documento de perfil. As notas permanecem um mapa nativo do Firestore. O ranking é calculado no aplicativo.

Fluxo preservado: UI → ViewModel/Command → Facade → UseCases → Repository → Firestore. A sessão observa `idTokenChanges()`; o router usa uma política única de redirecionamento. As regras verificam `request.auth.uid == uid` no servidor, independentemente da UI.

## Verificação

```sh
flutter analyze
flutter test
npm run test:firebase
flutter build web
```

A suíte Firebase executa os emuladores oficiais, autenticação real do emulador e testes de regras com usuários distintos. Veja [evidências e roteiro de demonstração](docs/TESTES.md).

GitHub Actions executa análise, testes, build web e testes Firebase a cada push/PR. Não utiliza credenciais de produção.

## Datas informadas na atividade

- Início: **01/09/2026**.
- Possibilidades de entrega informadas: **13/10/2026 ou 20/10/2026**.
- A data definitiva continua **dependente da confirmação do professor**. O repositório não assume uma confirmação.

## Referências

- [Referência Firebase](https://firebase.google.com/docs/reference)
- [Firebase para Flutter](https://firebase.google.com/docs/flutter/setup)
- [Firebase Authentication em Flutter](https://firebase.google.com/docs/auth/flutter/start)
- [Teste de regras com emuladores](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
- [Projeto de controle de sessão indicado pelo professor](https://github.com/RobertoBronco/auth_login_2025)
