import 'package:flutter_test/flutter_test.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';

void main() {
  group('WeeklyCubit multi-day tasks', () {
    test('addTaskToDays creates tasks for all selected days including creation day', () async {
      final cubit = WeeklyCubit();

      // Create across three days: 0 (Sat), 1 (Sun), 5 (Thu)
      await cubit.addTaskToDays(
        'Test Multi',
        {0, 1, 5},
        isImportant: true,
        reminderTime: null, // avoid notifications in tests
        categoryId: 'other',
      );

      final tasksDay0 = cubit.getTasksForDay(0);
      final tasksDay1 = cubit.getTasksForDay(1);
      final tasksDay5 = cubit.getTasksForDay(5);

      expect(tasksDay0.where((t) => t.title == 'Test Multi').length, 1);
      expect(tasksDay1.where((t) => t.title == 'Test Multi').length, 1);
      expect(tasksDay5.where((t) => t.title == 'Test Multi').length, 1);
    });

    test('updateTaskAcrossDays adds new days and removes deselected days', () async {
      final cubit = WeeklyCubit();

      // Start with days 0 and 1
      await cubit.addTaskToDays('Series', {0, 1}, reminderTime: null);

      final initial0 = cubit.getTasksForDay(0).firstWhere((t) => t.title == 'Series');

      // Update to include day 5 as well
      await cubit.updateTaskAcrossDays(
        initial0.id,
        {0, 1, 5},
        newTitle: 'Series',
        reminderTime: null,
      );

      expect(cubit.getTasksForDay(0).where((t) => t.title == 'Series').length, 1);
      expect(cubit.getTasksForDay(1).where((t) => t.title == 'Series').length, 1);
      expect(cubit.getTasksForDay(5).where((t) => t.title == 'Series').length, 1);

      // Now remove day 0
      await cubit.updateTaskAcrossDays(initial0.id, {1, 5}, newTitle: 'Series', reminderTime: null);

      expect(cubit.getTasksForDay(0).where((t) => t.title == 'Series').isEmpty, true);
      expect(cubit.getTasksForDay(1).where((t) => t.title == 'Series').length, 1);
      expect(cubit.getTasksForDay(5).where((t) => t.title == 'Series').length, 1);
    });

    test('updateTaskAcrossDays is idempotent (no duplicates on repeated saves)', () async {
      final cubit = WeeklyCubit();

      await cubit.addTaskToDays('Idem', {0, 1}, reminderTime: null);
      final seed = cubit.getTasksForDay(0).firstWhere((t) => t.title == 'Idem');

      // Apply same target twice
      await cubit.updateTaskAcrossDays(seed.id, {0, 1}, newTitle: 'Idem', reminderTime: null);
      await cubit.updateTaskAcrossDays(seed.id, {0, 1}, newTitle: 'Idem', reminderTime: null);

      expect(cubit.getTasksForDay(0).where((t) => t.title == 'Idem').length, 1);
      expect(cubit.getTasksForDay(1).where((t) => t.title == 'Idem').length, 1);
    });
  });
}
