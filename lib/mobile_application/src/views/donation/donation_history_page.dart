import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../widget/main_app_bar.dart';
import 'donation_details.dart';

class DonationHistoryPage extends StatelessWidget {
  final String userId;

  const DonationHistoryPage({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> _fetchDonations(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('donations')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()..['id'] = doc.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Donation History',
        backgroundColor: Colors.white,
        iconThemeColor: Colors.black,
        showBackButton: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDonations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading donations'));
          }

          final donationsAvailable =
              snapshot.hasData && snapshot.data!.isNotEmpty;

          if (!donationsAvailable) {
            return const Center(child: Text('No donations found'));
          }

          final donations = snapshot.data!;
          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                      bottom: donations.last == donation
                          ? BorderSide(color: Colors.black)
                          : BorderSide.none,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                        'Donated on: ${DateFormat('yyyy-MM-dd').format(donation['timestamp'].toDate())}'),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
