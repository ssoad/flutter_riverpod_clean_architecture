import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/tasks/presentation/providers/task_provider.dart';
import 'package:intl/intl.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tasksProvider.notifier).loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tasksProvider);
    final notifier = ref.read(tasksProvider.notifier);

    ref.listen(tasksProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppUtils.showSnackBar(
          context,
          message: next.errorMessage!,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.tasks.isEmpty
              ? 'Tasks'
              : 'Tasks (${state.completedCount}/${state.tasks.length})',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: TaskFilter.values.map((f) {
                return ChoiceChip(
                  label: Text(_filterLabel(f)),
                  selected: state.filter == f,
                  onSelected: (_) => notifier.setFilter(f),
                );
              }).toList(),
            ),
          ),
          Expanded(child: _buildBody(context, state, notifier)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TasksState state,
    TasksNotifier notifier,
  ) {
    if (state.status == TasksStatus.loading && state.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final visible = state.visibleTasks;

    if (visible.isEmpty) {
      return Center(
        child: Text(
          state.filter == TaskFilter.all
              ? 'No tasks yet. Tap + to add one.'
              : 'No ${_filterLabel(state.filter).toLowerCase()} tasks.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final task = visible[index];
          return Dismissible(
            key: ValueKey(task.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: Theme.of(context).colorScheme.error,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => notifier.deleteTask(task.id),
            child: ListTile(
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (_) => notifier.toggleTask(task.id),
              ),
              title: Text(
                task.title,
                style: task.isCompleted
                    ? const TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
              subtitle: _buildSubtitle(context, task),
              trailing: _PriorityDot(priority: task.priority),
              onTap: () => _showTaskForm(context, task: task),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context, TaskEntity task) {
    final parts = <String>[];
    if (task.description != null && task.description!.isNotEmpty) {
      parts.add(task.description!);
    }
    if (task.dueDate != null) {
      parts.add('Due ${DateFormat.yMMMd().format(task.dueDate!)}');
    }
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' • '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: task.isOverdue
          ? TextStyle(color: Theme.of(context).colorScheme.error)
          : null,
    );
  }

  String _filterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.completed:
        return 'Completed';
    }
  }

  Future<void> _showTaskForm(BuildContext context, {TaskEntity? task}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TaskFormSheet(task: task),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.high => Colors.red,
      TaskPriority.medium => Colors.orange,
      TaskPriority.low => Colors.green,
    };
    return Tooltip(
      message: '${priority.name} priority',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _TaskFormSheet extends ConsumerStatefulWidget {
  final TaskEntity? task;

  const _TaskFormSheet({this.task});

  @override
  ConsumerState<_TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<_TaskFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  DateTime? _dueDate;
  bool _saving = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isEditing ? 'Edit task' : 'New task',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<TaskPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TaskPriority.values
                      .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _dueDate == null
                        ? 'Due date'
                        : DateFormat.yMMMd().format(_dueDate!),
                  ),
                  onPressed: _pickDueDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isEditing ? 'Save changes' : 'Add task'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _saving = true);

    final notifier = ref.read(tasksProvider.notifier);
    final success = _isEditing
        ? await notifier.updateTask(
            widget.task!.copyWith(
              title: title,
              description: _descriptionController.text,
              priority: _priority,
              dueDate: _dueDate,
              clearDueDate: _dueDate == null,
            ),
          )
        : await notifier.addTask(
            title: title,
            description: _descriptionController.text,
            priority: _priority,
            dueDate: _dueDate,
          );

    if (!mounted) return;
    setState(() => _saving = false);
    if (success) Navigator.of(context).pop();
  }
}
