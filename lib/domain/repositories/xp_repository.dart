import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/gamification/xp_ledger.dart';

abstract interface class XpRepository {
  Future<List<XpEvent>> getLedger({LocalDate? through});

  /// Inserts idempotently using (action, sourceId, logicalDate) as its key.
  Future<bool> insertIfAbsent(XpEvent event);

  Future<void> reverse(XpEvent event);
}
