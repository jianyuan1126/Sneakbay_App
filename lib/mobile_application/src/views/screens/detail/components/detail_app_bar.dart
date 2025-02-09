import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/shoe_model.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String shoeId;
  final TabController tabController;

  const DetailAppBar({
    Key? key,
    required this.shoeId,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      centerTitle: true,
      actions: [
        if (user != null)
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('wishlist')
                .doc(shoeId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              bool isFavorite = snapshot.data!.exists;

              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black,
                ),
                onPressed: () async {
                  if (isFavorite) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('wishlist')
                        .doc(shoeId)
                        .delete();
                  } else {
                    final shoeDoc = await FirebaseFirestore.instance
                        .collection('shoes')
                        .doc(shoeId)
                        .get();
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('wishlist')
                        .doc(shoeId)
                        .set(shoeDoc.data()!);
                  }
                },
              );
            },
          ),
      ],
      flexibleSpace: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('shoes')
            .doc(shoeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading shoe'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Loading...'));
          }

          final ShoeModel shoe = ShoeModel.fromFirestore(
              snapshot.data!.data() as Map<String, dynamic>, shoeId);

          return LayoutBuilder(
            builder: (context, constraints) {
              double paddingLeft = MediaQuery.of(context).padding.left;
              return Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: paddingLeft + 50.0),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shoe.sku,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      shoe.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.0),
        child: Divider(
          height: 1.0,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 10.0);
}
