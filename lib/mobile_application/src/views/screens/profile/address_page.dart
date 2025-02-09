import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../../../../models/address_model.dart';
import '../../../widget/custom_navigation_button.dart';
import '../../../widget/main_app_bar.dart';
import 'components/otp_verification_dialog.dart';

class ReturnAddressPage extends StatefulWidget {
  const ReturnAddressPage({Key? key}) : super(key: key);

  @override
  _ReturnAddressPageState createState() => _ReturnAddressPageState();
}

class _ReturnAddressPageState extends State<ReturnAddressPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _streetAddress1Controller =
      TextEditingController();
  final TextEditingController _streetAddress2Controller =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final String _countryCode = '+60';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetAddress1Controller.dispose();
    _streetAddress2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _phoneNumberController.dispose();
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
        if (userData != null) {
          _nameController.text = userData['name'] ?? '';
          _phoneNumberController.text = userData['phoneNumber'].toString();
          if (userData.containsKey('address')) {
            final address = Address.fromMap(userData['address']);
            _streetAddress1Controller.text = address.streetAddress1;
            _streetAddress2Controller.text = address.streetAddress2 ?? '';
            _cityController.text = address.city;
            _stateController.text = address.state;
            _postalCodeController.text = address.postalCode.toString();
          }
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _saveAddress() async {
    final address = Address(
      streetAddress1: _streetAddress1Controller.text,
      streetAddress2: _streetAddress2Controller.text,
      city: _cityController.text,
      state: _stateController.text,
      postalCode: int.tryParse(_postalCodeController.text) ?? 0,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'phoneNumber': int.tryParse(_phoneNumberController.text) ?? 0,
        'address': address.toMap(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully')),
      );
    }
  }

  Future<void> _startEditPhoneNumber() async {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Return Address',
        backgroundColor: Colors.white,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.lock),
                  onPressed: () {},
                ),
              ),
              style: const TextStyle(color: Colors.black),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _streetAddress1Controller,
              decoration: const InputDecoration(
                labelText: 'Address 1',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _streetAddress2Controller,
              decoration: const InputDecoration(
                labelText: 'Address 2',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () =>
                  _showSelectStateBottomSheet(context, _stateController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                labelText: 'Postal Code',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Country Code',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                      filled: true,
                    ),
                    controller: TextEditingController(text: _countryCode),
                    readOnly: true,
                    enabled: false,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.lock),
                        onPressed: _startEditPhoneNumber,
                      ),
                    ),
                    readOnly: !_isEditing,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
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
            onPressed: _saveAddress,
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  final List<String> states = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Perak',
    'Perlis',
    'Pulau Pinang',
    'Sabah',
    'Sarawak'
  ];

  void _showSelectStateBottomSheet(
      BuildContext context, TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 400,
          child: ListView.builder(
            itemCount: states.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(states[index]),
                onTap: () {
                  controller.text = states[index];
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
