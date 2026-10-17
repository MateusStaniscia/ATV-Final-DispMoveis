import 'package:flutter_test/flutter_test.dart';
import 'package:piramid_game/core/routing/session_redirect.dart';

void main() {
  for (final path in [
    '/home',
    '/form',
    '/form?id=aluno',
    '/detail/aluno',
    '/about',
  ]) {
    test('bloqueia acesso anônimo a $path', () {
      expect(
        sessionRedirect(ready: true, signedIn: false, location: path),
        '/login',
      );
    });
    test('aguarda restauração da sessão em $path', () {
      expect(
        sessionRedirect(ready: false, signedIn: false, location: path),
        '/',
      );
    });
    test('permite acesso autenticado a $path', () {
      expect(
        sessionRedirect(ready: true, signedIn: true, location: path),
        null,
      );
    });
  }
  test('login sai da área pública; logout sai da área privada', () {
    expect(
      sessionRedirect(ready: true, signedIn: true, location: '/login'),
      '/home',
    );
    expect(
      sessionRedirect(ready: true, signedIn: false, location: '/home'),
      '/login',
    );
    expect(
      sessionRedirect(ready: true, signedIn: false, location: '/login'),
      null,
    );
  });
}
