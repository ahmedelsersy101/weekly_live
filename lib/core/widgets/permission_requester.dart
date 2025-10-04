import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/services/permission_service.dart';
import 'package:weekly_dash_board/core/widgets/permission_dialog.dart';

class PermissionRequester extends StatefulWidget {
  final Widget child;
  const PermissionRequester({super.key, required this.child});

  @override
  State<PermissionRequester> createState() => _PermissionRequesterState();
}

class _PermissionRequesterState extends State<PermissionRequester> {
  final PermissionService _permissionService = PermissionService();
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _checked) return;
      _checked = true;
      final status = await _permissionService.ensureAllPermissions();
      if (!status.isReadyForReminders && mounted) {
        // ignore: use_build_context_synchronously
        await showDialog(
          context: context,
          builder: (_) => PermissionDialog(permissionService: _permissionService),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
