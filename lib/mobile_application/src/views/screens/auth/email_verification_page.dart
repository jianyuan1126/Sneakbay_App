// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../models/user_model.dart';
import '../main_page.dart';

class EmailVerificationPage extends StatelessWidget {
  final UserModel userModel;

  const EmailVerificationPage({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.email,
                size: 100,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              const Text(
                'Verify your email address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'We have just sent an email verification link to your email. Please check your email and click on that link to verify your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                userModel.email,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => checkEmailVerified(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200, // Set a specific width for the Resend button
                child: ElevatedButton(
                  onPressed: () => resendVerificationEmail(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50), // Match the height of the Continue button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Resend Email Link'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);  // Go back to the login page
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, // Text color
                ),
                child: const Text('<- Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkEmailVerified(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // Reload to get the latest user info from Firebase
    if (user != null && user.emailVerified) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()), // Navigate to main page if verified
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please verify your email first."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void resendVerificationEmail(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Verification email sent again to ${user.email}"),
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send verification email: $e"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else if (user != null && user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email is already verified."),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No user logged in."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
