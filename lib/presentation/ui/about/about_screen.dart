import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sobre o App')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'PirâmidGame IFPR-Pgua',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        const Text(
          'Aplicativo didático do IFPR – Campus Paranaguá para cadastrar pessoas e avaliar critérios descontraídos de convivência, destaque e participação. Use as avaliações com respeito.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Nível Lenda',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Cada avaliação contém 15 critérios, de 1 a 5 estrelas. O Nível Lenda é a soma das notas: de 15 a 75 pontos.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Ranking Pessoal',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Considera exclusivamente as avaliações realizadas pela sua conta. As notas de outras pessoas não mudam sua classificação pessoal.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Ranking Global',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Usa a média dos totais recebidos por cada pessoa e mostra quantas avaliações compõem essa média. Por exemplo, 60, 70 e 65 pontos resultam em 65. Empates seguem a ordem alfabética.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Conta, dados e aparência',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Firebase Authentication permite entrar com e-mail/senha ou Google e restaura sua sessão. O Firestore guarda usuários, pessoas e avaliações, disponíveis em outros dispositivos com a mesma conta. SharedPreferences guarda somente a preferência de tema claro ou escuro.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Pessoa e usuário são registros diferentes. Vincule seu perfil em “Esta pessoa sou eu”; o sistema bloqueia autoavaliações. Cada usuário possui somente uma avaliação ativa por pessoa e pode alterá-la.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Quem cadastrou pode editar e remover pessoas sem vínculo. A própria pessoa vinculada também pode editar seu perfil. A remoção retira o perfil dos rankings e preserva o histórico remoto, sem opção de restaurar pelo aplicativo.',
        ),
      ],
    ),
  );
}
