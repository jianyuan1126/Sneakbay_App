import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/creditcard_model.dart';
import 'package:flutter_application_1/mobile_application/src/widget/custom_navigation_button.dart';
import '../../../widget/main_app_bar.dart';
import 'components/otp_verification_dialog.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({Key? key}) : super(key: key);

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchCardDetails();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _fetchCardDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('cardDetails')) {
          final cardDetails = CreditCard.fromMap(userData['cardDetails']);
          _cardNumberController.text =
              '************${cardDetails.cardNumber.substring(cardDetails.cardNumber.length - 4)}';
          _expiryMonthController.text = cardDetails.expiryMonth;
          _expiryYearController.text = cardDetails.expiryYear;
          _cvvController.text = '***';
          setState(() {
            _isEditing = false;
          });
        } else {
          setState(() {
            _isEditing = true;
          });
        }
      } catch (e) {
        print("Error fetching card details: $e");
        setState(() {
          _isEditing = true;
        });
      }
    }
  }

  Future<void> _saveCardDetails() async {
    final cardDetails = CreditCard(
      cardNumber: _cardNumberController.text.replaceAll('*', ''),
      expiryMonth: _expiryMonthController.text,
      expiryYear: _expiryYearController.text,
      cvv: _cvvController.text,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'cardDetails': cardDetails.toMap(),
      });

      setState(() {
        _isEditing = false;
        _cardNumberController.text =
            '************${cardDetails.cardNumber.substring(cardDetails.cardNumber.length - 4)}';
        _cvvController.text = '***';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card details saved successfully')),
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
            _cardNumberController.text =
                _cardNumberController.text.replaceAll('*', '');
          });
        }
      }
    }
  }

  void _handleSaveButtonPressed() {
    _saveCardDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payment Method',
        backgroundColor: Colors.white,
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
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
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              obscureText: false,
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _expiryMonthController,
              decoration: InputDecoration(
                labelText: 'Expiry Month (MM)',
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
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _expiryYearController,
              decoration: InputDecoration(
                labelText: 'Expiry Year (YY)',
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
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              readOnly: !_isEditing,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cvvController,
              decoration: InputDecoration(
                labelText: 'CVV',
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
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              obscureText: true,
              readOnly: !_isEditing,
            ),
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
