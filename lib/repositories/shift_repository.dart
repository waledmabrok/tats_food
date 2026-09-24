import '../core/database/database_helper.dart';

class ShiftRepository {
  final _db = DatabaseHelper.instance;

  Future<Map<String, dynamic>?> getCurrentShift() => _db.getCurrentShift();

  Future<String> openShift({
    required String userId,
    required String userName,
    required double openingCash,
  }) => _db.openShift(
    userId: userId,
    userName: userName,
    openingCash: openingCash,
  );

  /// ملخص لحظي (يُستخدم للعرض والشيفت لسه مفتوح)
  Future<Map<String, dynamic>> getShiftSummary(String shiftId) =>
      _db.getShiftSummary(shiftId);

  /// قفل الشيفت بعد عدّ الدرج فعليًا — بيرجع الملخص + الفرق (عجز/زيادة)
  Future<Map<String, dynamic>> closeShift(
    String shiftId, {
    required double actualClosingCash,
    String? notes,
  }) => _db.closeShift(
    shiftId,
    actualClosingCash: actualClosingCash,
    notes: notes,
  );

  Future<List<Map<String, dynamic>>> getHistory({int limit = 30}) =>
      _db.getShiftsHistory(limit: limit);
}
