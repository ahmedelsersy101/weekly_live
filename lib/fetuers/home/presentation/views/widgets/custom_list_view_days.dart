import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/custom_card_home_view.dart';

class CustomListViewDays extends StatelessWidget {
  final Map<int, GlobalKey> dayKeys;
  const CustomListViewDays({super.key, this.dayKeys = const <int, GlobalKey>{}});

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemBuilder: (context, index) {
        final key = dayKeys[index] ?? ValueKey('day_$index');
        return Container(
          key: key,
          child: CustomCardHomeView(dayIndex: index),
        );
      },
      itemCount: 7, // Saturday to Thursday (6 days), Friday is day off
    );
  }
}

class CustomGridViewDays extends StatelessWidget {
  final Map<int, GlobalKey> dayKeys;

  const CustomGridViewDays({super.key, this.dayKeys = const <int, GlobalKey>{}});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: MasonryGridView.count(
        crossAxisCount: 2, // عدد الأعمدة (موبايل 2 - ديسكتوب 3 أو 4)
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 7,
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(), // مهم عشان scroll كله يبقى مع الـ CustomScrollView
        itemBuilder: (context, index) {
          final key = dayKeys[index] ?? ValueKey('day_$index');
          return Container(
            key: key,
            child: CustomCardHomeView(dayIndex: index),
          );
        },
      ),
    );
  }
}
