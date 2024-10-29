import 'package:flutter/material.dart';
import 'package:geminichatbotapp/themes/my_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;
  Color get buttonColor => _isDarkMode ? Colors.blue : Colors.grey;
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
