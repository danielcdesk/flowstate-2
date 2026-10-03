import 'package:flowstate/domain/focus/focus_session.dart';

abstract interface class FocusRepository {
  Future<List<FocusSession>> getSessions();

  Future<void> saveSession(FocusSession session);
}
