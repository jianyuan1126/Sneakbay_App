import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../widget/main_app_bar.dart';
import '../../pricing/pricing_page.dart'; // Adjust the path as needed
import 'package:flutter_application_1/models/shoe_model.dart'; // Adjust the path as needed

class NotForSalePage extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  NotForSalePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Not For Sale',
          iconThemeColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
            child:
                Text('You need to be logged in to view your draft listings.')),
      );
    }

    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: CustomAppBar(
        title: 'Not For Sale',
        iconThemeColor: Theme.of(context).primaryColor,
        showBackButton: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('drafts')
            .where('status', isEqualTo: 'draft')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((document) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('shoes')
                    .doc(document['shoeId'])
                    .get(),
                builder: (context, shoeSnapshot) {
                  if (shoeSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (shoeSnapshot.hasError || !shoeSnapshot.hasData) {
                    return const Center(
                        child: Text('Failed to load shoe details'));
                  }

                  ShoeModel shoeModel = ShoeModel.fromFirestore(
                    shoeSnapshot.data!.data() as Map<String, dynamic>,
                    shoeSnapshot.data!.id,
                  );

                  return Dismissible(
                    key: Key(document.id),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        await _activateListing(user.uid, document.id);
                        return false;
                      } else {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.black, width: 2),
                              ),
                              title: const Text('Confirm'),
                              content: const Text(
                                  'Do you want to delete this item?'),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    onDismissed: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        await _deleteListing(user.uid, document.id);
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text('Listing deleted successfully.'),
                          ),
                        );
                      }
                    },
                    background: Container(
                      color: Colors.green,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                        'Activate',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    child: DraftListingItem(
                      documentId: document.id,
                      shoeModel: shoeModel,
                      size: document['size'],
                      condition: document['condition'],
                      packaging: document['packaging'],
                      price: (document['price'] is int)
                          ? document['price'].toDouble()
                          : document['price'],
                      imageUrl: document['imgAddress'],
                      userId: user.uid,
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<void> _deleteListing(String userId, String documentId) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('drafts')
        .doc(documentId);

    await userDoc.delete();
  }

  Future<void> _activateListing(String userId, String documentId) async {
    final userDraftDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('drafts')
        .doc(documentId);

    final listingData = (await userDraftDoc.get()).data();
    if (listingData != null) {
      listingData['status'] = 'for_sale';
      listingData['timestamp'] = FieldValue.serverTimestamp();

      final shoeId = listingData['shoeId'];
      final allListingsDoc = FirebaseFirestore.instance
          .collection('all_listings')
          .doc(shoeId)
          .collection('listings')
          .doc(documentId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Add listing to sub-collection
        transaction.set(allListingsDoc, listingData);

        // Remove listing from top-level collection
        final topLevelListingDoc = FirebaseFirestore.instance
            .collection('all_listings')
            .doc(documentId);
        transaction.delete(topLevelListingDoc);

        // Add listing to user's listings collection
        final userListingDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('listings')
            .doc(documentId);
        transaction.set(userListingDoc, listingData);

        // Remove listing from drafts
        transaction.delete(userDraftDoc);
      });
    }
  }
}

class DraftListingItem extends StatelessWidget {
  final String documentId;
  final ShoeModel shoeModel;
  final String size;
  final String condition;
  final String packaging;
  final double price;
  final String imageUrl;
  final String userId;

  const DraftListingItem({
    Key? key,
    required this.documentId,
    required this.shoeModel,
    required this.size,
    required this.condition,
    required this.packaging,
    required this.price,
    required this.imageUrl,
    required this.userId,
  }) : super(key: key);

  Future<List<double>> _fetchPricingDetails() async {
    final offersRef = FirebaseFirestore.instance.collection('all_offers');
    final listingsRef = FirebaseFirestore.instance
        .collection('all_listings')
        .doc(shoeModel.id)
        .collection('listings');

    double topOffer = -1;
    double lastSold = -1;
    double lowestPrice = -1;

    // Fetch top offer
    final topOfferSnapshot = await offersRef
        .where('shoeId', isEqualTo: shoeModel.id)
        .where('size', isEqualTo: size)
        .where('condition', isEqualTo: condition)
        .where('packaging', isEqualTo: packaging)
        .orderBy('offerPrice', descending: true)
        .limit(1)
        .get();

    if (topOfferSnapshot.docs.isNotEmpty) {
      topOffer = topOfferSnapshot.docs.first['offerPrice'].toDouble();
    }

    // Fetch last sold price from all_sold collection
    final lastSoldSnapshot = await FirebaseFirestore.instance
        .collection('all_sold')
        .where('shoeName', isEqualTo: shoeModel.name)
        .where('condition', isEqualTo: condition)
        .where('packaging', isEqualTo: packaging)
        .orderBy('orderCreatedTimestamp', descending: true)
        .limit(1)
        .get();

    if (lastSoldSnapshot.docs.isNotEmpty) {
      lastSold = lastSoldSnapshot.docs.first['price'].toDouble();
    }

    // Fetch lowest listing price
    final lowestPriceSnapshot = await listingsRef
        .where('size', isEqualTo: size)
        .where('condition', isEqualTo: condition)
        .where('packaging', isEqualTo: packaging)
        .orderBy('price')
        .limit(1)
        .get();

    if (lowestPriceSnapshot.docs.isNotEmpty) {
      lowestPrice = lowestPriceSnapshot.docs.first['price'].toDouble();
    }

    return [topOffer, lastSold, lowestPrice];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<double>>(
      future: _fetchPricingDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load pricing details'));
        }

        double topOffer = snapshot.data![0];
        double lastSold = snapshot.data![1];
        double lowestPrice =
            snapshot.data![2] != -1 ? snapshot.data![2] : price;

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: Colors.black, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shoeModel.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Size: $size'),
                          Text('Condition: $condition'),
                          Text('Packaging: $packaging'),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PricingPage(
                              documentId: documentId,
                              shoeModel: shoeModel,
                              sku: shoeModel.sku,
                              size: size,
                              condition: condition,
                              packaging: packaging,
                              selectedSizes: [],
                              isNotForSalePage:
                                  true, // Indicate it's from NotForSalePage
                              initialPrice: price, // Pass the current price
                            ),
                          ),
                        );
                      },
                      child: Text(
                        '\$$price',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Offer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(topOffer != -1
                            ? '\$${topOffer.toStringAsFixed(0)}'
                            : '--'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lowest',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('\$${lowestPrice.toStringAsFixed(1)}'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Last Sold',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(lastSold != -1
                            ? '\$${lastSold.toStringAsFixed(0)}'
                            : '--'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
