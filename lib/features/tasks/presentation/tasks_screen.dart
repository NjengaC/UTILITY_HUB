import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:utility_hub/features/tasks/domain/task_model.dart';
import 'package:utility_hub/features/tasks/presentation/tasks_provider.dart';
import 'package:intl/intl.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'all'; // all, active, completed

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/tasks/editor');
          ref.read(tasksListProvider.notifier).loadTasks();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task'),
      ),
      body: tasksState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          final filtered = _applyFilters(tasks);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      count: tasks.length,
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Active',
                      count: tasks.where((t) => !t.isCompleted).length,
                      selected: _filter == 'active',
                      onTap: () => setState(() => _filter = 'active'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Done',
                      count: tasks.where((t) => t.isCompleted).length,
                      selected: _filter == 'completed',
                      onTap: () => setState(() => _filter = 'completed'),
                    ),
                  ],
                ),
              ),

              // Progress indicator
              if (tasks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _ProgressBar(
                    completed: tasks.where((t) => t.isCompleted).length,
                    total: tasks.length,
                  ),
                ),

              // Task list
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(
                        hasFilter: _searchQuery.isNotEmpty || _filter != 'all',
                        onAddTap: () async {
                          await context.push('/tasks/editor');
                          ref.read(tasksListProvider.notifier).loadTasks();
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final task = filtered[index];
                          return _TaskTile(
                            task: task,
                            onToggle: () {
                              ref.read(tasksListProvider.notifier).toggleComplete(task.id);
                            },
                            onEdit: () async {
                              await context.push('/tasks/editor?id=${task.id}');
                              ref.read(tasksListProvider.notifier).loadTasks();
                            },
                            onDelete: () => _confirmDelete(context, ref, task),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    var result = tasks;

    // Apply status filter
    if (_filter == 'active') {
      result = result.where((t) => !t.isCompleted).toList();
    } else if (_filter == 'completed') {
      result = result.where((t) => t.isCompleted).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tasksListProvider.notifier).deleteTask(task.id);
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

// --- Task tile ---

class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, y');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: colorScheme.error,
          child: Icon(Icons.delete_rounded, color: colorScheme.onError),
        ),
        confirmDismiss: (_) async {
          onDelete();
          return false;
        },
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggle(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(task.updatedAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      size: 20, color: colorScheme.onSurfaceVariant),
                  onPressed: onEdit,
                  tooltip: 'Edit task',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Filter chip ---

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// --- Progress bar ---

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed of $total completed',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

// --- Empty state ---

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onAddTap;

  const _EmptyState({required this.hasFilter, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter ? Icons.search_off_rounded : Icons.checklist_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter ? 'No tasks match your filter' : 'No tasks yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try a different search or filter'
                  : 'Tap the button below to create your first task',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasFilter) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddTap,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Task'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
