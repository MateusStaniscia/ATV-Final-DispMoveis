import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/di.dart';
import '../../../domain/entities/campus.dart';

class HomeScreen extends SignalStatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final vm = campusViewModel;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) vm.loadCommand.execute();
    });
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('PirâmidGame'),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            onPressed: vm.loadCommand.isExecuting
                ? null
                : () => vm.loadCommand.execute(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: () => themeViewModel.toggleThemeCommand.execute(),
            icon: Icon(
              themeViewModel.isDarkMode.value
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          IconButton(
            tooltip: 'Sobre o App',
            onPressed: () => context.push('/about'),
            icon: const Icon(Icons.info_outline),
          ),
          IconButton(
            tooltip: 'Sair da conta',
            onPressed: authViewModel.busy
                ? null
                : () async {
                    await authViewModel.signOut();
                    if (context.mounted && authViewModel.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(authViewModel.error!)),
                      );
                    }
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: const TabBar(
          isScrollable: false,
          labelPadding: EdgeInsets.symmetric(horizontal: 4),
          tabs: [
            Tab(text: 'Pessoas'),
            Tab(text: 'Ranking Pessoal'),
            Tab(text: 'Ranking Global'),
          ],
        ),
      ),
      body: vm.loadCommand.isExecuting
          ? const Center(child: CircularProgressIndicator())
          : vm.error.value.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.error.value),
                    TextButton(
                      onPressed: () => vm.loadCommand.execute(),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          : TabBarView(
              children: [
                _people(),
                _ranking(vm.personalRanking.value, false),
                _ranking(vm.globalRanking.value, true),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/form'),
        icon: const Icon(Icons.person_add),
        label: const Text('Cadastrar pessoa'),
      ),
    ),
  );
  Widget _people() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [
      Text(
        'IFPR • Campus Paranaguá',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        vm.data.value.myPersonId == null
            ? 'Você também está no cadastro? Abra seu perfil e toque em “Esta pessoa sou eu” para impedir autoavaliações.'
            : 'Seu perfil está vinculado à conta. Você pode avaliar as outras pessoas.',
      ),
      const SizedBox(height: 16),
      if (vm.data.value.people.isEmpty)
        const Text(
          'Nenhuma pessoa cadastrada. Comece pelo botão Cadastrar pessoa.',
        ),
      for (final p in vm.data.value.people)
        Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(p.name.substring(0, 1).toUpperCase()),
            ),
            title: Text(p.name),
            subtitle: Text(
              '${p.nickname.isEmpty ? '' : '${p.nickname} • '}${p.course} ${p.year}${p.linkedUid == vm.uid ? ' • Você' : ''}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/detail/${p.id}'),
          ),
        ),
    ],
  );
  Widget _ranking(List<RankingEntry> entries, bool global) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [
      Text(
        global ? 'Na opinião do campus' : 'Na minha opinião',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      Text(
        global
            ? 'Média de todas as avaliações recebidas. Escala de 15 a 75 pontos.'
            : 'Somente as avaliações que você realizou. Escala de 15 a 75 pontos.',
      ),
      const SizedBox(height: 16),
      if (entries.isEmpty)
        const Text('Ainda não há avaliações para este ranking.'),
      for (var i = 0; i < entries.length; i++)
        Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${i + 1}º')),
            title: Text(entries[i].person.name),
            subtitle: Text(
              global
                  ? '${entries[i].count} avaliações • ${entries[i].person.course}'
                  : entries[i].person.course,
            ),
            trailing: Text(
              '${entries[i].average.toStringAsFixed(global ? 1 : 0)} pts',
            ),
            onTap: () => context.push('/detail/${entries[i].person.id}'),
          ),
        ),
    ],
  );
}
