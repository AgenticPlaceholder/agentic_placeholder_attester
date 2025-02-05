import 'package:flutter/material.dart';
import 'package:reown_appkit/reown_appkit.dart';

import '../pages/home_page.dart';
import '../utils/string_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppWithTheme();
  }
}

class AppWithTheme extends StatefulWidget {
  const AppWithTheme({Key? key}) : super(key: key);

  @override
  State<AppWithTheme> createState() => _AppWithThemeState();
}

class _AppWithThemeState extends State<AppWithTheme>
    with WidgetsBindingObserver {
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final platformBrightness = MediaQuery.of(context).platformBrightness;
      setState(() {
        _isDarkMode = platformBrightness == Brightness.dark;
      });
    });
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      final platformBrightness = MediaQuery.of(context).platformBrightness;
      _isDarkMode = platformBrightness == Brightness.dark;
    });
    super.didChangePlatformBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReownAppKitModalTheme(
      isDarkMode: _isDarkMode,
      child: MaterialApp(
        title: StringConstants.appTitle,
        home: const HomePage(),
      ),
    );
  }
}
