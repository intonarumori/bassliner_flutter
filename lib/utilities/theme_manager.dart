import 'package:bassliner/views/theme.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const preferencesThemeSelectedIndexKey = 'theme_selected_index';

  static const colors = [
    Colors.red,
    Color(0xFF010101),
    Color(0xFF9395CE),
    Colors.orange,
    Colors.cyan,
    Colors.pink,
    Colors.blue,
    Colors.green,
  ];

  final currentTheme = BehaviorSubject<ThemeData>.seeded(_generateTheme(colors[0]));
  int _currentThemeIndex = 0;

  SharedPreferences? _preferences;

  ThemeManager() {
    _loadPreferences();
  }

  void _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
    final value = preferences.getInt(preferencesThemeSelectedIndexKey) ?? 0;
    _currentThemeIndex = value % colors.length;
    _refreshTheme();
  }

  void advanceTheme() {
    _currentThemeIndex = (_currentThemeIndex + 1) % colors.length;
    _refreshTheme();
  }

  void _refreshTheme() {
    _preferences?.setInt(preferencesThemeSelectedIndexKey, _currentThemeIndex);
    currentTheme.add(_generateTheme(colors[_currentThemeIndex]));
  }

  static ThemeData _generateTheme(Color color) {
    final basslinerTheme = BasslinerTheme.generateTheme(color);
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: color,
      onPrimary: basslinerTheme.selectionColor,
      secondary: color,
      onSecondary: basslinerTheme.selectionColor,
      error: Colors.red,
      onError: Colors.white,
      background: basslinerTheme.backgroundColor,
      onBackground: basslinerTheme.selectionColor,
      surface: basslinerTheme.disabledBlackKeyColor,
      onSurface: basslinerTheme.whiteKeyColor,
    );
    final theme = ThemeData.from(colorScheme: colorScheme)..basslinerTheme = basslinerTheme;
    return theme;
  }
}
