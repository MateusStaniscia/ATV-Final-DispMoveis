import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/core/result/result.dart';
import 'package:piramid_game/domain/entities/student.dart';
import 'package:piramid_game/domain/usecases/calculate_ranking_usecase.dart';

void main() {
  group('Teste do Caso de Uso CalculateRankingUseCase', () {
    const calculateUseCase = CalculateRankingUseCase();

    test('Deve ordenar alunos pelo Nível Lenda em ordem decrescente', () {
      final studentA = Student(
        id: '1',
        name: 'Ana Clara',
        course: 'INFO',
        year: 2024,
        nickname: 'Ana',
        birthDate: DateTime(2000, 1, 1),
        scores: {
          'resenha': 5,
          'presenca_vip': 4,
          'aura': 5,
        }, // Soma = 14 + 12*1 = 26
      );

      final studentB = Student(
        id: '2',
        name: 'João Pedro',
        course: 'MEC',
        year: 2023,
        nickname: 'João',
        birthDate: DateTime(2001, 2, 2),
        scores: {
          'resenha': 5,
          'presenca_vip': 5,
          'aura': 5,
          'modo_parceiro': 5,
        }, // Soma = 20 + 11*1 = 31
      );

      final studentC = Student(
        id: '3',
        name: 'Maria Eduarda',
        course: 'MAMB',
        year: 2025,
        nickname: 'Maria',
        birthDate: DateTime(1999, 12, 12),
        scores: {
          'resenha': 2,
        }, // Soma = 2 + 14*1 = 16
      );

      final studentsList = [studentA, studentB, studentC];
      final result = calculateUseCase(studentsList);

      expect(result, isA<Success<List<Student>>>());
      final sorted = (result as Success<List<Student>>).data;

      expect(sorted.length, 3);
      // Top 1: João Pedro (31 pts)
      expect(sorted[0].id, '2');
      // Top 2: Ana Clara (26 pts)
      expect(sorted[1].id, '1');
      // Top 3: Maria Eduarda (16 pts)
      expect(sorted[2].id, '3');
    });

    test('Deve desempatar em ordem alfabética case-insensitive se as notas forem iguais', () {
      final studentA = Student(
        id: '1',
        name: 'Zeca',
        course: 'TADS',
        year: 2024,
        nickname: '',
        birthDate: DateTime(2000, 1, 1),
        scores: {}, // Todos 1 estrela por padrão = 15 pts
      );

      final studentB = Student(
        id: '2',
        name: 'Abel',
        course: 'MEC',
        year: 2023,
        nickname: '',
        birthDate: DateTime(2001, 2, 2),
        scores: {}, // Todos 1 estrela por padrão = 15 pts
      );

      final studentsList = [studentA, studentB];
      final result = calculateUseCase(studentsList);
      final sorted = (result as Success<List<Student>>).data;

      expect(sorted[0].name, 'Abel');
      expect(sorted[1].name, 'Zeca');
    });
  });
}
