import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/ui/components/atoms/load_progress_indicator.dart';

import '../atoms/mala_logo.dart';
import 'labeled_text_box.dart';

class LoginFields extends StatefulWidget {
  LoginFields({
    super.key,
    required this.onLogin,
  });

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final FutureOr<void> Function(String email, String password) onLogin;

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  bool _enteredEmail = false;
  bool get enteredEmail => _enteredEmail;
  set enteredEmail(bool value) {
    if (value == _enteredEmail) return;
    setState(() {
      if (!value) {
        widget.passwordController.clear();
        _enteredPassword = false;
      }
      _enteredEmail = value;
    });
  }

  bool _enteredPassword = false;
  bool get enteredPassword => _enteredPassword;
  set enteredPassword(bool value) {
    setState(() {
      _enteredPassword = value;
    });
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const MalaLogo(),
            const SizedBox(height: 20),
            _email(),
            const SizedBox(height: 10),
            _password(),
            const SizedBox(height: 20),
            AnimatedCrossFade(
              crossFadeState: enteredPassword ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
              firstChild: _loginButton(),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  LabeledTextBox _email() {
    return LabeledTextBox(
      label: 'Email',
      controller: widget.emailController,
      onChange: (value) {
        enteredEmail = value.contains('@');
      },
    );
  }

  AnimatedCrossFade _password() {
    return AnimatedCrossFade(
      crossFadeState: enteredEmail ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: const Duration(milliseconds: 400),
      firstChild: LabeledTextBox(
        label: 'Senha',
        controller: widget.passwordController,
        isPassword: true,
        onChange: (value) {
          enteredPassword = value.isNotEmpty;
        },
      ),
      secondChild: const SizedBox.shrink(),
    );
  }

  Widget _loginButton() {
    content() {
      if (isLoading) {
        return const LoadProgressIndicator();
      }
      return Center(
        child: FilledButton(
          onPressed: _login,
          child: const Text('Logar'),
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: content(),
    );
  }

  void _login() async {
    var email = widget.emailController.text;
    var password = widget.passwordController.text;
    isLoading = true;
    try {
      await widget.onLogin(email, password);
    } finally {
      isLoading = false;
    }
  }
}
