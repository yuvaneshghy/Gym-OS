import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../core/config/tenant_config.dart';
import '../../../core/config/tenant_config_repository.dart';
import '../../../core/theme/app_tokens.dart';

class AdvancedSettingsScreen extends ConsumerStatefulWidget {
  const AdvancedSettingsScreen({super.key, required this.adminPb});
  final PocketBase adminPb;

  @override
  ConsumerState<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends ConsumerState<AdvancedSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _hexController;
  
  String _selectedCurrency = '₹';
  late TenantConfig _currentConfig;
  bool _isLoading = false;

  final List<Color> _presetColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.brown,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    _currentConfig = ref.read(tenantConfigProvider).value ?? const TenantConfig();
    
    _nameController = TextEditingController(text: _currentConfig.gymName);
    _phoneController = TextEditingController(text: _currentConfig.gymPhone);
    _emailController = TextEditingController(text: _currentConfig.gymEmail);
    _addressController = TextEditingController(text: _currentConfig.gymAddress);
    _selectedCurrency = _currentConfig.currency;
    _hexController = TextEditingController(text: '#${(_currentConfig.seedColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _hexController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final records = await widget.adminPb.collection('app_config').getFullList();
      if (records.isEmpty) throw Exception('No config found');
      
      final recordId = records.first.id;
      final colorHex = _hexController.text.toUpperCase();
      
      await widget.adminPb.collection('app_config').update(recordId, body: {
        'gym_name': _nameController.text.trim(),
        'gym_phone': _phoneController.text.trim(),
        'gym_email': _emailController.text.trim(),
        'gym_address': _addressController.text.trim(),
        'seed_color': colorHex,
        'currency': _selectedCurrency,
      });

      // Update local state so it immediately reflects without a hard reload
      final updatedConfig = _currentConfig.copyWith(
        gymName: _nameController.text.trim(),
        gymPhone: _phoneController.text.trim(),
        gymEmail: _emailController.text.trim(),
        gymAddress: _addressController.text.trim(),
        currency: _selectedCurrency,
        seedColor: Color(int.parse(colorHex.replaceFirst('#', 'FF'), radix: 16)),
      );
      ref.read(tenantConfigProvider.notifier).setLocalConfig(updatedConfig);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Config updated successfully')));
        Navigator.pop(context);
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateColor(Color c) {
    setState(() {
      _hexController.text = '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    });
  }

  Future<void> _uploadLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    
    setState(() => _isLoading = true);
    try {
      final records = await widget.adminPb.collection('app_config').getFullList();
      if (records.isEmpty) throw Exception('No config found');
      
      final bytes = await file.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes('logo', bytes, filename: file.name);
      
      final updatedRecord = await widget.adminPb.collection('app_config').update(
        records.first.id,
        files: [multipartFile],
      );
      
      final logoUrl = widget.adminPb.files.getUrl(updatedRecord, updatedRecord.getStringValue('logo')).toString();
      
      final updatedConfig = _currentConfig.copyWith(logoUrl: logoUrl);
      ref.read(tenantConfigProvider.notifier).setLocalConfig(updatedConfig);
      
      if (mounted) {
        setState(() {
          _currentConfig = updatedConfig;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo uploaded successfully')));
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload logo: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Superadmin Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text('Brand Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            // Logo Placeholder
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _currentConfig.logoUrl.isNotEmpty 
                    ? Image.network(_currentConfig.logoUrl, fit: BoxFit.contain)
                    : Icon(Icons.image, size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _uploadLogo,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Logo'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Primary Color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetColors.map((c) {
                return InkWell(
                  onTap: () => _updateColor(c),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _hexController,
              decoration: const InputDecoration(labelText: 'Primary Color (Hex)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            Text('Gym Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Gym Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Physical Address', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCurrency,
              decoration: const InputDecoration(labelText: 'Currency Symbol', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: '₹', child: Text('₹ (INR)')),
                DropdownMenuItem(value: r'$', child: Text(r'$ (USD)')),
                DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
                DropdownMenuItem(value: '£', child: Text('£ (GBP)')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedCurrency = v);
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveConfig,
                child: _isLoading 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
