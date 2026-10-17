import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/di.dart';
import '../../../domain/entities/popularity_criteria.dart';

class StudentFormScreen extends SignalStatefulWidget {
  final String? studentId;

  const StudentFormScreen({super.key, this.studentId});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _viewModel = studentFormViewModel;
  final _listViewModel = studentListViewModel;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.studentId != null) {
        _viewModel.loadStudentForEditCommand.execute(widget.studentId!);
      } else {
        _viewModel.reset();
      }
    });

    // Sincroniza controles de texto com os sinais da ViewModel
    _nameController.addListener(() {
      _viewModel.name.value = _nameController.text;
    });
    _nicknameController.addListener(() {
      _viewModel.nickname.value = _nicknameController.text;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(
    BuildContext context,
    DateTime currentDate,
  ) async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != currentDate) {
      _viewModel.birthDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Assina os sinais reativos da ViewModel
    final isEdit = _viewModel.isEditMode.value;
    final isSaving = _viewModel.saveStudentCommand.isExecutingSignal.value;
    final isLoadingData =
        _viewModel.loadStudentForEditCommand.isExecutingSignal.value;

    final currentCourse = _viewModel.course.value;
    final currentYear = _viewModel.year.value;
    final currentBirthDate = _viewModel.birthDate.value;
    final currentScores = _viewModel.scores.value;
    final legendLevelVal = _viewModel.legendLevel.value;
    final error = _viewModel.errorMessage.value;
    final successVal = _viewModel.success.value;

    // Efeito para sincronizar texto ao carregar dados do modo edição
    final vmName = _viewModel.name.value;
    final vmNickname = _viewModel.nickname.value;
    if (isEdit && _nameController.text != vmName) {
      _nameController.text = vmName;
    }
    if (isEdit && _nicknameController.text != vmNickname) {
      _nicknameController.text = vmNickname;
    }

    // Escuta o sucesso para navegar de volta
    if (successVal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _viewModel.success.value = false;
        _viewModel.reset();
        _listViewModel.loadStudentsCommand.execute();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Aluno atualizado com sucesso!'
                  : 'Aluno cadastrado com sucesso!',
            ),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      });
    }

    // Escuta erros para mostrar mensagem
    if (error.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        _viewModel.errorMessage.value = '';
      });
    }

    final coursesList = ['INFO', 'MEC', 'MAMB', 'PROD', 'TADS', 'TGA'];
    final yearsList = List<int>.generate(2026 - 1998 + 1, (i) => 1998 + i);

    final formattedBirthDate =
        '${currentBirthDate.day.toString().padLeft(2, '0')}/${currentBirthDate.month.toString().padLeft(2, '0')}/${currentBirthDate.year}';

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Aluno' : 'Cadastrar Aluno')),
      body: isLoadingData
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Seção de Cadastro
                    Text(
                      'Dados Cadastrais',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nome do Aluno *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'O nome é obrigatório';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nicknameController,
                              decoration: const InputDecoration(
                                labelText: 'Apelido (Opcional)',
                                prefixIcon: Icon(Icons.alternate_email),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: currentCourse,
                                    decoration: const InputDecoration(
                                      labelText: 'Curso',
                                    ),
                                    items: coursesList.map((course) {
                                      return DropdownMenuItem<String>(
                                        value: course,
                                        child: Text(course),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        _viewModel.course.value = val;
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    initialValue: currentYear,
                                    decoration: const InputDecoration(
                                      labelText: 'Ano',
                                    ),
                                    items: yearsList.map((year) {
                                      return DropdownMenuItem<int>(
                                        value: year,
                                        child: Text('$year'),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        _viewModel.year.value = val;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () =>
                                  _selectBirthDate(context, currentBirthDate),
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Data de Nascimento',
                                  prefixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                  ),
                                ),
                                child: Text(
                                  formattedBirthDate,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Seção de Critérios
                    Text(
                      'Critérios de Avaliação',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...PopularityCriteria.values.map((criteria) {
                      final score = currentScores[criteria.id] ?? 3;
                      return _buildCriteriaFormRow(criteria, score);
                    }),
                    const SizedBox(
                      height: 100,
                    ), // Espaço inferior para o botão fixo
                  ],
                ),
              ),
            ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nível Lenda:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '$legendLevelVal pontos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: isSaving
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : ElevatedButton(
                      onPressed: isLoadingData || !_viewModel.editLoaded.value
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _viewModel.saveStudentCommand.execute();
                              }
                            },
                      child: Text(
                        isEdit ? 'Salvar Alterações' : 'Cadastrar Aluno',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaFormRow(PopularityCriteria criteria, int score) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    criteria.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Estrelas Interativas
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (starIndex) {
                    final starValue = starIndex + 1;
                    final isSelected = starValue <= score;
                    return GestureDetector(
                      onTap: () {
                        _viewModel.updateScore(criteria.id, starValue);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          isSelected
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: isSelected
                              ? Colors.amber
                              : Colors.grey.shade400,
                          size: 28,
                        ),
                      ),
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
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
