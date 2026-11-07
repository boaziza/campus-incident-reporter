import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/primary_button.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Check every 5 seconds so the app opens as soon as the link is clicked
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _check());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check({bool showResult = false}) async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final verified = await context.read<AuthProvider>().checkEmailVerified();
      if (verified) {
        _timer?.cancel();
      } else if (showResult && mounted) {
        _showMessage('Email not verified yet. Check your inbox and spam.');
      }
    } catch (_) {
      if (showResult && mounted) _showMessage('Could not check right now.');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.resendVerification();
    if (mounted) {
      _showMessage(success
          ? 'Verification email sent again.'
          : auth.errorMessage ?? 'Could not send email.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.mark_email_unread_outlined,
                    size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify your email',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a verification link to\n${auth.email ?? 'your ALU email'}.\n'
                'Open it to activate your account.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textGrey, height: 1.5),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: "I've verified my email",
                isLoading: _checking,
                onPressed: () => _check(showResult: true),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: auth.isBusy ? null : _resend,
                child: const Text('Resend email'),
              ),
              TextButton(
                onPressed: () => context.read<AuthProvider>().logout(),
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
