// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';

import 'package:weekly_dash_board/core/models/drawer_item_model.dart';

class inActiveDrawerItem extends StatelessWidget {
  const inActiveDrawerItem({super.key, required this.drawerItemModel});
  final DrawerItemModel drawerItemModel;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        drawerItemModel.image,
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context).tr(drawerItemModel.title),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
