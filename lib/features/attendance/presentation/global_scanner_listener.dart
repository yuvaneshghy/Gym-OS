import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/attendance_repository.dart';

/// A global widget that listens to hardware keyboard events (like a USB barcode scanner)
/// and triggers attendance check-ins, regardless of which screen is active.
class GlobalScannerListener extends ConsumerStatefulWidget {
  const GlobalScannerListener({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<GlobalScannerListener> createState() => _GlobalScannerListenerState();
}

class _GlobalScannerListenerState extends ConsumerState<GlobalScannerListener> {
  final StringBuffer _buffer = StringBuffer();
  DateTime? _lastKeystroke;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    
    final now = DateTime.now();
    
    // If it's been more than 50ms since the last keystroke, clear the buffer.
    // Human typists are rarely faster than 50ms between keys.
    // Barcode scanners are typically 5-20ms per character.
    if (_lastKeystroke != null && now.difference(_lastKeystroke!).inMilliseconds > 50) {
      _buffer.clear();
    }
    _lastKeystroke = now;

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final code = _buffer.toString().trim();
      _buffer.clear();
      
      // PocketBase IDs are 15 characters long. 
      // We check for >= 10 to be safe and avoid triggering on random short words.
      if (code.isNotEmpty && code.length >= 10) {
        _processScan(code);
        return true; // Prevent Enter from triggering submit on a focused field
      }
      return false;
    }

    if (event.character != null) {
      _buffer.write(event.character);
    }
    
    return false; // Let the event propagate
  }

  Future<void> _processScan(String code) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final result = await repo.checkInMember(code, enforceActivePlan: true);
      if (mounted) {
        _showOverlay(result);
      }
    } on Object catch (_) {
      if (mounted) {
        // Fallback for "record not found" if they scan an invalid QR code
        _showOverlay('INVALID_ID');
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _showOverlay(String status) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        left: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: _ScannerOverlayCard(status: status),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _ScannerOverlayCard extends StatelessWidget {
  const _ScannerOverlayCard({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;
    String message;

    switch (status) {
      case 'GRANTED':
        color = Colors.green;
        icon = Icons.check_circle;
        message = 'Access Granted';
        break;
      case 'CHECKED_OUT':
        color = Colors.blue;
        icon = Icons.exit_to_app;
        message = 'Checked Out';
        break;
      case 'ALREADY_CHECKED_IN':
        color = Colors.orange;
        icon = Icons.info;
        message = 'Already Checked In';
        break;
      case 'DENIED_EXPIRED':
        color = theme.colorScheme.error;
        icon = Icons.cancel;
        message = 'Denied: Plan Expired';
        break;
      case 'INVALID_ID':
        color = theme.colorScheme.error;
        icon = Icons.error_outline;
        message = 'Invalid Member ID';
        break;
      default:
        color = theme.colorScheme.error;
        icon = Icons.error;
        message = 'Error Processing Scan';
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Container(
              width: 300,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(50),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
