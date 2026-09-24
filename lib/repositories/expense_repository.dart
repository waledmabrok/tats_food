import '../core/database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<Expense>> getAll({DateTime? from, DateTime? to, int? limit, int? offset}) async {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (from != null) {
      conditions.add("date(date) >= date(?)");
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add("date(date) <= date(?)");
      args.add(to.toIso8601String());
    }

    final results = await _db.query(
      'expenses',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    return results.map(Expense.fromMap).toList();
  }

  Future<void> insert(Expense expense) async {
    await _db.insert('expenses', expense.toMap());
  }

  Future<void> update(Expense expense) async {
    await _db.update('expenses', expense.toMap(), 'id = ?', [expense.id]);
  }

  Future<void> delete(String id) async {
    await _db.delete('expenses', 'id = ?', [id]);
  }

  Future<double> getTotalByDateRange(DateTime from, DateTime to) async {
    final result = await _db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE date(date) >= date(?) AND date(date) <= date(?)",
      [from.toIso8601String(), to.toIso8601String()],
    );
    return (result.first['total'] as num).toDouble();
  }
}
