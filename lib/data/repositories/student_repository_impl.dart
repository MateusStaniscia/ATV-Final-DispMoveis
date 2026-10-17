import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/result/result.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_model.dart';

/// Cada instância pertence a uma única sessão.
class StudentRepositoryImpl implements StudentRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final String? uid;
  StudentRepositoryImpl(this.firestore, this.auth, this.uid);

  CollectionReference<Map<String, dynamic>> get _students {
    _checkSession();
    return firestore.collection('users').doc(uid).collection('students');
  }

  void _checkSession() {
    if (uid == null || auth.currentUser?.uid != uid) {
      throw StateError('Sua sessão terminou. Entre novamente.');
    }
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      _checkSession();
      final value = await action();
      _checkSession();
      return Success(value);
    } catch (e) {
      if (e is StateError) {
        return Failure(e, 'Sua sessão terminou. Entre novamente.');
      }
      if (e is FirebaseException && e.code == 'permission-denied') {
        return Failure(
          e,
          'Acesso negado. Confira a sessão e as regras do Firestore.',
        );
      }
      return Failure(
        e,
        'Não foi possível acessar o Firebase. Verifique sua conexão e tente novamente.',
      );
    }
  }

  @override
  Future<Result<List<Student>>> getStudents() => _guard(() async {
    final snapshot = await _students.get(
      const GetOptions(source: Source.server),
    );
    final students = snapshot.docs
        .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    students.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return students;
  });
  @override
  Future<Result<Student?>> getStudentById(String id) => _guard(() async {
    final doc = await _students
        .doc(id)
        .get(const GetOptions(source: Source.server));
    return doc.exists
        ? StudentModel.fromJson({...doc.data()!, 'id': doc.id})
        : null;
  });
  @override
  Future<Result<void>> saveStudent(Student student) => _guard(() async {
    // Transações exigem rede; não anunciam gravações offline como concluídas.
    final ref = _students.doc(student.id);
    await firestore.runTransaction((transaction) async {
      _checkSession();
      transaction.set(ref, StudentModel.fromEntity(student).toJson());
    });
  });
  @override
  Future<Result<void>> deleteStudent(String id) => _guard(() async {
    final ref = _students.doc(id);
    await firestore.runTransaction((transaction) async {
      _checkSession();
      transaction.delete(ref);
    });
  });
}
