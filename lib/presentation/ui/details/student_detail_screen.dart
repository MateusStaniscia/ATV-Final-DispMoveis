import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/di.dart';
import '../../../domain/entities/popularity_criteria.dart';

class StudentDetailScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentDetailViewModel.loadStudentCommand.execute(widget.studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Assina os sinais reativos da ViewModel
    final student = studentDetailViewModel.student.watch(context);
    final isLoading = studentDetailViewModel.loadStudentCommand.isExecutingSignal.watch(context);
    final error = studentDetailViewModel.errorMessage.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ficha do Aluno'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : error.isNotEmpty
              ? Center(
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : student == null
                  ? const Center(child: Text('Aluno não encontrado.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card de Perfil Básico
                          _buildProfileCard(context, student),
                          const SizedBox(height: 20),

                          // Header da Seção de Critérios
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Critérios de Popularidade',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '15 Categorias',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Lista de Notas dos 15 Critérios
                          ...PopularityCriteria.values.map((criteria) {
                            final score = student.scores[criteria.id] ?? 1;
                            return _buildCriteriaRow(context, criteria, score);
                          }),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic student) {
    final theme = Theme.of(context);

    // Formata data de nascimento de forma legível
    final date = student.birthDate as DateTime;
    final formattedBirthDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (student.nickname.isNotEmpty)
                        Text(
                          'Vulgo: "${student.nickname}"',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(),
            ),
            _buildInfoRow('Curso:', student.course),
            const SizedBox(height: 8),
            _buildInfoRow('Turma/Ano:', '${student.year}'),
            const SizedBox(height: 8),
            _buildInfoRow('Nascimento:', formattedBirthDate),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nível Lenda:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${student.legendLevel} pontos',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCriteriaRow(BuildContext context, PopularityCriteria criteria, int score) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  criteria.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                // Exibição de Estrelas
                Row(
                  children: List.generate(5, (starIndex) {
                    final isFilled = starIndex < score;
                    return Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFilled ? Colors.amber : Colors.grey.shade400,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              criteria.description,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
