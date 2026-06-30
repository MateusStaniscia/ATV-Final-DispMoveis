import '../../core/result/result.dart';
import '../repositories/theme_repository.dart';

class GetThemeUseCase {
  final ThemeRepository _repository;

  const GetThemeUseCase(this._repository);

  Future<Result<bool>> call() {
    return _repository.isDarkMode();
  }
}
