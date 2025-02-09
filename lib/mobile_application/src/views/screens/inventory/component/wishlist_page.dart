import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../widget/main_app_bar.dart';
import '../../detail/detail_screen.dart'; // Import the DetailScreen

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Wishlist',
          iconThemeColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
            child: Text('You need to be logged in to view your wishlist.')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Wishlist',
        iconThemeColor: Theme.of(context).primaryColor,
        showBackButton: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items in your wishlist.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return WishlistItem(
                documentId: document.id,
                name: document['name'],
                imageUrl: document['imgAddress'],
                onRemove: () {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('wishlist')
                      .doc(document.id)
                      .delete();
                },
              );
            }).toList(),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

class WishlistItem extends StatelessWidget {
  final String documentId;
  final String name;
  final String imageUrl;
  final VoidCallback onRemove;

  const WishlistItem({
    Key? key,
    required this.documentId,
    required this.name,
    required this.imageUrl,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              shoeId: documentId,
              isComeFromMoreSection: false,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Colors.black, width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
