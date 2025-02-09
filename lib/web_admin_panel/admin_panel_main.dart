// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

import 'src/view/admin_panel/admin_panel_page.dart';

void main() {
  runApp(const AdminDashboard());
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        hintColor: Colors.greenAccent,
        typography: Typography.material2018(platform: TargetPlatform.iOS),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}