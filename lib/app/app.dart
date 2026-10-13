import 'package:flutter/material.dart';
import 'package:baby_helper_ai/core/theme/theme.dart';
import 'package:baby_helper_ai/core/constants/app_strings.dart';
import 'package:baby_helper_ai/app/routes/app_router.dart';

class BabyHelperApp extends StatelessWidget {
  const BabyHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = createRouter();

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
