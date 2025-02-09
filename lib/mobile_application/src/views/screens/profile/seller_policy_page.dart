import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../widget/main_app_bar.dart';

class SellerPolicyPage extends StatelessWidget {
  const SellerPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Seller Policy',
        showBackButton: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('content')
            .doc('sellerPolicy')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Seller Policy not available.'));
          }

          final policyData = snapshot.data!;
          final policyText = policyData['text'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              policyText,
              style: TextStyle(fontSize: 16.0),
            ),
          );
        },
      ),
    );
  }
}
