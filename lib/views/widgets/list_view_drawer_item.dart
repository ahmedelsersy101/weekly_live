import 'package:flutter/material.dart';

import 'package:weekly_dash_board/core/models/drawer_item_model.dart';
import 'package:weekly_dash_board/core/theme/app_images.dart';
import 'package:weekly_dash_board/core/widgets/drawer_page.dart';
import 'package:weekly_dash_board/core/utils/size_config.dart';
import 'package:weekly_dash_board/views/widgets/drawer_item.dart';

class ListViewDrawerItem extends StatefulWidget {
  final Function(int index, DrawerPage page)? onItemSelected;

  const ListViewDrawerItem({super.key, this.onItemSelected});

  @override
  State<ListViewDrawerItem> createState() => _ListViewDrawerItemState();
}

class _ListViewDrawerItemState extends State<ListViewDrawerItem> {
  int selectedIndex = 0;

  final List<DrawerItemModel> drawerItems = [
    const DrawerItemModel(
      title: 'navigation.weekly',
      image: Assets.imagescalendar,
    ),
    const DrawerItemModel(
      title: 'common.Search',
      image: Assets.imagescalendarSearch,
    ),
    const DrawerItemModel(title: 'app.stats', image: Assets.imagesStatistics),
    const DrawerItemModel(title: 'app.more', image: Assets.imagesmore),
    const DrawerItemModel(title: 'app.settings', image: Assets.imagesSettings),
  ];

  final List<DrawerPage> drawerPages = [
    DrawerPage.weekly,
    DrawerPage.search,
    DrawerPage.stats,
    DrawerPage.more,
    DrawerPage.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredItems = <DrawerItemModel>[];
    final filteredPages = <DrawerPage>[];

    for (int i = 0; i < drawerItems.length; i++) {
      if (screenWidth >= SizeConfig.desktop &&
          drawerItems[i].title == 'app.stats') {
        continue; // متعرضش Stats في الديسكتوب
      }
      filteredItems.add(drawerItems[i]);
      filteredPages.add(drawerPages[i]);
    }

    return SliverList.builder(
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (selectedIndex != index) {
              setState(() {
                selectedIndex = index;
              });
              widget.onItemSelected?.call(index, filteredPages[index]);
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: DrawerItem(
              drawerItemModel: filteredItems[index],
              isSelected: selectedIndex == index,
            ),
          ),
        );
      },
    );
  }

  void updateSelectedIndex(int index) {
    if (mounted) {
      setState(() {
        selectedIndex = index;
      });
    }
  }
}
