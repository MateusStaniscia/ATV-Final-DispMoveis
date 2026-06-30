import 'dart:convert';
import '../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_model.dart';
import '../services/shared_preferences_service.dart';

class StudentRepositoryImpl implements StudentRepository {
  final SharedPreferencesService _service;
  static const String _studentsKey = 'students_list';

  const StudentRepositoryImpl(this._service);

  @override
  Future<Result<List<Student>>> getStudents() async {
    try {
      final jsonString = await _service.getString(_studentsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return const Success([]);
      }

      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final List<Student> students = jsonList
          .map((item) => StudentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return Success(students);
    } catch (e) {
      return Failure(e, 'Falha ao recuperar a lista de alunos.');
    }
  }

  @override
  Future<Result<Student?>> getStudentById(String id) async {
    try {
      final result = await getStudents();
      return result.when(
        onSuccess: (students) {
          try {
            final student = students.firstWhere((s) => s.id == id);
            return Success(student);
          } catch (_) {
            return const Success(null);
          }
        },
        onFailure: (err, msg) => Failure(err, msg),
      );
    } catch (e) {
      return Failure(e, 'Falha ao buscar aluno pelo identificador.');
    }
  }

  @override
  Future<Result<void>> saveStudent(Student student) async {
    try {
      final result = await getStudents();
      return await result.when(
        onSuccess: (students) async {
          final modelToSave = StudentModel.fromEntity(student);
          final list = List<Student>.from(students);
          
          final index = list.indexWhere((s) => s.id == student.id);
          if (index != -1) {
            // Atualizar
            list[index] = modelToSave;
          } else {
            // Inserir
            list.add(modelToSave);
          }

          // Converter lista inteira para String JSON
          final jsonList = list
              .map((s) => StudentModel.fromEntity(s).toJson())
              .toList();
          final jsonString = jsonEncode(jsonList);

          // Salvar string inteira de volta no SharedPreferences
          final success = await _service.setString(_studentsKey, jsonString);
          if (success) {
            return const Success(null);
          } else {
            return Failure(StateError('Erro ao gravar dados no SharedPreferences.'));
          }
        },
        onFailure: (err, msg) => Failure(err, msg),
      );
    } catch (e) {
      return Failure(e, 'Falha ao salvar aluno.');
    }
  }

  @override
  Future<Result<void>> deleteStudent(String id) async {
    try {
      final result = await getStudents();
      return await result.when(
        onSuccess: (students) async {
          final list = List<Student>.from(students);
          
          final exists = list.any((s) => s.id == id);
          if (!exists) {
            return Failure(ArgumentError('Aluno não encontrado para exclusão.'));
          }

          list.removeWhere((s) => s.id == id);

          // Converter lista de volta para JSON
          final jsonList = list
              .map((s) => StudentModel.fromEntity(s).toJson())
              .toList();
          final jsonString = jsonEncode(jsonList);

          // Salvar string inteira de volta no SharedPreferences
          final success = await _service.setString(_studentsKey, jsonString);
          if (success) {
            return const Success(null);
          } else {
            return Failure(StateError('Erro ao gravar dados no SharedPreferences.'));
          }
        },
        onFailure: (err, msg) => Failure(err, msg),
      );
    } catch (e) {
      return Failure(e, 'Falha ao excluir aluno.');
    }
  }
}
