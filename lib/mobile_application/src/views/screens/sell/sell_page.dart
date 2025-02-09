import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/models/common_enums.dart';
import 'package:flutter_application_1/models/shoe_model.dart';

class SellPage extends StatefulWidget {
  final String shoeId;
  final ShoeModel shoeModel;

  const SellPage({Key? key, required this.shoeId, required this.shoeModel})
      : super(key: key);

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shoeId.isEmpty) {
      return const Center(child: Text('Shoe ID is missing.'));
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontSize: 13.0),
          tabs: const [
            Tab(text: 'NEW'),
            Tab(text: 'NEW W/ DEFECTS'),
            Tab(text: 'USED'),
          ],
        ),
        Expanded(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('shoes')
                .doc(widget.shoeId)
                .get(),
            builder: (context, shoeSnapshot) {
              if (shoeSnapshot.hasError) {
                return Center(
                    child: Text('Something went wrong: ${shoeSnapshot.error}'));
              }

              if (shoeSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!shoeSnapshot.hasData || !shoeSnapshot.data!.exists) {
                return const Center(child: Text('Shoe not found.'));
              }

              ShoeModel shoe = ShoeModel.fromFirestore(
                  shoeSnapshot.data!.data() as Map<String, dynamic>,
                  widget.shoeId);
              List<double> predefinedSizesList =
                  predefinedSizes[shoe.sizeCategory] ?? [];
              List<String> predefinedSizesStr = predefinedSizesList
                  .map((size) => size.toString().replaceAll('.0', ''))
                  .toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(context, predefinedSizesStr, 'New'),
                  _buildListView(context, predefinedSizesStr, 'New w/ Defects'),
                  _buildListView(context, predefinedSizesStr, 'Used'),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListView(
      BuildContext context, List<String> predefinedSizesStr, String condition) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHeaderCell('US'),
            _buildHeaderCell('Last Sold'),
            _buildHeaderCell('Lowest'),
            _buildHeaderCell('Top Offer'),
          ],
        ),
        const Divider(color: Colors.black),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('all_listings')
                .doc(widget.shoeId)
                .collection('listings')
                .where('condition', isEqualTo: condition)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Text('Something went wrong: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final listings = snapshot.data?.docs ?? [];
              final Map<String, List<QueryDocumentSnapshot>> groupedBySize = {};
              for (var doc in listings) {
                final size = doc['size'];
                if (groupedBySize.containsKey(size)) {
                  groupedBySize[size]!.add(doc);
                } else {
                  groupedBySize[size] = [doc];
                }
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: predefinedSizesStr.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.black),
                itemBuilder: (context, index) {
                  final size = predefinedSizesStr[index];
                  final sizeListings = groupedBySize[size] ?? [];

                  final lowestPrice = sizeListings.isNotEmpty
                      ? sizeListings
                          .map((doc) => doc['price'] as num)
                          .reduce((a, b) => a < b ? a : b)
                      : null;


                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('all_offers')
                        .where('shoeId', isEqualTo: widget.shoeId)
                        .where('size', isEqualTo: size)
                        .where('condition', isEqualTo: condition)
                        .orderBy('offerPrice', descending: true)
                        .limit(1)
                        .get(),
                    builder: (context, offerSnapshot) {
                      if (offerSnapshot.hasError) {
                        return Center(
                            child: Text(
                                'Something went wrong: ${offerSnapshot.error}'));
                      }

                      if (offerSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final topOfferPrice = offerSnapshot.hasData &&
                              offerSnapshot.data!.docs.isNotEmpty
                          ? offerSnapshot.data!.docs.first['offerPrice'] as num
                          : null;

                      return FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('all_purchased')
                            .where('shoeId', isEqualTo: widget.shoeId)
                            .where('size', isEqualTo: size)
                            .where('condition', isEqualTo: condition)
                            .orderBy('timestamp', descending: true)
                            .limit(1)
                            .get(),
                        builder: (context, purchasedSnapshot) {
                          if (purchasedSnapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Something went wrong: ${purchasedSnapshot.error}'));
                          }

                          if (purchasedSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final lastSoldPrice = purchasedSnapshot.hasData &&
                                  purchasedSnapshot.data!.docs.isNotEmpty
                              ? purchasedSnapshot.data!.docs.first['price'] as num
                              : null;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildCell(size),
                              _buildCell(lastSoldPrice != null
                                  ? '\$${lastSoldPrice.toString()}'
                                  : '-'),
                              _buildCell(lowestPrice != null
                                  ? '\$${lowestPrice.toString()}'
                                  : '-'),
                              _buildCell(topOfferPrice != null
                                  ? '\$${topOfferPrice.toString()}'
                                  : '-'),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          text,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCell(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
