import 'package:signals_flutter/signals_flutter.dart';
import '../result/result.dart';

typedef CommandAction<T> = Future<Result<T>> Function();
typedef CommandActionWithParam<T, P> = Future<Result<T>> Function(P parameter);

/// Um comando que executa uma ação assíncrona sem parâmetros.
/// Mantém um sinal reativo `isExecuting` para controle de estado na UI.
class Command<T> {
  final CommandAction<T> _action;
  final _isExecuting = signal(false);

  Command(this._action);

  /// Getter reativo para saber se o comando está executando.
  bool get isExecuting => _isExecuting.value;
  ReadonlySignal<bool> get isExecutingSignal => _isExecuting;

  Future<Result<T>> execute() async {
    if (_isExecuting.value) {
      return Failure(StateError('Este comando já está sendo executado.'));
    }
    
    _isExecuting.value = true;
    try {
      return await _action();
    } catch (e) {
      return Failure(e, 'Erro inesperado ao executar o comando.');
    } finally {
      _isExecuting.value = false;
    }
  }
}

/// Um comando que executa uma ação assíncrona recebendo um parâmetro do tipo [P].
/// Mantém um sinal reativo `isExecuting` para controle de estado na UI.
class CommandWithParam<T, P> {
  final CommandActionWithParam<T, P> _action;
  final _isExecuting = signal(false);

  CommandWithParam(this._action);

  /// Getter reativo para saber se o comando está executando.
  bool get isExecuting => _isExecuting.value;
  ReadonlySignal<bool> get isExecutingSignal => _isExecuting;

  Future<Result<T>> execute(P parameter) async {
    if (_isExecuting.value) {
      return Failure(StateError('Este comando já está sendo executado.'));
    }

    _isExecuting.value = true;
    try {
      return await _action(parameter);
    } catch (e) {
      return Failure(e, 'Erro inesperado ao executar o comando.');
    } finally {
      _isExecuting.value = false;
    }
  }
}
