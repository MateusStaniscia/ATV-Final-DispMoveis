import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../core/di.dart';
import '../../../domain/entities/popularity_criteria.dart';

class StudentFormScreen extends StatefulWidget {
  final String? studentId;

  const StudentFormScreen({
    super.key,
    this.studentId,
  });

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.studentId != null) {
        studentFormViewModel.loadStudentForEditCommand.execute(widget.studentId!);
      } else {
        studentFormViewModel.reset();
      }
    });

    // Sincroniza controles de texto com os sinais da ViewModel
    _nameController.addListener(() {
      studentFormViewModel.name.value = _nameController.text;
    });
    _nicknameController.addListener(() {
      studentFormViewModel.nickname.value = _nicknameController.text;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context, DateTime currentDate) async {
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
      studentFormViewModel.birthDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Assina os sinais reativos da ViewModel
    final isEdit = studentFormViewModel.isEditMode.watch(context);
    final isSaving = studentFormViewModel.saveStudentCommand.isExecutingSignal.watch(context);
    final isLoadingData = studentFormViewModel.loadStudentForEditCommand.isExecutingSignal.watch(context);
    
    final currentCourse = studentFormViewModel.course.watch(context);
    final currentYear = studentFormViewModel.year.watch(context);
    final currentBirthDate = studentFormViewModel.birthDate.watch(context);
    final currentScores = studentFormViewModel.scores.watch(context);
    final legendLevelVal = studentFormViewModel.legendLevel.watch(context);
    final error = studentFormViewModel.errorMessage.watch(context);
    final successVal = studentFormViewModel.success.watch(context);

    // Efeito para sincronizar texto ao carregar dados do modo edição
    final vmName = studentFormViewModel.name.value;
    final vmNickname = studentFormViewModel.nickname.value;
    if (isEdit && _nameController.text != vmName) {
      _nameController.text = vmName;
    }
    if (isEdit && _nicknameController.text != vmNickname) {
      _nicknameController.text = vmNickname;
    }

    // Escuta o sucesso para navegar de volta
    if (successVal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        studentFormViewModel.success.value = false;
        studentFormViewModel.reset();
        studentListViewModel.loadStudentsCommand.execute();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Aluno atualizado com sucesso!' : 'Aluno cadastrado com sucesso!')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        studentFormViewModel.errorMessage.value = '';
      });
    }

    final coursesList = ['INFO', 'MEC', 'MAMB', 'PROD', 'TADS', 'TGA'];
    final yearsList = List<int>.generate(2026 - 1998 + 1, (i) => 1998 + i);

    final formattedBirthDate = '${currentBirthDate.day.toString().padLeft(2, '0')}/${currentBirthDate.month.toString().padLeft(2, '0')}/${currentBirthDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Aluno' : 'Cadastrar Aluno'),
      ),
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
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                                        studentFormViewModel.course.value = val;
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
                                        studentFormViewModel.year.value = val;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectBirthDate(context, currentBirthDate),
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Data de Nascimento',
                                  prefixIcon: Icon(Icons.calendar_today_outlined),
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
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...PopularityCriteria.values.map((criteria) {
                      final score = currentScores[criteria.id] ?? 3;
                      return _buildCriteriaFormRow(criteria, score);
                    }),
                    const SizedBox(height: 100), // Espaço inferior para o botão fixo
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          studentFormViewModel.saveStudentCommand.execute();
                        }
                      },
                      child: Text(isEdit ? 'Salvar Alterações' : 'Cadastrar Aluno'),
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                        studentFormViewModel.updateScore(criteria.id, starValue);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isSelected ? Colors.amber : Colors.grey.shade400,
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
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
