import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../widget/main_app_bar.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Terms of Use',
        showBackButton: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('content')
            .doc('terms')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Terms of Use not available.'));
          }

          final termsData = snapshot.data!;
          final termsText = termsData['text'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              termsText,
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.justify,
            ),
          );
        },
      ),
    );
  }
}
