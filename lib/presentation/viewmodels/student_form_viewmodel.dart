import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command/command.dart';
import '../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/popularity_criteria.dart';
import '../../domain/facades/student_facade.dart';

class StudentFormViewModel {
  final StudentFacade _facade;

  // Sinais de Campos do Formulário
  final name = signal<String>('');
  final course = signal<String>('INFO');
  final year = signal<int>(2026);
  final nickname = signal<String>('');
  final birthDate = signal<DateTime>(DateTime.now().subtract(const Duration(days: 365 * 18))); // ~18 anos padrão
  final scores = signal<Map<String, int>>({});

  // Sinais de Controle de UI
  final isEditMode = signal<bool>(false);
  final studentId = signal<String>('');
  final errorMessage = signal<String>('');
  final success = signal<bool>(false);

  // Nível Lenda Computado Dinamicamente
  late final Computed<int> legendLevel;

  // Comandos
  late final Command<void> saveStudentCommand;
  late final CommandWithParam<void, String> loadStudentForEditCommand;

  StudentFormViewModel(this._facade) {
    _resetScores();

    // Calcula dinamicamente o Nível Lenda conforme as notas são alteradas
    legendLevel = computed(() {
      int total = 0;
      final currentScores = scores.value;
      for (final criteria in PopularityCriteria.values) {
        total += (currentScores[criteria.id] ?? 1);
      }
      return total;
    });

    saveStudentCommand = Command<void>(() async {
      errorMessage.value = '';
      success.value = false;

      final id = isEditMode.value ? studentId.value : DateTime.now().microsecondsSinceEpoch.toString();
      
      final student = Student(
        id: id,
        name: name.value,
        course: course.value,
        year: year.value,
        nickname: nickname.value,
        birthDate: birthDate.value,
        scores: Map<String, int>.from(scores.value),
      );

      final result = await _facade.saveStudent(student);
      return result.when(
        onSuccess: (_) {
          success.value = true;
          return const Success(null);
        },
        onFailure: (err, msg) {
          errorMessage.value = msg;
          return Failure(err, msg);
        },
      );
    });

    loadStudentForEditCommand = CommandWithParam<void, String>((id) async {
      errorMessage.value = '';
      isEditMode.value = true;
      studentId.value = id;

      final result = await _facade.getStudentById(id);
      return result.when(
        onSuccess: (student) {
          if (student != null) {
            name.value = student.name;
            course.value = student.course;
            year.value = student.year;
            nickname.value = student.nickname;
            birthDate.value = student.birthDate;
            scores.value = Map<String, int>.from(student.scores);
            return const Success(null);
          } else {
            errorMessage.value = 'Aluno não encontrado.';
            return Failure(StateError('Aluno não encontrado.'));
          }
        },
        onFailure: (err, msg) {
          errorMessage.value = msg;
          return Failure(err, msg);
        },
      );
    });
  }

  /// Atualiza o score de um critério específico
  void updateScore(String criteriaId, int value) {
    final current = Map<String, int>.from(scores.value);
    current[criteriaId] = value.clamp(1, 5);
    scores.value = current;
  }

  /// Limpa/reseta o formulário
  void reset() {
    name.value = '';
    course.value = 'INFO';
    year.value = 2026;
    nickname.value = '';
    birthDate.value = DateTime.now().subtract(const Duration(days: 365 * 18));
    _resetScores();
    isEditMode.value = false;
    studentId.value = '';
    errorMessage.value = '';
    success.value = false;
  }

  void _resetScores() {
    final defaultScores = <String, int>{};
    for (final criteria in PopularityCriteria.values) {
      defaultScores[criteria.id] = 3; // Inicializa com nota média neutra (3 estrelas)
    }
    scores.value = defaultScores;
  }
}
