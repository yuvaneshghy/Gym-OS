import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/members_repository.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});

  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await ref.read(membersRepositoryProvider).createMember(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Refresh the members list
      ref.invalidate(membersListProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully!')),
        );
      }
    } on Object catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Member'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                  ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (v) => v == null || v.length < 8 ? 'Min 8 characters' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Member'),
        ),
      ],
    );
  }
}
