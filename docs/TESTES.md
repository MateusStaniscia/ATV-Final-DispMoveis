# Evidências de validação — 18/10/2026

Revisão baseada na especificação Firebase/Firestore de 25 páginas. O relatório PDF de 17/10 é histórico e descreve a implementação anterior; esta página e CONFORMIDADE.md representam a versão atual.

## Resultados locais

| Verificação | Resultado |
|---|---|
| Análise estática Dart/Flutter | Sem problemas |
| Testes Flutter | 40 aprovados |
| Firebase Emulator Suite | 35 aprovados, nenhuma falha |
| Compilação Android debug | APK gerado em modo emulador |
| Compilação Web debug | Concluída em modo emulador |
| OAuth Google real | Pendente de configuração e acesso ao projeto |
| Firebase remoto real | Pendente; nenhum projeto real configurado nesta sessão |
| Execução em dispositivo físico | Não realizada |

Ambiente: Windows, Flutter 3.38.9, Dart 3.10.8, Java 22, Node 24, Firebase CLI 15.34.0. Android SDK 36, mínimo 24, AGP 8.11.1, Kotlin 2.4.21. O workflow usa Java 21 e Node 22 e também compila Android para detectar incompatibilidades nativas.

## Cobertura dos 40 testes Flutter

- Sessão: espera pela restauração, rotas privadas, logout e renovação de token.
- Resposta atrasada do perfil remoto não reabre uma sessão após logout.
- Login e cadastro validam entradas; mensagem de credenciais inválidas é apresentada.
- Botão Google dispara o Command correspondente (não é teste de OAuth real).
- Perfil sem avaliações automáticas, campos válidos e normalização do nome.
- Avaliação exige os 15 critérios, notas inteiras de 1 a 5, autor/alvo corretos e não permite autoavaliação vinculada.
- Ranking pessoal ignora as avaliações das demais contas.
- Ranking global usa a média, não a soma nem a quantidade; exemplo 60, 70 e 65 resulta em 65.
- Empates por nome/ID; pessoas sem avaliações ou removidas não entram.
- UI em 390 × 844: abas de pessoas e dois rankings, valores de ranking distintos, formulário sem notas, carregamento de avaliação anterior e total reativo às estrelas.
- Perfil próprio esconde a opção de avaliar; URL direta de avaliação própria também é bloqueada.

Os testes adicionais de UI identificaram e corrigiram uma atualização de Signals durante a construção da rota, além da visibilidade das três abas no celular.

## Cobertura dos 35 testes Firebase

Os testes executam nos emuladores oficiais Authentication e Firestore, com regras reais, usando apenas dados fictícios.

- Cadastro, login, senha incorreta, cadastro duplicado, recuperação de senha e logout.
- Token do Authentication autoriza criação de perfil, pessoa e avaliação no Firestore.
- Pessoas compartilhadas e perfis de autenticação privados.
- Uma avaliação por usuário/pessoa, atualizada sem duplicação.
- Autoria, alvo, notas, total e timestamp validados no servidor.
- Acesso anônimo, alteração de avaliação alheia e falsificação de autoria negados.
- Vínculo de identidade atômico; não permite vínculos incompletos, segunda pessoa ou remoção do vínculo.
- Vínculo remove eventual autoavaliação anterior e impede futuras autoavaliações.
- Pessoa vinculada pode editar perfil criado por outra conta.
- Remoção lógica bloqueia reativação e novas avaliações.
- Leitura de avaliações de várias contas para o ranking global.

Mensagens PERMISSION_DENIED nos testes negativos são esperadas e comprovam que as regras rejeitam essas operações.

## Reproduzir

```sh
flutter pub get
flutter analyze
flutter test
npm ci
npm run test:firebase
flutter build web --debug --dart-define=USE_FIREBASE_EMULATORS=true
flutter build apk --debug --dart-define=USE_FIREBASE_EMULATORS=true
```

## Validação ainda necessária antes de apresentar

- [ ] Criar o projeto real e publicar regras/índices.
- [ ] Ativar e-mail/senha e Google; registrar aplicativos e certificados Android.
- [ ] Entrar com ambos os provedores em Android/Web.
- [ ] Cadastrar pessoas fictícias e avaliar a mesma pessoa com duas contas.
- [ ] Conferir documentos e média global no console.
- [ ] Alterar avaliação sem duplicar; verificar ranking pessoal independente.
- [ ] Vincular o próprio perfil e testar bloqueio de autoavaliação.
- [ ] Reabrir o aplicativo e acessar a mesma conta em outro dispositivo.
- [ ] Fazer logout e abrir URLs privadas diretamente.
- [ ] Testar perda de internet e confirmar que erros não aparecem como sucesso.
- [ ] Instalar e executar no Android da apresentação.
- [ ] Confirmar data definitiva com o professor (13/10 ou 20/10/2026).

Testes de regra, testes de widget e compilação não substituem a demonstração de banco remoto nem comprovam consentimento OAuth Google real. O teste anterior Flutter/Chrome que não conectou ao executor não foi contado como aprovado.
