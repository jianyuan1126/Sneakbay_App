import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'donation_details.dart'; // Import the details page
import 'donation_history_page.dart'; // Import the donation history page

import '../../widget/main_app_bar.dart';

class DonationPage extends StatefulWidget {
  @override
  _DonationPageState createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  List<Map<String, dynamic>> _donationHistory = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = pickedFile;
    });
  }

  Future<void> _submitDonation() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (_image != null && user != null) {
      final donationData = {
        'image': _image?.path,
        'timestamp': Timestamp.now(),
        'userId': user.uid,
      };

      // Add to the user's donations subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('donations')
          .add(donationData);

      // Add to the all_donations collection
      await FirebaseFirestore.instance
          .collection('all_donations')
          .add(donationData);

      setState(() {
        _image = null;
        _fetchDonationHistory();
      });
    }
  }

  Future<void> _fetchDonationHistory() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('donations')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
      setState(() {
        _donationHistory = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDonationHistory();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Donate Sneakers',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
            left: 16.0, right: 16.0, top: 16.0, bottom: bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please only make the donation when you are at the warehouse.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Icon(Icons.camera_alt, size: 40, color: Colors.black),
                  SizedBox(height: 16),
                  Text(
                    'Click the button to take a photo of the sneaker you want to donate.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text('Take Photo'),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (_image != null) Image.file(File(_image!.path)),
            Center(
              child: ElevatedButton(
                onPressed: _submitDonation,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text('Submit Donation'),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Your Donation History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Column(
              children: _donationHistory.map((donation) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                      bottom: _donationHistory.last == donation
                          ? BorderSide(color: Colors.black)
                          : BorderSide.none,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      'Donated on: ${DateFormat('yyyy-MM-dd').format(donation['timestamp'].toDate())}',
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationDetailsPage(
                            donation: donation,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
            if (_donationHistory.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationHistoryPage(
                            userId: FirebaseAuth.instance.currentUser!.uid,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'VIEW ALL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
