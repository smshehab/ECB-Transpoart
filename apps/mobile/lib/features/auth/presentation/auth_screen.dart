import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../notifications/presentation/notification_providers.dart';
import 'auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({required this.register, super.key});

  final bool register;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repository = ref.read(authRepositoryProvider);
      if (widget.register) {
        await repository.register(name: _name.text, email: _email.text, password: _password.text);
      } else {
        final credential = await repository.signIn(email: _email.text, password: _password.text);
        await credential.user?.getIdToken(true);
      }
      try {
        await ref.read(pushNotificationServiceProvider).initializeForCurrentUser();
      } catch (error) {
        if (mounted) setState(() => _error = 'Signed in, but notification setup failed: $error');
      }
      if (mounted) context.go('/passenger');
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.register ? 'Create user account' : 'Sign in';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  if (widget.register) ...[
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (value) => value == null || value.trim().length < 2 ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) => value == null || value.length < 6 ? 'Use at least 6 characters' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_busy ? 'Please wait…' : title),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => context.go(widget.register ? '/login' : '/register'),
                    child: Text(widget.register ? 'Already have an account? Sign in' : 'Create a user account'),
                  ),
                  if (!widget.register)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              if (_email.text.trim().isEmpty) {
                                setState(() => _error = 'Enter your email first.');
                                return;
                              }
                              try {
                                await ref.read(authRepositoryProvider).sendPasswordReset(_email.text);
                                if (mounted) setState(() => _error = 'Password reset email sent.');
                              } catch (error) {
                                if (mounted) setState(() => _error = error.toString());
                              }
                            },
                      child: const Text('Forgot password?'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
