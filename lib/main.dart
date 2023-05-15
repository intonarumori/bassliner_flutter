import 'package:bassliner/data/pattern_editor.dart';
import 'package:bassliner/editor/editor_screen.dart';
import 'package:bassliner/views/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
  final colors = [
    Colors.red,
    const Color(0xFF010101),
    Colors.orange,
    Colors.brown,
    Colors.blue,
    Colors.green
  ];
  int _currentTheme = 0;

  ThemeData theme = ThemeData.dark();

  @override
  void initState() {
    _toggleTheme();
    super.initState();
  }

  void _toggleTheme() {
    _currentTheme = (_currentTheme + 1) % colors.length;
    final color = colors[_currentTheme];

    final basslinerTheme = BasslinerTheme.generateTheme(color);
    theme = ThemeData.light()..basslinerTheme = basslinerTheme;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatternEditor(),
      child: MaterialApp(
        theme: theme,
        home: Scaffold(
          body: EditorScreen(onToggleTheme: _toggleTheme),
        ),
      ),
    );
  }
}