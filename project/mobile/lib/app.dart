import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ytu_assistant/core/constants/app_constants.dart';
import 'package:ytu_assistant/core/router/app_router.dart';
import 'package:ytu_assistant/core/theme/app_theme.dart';
import 'package:ytu_assistant/l10n/app_localizations.dart';

/// Root widget: wires the router, the Material 3 theme and localization.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appFullName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: const Locale('tr'),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
    );
  }
}
