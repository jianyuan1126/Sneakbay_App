import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../widget/main_app_bar.dart';
import '../../../../widget/offer_price_picker.dart';
import 'package:flutter_application_1/models/shoe_model.dart';

class ForOfferPage extends StatefulWidget {
  const ForOfferPage({super.key});

  @override
  _ForOfferPageState createState() => _ForOfferPageState();
}

class _ForOfferPageState extends State<ForOfferPage> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'For Offer',
          iconThemeColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
            child: Text('You need to be logged in to view your offers.')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'For Offer',
        iconThemeColor: Theme.of(context).primaryColor,
        showBackButton: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('offers')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No offers available.'));
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

                  return OfferItem(
                    documentId: document.id,
                    shoeModel: shoeModel,
                    size: document['size'],
                    condition: document['condition'],
                    packaging: document['packaging'],
                    price: (document['offerPrice'] is int)
                        ? document['offerPrice'].toDouble()
                        : document['offerPrice'],
                    imageUrl: document['imgAddress'],
                    onOfferUpdated: (newPrice) async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('offers')
                          .doc(document.id)
                          .update({'offerPrice': newPrice});

                      await FirebaseFirestore.instance
                          .collection('all_offers')
                          .doc(document.id)
                          .update({'offerPrice': newPrice});

                      setState(() {}); // Refresh the page
                    },
                    onOfferDeleted: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('offers')
                          .doc(document.id)
                          .delete();

                      await FirebaseFirestore.instance
                          .collection('all_offers')
                          .doc(document.id)
                          .delete();

                      setState(() {}); // Refresh the page
                    },
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
}

class OfferItem extends StatelessWidget {
  final String documentId;
  final ShoeModel shoeModel;
  final String size;
  final String condition;
  final String packaging;
  final double price;
  final String imageUrl;
  final Function(double) onOfferUpdated;
  final Function onOfferDeleted;

  const OfferItem({
    Key? key,
    required this.documentId,
    required this.shoeModel,
    required this.size,
    required this.condition,
    required this.packaging,
    required this.price,
    required this.imageUrl,
    required this.onOfferUpdated,
    required this.onOfferDeleted,
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
        .where('size', isEqualTo: size)
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
    } else {
      lowestPrice = -1; // Set to -1 if no listing is found
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
        double lowestPrice = snapshot.data![2] != -1
            ? snapshot.data![2]
            : -1; // Update condition here

        return Dismissible(
          key: Key(documentId),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            await onOfferDeleted();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Offer deleted successfully.'),
                ),
              );
            }
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(4.0),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            builder: (BuildContext context) {
                              return PricePicker(
                                initialPrice: price,
                                listingPrice: lowestPrice != -1
                                    ? lowestPrice
                                    : 5000, // Use 5000 if no lowest price
                                topOffer: topOffer,
                                onPriceSelected: (newPrice) {
                                  onOfferUpdated(newPrice);
                                },
                              );
                            },
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
                          Text(lowestPrice != -1
                              ? '\$${lowestPrice.toStringAsFixed(0)}'
                              : '--'),
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
          ),
        );
      },
    );
  }
}
