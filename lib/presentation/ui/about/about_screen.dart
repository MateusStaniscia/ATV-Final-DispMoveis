import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primary.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PiramidGame IFPR-Pgua',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Versão Didática 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Texto Sugerido pelo PDF
            _buildSectionCard(
              context: context,
              title: 'Descrição Geral',
              icon: Icons.description_outlined,
              child: Text(
                'O Ranking de Popularidade dos Alunos é um aplicativo desenvolvido em Flutter para fins didáticos. '
                'Ele permite cadastrar alunos do IFPR – Campus Paranaguá e avaliá-los em critérios descontraídos '
                'de convivência, destaque e participação na turma.\n\n'
                'Cada aluno recebe notas de 1 a 5 estrelas em 15 categorias. A soma dessas notas forma o '
                'Nível Lenda, usado para organizar o ranking geral.\n\n'
                'Todos os dados são armazenados localmente no dispositivo utilizando SharedPreferences. '
                'O aplicativo também permite alternar entre tema claro e tema escuro.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
            const SizedBox(height: 16),

            // Objetivos e Contexto
            _buildSectionCard(
              context: context,
              title: 'Objetivo & Contexto',
              icon: Icons.school_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(
                    context,
                    'Objetivo:',
                    'Registrar de forma bem-humorada e didática a convivência, resenha e caos saudável dos alunos.',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                    context,
                    'Contexto:',
                    'Desenvolvido para a disciplina de Dispositivos Móveis do curso de TADS no IFPR - Campus Paranaguá.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Funcionamento do Ranking e Nível Lenda
            _buildSectionCard(
              context: context,
              title: 'Cálculo do Nível Lenda',
              icon: Icons.star_border_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cada aluno é avaliado em 15 critérios de popularidade com notas de 1 a 5 estrelas.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Mínimo', '15 pts'),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                        _buildStat('Máximo', '75 pts'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A ordenação do ranking geral é feita de forma decrescente a partir do total acumulado.',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Persistência e Customização
            _buildSectionCard(
              context: context,
              title: 'Armazenamento & Preferências',
              icon: Icons.settings_brightness_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBulletPoint(
                    context,
                    'Persistência:',
                    'Todos os dados dos alunos cadastrados são salvos localmente em formato JSON string no SharedPreferences. Eles permanecem salvos mesmo após fechar o aplicativo.',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                    context,
                    'Visual:',
                    'Suporte completo para alternância dinâmica entre Tema Claro e Tema Escuro a partir da barra superior da tela inicial.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String boldText, String normalText) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4.0, right: 6.0),
          child: Icon(Icons.circle, size: 6, color: Colors.grey),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$boldText ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: normalText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
