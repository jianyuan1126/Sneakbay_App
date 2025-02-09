import 'package:flutter/material.dart';
import '../../../widget/main_app_bar.dart';
import 'login_page.dart';

class BannedUserPage extends StatelessWidget {
  const BannedUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Account Banned',
        showBackButton: false,
        iconThemeColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Sorry, your account has been banned due to the points dropping below or equal to 0.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
