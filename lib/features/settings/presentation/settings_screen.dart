import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/tenant_config.dart';
import '../../../core/config/tenant_config_repository.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../auth/data/auth_repository.dart';
import 'member_profile_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _hexController;

  TenantConfig _currentConfig = const TenantConfig();
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
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _hexController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfig();
    });
  }

  void _loadConfig() {
    if (!mounted) return;
    final configAsync = ref.read(tenantConfigProvider);
    if (configAsync.hasValue) {
      setState(() {
        _currentConfig = configAsync.value!;
        _nameController.text = _currentConfig.gymName;
        _phoneController.text = _currentConfig.gymPhone;
        _emailController.text = _currentConfig.gymEmail;
        _addressController.text = _currentConfig.gymAddress;
        _hexController.text = '#${(_currentConfig.seedColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
      });
    }
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

  void _updateConfig(TenantConfig config) {
    setState(() {
      _currentConfig = config;
      _hexController.text = '#${(config.seedColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    });
    // Update local cache and state for instant preview
    ref.read(tenantConfigProvider.notifier).updateConfig(config);
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final notifier = ref.read(tenantConfigProvider.notifier);
      final newConfig = _currentConfig.copyWith(
        gymName: _nameController.text,
        gymPhone: _phoneController.text,
        gymEmail: _emailController.text,
        gymAddress: _addressController.text,
      );
      await notifier.updateConfig(newConfig);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadLogo() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    
    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(tenantConfigProvider.notifier);
      await notifier.uploadLogo(file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo uploaded successfully')),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload logo: $e')),
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
    return Scaffold(
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                        if (_isLoading)
                          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        else if (ref.watch(authRepositoryProvider).currentRole == 'owner')
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: const Text('Save Configuration'),
                            onPressed: _saveConfig,
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('App Preferences', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Consumer(
                      builder: (context, ref, child) {
                        final currentMode = ref.watch(themeModeProvider);
                        return SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                            ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                            ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                          ],
                          selected: {currentMode},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            ref.read(themeModeProvider.notifier).setMode(newSelection.first);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    if (ref.watch(authRepositoryProvider).currentRole == 'owner') ...[
                      Text('Team Management', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      ListTile(
                        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        leading: const Icon(Icons.group),
                        title: const Text('Manage Staff & Employees', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Create accounts for trainers and managers'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.go('/settings/staff');
                        },
                      ),
                      const SizedBox(height: 32),

                      Text('Gym Profile', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Gym Name'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Physical Address'),
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 32),
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
                      children: _presetColors.map((color) {
                        return InkWell(
                          onTap: () => _updateConfig(_currentConfig.copyWith(seedColor: color)),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _currentConfig.seedColor == color ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hexController,
                      decoration: const InputDecoration(
                        labelText: 'Hex Color (e.g., #FF5500)',
                        prefixIcon: Icon(Icons.color_lens),
                      ),
                      onChanged: (val) {
                        if (val.length == 7 && val.startsWith('#')) {
                          final color = Color(int.tryParse(val.replaceAll('#', 'FF'), radix: 16) ?? 0xFF2196F3);
                          _updateConfig(_currentConfig.copyWith(seedColor: color));
                        }
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    Text('Input Style', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownMenu<String>(
                      initialSelection: _currentConfig.inputStyle,
                      onSelected: (val) {
                        if (val != null) _updateConfig(_currentConfig.copyWith(inputStyle: val));
                      },
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: 'outlined', label: 'Outlined'),
                        DropdownMenuEntry(value: 'filled', label: 'Filled'),
                        DropdownMenuEntry(value: 'underlined', label: 'Underlined'),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    Text('Corner Radius (${_currentConfig.cornerRadius.toStringAsFixed(1)})', style: Theme.of(context).textTheme.titleMedium),
                    Slider(
                      value: _currentConfig.cornerRadius,
                      max: 24.0,
                      onChanged: (val) {
                        _updateConfig(_currentConfig.copyWith(cornerRadius: val));
                      },
                    ),
                    ] else ...[
                      const MemberProfileSettings(),
                      const SizedBox(height: 32),
                      Text('Gym Contact Info', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(context.tokens.cornerRadius),
                          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_currentConfig.gymName.isNotEmpty)
                                ListTile(
                                  leading: const Icon(Icons.fitness_center),
                                  title: Text(_currentConfig.gymName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (_currentConfig.gymPhone.isNotEmpty)
                                ListTile(
                                  leading: const Icon(Icons.phone),
                                  title: Text(_currentConfig.gymPhone),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (_currentConfig.gymEmail.isNotEmpty)
                                ListTile(
                                  leading: const Icon(Icons.email),
                                  title: Text(_currentConfig.gymEmail),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              if (_currentConfig.gymAddress.isNotEmpty)
                                ListTile(
                                  leading: const Icon(Icons.location_on),
                                  title: Text(_currentConfig.gymAddress),
                                  contentPadding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
