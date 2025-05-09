import 'package:flutter/material.dart';
import 'package:wallgram/themes/dark_mode.dart';
import 'package:wallgram/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;

  void toggleTheme() {
    if (_themeData == lightMode) {
      _themeData = darkMode;
    } else {
      _themeData = lightMode;
    }
    notifyListeners();
  }

  set themeData(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
}
