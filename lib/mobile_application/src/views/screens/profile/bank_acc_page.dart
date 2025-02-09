import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../../widget/custom_navigation_button.dart';
import '../../../widget/main_app_bar.dart';
import 'components/otp_verification_dialog.dart'; // Ensure this path is correct

class BankAccPage extends StatefulWidget {
  const BankAccPage({Key? key}) : super(key: key);

  @override
  _BankAccPageState createState() => _BankAccPageState();
}

class _BankAccPageState extends State<BankAccPage> {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('bankAccountDetails')) {
          final bankDetails = userData['bankAccountDetails'] as Map<String, dynamic>;
          _bankNameController.text = bankDetails['bankName'] ?? '';
          _accountNumberController.text = bankDetails['accountNumber'] ?? '';
          _accountHolderNameController.text = bankDetails['accountHolderName'] ?? '';
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _saveBankDetails() async {
    final bankDetails = {
      'bankName': _bankNameController.text,
      'accountNumber': _accountNumberController.text,
      'accountHolderName': _accountHolderNameController.text,
    };

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'bankAccountDetails': bankDetails,
      });

      // Pop with a result to indicate bank details have been updated
      Navigator.pop(context, true);
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

  void _handleSaveButtonPressed() {
    _saveBankDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Bank Account Details',
        backgroundColor: Colors.white,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _bankNameController,
              decoration: InputDecoration(
                labelText: 'Bank Name',
                border: const OutlineInputBorder(),
                suffixIcon: !_isEditing
                    ? IconButton(
                        icon: const Icon(Icons.lock),
                        onPressed: _startEdit,
                      )
                    : null,
              ),
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _accountNumberController,
              decoration: InputDecoration(
                labelText: 'Account Number',
                border: const OutlineInputBorder(),
                suffixIcon: !_isEditing
                    ? IconButton(
                        icon: const Icon(Icons.lock),
                        onPressed: _startEdit,
                      )
                    : null,
              ),
              readOnly: !_isEditing,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _accountHolderNameController,
              decoration: InputDecoration(
                labelText: 'Account Holder Name',
                border: const OutlineInputBorder(),
                suffixIcon: !_isEditing
                    ? IconButton(
                        icon: const Icon(Icons.lock),
                        onPressed: _startEdit,
                      )
                    : null,
              ),
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(color: Colors.black),
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
