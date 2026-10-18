import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/di.dart';
import '../../../core/result/result.dart';
import '../../../domain/entities/campus.dart';

class StudentFormScreen extends SignalStatefulWidget {
  final String? studentId;
  const StudentFormScreen({super.key, this.studentId});
  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final vm = campusViewModel;
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), nickname = TextEditingController();
  String course = 'INFO';
  int year = 2026;
  DateTime birthDate = DateTime(2000);
  bool loading = true;
  Person? original;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    if (widget.studentId != null) {
      await vm.loadCommand.execute();
      if (!mounted) return;
      original = vm.person(widget.studentId!);
      if (original != null) {
        name.text = original!.name;
        nickname.text = original!.nickname;
        course = original!.course;
        year = original!.year;
        birthDate = original!.birthDate;
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    name.dispose();
    nickname.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!form.currentState!.validate()) return;
    final result = await vm.savePersonCommand.execute(
      Person(
        id: original?.id ?? '',
        name: name.text,
        nickname: nickname.text,
        course: course,
        year: year,
        birthDate: birthDate,
        createdBy: original?.createdBy ?? vm.uid,
        linkedUid: original?.linkedUid,
      ),
    );
    if (!mounted) return;
    if (result is Success<void>) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final unavailable =
        widget.studentId != null &&
        (original == null || !vm.canEdit(original!));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.studentId == null ? 'Cadastrar pessoa' : 'Editar pessoa',
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : unavailable
          ? const Center(
              child: Text('Pessoa indisponível ou sem permissão para editar.'),
            )
          : Form(
              key: form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'O cadastro cria um perfil para avaliação, sem criar uma conta de login.',
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: name,
                    maxLength: 120,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (v) =>
                        (v?.trim().isEmpty ?? true) ? 'Informe o nome.' : null,
                  ),
                  TextFormField(
                    controller: nickname,
                    maxLength: 60,
                    decoration: const InputDecoration(
                      labelText: 'Apelido (opcional)',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: course,
                    decoration: const InputDecoration(labelText: 'Curso'),
                    items: ['INFO', 'MEC', 'MAMB', 'PROD', 'TADS', 'TGA']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => course = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: year,
                    decoration: const InputDecoration(labelText: 'Turma / ano'),
                    items: List.generate(29, (i) => 2026 - i)
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text('$y')),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => year = v!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Data de nascimento'),
                    subtitle: Text(
                      '${birthDate.day}/${birthDate.month}/${birthDate.year}',
                    ),
                    trailing: const Icon(Icons.calendar_month),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: birthDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (date != null && mounted) {
                        setState(() => birthDate = date);
                      }
                    },
                  ),
                  if (vm.error.value.isNotEmpty)
                    Text(
                      vm.error.value,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: vm.savePersonCommand.isExecuting ? null : _save,
                    child: Text(
                      vm.savePersonCommand.isExecuting
                          ? 'Salvando…'
                          : 'Salvar pessoa',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
