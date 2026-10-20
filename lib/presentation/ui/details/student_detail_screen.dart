import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/di.dart';
import '../../../core/result/result.dart';
import '../../../domain/entities/popularity_criteria.dart';

class StudentDetailScreen extends SignalStatefulWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});
  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final vm = campusViewModel;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) vm.loadCommand.execute();
    });
  }

  Future<bool> _confirm(String title, String text) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;
  @override
  Widget build(BuildContext context) {
    final p = vm.person(widget.studentId),
        rating = vm.myEvaluation(widget.studentId);
    final busy =
        vm.linkPersonCommand.isExecuting || vm.removePersonCommand.isExecuting;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da pessoa'),
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: vm.loadCommand.isExecuting
          ? const Center(child: CircularProgressIndicator())
          : p == null
          ? Center(
              child: Text(
                vm.error.value.isEmpty
                    ? 'Pessoa não encontrada.'
                    : vm.error.value,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(p.name, style: Theme.of(context).textTheme.headlineMedium),
                Text(p.nickname),
                Text('${p.course} • Turma ${p.year}'),
                Text(
                  'Nascimento: ${p.birthDate.day}/${p.birthDate.month}/${p.birthDate.year}',
                ),
                const SizedBox(height: 20),
                if (p.linkedUid == vm.uid)
                  const Text(
                    'Este é o seu perfil. A autoavaliação está bloqueada.',
                  ),
                if (p.linkedUid == null && vm.data.value.myPersonId == null)
                  OutlinedButton(
                    onPressed: busy
                        ? null
                        : () async {
                            if (!await _confirm(
                              'Vincular meu perfil',
                              'Confirma que esta pessoa é você? O vínculo é permanente no aplicativo e remove uma eventual avaliação sua deste perfil.',
                            )) {
                              return;
                            }
                            await vm.linkPersonCommand.execute(p.id);
                          },
                    child: const Text('Esta pessoa sou eu'),
                  ),
                if (vm.canEvaluate(p))
                  FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () => context.push('/evaluate/${p.id}'),
                    icon: const Icon(Icons.star),
                    label: Text(
                      rating == null
                          ? 'Avaliar pessoa'
                          : 'Alterar minha avaliação',
                    ),
                  ),
                if (vm.canEdit(p))
                  OutlinedButton(
                    onPressed: busy
                        ? null
                        : () => context.push('/form?id=${p.id}'),
                    child: const Text('Editar cadastro'),
                  ),
                if (vm.canRemove(p))
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            if (!await _confirm(
                              'Remover pessoa',
                              'Remover ${p.name} do cadastro e dos rankings? Não será possível restaurar pelo aplicativo. As avaliações serão preservadas no histórico remoto.',
                            )) {
                              return;
                            }
                            final result = await vm.removePersonCommand.execute(
                              p.id,
                            );
                            if (context.mounted && result is Success<void>) {
                              context.go('/home');
                            }
                          },
                    child: const Text('Remover pessoa'),
                  ),
                if (vm.error.value.isNotEmpty)
                  Text(
                    vm.error.value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const Divider(),
                Text(
                  'Minha avaliação',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (rating == null)
                  const Text('Você ainda não avaliou esta pessoa.')
                else ...[
                  Text('Nível Lenda: ${rating.total} / 75 pontos'),
                  Text(
                    'Atualizada em ${rating.date.day}/${rating.date.month}/${rating.date.year}',
                  ),
                  for (final c in PopularityCriteria.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.name),
                      subtitle: Text(c.description),
                      trailing: Text('${rating.scores[c.id]} ★'),
                    ),
                ],
              ],
            ),
    );
  }
}
