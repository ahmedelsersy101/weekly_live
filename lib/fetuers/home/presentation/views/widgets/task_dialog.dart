import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/utils/app_style.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/category_model.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/task_model.dart';

class TaskDialogWidget extends StatefulWidget {
  final TaskModel? task; // null في حالة الإضافة
  final int? dayIndex; // مستخدم للإضافة فقط
  final void Function({
    required String title,
    required Set<int> days,
    required bool isImportant,
    required TimeOfDay? reminderTime,
    required String categoryId,
  })
  onConfirm;

  const TaskDialogWidget({super.key, this.task, this.dayIndex, required this.onConfirm});

  @override
  State<TaskDialogWidget> createState() => _TaskDialogWidgetState();
}

class _TaskDialogWidgetState extends State<TaskDialogWidget> {
  late TextEditingController titleController;
  late bool isImportant;
  TimeOfDay? reminderTime;
  late TaskCategoryModel selectedCategory;
  late List<TaskCategoryModel> categories;
  late Set<int> selectedDays;

  @override
  void initState() {
    super.initState();

    categories = TaskCategoryModel.getDefaultCategories();

    if (widget.task != null) {
      // حالة Edit
      titleController = TextEditingController(text: widget.task!.title);
      isImportant = widget.task!.isImportant;
      reminderTime = widget.task!.reminderTime;
      selectedCategory = categories.firstWhere(
        (c) => c.id == widget.task!.categoryId,
        orElse: () => categories.first,
      );
      selectedDays = {};
    } else {
      // حالة Add
      titleController = TextEditingController();
      isImportant = false;
      reminderTime = null;
      selectedCategory = categories.first;
      selectedDays = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;
    final baseDay = isEdit ? widget.task!.dayOfWeek : widget.dayIndex!;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// العنوان الرئيسي
            Text(
              isEdit
                  ? AppLocalizations.of(context).tr('settings.editTask')
                  : AppLocalizations.of(context).tr('settings.addNewTask'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),

            /// إدخال العنوان
            TextField(
              controller: titleController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              cursorColor: Theme.of(context).colorScheme.primary,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).tr('settings.enterTaskTitle'),
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                border: customOutlineInputBorder(context),
                enabledBorder: customOutlineInputBorder(context),
                focusedBorder: customOutlineInputBorder(context),
              ),
            ),
            const SizedBox(height: 12),

            /// اختيار أيام أخرى
            Text(
              AppLocalizations.of(context).tr('settings.selectOtherDays'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _orderedOtherDays(baseDay).map((d) {
                final isSelected = selectedDays.contains(d);
                return FilterChip(
                  label: Text(_localizedDayLabel(context, d)),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selectedDays.add(d);
                      } else {
                        selectedDays.remove(d);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            /// عرض الأيام المختارة
            Builder(
              builder: (context) {
                final combinedDays = <int>{baseDay, ...selectedDays};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).tr('settings.selectedDays'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: combinedDays
                          .map((d) => Chip(label: Text(_localizedDayLabel(context, d))))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),

            /// Checkbox المهمة المهمة
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CheckboxListTile(
                value: isImportant,
                onChanged: (value) {
                  setState(() => isImportant = value ?? false);
                },
                title: Text(
                  AppLocalizations.of(context).tr('settings.markAsImportant'),
                  style: AppStyles.styleSemiBold20(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
                activeColor: Theme.of(context).colorScheme.onPrimary,
                checkColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
            const SizedBox(height: 12),

            /// Dropdown الكاتيجوري
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              child: DropdownButton<TaskCategoryModel>(
                value: selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                items: categories.map((category) {
                  return DropdownMenuItem<TaskCategoryModel>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(
                          IconData(category.iconCodePoint, fontFamily: category.iconFontFamily),
                          color: category.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? category.nameAr
                              : category.name,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            /// وقت التذكير
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context).tr('settings.reminderTime'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.access_time,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () async {
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (selectedTime != null) {
                              setState(() => reminderTime = selectedTime);
                            }
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32, top: 4),
                      child: Text(
                        reminderTime != null
                            ? '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
                            : AppLocalizations.of(context).tr('settings.noReminder'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// الأزرار
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context).tr('settings.cancel'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      final days = <int>{baseDay, ...selectedDays};
                      widget.onConfirm(
                        title: titleController.text.trim(),
                        days: days,
                        isImportant: isImportant,
                        reminderTime: reminderTime,
                        categoryId: selectedCategory.id,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(
                    isEdit
                        ? AppLocalizations.of(context).tr('settings.save')
                        : AppLocalizations.of(context).tr('settings.add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder customOutlineInputBorder(BuildContext context) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }
}

/// ميثود لترتيب الأيام حسب اللوجيك بتاعك
List<int> _orderedOtherDays(int baseDay) {
  return List.generate(7, (i) => i).where((d) => d != baseDay).toList();
}

/// ميثود لترجمة الأيام
String _localizedDayLabel(BuildContext context, int day) {
  // عدلها حسب ترجمتك
  const daysEn = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  const daysAr = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  return Localizations.localeOf(context).languageCode == 'ar' ? daysAr[day] : daysEn[day];
}
