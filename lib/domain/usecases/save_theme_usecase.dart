import '../../core/result/result.dart';
import '../repositories/theme_repository.dart';

class SaveThemeUseCase {
  final ThemeRepository _repository;

  const SaveThemeUseCase(this._repository);

  Future<Result<void>> call(bool isDark) {
    return _repository.setDarkMode(isDark);
  }
}
