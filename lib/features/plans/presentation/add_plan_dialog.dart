import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/plans_repository.dart';
import '../domain/plan.dart';

class AddPlanDialog extends ConsumerStatefulWidget {
  const AddPlanDialog({super.key, this.existingPlan});
  final Plan? existingPlan;

  @override
  ConsumerState<AddPlanDialog> createState() => _AddPlanDialogState();
}

class _AddPlanDialogState extends ConsumerState<AddPlanDialog> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();
  final _priceController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existingPlan != null) {
      _nameController.text = widget.existingPlan!.name;
      _durationController.text = widget.existingPlan!.durationDays.toString();
      _priceController.text = widget.existingPlan!.price.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      if (widget.existingPlan != null) {
        await ref.read(plansRepositoryProvider).updatePlan(
          id: widget.existingPlan!.id,
          name: _nameController.text.trim(),
          durationDays: int.parse(_durationController.text),
          price: double.parse(_priceController.text),
        );
      } else {
        await ref.read(plansRepositoryProvider).createPlan(
          name: _nameController.text.trim(),
          durationDays: int.parse(_durationController.text),
          price: double.parse(_priceController.text),
        );
      }
      
      ref.invalidate(plansListProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.existingPlan != null ? 'Plan updated successfully!' : 'Plan created successfully!')),
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
      title: Text(widget.existingPlan != null ? 'Edit Plan' : 'Create New Plan'),
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
                  decoration: const InputDecoration(labelText: 'Plan Name (e.g. Monthly Pro)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Duration (Days)', suffixText: 'days'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price', prefixText: r'$'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
              : Text(widget.existingPlan != null ? 'Save Changes' : 'Create Plan'),
        ),
      ],
    );
  }
}
