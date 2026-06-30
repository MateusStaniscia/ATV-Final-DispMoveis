import '../../core/result/result.dart';
import '../usecases/get_theme_usecase.dart';
import '../usecases/save_theme_usecase.dart';

class ThemeFacade {
  final GetThemeUseCase _getThemeUseCase;
  final SaveThemeUseCase _saveThemeUseCase;

  const ThemeFacade({
    required GetThemeUseCase getThemeUseCase,
    required SaveThemeUseCase saveThemeUseCase,
  })  : _getThemeUseCase = getThemeUseCase,
        _saveThemeUseCase = saveThemeUseCase;

  Future<Result<bool>> getTheme() {
    return _getThemeUseCase();
  }

  Future<Result<void>> saveTheme(bool isDark) {
    return _saveThemeUseCase(isDark);
  }
}
