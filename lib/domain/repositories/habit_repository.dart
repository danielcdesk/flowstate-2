import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/habits/habit.dart';

abstract interface class HabitRepository {
  Future<List<Habit>> getActiveHabits();

  Future<void> saveHabit(Habit habit);

  Future<List<HabitLog>> getHabitLogs({
    required LocalDate from,
    required LocalDate through,
  });

  Future<void> saveHabitLog(HabitLog log);
}
