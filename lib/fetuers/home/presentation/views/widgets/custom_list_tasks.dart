import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/task_model.dart' hide TaskPriority;
import 'package:weekly_dash_board/fetuers/home/data/models/category_model.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/enhanced_task_item.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/task_dialog.dart';

class CustomListTasks extends StatefulWidget {
  final int dayIndex;

  const CustomListTasks({super.key, required this.dayIndex});

  @override
  State<CustomListTasks> createState() => _CustomListTasksState();
}

class _CustomListTasksState extends State<CustomListTasks> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyCubit, WeeklyState>(
      builder: (context, state) {
        if (state is WeeklySuccess) {
          final tasks = context.read<WeeklyCubit>().getTasksForDay(widget.dayIndex);
          if (tasks.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context).tr('more.no_tasks_for_this_day'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          final tasksByCategory = <String, List<TaskModel>>{};
          for (final task in tasks) {
            if (!tasksByCategory.containsKey(task.categoryId)) {
              tasksByCategory[task.categoryId] = [];
            }
            tasksByCategory[task.categoryId]!.add(task);
          }

          final sortedCategories = tasksByCategory.keys.toList()
            ..sort((a, b) => getCategoryPriority(a).index.compareTo(getCategoryPriority(b).index));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...sortedCategories.map((categoryId) {
                final categoryTasks = tasksByCategory[categoryId]!;
                final category = TaskCategoryModel.getDefaultCategories().firstWhere(
                  (cat) => cat.id == categoryId,
                  orElse: () => TaskCategoryModel.getDefaultCategories().last,
                );
                final importantTasks = categoryTasks.where((t) => t.isImportant).toList();
                final regularTasks = categoryTasks.where((t) => !t.isImportant).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: category.color.withOpacity(0.3)),
                            ),
                            child: Icon(
                              IconData(category.iconCodePoint, fontFamily: category.iconFontFamily),
                              color: category.color,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.nameAr,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${categoryTasks.length}',
                              style: TextStyle(
                                color: category.color,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (importantTasks.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context).tr('settings.Important'),

                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...importantTasks.map(
                        (task) => EnhancedTaskItem(
                          task: task,
                          onEdit: () => _showEditTaskDialog(context, task),
                          onDelete: () => _deleteTask(context, task),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (regularTasks.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.list,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context).tr('settings.AsRegular'),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...regularTasks.map(
                        (task) => EnhancedTaskItem(
                          task: task,
                          onEdit: () => _showEditTaskDialog(context, task),
                          onDelete: () => _deleteTask(context, task),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
void _showEditTaskDialog(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TaskDialogWidget(
          task: task,
          onConfirm:
              ({
                required title,
                required days,
                required isImportant,
                required reminderTime,
                required categoryId,
              }) {
                context.read<WeeklyCubit>().updateTaskAcrossDays(
                  task.id,
                  days,
                  newTitle: title,
                  isImportant: isImportant,
                  reminderTime: reminderTime,
                  categoryId: categoryId,
                );
              },
        );
      },
    );
  }

  OutlineInputBorder customOutlineInputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );
  }

  void _deleteTask(BuildContext context, TaskModel task) {
    context.read<WeeklyCubit>().deleteTask(task.id);
  }
}

List<int> _orderedOtherDays(int currentDay) {
  return List<int>.generate(6, (i) => (currentDay + 1 + i) % 7);
}

String _localizedDayLabel(BuildContext context, int dayIndex) {
  const keys = ['saturday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
  if (dayIndex < 0 || dayIndex >= keys.length) return '';
  return AppLocalizations.of(context).tr(keys[dayIndex]);
}
