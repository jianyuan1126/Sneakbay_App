import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../widget/custom_navigation_button.dart';
import '../../../widget/main_app_bar.dart';
import 'components/otp_verification_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController(text: user?.email ?? '');
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? user?.displayName ?? '';
        _emailController.text = user?.email ?? '';
      }
    }
  }

  Future<void> _saveProfileDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'email': _emailController.text,
      });

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile details saved successfully')),
      );
    }
  }

  Future<void> _startEdit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final phoneNumber = user.phoneNumber;
      if (phoneNumber != null) {
        final result = await showDialog(
          context: context,
          builder: (context) => OtpVerificationDialog(phoneNumber: phoneNumber),
        );

        if (result == true) {
          setState(() {
            _isEditing = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSaveButtonPressed() {
    _saveProfileDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        backgroundColor: Colors.white,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Legal Name',
                labelStyle: const TextStyle(color: Colors.black),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: !_isEditing
                    ? IconButton(
                        icon: const Icon(Icons.lock),
                        onPressed: _startEdit,
                      )
                    : null,
              ),
              readOnly: !_isEditing,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(color: Colors.black),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: !_isEditing
                    ? IconButton(
                        icon: const Icon(Icons.lock),
                        onPressed: _startEdit,
                      )
                    : null,
              ),
              readOnly: !_isEditing,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, color: Colors.black),
          CustomNavigationButton(
            buttonText: 'Save',
            onPressed: _isEditing ? _handleSaveButtonPressed : () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
