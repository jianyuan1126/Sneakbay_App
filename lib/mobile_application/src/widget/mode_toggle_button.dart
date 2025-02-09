import 'package:flutter/material.dart';
import 'package:flutter_application_1/mobile_application/src/service/mode_provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

class ModeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final modeProvider = Provider.of<ModeProvider>(context);

    return FlutterSwitch(
      width: 80.0,
      height: 40.0,
      valueFontSize: 16.0,
      toggleSize: 25.0,
      value: modeProvider.isBuyMode,
      borderRadius: 30.0,
      padding: 8.0,
      showOnOff: true,
      activeColor: Colors.indigo,
      inactiveColor: Colors.red,
      activeText: "Buy",
      inactiveText: "Sell",
      onToggle: (val) {
        modeProvider.toggleMode();
      },
    );
  }
}
