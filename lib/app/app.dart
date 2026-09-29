import 'package:flutter/material.dart';

import 'package:flowstate/core/app_constants.dart';

class FlowStateApp extends StatelessWidget {
  const FlowStateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: AppConstants.appName, home: const Scaffold());
  }
}
