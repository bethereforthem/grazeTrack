import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _phoneController.text.trim(),
        );

    if (mounted) {
      if (success) {
        context.go('/dashboard');
      } else {
        final error = ref.read(authProvider).error;
        final l10n = AppLocalizations.of(context);
        AppUtils.showSnackBar(context, error ?? l10n.createAccount, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryGreen,
        elevation: 0,
        title: Text(l10n.createAccount),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Full Name ─────────────────────────────────
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outlined),
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? l10n.nameRequired : null,
                ),
                const SizedBox(height: 16),

                // ─── Email ─────────────────────────────────────
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return l10n.emailRequired;
                    if (!val.contains('@')) return l10n.emailInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ─── Phone Number ──────────────────────────────
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    hintText: l10n.phoneHint,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return l10n.phoneRequired;
                    if (val.length < 7) return l10n.phoneInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ─── Password ──────────────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return l10n.passwordRequired;
                    if (val.length < 6) return l10n.passwordMinLength;
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // ─── Role note ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryGreen.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.registeredAsFarmer,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Register Button ───────────────────────────
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _register,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(l10n.createAccount),
                ),
                const SizedBox(height: 16),

                // ─── Login Link ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${l10n.alreadyHaveAccount} '),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        l10n.login,
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
