import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/attendance_record.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(pocketBaseProvider));
});

final todaysAttendanceProvider = FutureProvider.autoDispose<List<AttendanceRecord>>((ref) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  
  final pb = ref.watch(pocketBaseProvider);
  // ignore: unawaited_futures
  pb.collection('attendance').subscribe('*', (e) {
    ref.invalidateSelf();
  });
  
  ref.onDispose(() {
    // ignore: unawaited_futures
    pb.collection('attendance').unsubscribe('*');
  });
  
  return repo.getTodaysAttendance();
});

class AttendanceRepository {
  AttendanceRepository(this._pb);
  final PocketBase _pb;

  Future<List<AttendanceRecord>> getTodaysAttendance() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    // Convert to UTC strings for PB comparison
    final startStr = startOfDay.toUtc().toIso8601String().replaceFirst('T', ' ');
    
    final res = await _pb.collection('attendance').getFullList(
      filter: 'check_in_time >= "$startStr"',
      sort: '-check_in_time',
      expand: 'member',
    );
    return res.map(AttendanceRecord.fromRecord).toList();
  }

  /// Attempts to check in a member.
  /// Throws an exception if their plan is expired/dues pending (if we enforce it here),
  /// or simply returns a status string that the UI handles.
  Future<String> checkInMember(String memberId, {required bool enforceActivePlan}) async {
    // 1. Fetch memberships to verify active plan
    final membershipsRes = await _pb.collection('memberships').getFullList(
      filter: 'member="$memberId"',
    );
    
    final now = DateTime.now();
    var hasActive = false;
    for (final m in membershipsRes) {
      final start = DateTime.parse(m.getStringValue('start_date')).toLocal();
      final end = DateTime.parse(m.getStringValue('end_date')).toLocal();
      if (now.isAfter(start) && now.isBefore(end)) {
        hasActive = true;
        break;
      }
    }
    
    if (enforceActivePlan && !hasActive) {
      return 'DENIED_EXPIRED';
    }
    
    // Proceed to check in
    String pbDate(DateTime d) => d.toUtc().toIso8601String().replaceFirst('T', ' ');
    await _pb.collection('attendance').create(body: {
      'member': memberId,
      'check_in_time': pbDate(now),
    });
    
    return 'GRANTED';
  }
}
