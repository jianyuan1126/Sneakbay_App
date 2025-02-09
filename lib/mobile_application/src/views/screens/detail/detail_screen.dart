import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../models/shoe_model.dart';
import 'components/body.dart';

class DetailScreen extends StatelessWidget {
  final String shoeId; 
  final bool isComeFromMoreSection;

  const DetailScreen({
    super.key,
    required this.shoeId,
    required this.isComeFromMoreSection,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('shoes')
              .doc(shoeId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No data found.'));
            }

            final shoe = ShoeModel.fromFirestore(
                snapshot.data!.data() as Map<String, dynamic>,
                snapshot.data!.id);

            return DetailsBody(
              model: shoe,
              isComeFromMoreSection: isComeFromMoreSection,
            );
          },
        ),
      ),
    );
  }
}