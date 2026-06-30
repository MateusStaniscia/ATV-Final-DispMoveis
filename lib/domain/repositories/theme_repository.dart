import '../../core/result/result.dart';

abstract class ThemeRepository {
  Future<Result<bool>> isDarkMode();
  Future<Result<void>> setDarkMode(bool isDark);
}
