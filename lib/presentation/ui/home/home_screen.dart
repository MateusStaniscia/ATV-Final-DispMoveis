import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/di.dart';
import '../../../domain/entities/student.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Dispara o carregamento dos alunos assim que a tela inicializa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      studentListViewModel.loadStudentsCommand.execute();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Assina os sinais reativos para reconstruir o widget quando o estado mudar
    final isDark = themeViewModel.isDarkMode.watch(context);
    final listLoading = studentListViewModel.loadStudentsCommand.isExecutingSignal.watch(context);
    final deleteLoading = studentListViewModel.deleteStudentCommand.isExecutingSignal.watch(context);
    final studentsList = studentListViewModel.students.watch(context);
    final rankedList = studentListViewModel.rankedStudents.watch(context);
    final error = studentListViewModel.errorMessage.watch(context);

    final isLoading = listLoading || deleteLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PirâmidGame'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amber : theme.colorScheme.primary,
            ),
            tooltip: 'Alternar Tema',
            onPressed: () => themeViewModel.toggleThemeCommand.execute(),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Sobre o App',
            onPressed: () => context.push('/about'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(
              icon: Icon(Icons.people_alt_outlined),
              text: 'Alunos',
            ),
            Tab(
              icon: Icon(Icons.emoji_events_outlined),
              text: 'Ranking Geral',
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : TabBarView(
              controller: _tabController,
              children: [
                // Aba 1: Lista de Alunos
                _buildStudentsTab(context, studentsList, error),
                // Aba 2: Ranking
                _buildRankingTab(context, rankedList, error),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          studentFormViewModel.reset();
          context.push('/form');
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Cadastrar'),
      ),
    );
  }

  Widget _buildStudentsTab(BuildContext context, List<Student> students, String error) {
    if (error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (students.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum aluno cadastrado.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Toque no botão cadastrar para começar!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return _buildStudentCard(context, student);
      },
    );
  }

  Widget _buildStudentCard(BuildContext context, Student student) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                student.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (student.nickname.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  student.nickname,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              'Curso: ${student.course} | Ano: ${student.year}',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Nível Lenda: ${student.legendLevel} pts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue),
              onPressed: () {
                studentFormViewModel.reset();
                studentFormViewModel.loadStudentForEditCommand.execute(student.id);
                context.push('/form?id=${student.id}');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: () => _confirmDelete(context, student),
            ),
          ],
        ),
        onTap: () {
          context.push('/detail/${student.id}');
        },
      ),
    );
  }

  Widget _buildRankingTab(BuildContext context, List<Student> students, String error) {
    if (error.isNotEmpty) {
      return Center(child: Text(error, style: const TextStyle(color: Colors.red)));
    }

    if (students.isEmpty) {
      return const Center(
        child: Text(
          'Sem dados suficientes para gerar ranking.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final position = index + 1;
        return _buildRankingCard(context, student, position);
      },
    );
  }

  Widget _buildRankingCard(BuildContext context, Student student, int position) {
    final theme = Theme.of(context);
    final isTop3 = position <= 3;
    
    // Cores temáticas para o pódio
    Color medalColor;
    Color? bgPodiumColor;
    IconData? trophyIcon;

    if (position == 1) {
      medalColor = const Color(0xFFFFD700); // Ouro
      bgPodiumColor = const Color(0xFFFFD700).withOpacity(0.08);
      trophyIcon = Icons.workspace_premium_rounded;
    } else if (position == 2) {
      medalColor = const Color(0xFFC0C0C0); // Prata
      bgPodiumColor = const Color(0xFFC0C0C0).withOpacity(0.08);
      trophyIcon = Icons.military_tech_rounded;
    } else if (position == 3) {
      medalColor = const Color(0xFFCD7F32); // Bronze
      bgPodiumColor = const Color(0xFFCD7F32).withOpacity(0.08);
      trophyIcon = Icons.military_tech_rounded;
    } else {
      medalColor = Colors.grey.shade400;
      bgPodiumColor = null;
      trophyIcon = null;
    }

    return Card(
      color: bgPodiumColor ?? theme.cardTheme.color,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: medalColor.withOpacity(0.15),
            shape: BoxShape.circle,
            border: isTop3 ? Border.all(color: medalColor, width: 2) : null,
          ),
          child: Center(
            child: trophyIcon != null
                ? Icon(trophyIcon, color: medalColor, size: 24)
                : Text(
                    '$positionº',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                student.name,
                style: TextStyle(
                  fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            if (student.nickname.isNotEmpty)
              Text(
                '(${student.nickname})',
                style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
          ],
        ),
        subtitle: Text(
          '${student.course} - ${student.year}',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${student.legendLevel} pts',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isTop3 ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              position == 1
                  ? 'Lenda do IFPR'
                  : isTop3
                      ? 'Nível Elite'
                      : 'Popular',
              style: TextStyle(
                fontSize: 10,
                color: isTop3 ? theme.colorScheme.secondary : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () {
          context.push('/detail/${student.id}');
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Deseja realmente remover o registro de "${student.name}" do aplicativo? Esta ação é definitiva.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final result = await studentListViewModel.deleteStudentCommand.execute(student.id);
                result.when(
                  onSuccess: (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${student.name} removido com sucesso.')),
                      );
                    }
                  },
                  onFailure: (err, msg) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao remover aluno: $msg'), backgroundColor: Colors.red),
                      );
                    }
                  },
                );
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
