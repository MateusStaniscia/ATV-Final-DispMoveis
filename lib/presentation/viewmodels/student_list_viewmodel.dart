import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command/command.dart';
import '../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/facades/student_facade.dart';

class StudentListViewModel {
  final StudentFacade _facade;

  // Estados Reativos
  final students = signal<List<Student>>([]);
  final rankedStudents = signal<List<Student>>([]);
  final errorMessage = signal<String>('');

  // Comandos
  late final Command<List<Student>> loadStudentsCommand;
  late final CommandWithParam<void, String> deleteStudentCommand;

  StudentListViewModel(this._facade) {
    loadStudentsCommand = Command<List<Student>>(() async {
      errorMessage.value = '';
      final result = await _facade.getStudents();
      return result.when(
        onSuccess: (list) {
          students.value = list;
          
          // Calcular o ranking
          final rankingResult = _facade.calculateRanking(list);
          rankingResult.when(
            onSuccess: (sorted) {
              rankedStudents.value = sorted;
            },
            onFailure: (err, msg) {
              errorMessage.value = msg;
            },
          );
          return Success(list);
        },
        onFailure: (err, msg) {
          errorMessage.value = msg;
          return Failure(err, msg);
        },
      );
    });

    deleteStudentCommand = CommandWithParam<void, String>((id) async {
      errorMessage.value = '';
      final result = await _facade.deleteStudent(id);
      return result.when(
        onSuccess: (_) async {
          // Recarrega a lista de estudantes após exclusão bem sucedida
          await loadStudentsCommand.execute();
          return const Success(null);
        },
        onFailure: (err, msg) {
          errorMessage.value = msg;
          return Failure(err, msg);
        },
      );
    });
  }
}
