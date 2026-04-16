import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:utility_hub/features/tasks/domain/task_model.dart';
import 'package:utility_hub/features/tasks/presentation/tasks_provider.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  final String? taskId;
  const TaskEditorScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _isEditing = true;
      _loadTask();
    }
  }

  Future<void> _loadTask() async {
    final repo = ref.read(tasksRepositoryProvider);
    final task = await repo.getTaskById(widget.taskId!);
    if (task != null && mounted) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repo = ref.read(tasksRepositoryProvider);
    final now = DateTime.now();

    if (_isEditing) {
      final existing = await repo.getTaskById(widget.taskId!);
      if (existing != null) {
        existing.title = _titleController.text.trim();
        existing.description = _descriptionController.text.trim();
        existing.updatedAt = now;
        await repo.saveTask(existing);
      }
    } else {
      final task = TaskModel(
        id: now.millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await repo.saveTask(task);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
              tooltip: 'Delete task',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Task title',
                hintText: 'What needs to be done?',
                prefixIcon: const Icon(Icons.task_alt_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              minLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add details about this task...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            FilledButton.icon(
              onPressed: _isLoading ? null : _saveTask,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEditing ? Icons.save_rounded : Icons.add_task_rounded),
              label: Text(_isEditing ? 'Save Changes' : 'Create Task'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(tasksRepositoryProvider).deleteTask(widget.taskId!);
              if (mounted) {
                if (context.mounted) context.pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
