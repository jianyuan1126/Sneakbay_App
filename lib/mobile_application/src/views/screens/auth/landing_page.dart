import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import '../main_page.dart';
import 'login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds to simulate loading time
    Future.delayed(const Duration(seconds: 5), checkUserStatus);
  }

  void checkUserStatus() {
    FirebaseAuth.instance.authStateChanges().first.then((User? user) {
      if (user != null && user.emailVerified) {
        // If the user is logged in and email is verified, navigate to the MainScreen
        Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const MainScreen(), // Assuming you have a MainScreen
              duration: const Duration(milliseconds: 200),
            ));
      } else {
        // If no user is logged in, navigate to the LoginPage
        Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: const LoginPage(),
              duration: const Duration(milliseconds: 200),
            ));
      }
    }).catchError((error) {
      // Handle errors or default to LoginPage if something goes wrong
      Navigator.pushReplacement(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: const LoginPage(),
            duration: const Duration(milliseconds: 200),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/icons/SneakBay_Logo.png', // Your app logo here
              width: 200,
              height: 200,
            ),
          ],
        ),
      ),
    );
  }
}
