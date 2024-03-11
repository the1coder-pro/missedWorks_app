import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void updateTheme(bool isDark) {
    _isDark = isDark;
    notifyListeners();
  }
}
