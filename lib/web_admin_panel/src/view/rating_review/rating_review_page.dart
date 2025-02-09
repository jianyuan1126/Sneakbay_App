import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingReviewPage extends StatelessWidget {
  const RatingReviewPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchRatings() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('ratings').get();

    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Ratings'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRatings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching ratings: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No ratings available'));
          }

          List<Map<String, dynamic>> ratings = snapshot.data!;

          return ListView.builder(
            itemCount: ratings.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> ratingData = ratings[index];
              return ListTile(
                leading: Icon(Icons.star, color: Colors.amber),
                title: Text('Rating: ${ratingData['rating']}'),
                subtitle:
                    Text('Comment: ${ratingData['comment'] ?? 'No comment'}'),
                trailing: Text('User ID: ${ratingData['userId']}'),
              );
            },
          );
        },
      ),
    );
  }
}
