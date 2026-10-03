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
    final now = DateTime.now();
    String pbDate(DateTime d) => d.toUtc().toIso8601String().replaceFirst('T', ' ');

    // 1. Check for existing attendance today
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startStr = pbDate(startOfDay);
    
    final recentRecords = await _pb.collection('attendance').getFullList(
      filter: 'member="$memberId" && check_in_time >= "$startStr"',
      sort: '-check_in_time',
    );

    if (recentRecords.isNotEmpty) {
      final latest = recentRecords.first;
      final checkOutTime = latest.getStringValue('check_out_time');
      
      if (checkOutTime.isEmpty) {
        final checkInTime = DateTime.parse(latest.getStringValue('check_in_time')).toLocal();
        final diff = now.difference(checkInTime);
        
        if (diff.inMinutes < 5) {
          // Debounce: Scanned again within 5 minutes
          return 'ALREADY_CHECKED_IN';
        } else {
          // Check-out: Scanned after 5 minutes
          await _pb.collection('attendance').update(latest.id, body: {
            'check_out_time': pbDate(now),
          });
          return 'CHECKED_OUT';
        }
      }
    }

    // 2. Fetch memberships to verify active plan (if this is a check-in)
    final membershipsRes = await _pb.collection('memberships').getFullList(
      filter: 'member="$memberId"',
    );
    
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
    
    // 3. Proceed to check in
    await _pb.collection('attendance').create(body: {
      'member': memberId,
      'check_in_time': pbDate(now),
    });
    
    return 'GRANTED';
  }
}
