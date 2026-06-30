import '../../core/result/result.dart';
import '../entities/student.dart';

class CalculateRankingUseCase {
  const CalculateRankingUseCase();

  Result<List<Student>> call(List<Student> students) {
    try {
      // Cria uma cópia mutável da lista e ordena decrescente pelo Nível Lenda
      final sortedList = List<Student>.from(students)
        ..sort((a, b) {
          final compareLegend = b.legendLevel.compareTo(a.legendLevel);
          if (compareLegend != 0) return compareLegend;
          // Critério de desempate secundário: Ordem alfabética
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      return Success(sortedList);
    } catch (e) {
      return Failure(e, 'Erro ao calcular o ranking geral.');
    }
  }
}
