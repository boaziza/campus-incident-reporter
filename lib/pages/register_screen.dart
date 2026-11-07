import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;

    if (success) {
      // Go back to the root, AuthWrapper now shows the verify email screen
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registration failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = context.watch<AuthProvider>().isBusy;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join your campus community',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Only ALU email addresses can register. We will send you a verification link.',
                  style: TextStyle(color: AppColors.textGrey),
                ),
                const SizedBox(height: 28),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full name',
                  hint: 'e.g. Amina Hassan',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                ),
                const SizedBox(height: 18),
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
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(_hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: _confirmController,
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _hidePassword,
                  validator: (value) => Validators.confirmPassword(
                      value, _passwordController.text),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: 'Create Account',
                  isLoading: isBusy,
                  onPressed: _register,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?',
                        style: TextStyle(color: AppColors.textGrey)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sign in'),
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
