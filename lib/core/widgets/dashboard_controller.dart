import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/widgets/drawer_page.dart';

class DashboardController extends ChangeNotifier {
  DrawerPage _currentPage = DrawerPage.weekly;

  DrawerPage get currentPage => _currentPage;

  void changePage(DrawerPage page) {
    if (_currentPage != page) {
      _currentPage = page;
      notifyListeners();
    }
  }

  String getPageTitle(BuildContext context) {
    switch (_currentPage) {
      case DrawerPage.weekly:
        return 'Weekly Dashboard'; // أو AppLocalizations.of(context).tr('app.title')
      case DrawerPage.search:
        return 'Search'; // أو AppLocalizations.of(context).tr('common.Search')
      case DrawerPage.stats:
        return 'Statistics'; // أو AppLocalizations.of(context).tr('app.stats')
      case DrawerPage.more:
        return 'More Options'; // أو AppLocalizations.of(context).tr('app.more')
      case DrawerPage.settings:
        return 'Settings'; // أو AppLocalizations.of(context).tr('app.settings')
    }
  }
}
