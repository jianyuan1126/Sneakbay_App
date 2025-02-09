import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../models/shoe_model.dart';
import '../../../../theme/custom_app_theme.dart';
import '../../detail/detail_screen.dart';
import '../../../../widget/section_title.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> addToWishlist(ShoeModel shoe) async {
    if (user == null) {
      // Show a message to the user to log in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please log in to add items to your wishlist.')),
      );
      return;
    }

    try {
      final wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('wishlist')
          .doc(shoe.id);

      await wishlistRef.set(shoe.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${shoe.name} added to wishlist!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to wishlist: $e')),
      );
    }
  }

  Future<void> removeFromWishlist(ShoeModel shoe) async {
    if (user == null) {
      // Show a message to the user to log in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please log in to remove items from your wishlist.')),
      );
      return;
    }

    try {
      final wishlistRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('wishlist')
          .doc(shoe.id);

      await wishlistRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${shoe.name} removed from wishlist!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove from wishlist: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(text: 'Trending Sneakers'),
        SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('shoes')
              .orderBy('timestamp', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.requireData;
            final shoes = data.docs.map((doc) {
              return ShoeModel.fromFirestore(
                  doc.data() as Map<String, dynamic>, doc.id);
            }).toList();

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('wishlist')
                  .snapshots(),
              builder: (context, wishlistSnapshot) {
                if (wishlistSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (wishlistSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${wishlistSnapshot.error}'));
                }

                final wishlist =
                    wishlistSnapshot.data?.docs.map((doc) => doc.id).toList() ??
                        [];
                return middleCategoriesWidget(width, height, shoes, wishlist);
              },
            );
          },
        ),
      ],
    );
  }

  Widget middleCategoriesWidget(double width, double height,
      List<ShoeModel> shoes, List<String> wishlist) {
    return SizedBox(
      width: width,
      height: height / 2.4,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: shoes.length,
        itemBuilder: (ctx, index) {
          final model = shoes[index];
          final modelColor = isValidHexColor(model.modelColour)
              ? Color(int.parse(model.modelColour.replaceFirst('#', '0xff')))
              : Colors.grey; // Fallback color if modelColour is invalid

          final isFavorited = wishlist.contains(model.id);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => DetailScreen(
                    shoeId: model.id,
                    isComeFromMoreSection: false,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
              width: width / 1.4,
              child: Stack(
                children: [
                  Container(
                    width: width / 1.8,
                    decoration: BoxDecoration(
                      color: modelColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    top: 10,
                    child: Wrap(
                      children: [
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: width / 1.8 - 50),
                          child: Text(
                            model.name,
                            style: AppThemes.homeProductName
                                .copyWith(color: Colors.black),
                            overflow: TextOverflow.visible,
                            maxLines: 2,
                            softWrap: true,
                          ),
                        ),
                        IconButton(
                          onPressed: () => isFavorited
                              ? removeFromWishlist(model)
                              : addToWishlist(model),
                          icon: Icon(
                            isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorited ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 70,
                    left: 10,
                    child: Text(
                      model.brand,
                      style: AppThemes.homeProductModel
                          .copyWith(color: Colors.black),
                    ),
                  ),
                  Positioned(
                    top: 105,
                    left: 10,
                    child: Text(
                      "\RM${model.retailPrice.toStringAsFixed(2)}",
                      style: AppThemes.homeProductPrice
                          .copyWith(color: Colors.black),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 50,
                    child: Hero(
                      tag: model.imgAddress,
                      child: RotationTransition(
                        turns: const AlwaysStoppedAnimation(-30 / 360),
                        child: SizedBox(
                          width: 250,
                          height: 280,
                          child: Image.network(model.imgAddress),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 170,
                    child: IconButton(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.arrowCircleRight,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  bool isValidHexColor(String hexColor) {
    final validHexColorRegExp = RegExp(r'^#([A-Fa-f0-9]{6})$');
    return validHexColorRegExp.hasMatch(hexColor);
  }
}
