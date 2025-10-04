import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:weekly_dash_board/core/constants/app_color.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/view_model/settings_cubit.dart';
import 'package:weekly_dash_board/fetuers/splash/presentation/views/splash_view.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart' as settings;
import 'package:weekly_dash_board/core/services/notification_service.dart';
import 'package:weekly_dash_board/core/services/notification_production_helper.dart';
import 'package:weekly_dash_board/core/services/scheduled_notification_service.dart';
import 'package:weekly_dash_board/fetuers/home/data/services/hive_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:weekly_dash_board/core/widgets/permission_requester.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      options.tracesSampleRate = 0.2;
      options.enableAutoPerformanceTracing = true;
      options.sendDefaultPii = false;
    },
    appRunner: () async {
      try {
        await Supabase.initialize(
          url: 'https://okddqskxlureguahozhh.supabase.co',
          anonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9rZGRxc2t4bHVyZWd1YWhvemhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5NDg0NzMsImV4cCI6MjA3NDUyNDQ3M30.iZ1mLgEiwUpPR1M_ryqkBJcb59PLtCYo_HSwFK7Pc8k',
        );

        await SupabaseAuthService.initializeAuthState();
        await HiveService.init();
        await NotificationService.initialize();

        // Initialize scheduled notifications
        try {
          await ScheduledNotificationService.initializeScheduledNotifications();
        } catch (e, st) {
          // Log but do not crash
          // ignore: avoid_print
          print('Scheduled notifications initialization failed: $e');
          await Sentry.captureException(e, stackTrace: st);
        }

        try {
          await NotificationProductionHelper.initializeProductionMode();
        } catch (e, st) {
          // Log but do not crash
          // ignore: avoid_print
          print('Production notification helper initialization failed: $e');
          await Sentry.captureException(e, stackTrace: st);
        }
      } catch (e, st) {
        await Sentry.captureException(e, stackTrace: st);
      }

      runApp(DevicePreview(enabled: true, builder: (context) => const ResponsiveDashboardApp()));
    },
  );
}

class ResponsiveDashboardApp extends StatelessWidget {
  const ResponsiveDashboardApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WeeklyCubit()),
        BlocProvider(create: (_) => SettingsCubit()..loadSettings()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final s = state.settings;
          final locale = _mapLocale(s?.language);
          final primaryColor = s?.primaryColor ?? AppColors.primary;

          // Refresh scheduled notifications when settings are loaded
          if (s != null && !state.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<SettingsCubit>().refreshScheduledNotifications();
            });
          }

          final lightTheme = AppTheme.lightTheme.copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ),
          );

          final darkTheme = AppTheme.darkTheme.copyWith(
            colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
              primary: primaryColor,
              primaryContainer: primaryColor.withOpacity(0.8),
            ),
          );

          // Convert custom ThemeMode to Flutter's ThemeMode
          ThemeMode flutterThemeMode;
          switch (s?.themeMode) {
            case settings.ThemeMode.light:
              flutterThemeMode = ThemeMode.light;
              break;
            case settings.ThemeMode.dark:
              flutterThemeMode = ThemeMode.dark;
              break;
            case settings.ThemeMode.system:
            default:
              flutterThemeMode = ThemeMode.system;
              break;
          }

          return MaterialApp(
            builder: (context, child) =>
                PermissionRequester(child: child ?? const SizedBox.shrink()),
            home: const SplashView(),
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: flutterThemeMode,
            locale: locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('ar', '')],
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              final code = (locale != null
                  ? locale.languageCode
                  : (deviceLocale != null ? deviceLocale.languageCode : 'en'));
              return supportedLocales.firstWhere(
                (l) => l.languageCode == code,
                orElse: () => const Locale('en', ''),
              );
            },
          );
        },
      ),
    );
  }

  Locale _mapLocale(dynamic language) {
    if (language == null) return const Locale('en', '');
    final str = language.toString();
    if (str.contains('arabic')) return const Locale('ar', '');
    return const Locale('en', '');
  }
}
