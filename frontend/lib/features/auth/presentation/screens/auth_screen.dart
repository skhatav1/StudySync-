import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/ui_helpers.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 760;
                  final form = GlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_isLogin ? 'Sign in' : 'Create account',
                              style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                              'Use your Firebase account to sync plans, groups, resources, and AI history.',
                              style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                                labelText: 'Email'),
                            validator: (value) =>
                                value != null && value.contains('@')
                                    ? null
                                    : 'Enter a valid email',
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                                labelText: 'Password'),
                            validator: (value) =>
                                value != null && value.length >= 6
                                    ? null
                                    : 'Minimum 6 characters',
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: auth.isSubmitting
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    if (_isLogin) {
                                      await context.read<AuthProvider>().signIn(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          );
                                    } else {
                                      await context.read<AuthProvider>().signUp(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          );
                                    }
                                  },
                            icon: auth.isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : Icon(_isLogin
                                    ? Icons.login_rounded
                                    : Icons.person_add_alt_rounded),
                            label: Text(_isLogin ? 'Sign in' : 'Sign up'),
                          ),
                          if (auth.error != null) ...[
                            const SizedBox(height: 12),
                            ErrorText(auth.error!),
                          ],
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                setState(() => _isLogin = !_isLogin),
                            child: Text(_isLogin
                                ? 'Need an account? Sign up'
                                : 'Already have an account? Sign in'),
                          ),
                        ],
                      ),
                    ),
                  );
                  final story = GlassCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 34),
                        const SizedBox(height: 18),
                        Text('StudySync',
                            style: theme.textTheme.displaySmall
                                ?.copyWith(color: Colors.white)),
                        const SizedBox(height: 10),
                        Text(
                          'AI plans, real-time study rooms, resource intelligence, and progress analytics in one focused workspace.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82)),
                        ),
                        const SizedBox(height: 18),
                        const _AuthFeature(
                            label: 'Firebase Auth protected workspace'),
                        const _AuthFeature(
                            label: 'FastAPI AI planning backend'),
                        const _AuthFeature(
                            label: 'Firestore collaboration data'),
                      ],
                    ),
                  );
                  if (!wide) {
                    return Column(
                        children: [story, const SizedBox(height: 14), form]);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: story),
                      const SizedBox(width: 16),
                      Expanded(child: form),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthFeature extends StatelessWidget {
  const _AuthFeature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
