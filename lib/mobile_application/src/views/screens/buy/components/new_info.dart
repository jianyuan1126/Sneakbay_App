import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/buy/components/checkout_page.dart';
import 'package:flutter_application_1/models/shoe_model.dart';

import '../../main_page.dart';

class NewInfoWidget extends StatefulWidget {
  final ShoeModel shoeModel;
  final String selectedSize;

  const NewInfoWidget({
    Key? key,
    required this.shoeModel,
    required this.selectedSize,
  }) : super(key: key);

  @override
  _NewInfoWidgetState createState() => _NewInfoWidgetState();
}

class _NewInfoWidgetState extends State<NewInfoWidget> {
  String? selectedListingId;

  Future<bool> _isItemAlreadyInCart(String listingId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }
    var cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(listingId)
        .get();
    return cartSnapshot.exists;
  }

  void _addToCart(Map<String, dynamic> itemData) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Remove the check for user's own listing
      bool alreadyInCart = await _isItemAlreadyInCart(itemData['listingId']);
      if (alreadyInCart) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item is already in the cart')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemData['listingId'])
          .set(itemData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Image.network(
                itemData['imgAddress'],
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 10),
              const Text('Item added to cart'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handlePaymentSuccess() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const MainScreen(initialIndex: 3),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('all_listings')
          .doc(widget.shoeModel.id)
          .collection('listings')
          .where('size', isEqualTo: widget.selectedSize)
          .where('condition',
              whereIn: ['New', 'Brand New Defects']).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No new listings found.'));
        }

        var listings = snapshot.data!.docs;

        // Group listings by packaging type
        Map<String, QueryDocumentSnapshot> groupedListings = {};
        for (var listing in listings) {
          String packaging = listing['packaging'];
          if (!groupedListings.containsKey(packaging) ||
              (listing['price'] as num) <
                  (groupedListings[packaging]!['price'] as num)) {
            groupedListings[packaging] = listing;
          }
        }

        // Sort the grouped listings to prioritize "Good Box"
        List<String> packagingOrder = [
          'Good Box',
          'Missing Lid',
          'Damaged Box',
          'No Box'
        ];
        List<Widget> listingWidgets = [];
        for (String packaging in packagingOrder) {
          if (groupedListings.containsKey(packaging)) {
            var listing = groupedListings[packaging];
            listingWidgets.add(
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RM ${listing?['price'].toInt()}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Best Price / $packaging',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verified before shipping to you',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedListingId = listing!.id;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // Rounded border radius
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.black),
                  ],
                ),
              ),
            );
          }
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...listingWidgets,
              if (selectedListingId != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        var selectedListing = groupedListings.values.firstWhere(
                            (listing) => listing.id == selectedListingId);
                        var itemData = {
                          'condition': selectedListing['condition'],
                          'imgAddress': selectedListing['imgAddress'],
                          'listingId': selectedListing.id,
                          'packaging': selectedListing['packaging'],
                          'price': selectedListing['price'],
                          'shoeId': selectedListing['shoeId'],
                          'shoeName': selectedListing['shoeName'],
                          'size': selectedListing['size'],
                          'sku': selectedListing['sku'],
                          'userId': selectedListing['userId'],
                        };
                        // Remove the check for user's own listing
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => CheckoutBottomSheet(
                            items: [itemData],
                            onPaymentSuccess: _handlePaymentSuccess,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Checkout'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        var selectedListing = groupedListings.values.firstWhere(
                            (listing) => listing.id == selectedListingId);
                        var itemData = {
                          'condition': selectedListing['condition'],
                          'imgAddress': selectedListing['imgAddress'],
                          'listingId': selectedListing.id,
                          'packaging': selectedListing['packaging'],
                          'price': selectedListing['price'],
                          'shoeId': selectedListing['shoeId'],
                          'shoeName': selectedListing['shoeName'],
                          'size': selectedListing['size'],
                          'sku': selectedListing['sku'],
                          'userId': selectedListing['userId'],
                        };
                        _addToCart(itemData);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(5), // Rounded border radius
                        ),
                      ),
                      child: const Text('Add To Cart'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
