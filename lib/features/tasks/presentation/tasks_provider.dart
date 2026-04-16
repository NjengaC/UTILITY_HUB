import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utility_hub/features/tasks/data/tasks_repository.dart';
import 'package:utility_hub/features/tasks/domain/task_model.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

final tasksListProvider =
    StateNotifierProvider<TasksListNotifier, AsyncValue<List<TaskModel>>>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return TasksListNotifier(repo);
});

class TasksListNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final TasksRepository _repo;

  TasksListNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repo.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String id) async {
    await _repo.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleComplete(String id) async {
    await _repo.toggleComplete(id);
    await loadTasks();
  }
}
