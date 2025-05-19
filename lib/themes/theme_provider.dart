import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

class ThemeProvider with ChangeNotifier {
  static const String _prefKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.system;
  final ThemeData _lightTheme = lightMode;
  final ThemeData _darkTheme = darkMode;

  ThemeMode get themeMode => _themeMode;
  ThemeData get currentTheme => _themeMode == ThemeMode.light 
      ? _lightTheme 
      : _themeMode == ThemeMode.dark 
          ? _darkTheme 
          : _getSystemTheme();

  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData _getSystemTheme() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    return brightness == Brightness.dark ? _darkTheme : _lightTheme;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString(_prefKey);
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.toString() == savedTheme,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.toString());
  }
}