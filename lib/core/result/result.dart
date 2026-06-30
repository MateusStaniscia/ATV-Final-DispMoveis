sealed class Result<T> {
  const Result();

  /// Executa uma função com base no estado do resultado (sucesso ou falha).
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Object exception, String message) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else if (this is Failure<T>) {
      final failure = this as Failure<T>;
      return onFailure(failure.exception, failure.message);
    }
    throw StateError('Subclasse desconhecida de Result: $runtimeType');
  }

  /// Retorna o dado se for sucesso, ou lança a exceção se for falha.
  T getOrThrow() {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else if (this is Failure<T>) {
      throw (this as Failure<T>).exception;
    }
    throw StateError('Subclasse desconhecida de Result: $runtimeType');
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final Object exception;
  final String message;
  const Failure(this.exception, [this.message = '']);
}
