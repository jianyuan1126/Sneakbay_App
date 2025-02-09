import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widget/main_app_bar.dart';

class DonationDetailsPage extends StatelessWidget {
  final Map<String, dynamic> donation;

  const DonationDetailsPage({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Donation Details',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donated on: ${DateFormat('yyyy-MM-dd').format(donation['timestamp'].toDate())}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            if (donation['image'] != null)
              Center(
                child: Image.file(File(donation['image'])),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
