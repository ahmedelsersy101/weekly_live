import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';

import 'package:weekly_dash_board/core/models/drawer_item_model.dart';

class ActiveDrawerItem extends StatelessWidget {
  const ActiveDrawerItem({super.key, required this.drawerItemModel});
  final DrawerItemModel drawerItemModel;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        drawerItemModel.image,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context).tr(drawerItemModel.title),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      trailing: Container(
        width: 3.27,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
