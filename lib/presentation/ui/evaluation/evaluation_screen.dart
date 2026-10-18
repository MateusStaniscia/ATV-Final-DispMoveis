import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/di.dart';
import '../../../core/result/result.dart';
import '../../../domain/entities/popularity_criteria.dart';
import '../../viewmodels/campus_viewmodel.dart';

class EvaluationScreen extends SignalStatefulWidget {
  final String personId;
  const EvaluationScreen({super.key, required this.personId});
  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final vm = campusViewModel;
  Map<String, int> scores = {
    for (final c in PopularityCriteria.values) c.id: 3,
  };
  bool loading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    await vm.loadCommand.execute();
    if (!mounted) return;
    final old = vm.myEvaluation(widget.personId);
    setState(() {
      if (old != null) scores = Map.from(old.scores);
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = vm.person(widget.personId);
    final saving = vm.evaluateCommand.isExecuting;
    return Scaffold(
      appBar: AppBar(title: const Text('Minha avaliação')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : p == null || !vm.canEvaluate(p)
          ? const Center(
              child: Text('Pessoa indisponível ou autoavaliação bloqueada.'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(p.name, style: Theme.of(context).textTheme.headlineSmall),
                const Text(
                  'Uma avaliação por pessoa. Salvar substitui suas notas anteriores.',
                ),
                Text(
                  'Nível Lenda: ${scores.values.fold(0, (a, b) => a + b)} / 75',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                for (final c in PopularityCriteria.values)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(c.description),
                          Wrap(
                            children: List.generate(
                              5,
                              (i) => IconButton(
                                tooltip: '${c.name}: ${i + 1} estrelas',
                                onPressed: saving
                                    ? null
                                    : () =>
                                          setState(() => scores[c.id] = i + 1),
                                icon: Icon(
                                  i < scores[c.id]!
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (vm.error.value.isNotEmpty)
                  Text(
                    vm.error.value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final result = await vm.evaluateCommand.execute(
                            EvaluationRequest(p, Map.from(scores)),
                          );
                          if (context.mounted && result is Success<void>) {
                            context.go('/detail/${p.id}');
                          }
                        },
                  child: Text(saving ? 'Salvando…' : 'Salvar avaliação'),
                ),
              ],
            ),
    );
  }
}
