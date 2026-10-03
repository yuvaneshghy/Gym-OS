import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../../members/data/members_repository.dart';
import '../../members/domain/member.dart';

class MemberProfileSettings extends ConsumerStatefulWidget {
  const MemberProfileSettings({super.key});

  @override
  ConsumerState<MemberProfileSettings> createState() => _MemberProfileSettingsState();
}

class _MemberProfileSettingsState extends ConsumerState<MemberProfileSettings> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  
  bool _isLoading = false;
  Member? _member;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(membersRepositoryProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;
    if (user != null) {
      _emailController.text = user.getStringValue('email');
      _nameController.text = user.getStringValue('name');
    }
    
    final member = await repo.getCurrentMember();
    if (member != null && mounted) {
      setState(() {
        _member = member;
        _nameController.text = member.name;
        _phoneController.text = member.phone;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _member == null) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(membersRepositoryProvider).updateCurrentMember(
        memberId: _member!.id,
        userId: _member!.userId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_member == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Profile', style: Theme.of(context).textTheme.titleLarge),
              if (_isLoading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                ),
            ],
          ),
          const SizedBox(height: 16),
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
            decoration: const InputDecoration(
              labelText: 'Email Address', 
              prefixIcon: Icon(Icons.email),
              helperText: 'Contact gym admin to change email',
            ),
            readOnly: true, // Read-only because PB requires email change verification/admin
            enabled: false,
          ),
        ],
      ),
    );
  }
}
