import 'package:signals_flutter/signals_flutter.dart';
import '../../core/command/command.dart';
import '../../core/result/result.dart';
import '../../domain/facades/theme_facade.dart';

class ThemeViewModel {
  final ThemeFacade _facade;

  // Estado Reativo
  late final Signal<bool> isDarkMode;

  // Comandos
  late final Command<void> toggleThemeCommand;
  late final Command<void> loadThemeCommand;

  ThemeViewModel(this._facade) {
    isDarkMode = signal(false);

    loadThemeCommand = Command<void>(() async {
      final result = await _facade.getTheme();
      return result.when(
        onSuccess: (dark) {
          isDarkMode.value = dark;
          return const Success(null);
        },
        onFailure: (err, msg) => Failure(err, msg),
      );
    });

    toggleThemeCommand = Command<void>(() async {
      final current = isDarkMode.value;
      final result = await _facade.saveTheme(!current);
      return result.when(
        onSuccess: (_) {
          isDarkMode.value = !current;
          return const Success(null);
        },
        onFailure: (err, msg) => Failure(err, msg),
      );
    });
  }
}
