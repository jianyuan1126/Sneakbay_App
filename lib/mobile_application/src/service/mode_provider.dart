import 'package:flutter/material.dart';

class ModeProvider with ChangeNotifier {
  bool _isBuyMode = true;

  bool get isBuyMode => _isBuyMode;

  void toggleMode() {
    _isBuyMode = !_isBuyMode;
    notifyListeners();
  }
}
