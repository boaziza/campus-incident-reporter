import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );
    if (!success && mounted) {
      _showMessage(auth.errorMessage ?? 'Login failed.');
    }
    // On success AuthWrapper switches screens automatically
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text;
    if (Validators.email(email) != null) {
      _showMessage('Enter your ALU email above first.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordReset(email);
    if (mounted) {
      _showMessage(success
          ? 'Password reset link sent to $email'
          : auth.errorMessage ?? 'Could not send reset email.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<AuthProvider>().isBusy;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const _AppLogo(),
                const SizedBox(height: 32),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in with your ALU account to report and track campus issues.',
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _emailController,
                  label: 'ALU Email',
                  hint: 'name@alustudent.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(_hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isBusy ? null : _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Sign In',
                  isLoading: isBusy,
                  onPressed: _login,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(color: AppColors.textGrey)),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.register),
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B6CFF), AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 34),
    );
  }
}
