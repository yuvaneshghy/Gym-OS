import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';

import '../../members/data/members_repository.dart';
import '../data/attendance_repository.dart';

class ActiveModeScreen extends ConsumerStatefulWidget {
  const ActiveModeScreen({super.key});

  @override
  ConsumerState<ActiveModeScreen> createState() => _ActiveModeScreenState();
}

class _ActiveModeScreenState extends ConsumerState<ActiveModeScreen> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isProcessing = false;
  String? _overlayStatus; // 'GRANTED' or 'DENIED_EXPIRED' or 'NOT_FOUND'

  @override
  void initState() {
    super.initState();
    // Keep focus on the text field for USB barcode scanners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _processScan(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isProcessing = true;
      _overlayStatus = null;
    });

    try {
      final membersRepo = ref.read(membersRepositoryProvider);
      final attendanceRepo = ref.read(attendanceRepositoryProvider);

      // Search by phone or ID
      final members = await membersRepo.getMembers(perPage: 100);
      final match = members.where((m) => m.phone == query.trim() || m.id == query.trim()).firstOrNull;

      if (match == null) {
        _showOverlay('NOT_FOUND');
        return;
      }

      final status = await attendanceRepo.checkInMember(match.id, enforceActivePlan: true);
      _showOverlay(status);

    } on Object catch (_) {
      _showOverlay('NOT_FOUND');
    } finally {
      setState(() {
        _isProcessing = false;
      });
      _inputController.clear();
      _focusNode.requestFocus();
    }
  }

  void _showOverlay(String status) {
    setState(() {
      _overlayStatus = status;
    });
    
    // Auto-hide after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _overlayStatus == status) {
        setState(() {
          _overlayStatus = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(todaysAttendanceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Left side: Scanner / Manual Entry
              Expanded(
                flex: 6,
                child: ColoredBox(
                  color: theme.colorScheme.surface,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 100, color: theme.colorScheme.primary),
                      const SizedBox(height: 32),
                      Text('Check-In Scanner', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Scan member ID or enter phone number.', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                      const SizedBox(height: 48),
                      
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: _inputController,
                          focusNode: _focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'e.g. 555-0192 or mem_123',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.tokens.cornerRadius)),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest,
                            suffixIcon: _isProcessing 
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.arrow_forward),
                                  onPressed: () => _processScan(_inputController.text),
                                ),
                          ),
                          onSubmitted: _processScan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right side: Live Feed
              Expanded(
                flex: 4,
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainer,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            const Icon(Icons.history),
                            const SizedBox(width: 12),
                            Text("Today's Check-Ins", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: attendanceAsync.when(
                          data: (records) {
                            if (records.isEmpty) {
                              return Center(
                                child: Text('No check-ins today.', style: TextStyle(color: theme.colorScheme.outline)),
                              );
                            }
                            return ListView.builder(
                              itemCount: records.length,
                              itemBuilder: (context, index) {
                                final r = records[index];
                                final m = r.expandMember;
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.person),
                                  ),
                                  title: Text(m?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${r.checkInTime.hour.toString().padLeft(2, '0')}:${r.checkInTime.minute.toString().padLeft(2, '0')}'),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Center(child: Text('Error: $e')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Feedback Overlay
          if (_overlayStatus != null)
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: ColoredBox(
                  color: _overlayStatus == 'GRANTED'
                      ? context.tokens.successColor.withAlpha(230)
                      : context.tokens.dangerColor.withAlpha(230),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _overlayStatus == 'GRANTED' ? Icons.check_circle : Icons.error,
                          size: 150,
                          color: const Color(0xFFFFFFFF),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _overlayStatus == 'GRANTED'
                              ? 'ACCESS GRANTED'
                              : _overlayStatus == 'DENIED_EXPIRED'
                                  ? 'ACCESS DENIED\nPlan Expired'
                                  : 'MEMBER NOT FOUND',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: const Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
