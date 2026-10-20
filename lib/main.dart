import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme.dart';
import 'views/welcome_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const RunSenseApp());
}

class RunSenseApp extends StatelessWidget {
  const RunSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'runSense',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const WelcomeView(),
    );
  }
}