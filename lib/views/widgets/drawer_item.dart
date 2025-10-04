import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/models/drawer_item_model.dart';
import 'package:weekly_dash_board/views/widgets/active_drawer_item.dart';
import 'package:weekly_dash_board/views/widgets/in_active_drawer_item.dart';

class DrawerItem extends StatefulWidget {
  const DrawerItem({
    super.key,
    required this.drawerItemModel,
    required this.isSelected,
  });
  final DrawerItemModel drawerItemModel;
  final bool isSelected;

  @override
  State<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends State<DrawerItem> {
  bool _isVisible = false;

  @override
  void initState() {
    _isVisible = widget.isSelected;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DrawerItem oldWidget) {
    if (widget.isSelected != oldWidget.isSelected) {
      setState(() {
        _isVisible = widget.isSelected;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 600),
      firstChild: inActiveDrawerItem(drawerItemModel: widget.drawerItemModel),
      secondChild: ActiveDrawerItem(drawerItemModel: widget.drawerItemModel),
      crossFadeState: _isVisible
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
    );
  }
}
