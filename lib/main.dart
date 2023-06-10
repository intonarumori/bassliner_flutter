import 'dart:async';
import 'dart:io';

import 'package:bassliner/data/pattern_editor.dart';
import 'package:bassliner/editor/editor_screen.dart';
import 'package:bassliner/utilities/theme_manager.dart';
import 'package:bassliner/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }
  debugRepaintRainbowEnabled = false;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _themeManager = ThemeManager();
  late StreamSubscription<ThemeData> _themeSubscription;

  @override
  void initState() {
    super.initState();
    _themeSubscription = _themeManager.currentTheme.distinct().listen((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeSubscription.cancel();
    super.dispose();
  }

  // MARK:

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => PatternEditor(),
      child: MaterialApp(
        theme: _themeManager.currentTheme.value,
        home: AnnotatedRegion<SystemUiOverlayStyle>(
          // Use [SystemUiOverlayStyle.light] for white status bar
          // or [SystemUiOverlayStyle.dark] for black status bar
          // https://stackoverflow.com/a/58132007/1321917
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: Consumer<PatternEditor>(builder: (context, patternEditor, child) {
              return StreamBuilder(
                  stream: patternEditor.isConnected.stream,
                  builder: (context, snapshot) {
                    final connected = snapshot.data ?? false;
                    if (connected) {
                      return EditorScreen(onToggleTheme: _themeManager.advanceTheme);
                    } else {
                      return WelcomeScreen(onToggleTheme: _themeManager.advanceTheme);
                    }
                  });
            }),
          ),
        ),
      ),
    );
  }
}
