import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command/command.dart';
import '../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/facades/student_facade.dart';

class StudentDetailViewModel {
  final StudentFacade _facade;

  // Estado Reativo
  final student = signal<Student?>(null);
  final errorMessage = signal<String>('');

  // Comandos
  late final CommandWithParam<void, String> loadStudentCommand;

  StudentDetailViewModel(this._facade) {
    loadStudentCommand = CommandWithParam<void, String>((id) async {
      errorMessage.value = '';
      student.value = null;

      final result = await _facade.getStudentById(id);
      return result.when(
        onSuccess: (foundStudent) {
          if (foundStudent != null) {
            student.value = foundStudent;
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
}
