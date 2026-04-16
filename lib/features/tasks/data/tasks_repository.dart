import 'package:hive/hive.dart';
import 'package:utility_hub/features/tasks/domain/task_model.dart';

class TasksRepository {
  static const _boxName = 'tasks';

  Future<Box<TaskModel>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<TaskModel>(_boxName);
    }
    return await Hive.openBox<TaskModel>(_boxName);
  }

  Future<List<TaskModel>> getAllTasks() async {
    final box = await _getBox();
    final tasks = box.values.toList();
    // Sort: incomplete first, then by updatedAt descending
    tasks.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return tasks;
  }

  Future<TaskModel?> getTaskById(String id) async {
    final box = await _getBox();
    try {
      return box.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTask(TaskModel task) async {
    final box = await _getBox();
    final existingIndex = box.values.toList().indexWhere((t) => t.id == task.id);
    if (existingIndex >= 0) {
      await box.putAt(existingIndex, task);
    } else {
      await box.add(task);
    }
  }

  Future<void> deleteTask(String id) async {
    final box = await _getBox();
    final index = box.values.toList().indexWhere((t) => t.id == id);
    if (index >= 0) {
      await box.deleteAt(index);
    }
  }

  Future<void> toggleComplete(String id) async {
    final task = await getTaskById(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.updatedAt = DateTime.now();
      await task.save();
    }
  }
}
