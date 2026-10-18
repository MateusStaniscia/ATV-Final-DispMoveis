import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  final AuthViewModel model;
  const LoginScreen({super.key, required this.model});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _hidePassword = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
      ? null
      : 'Informe um e-mail válido.';
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (_register) {
      await widget.model.register(_email.text, _password.text);
    } else {
      await widget.model.signIn(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.model,
    builder: (context, _) {
      final model = widget.model;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AutofillGroup(
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.change_history_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'PirâmidGame',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _register
                              ? 'Crie sua conta'
                              : 'Entre para avaliar pessoas do campus',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _email,
                          enabled: !model.busy,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _password,
                          enabled: !model.busy,
                          obscureText: _hidePassword,
                          autofillHints: [
                            _register
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            suffixIcon: IconButton(
                              tooltip: _hidePassword
                                  ? 'Mostrar senha'
                                  : 'Ocultar senha',
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (value) => (value?.length ?? 0) < 6
                              ? 'Use pelo menos 6 caracteres.'
                              : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        if (_register) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirm,
                            enabled: !model.busy,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar senha',
                            ),
                            validator: (value) => value != _password.text
                                ? 'As senhas não coincidem.'
                                : null,
                          ),
                        ],
                        if (model.error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            model.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                        if (model.message != null) ...[
                          const SizedBox(height: 16),
                          Text(model.message!),
                        ],
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: model.busy ? null : _submit,
                          child: model.busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_register ? 'Criar conta' : 'Entrar'),
                        ),
                        OutlinedButton.icon(
                          onPressed: model.busy
                              ? null
                              : () => model.loginGoogleCommand.execute(),
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Text('Entrar com Google'),
                        ),
                        TextButton(
                          onPressed: model.busy
                              ? null
                              : () {
                                  setState(() {
                                    _register = !_register;
                                    _password.clear();
                                    _confirm.clear();
                                    model.clearMessages();
                                  });
                                },
                          child: Text(
                            _register ? 'Já tenho conta' : 'Criar uma conta',
                          ),
                        ),
                        if (!_register)
                          TextButton(
                            onPressed: model.busy
                                ? null
                                : () {
                                    final error = _validateEmail(_email.text);
                                    if (error != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                      return;
                                    }
                                    model.resetPassword(_email.text);
                                  },
                            child: const Text('Esqueci minha senha'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
