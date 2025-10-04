import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/task_model.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';

class EnhancedTaskItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EnhancedTaskItem({super.key, required this.task, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        } else {
          context.read<WeeklyCubit>().deleteTask(task.id);
        }
      },
      background: _buildDismissBackground(),
      child: Container(
        constraints: const BoxConstraints(minHeight: 30),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showTaskOptions(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.reminderTime != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: Theme.of(context).colorScheme.primary,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${AppLocalizations.of(context).tr('task.reminder')}: ${_formatTime(context, task.reminderTime!)}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],

                        Text(
                          task.title,
                          style: TextStyle(
                            color: task.isCompleted
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),

                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        if (task.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: task.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        if (task.dueDate != null || task.estimatedMinutes > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (task.dueDate != null) ...[
                                Icon(
                                  Icons.schedule,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getRelativeDateText(context, task.dueDate!),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],

                              if (task.dueDate != null && task.estimatedMinutes > 0) ...[
                                const SizedBox(width: 16),
                              ],

                              if (task.estimatedMinutes > 0) ...[
                                Icon(
                                  Icons.timer,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${task.estimatedMinutes} min',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        context.read<WeeklyCubit>().toggleTaskCompletion(task.id);
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      checkColor: Theme.of(context).colorScheme.onPrimary,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError, size: 24),
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final timeString = TimeOfDay(hour: time.hour, minute: time.minute).format(context);

    return timeString;
  }

  String _getRelativeDateText(BuildContext context, DateTime dueDate) {
    final today = DateTime.now();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (dueDay == today) {
      return AppLocalizations.of(context).tr('common.today');
    } else if (dueDay == today.add(const Duration(days: 1))) {
      return AppLocalizations.of(context).tr('common.tomorrow');
    } else if (dueDay == today.subtract(const Duration(days: 1))) {
      return AppLocalizations.of(context).tr('common.yesterday');
    } else {
      final difference = dueDay.difference(today).inDays;
      if (difference > 0) {
        return AppLocalizations.of(
          context,
        ).trWithParams('common.inDays', {'days': difference.toString()});
      } else {
        return AppLocalizations.of(
          context,
        ).trWithParams('common.daysAgo', {'days': difference.abs().toString()});
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context).tr('settings.deleteTask'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            AppLocalizations.of(
              context,
            ).trWithParams('settings.deleteTaskConfirmation', {'taskTitle': task.title}),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                AppLocalizations.of(context).tr('settings.cancel'),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(AppLocalizations.of(context).tr('settings.deleteTask')),
            ),
          ],
        );
      },
    );
  }

  void _showTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).tr('task.options'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionButton(
                context,
                AppLocalizations.of(context).tr('edit.tasks'),
                Icons.edit,
                () {
                  Navigator.of(context).pop();
                  if (onEdit != null) {
                    onEdit!();
                  }
                },
              ),
              const SizedBox(height: 10),
              _buildOptionButton(
                context,
                AppLocalizations.of(context).tr('delete.task'),
                Icons.delete,
                () {
                  Navigator.of(context).pop();
                  if (onDelete != null) {
                    onDelete!();
                  } else {
                    context.read<WeeklyCubit>().deleteTask(task.id);
                  }
                },
                isDestructive: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
        label: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,

            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDestructive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary,
          foregroundColor: isDestructive
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
