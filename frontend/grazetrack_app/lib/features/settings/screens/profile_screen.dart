import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final ApiService _api = ApiService();
  String _role = '';
  String _email = '';
  String _userId = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await AuthService().getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userId = user['id'] ?? '';
        _nameController.text = user['name'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _email = user['email'] ?? '';
        _role = user['role'] ?? '';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await _api.put('/users/$_userId', {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });
      final updatedUser = response.data['data'] as Map<String, dynamic>?;
      if (updatedUser != null) {
        final prefs = await SharedPreferences.getInstance();
        final current = await AuthService().getCurrentUser() ?? {};
        current['name'] = updatedUser['name'] ?? _nameController.text.trim();
        current['phone'] = updatedUser['phone'] ?? _phoneController.text.trim();
        await prefs.setString(AppConstants.userKey, jsonEncode(current));
      }
      if (mounted) {
        AppUtils.showSnackBar(context,
            AppLocalizations.of(context).profileUpdatedSuccess);
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context,
            AppLocalizations.of(context).updateFailed,
            isError: true);
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.backgroundGreen,
                child: Icon(Icons.person, size: 52, color: AppTheme.primaryGreen),
              ),
              const SizedBox(height: 8),
              Text(_email, style: const TextStyle(color: Colors.grey)),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_role,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person_outlined),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? l10n.nameRequiredError : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52)),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
