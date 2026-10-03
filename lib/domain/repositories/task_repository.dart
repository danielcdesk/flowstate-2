import 'package:flowstate/core/local_date.dart';
import 'package:flowstate/domain/tasks/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getActiveTasks();

  Future<void> saveTask(Task task);

  Future<List<TaskCompletion>> getCompletions({
    required LocalDate from,
    required LocalDate through,
  });

  Future<void> saveCompletion(TaskCompletion completion);
}
