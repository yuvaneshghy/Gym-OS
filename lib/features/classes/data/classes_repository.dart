import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../data/pocketbase_client.dart';
import '../domain/class_booking.dart';
import '../domain/gym_class.dart';

final classesRepositoryProvider = Provider<ClassesRepository>((ref) {
  return ClassesRepository(ref.watch(pocketBaseProvider));
});

final upcomingClassesProvider = FutureProvider.autoDispose<List<GymClass>>((ref) async {
  final repo = ref.watch(classesRepositoryProvider);
  return repo.getUpcomingClasses();
});

final memberBookingsProvider = FutureProvider.family.autoDispose<List<ClassBooking>, String>((ref, memberId) async {
  final repo = ref.watch(classesRepositoryProvider);
  return repo.getMemberBookings(memberId);
});

class ClassesRepository {
  ClassesRepository(this._pb);
  final PocketBase _pb;

  Future<List<GymClass>> getUpcomingClasses() async {
    final now = DateTime.now().toIso8601String();
    final records = await _pb.collection('classes').getFullList(
      filter: 'start_time >= "$now"',
      sort: 'start_time',
    );
    return records.map((r) => GymClass.fromJson(r.toJson())).toList();
  }

  Future<GymClass> createClass(GymClass gymClass) async {
    final record = await _pb.collection('classes').create(body: gymClass.toJson());
    return GymClass.fromJson(record.toJson());
  }

  Future<List<ClassBooking>> getMemberBookings(String memberId) async {
    final records = await _pb.collection('class_bookings').getFullList(
      filter: 'member = "$memberId"',
      expand: 'class',
      sort: '-created',
    );
    return records.map((r) => ClassBooking.fromJson(r.toJson())).toList();
  }

  Future<ClassBooking> bookClass(String classId, String memberId) async {
    final record = await _pb.collection('class_bookings').create(
      body: {
        'class': classId,
        'member': memberId,
        'status': 'booked',
      },
      expand: 'class',
    );
    return ClassBooking.fromJson(record.toJson());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _pb.collection('class_bookings').update(bookingId, body: {
      'status': status,
    });
  }
}
