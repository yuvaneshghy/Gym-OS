import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import 'advanced_settings_screen.dart';

class SuperadminAuthDialog extends ConsumerStatefulWidget {
  const SuperadminAuthDialog({super.key});

  @override
  ConsumerState<SuperadminAuthDialog> createState() => _SuperadminAuthDialogState();
}

class _SuperadminAuthDialogState extends ConsumerState<SuperadminAuthDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    // Create an isolated PocketBase instance just for admin operations
    final baseUrl = ref.read(pocketBaseProvider).baseURL;
    final adminPb = PocketBase(baseUrl);
    try {
      await adminPb.collection('_superusers').authWithPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (mounted) {
        Navigator.pop(context); // close dialog
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => AdvancedSettingsScreen(adminPb: adminPb),
          ),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid Superadmin credentials: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Superadmin Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please login with a PocketBase superuser account to modify core configuration.'),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Admin Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
            obscureText: _obscureText,
            keyboardType: TextInputType.visiblePassword,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Login'),
        ),
      ],
    );
  }
}
