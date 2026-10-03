import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/payments_repository.dart';

class RecordPaymentDialog extends ConsumerStatefulWidget {
  const RecordPaymentDialog({
    super.key,
    required this.memberId,
    this.membershipId,
    this.defaultAmount,
    required this.onRecorded,
  });

  final String memberId;
  final String? membershipId;
  final double? defaultAmount;
  final VoidCallback onRecorded;

  @override
  ConsumerState<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  final _notesController = TextEditingController();
  String _method = 'upi';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.defaultAmount?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(paymentsRepositoryProvider).recordPayment(
        memberId: widget.memberId,
        membershipId: widget.membershipId,
        amount: double.parse(_amountController.text),
        method: _method,
        notes: _notesController.text,
      );

      widget.onRecorded();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully!')),
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
      title: const Text('Record Payment'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                  ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: r'$'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownMenu<String>(
                  initialSelection: _method,
                  label: const Text('Payment Method'),
                  width: 350,
                  onSelected: (val) {
                    if (val != null) setState(() => _method = val);
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'upi', label: 'UPI / Digital'),
                    DropdownMenuEntry(value: 'cash', label: 'Cash'),
                    DropdownMenuEntry(value: 'card', label: 'Credit/Debit Card'),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                  maxLines: 2,
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
              : const Text('Save Payment'),
        ),
      ],
    );
  }
}
