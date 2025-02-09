import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widget/custom_list_item.dart';
import '../../../widget/main_app_bar.dart';
import '../../../widget/section.dart';
import '../../../widget/section_title.dart';
import '../../donation/donation_history_page.dart';
import 'component/for_sale_page.dart';
import 'component/for_offer_page.dart';
import 'component/not_for_sale.dart';
import 'component/wishlist_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  Future<void> _refreshInventory() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Inventory',
          iconThemeColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
            child: Text('You need to be logged in to view your inventory.')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inventory',
        iconThemeColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshInventory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                text: 'Item Status',
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('listings')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'For Sale', value: 'Error', onTap: () {}),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'For Sale',
                            value: 'Loading...',
                            onTap: () {}),
                      ],
                    );
                  }
                  int forSaleCount = snapshot.data?.docs.length ?? 0;
                  return Section(
                    children: [
                      CustomListItem(
                        title: 'For Sale',
                        value: forSaleCount.toString(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForSalePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SectionTitle(
                text: 'Draft Listings',
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('drafts')
                    .where('status', isEqualTo: 'draft')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Not For Sale',
                            value: 'Error',
                            onTap: () {}),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Not For Sale',
                            value: 'Loading...',
                            onTap: () {}),
                      ],
                    );
                  }
                  int draftCount = snapshot.data?.docs.length ?? 0;
                  return Section(
                    children: [
                      CustomListItem(
                        title: 'Not For Sale',
                        value: draftCount.toString(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NotForSalePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SectionTitle(
                text: 'Item Offer',
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('offers')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'For Offer', value: 'Error', onTap: () {}),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'For Offer',
                            value: 'Loading...',
                            onTap: () {}),
                      ],
                    );
                  }
                  int forOfferCount = snapshot.data?.docs.length ?? 0;
                  return Section(
                    children: [
                      CustomListItem(
                        title: 'For Offer',
                        value: forOfferCount.toString(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForOfferPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SectionTitle(
                text: 'Wishlist',
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('wishlist')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Wishlist', value: 'Error', onTap: () {}),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Wishlist',
                            value: 'Loading...',
                            onTap: () {}),
                      ],
                    );
                  }
                  int wishlistCount = snapshot.data?.docs.length ?? 0;
                  return Section(
                    children: [
                      CustomListItem(
                        title: 'Wishlist',
                        value: wishlistCount.toString(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WishlistPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SectionTitle(
                text: 'Donations',
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('donations')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Donations', value: 'Error', onTap: () {}),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Donations',
                            value: 'Loading...',
                            onTap: () {}),
                      ],
                    );
                  }
                  int donationCount = snapshot.data?.docs.length ?? 0;
                  return Section(
                    children: [
                      CustomListItem(
                        title: 'Donations',
                        value: donationCount.toString(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DonationHistoryPage(
                                userId: user.uid,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
