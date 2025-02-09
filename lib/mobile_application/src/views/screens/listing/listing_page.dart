import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/shoe_model.dart';
import '../../../../../models/sneaker_size_quantity.dart';
import '../../../widget/custom_navigation_button.dart';
import '../../../widget/main_app_bar.dart';
import 'components/condition_selection.dart';
import 'components/packaging_selection.dart';
import 'components/size_selection.dart';
import 'components/sneaker_widget.dart';
import '../pricing/pricing_page.dart';
import '../review_listing/review_listing_page.dart';
import 'list_multiple_page.dart';

class ListingPage extends StatefulWidget {
  final ShoeModel shoeModel;
  final String? initialSize;

  const ListingPage({super.key, required this.shoeModel, this.initialSize});

  @override
  _ListingPageState createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  String? selectedSize;
  String? selectedCondition;
  String? selectedPackaging;
  bool fromMultipleListing = false;
  String? existingDocumentId;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.initialSize;
    fromMultipleListing = widget.initialSize != null;
    fetchExistingOffer();
  }

  void fetchExistingOffer() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final offerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('offers')
          .where('shoeId', isEqualTo: widget.shoeModel.id)
          .where('size', isEqualTo: selectedSize)
          .where('condition', isEqualTo: selectedCondition)
          .where('packaging', isEqualTo: selectedPackaging)
          .get();

      if (offerSnapshot.docs.isNotEmpty) {
        setState(() {
          existingDocumentId = offerSnapshot.docs.first.id;
        });
      }
    }
  }

  void _continuePressed() async {
    if (selectedSize == null ||
        selectedCondition == null ||
        selectedPackaging == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all the required options.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      // Use existing documentId if available, else generate a new one
      final documentId = existingDocumentId ??
          FirebaseFirestore.instance.collection('users').doc().id;

      Navigator.push<double>(
        context,
        MaterialPageRoute(
          builder: (context) => PricingPage(
            shoeModel: widget.shoeModel,
            sku: widget.shoeModel.sku,
            size: selectedSize!,
            condition: selectedCondition!,
            packaging: selectedPackaging!,
            selectedSizes: const [],
            isForSalePage: false,
            documentId: documentId, 
          ),
        ),
      ).then(
        (priceSet) async {
          if (priceSet != null) {
            final listingData = {
              'userId': user.uid,
              'shoeId': widget.shoeModel.id,
              'shoeName': widget.shoeModel.name,
              'imgAddress': widget.shoeModel.imgAddress,
              'size': selectedSize,
              'condition': selectedCondition,
              'packaging': selectedPackaging,
              'quantity': 1,
              'price': priceSet,
              'status': 'for_sale',
              'timestamp': FieldValue.serverTimestamp(),
              'listingId': '${widget.shoeModel.id}-$selectedSize',
              'sku': widget.shoeModel.sku,
              'documentId': documentId,
            };

            final userDoc =
                FirebaseFirestore.instance.collection('users').doc(user.uid);
            final listingId = '${widget.shoeModel.id}-$selectedSize';

            await userDoc
                .collection('listings')
                .doc(listingId)
                .set(listingData);
            await FirebaseFirestore.instance
                .collection('all_listings')
                .doc(listingId)
                .set(listingData);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewListingPage(
                  selectedShoe: widget.shoeModel,
                  selectedSizes: [
                    SneakerSizeQuantity(
                      size: selectedSize!,
                      quantity: 1,
                      price: priceSet,
                      condition: selectedCondition!,
                      packaging: selectedPackaging!,
                    )
                  ],
                ),
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Sneaker Details',
        backgroundColor: Colors.white,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SneakerWidget(shoe: widget.shoeModel),
              SizeSelectionWidget(
                category: widget.shoeModel.sizeCategory,
                selectedSize: selectedSize,
                onSizeSelected: (size) => setState(() => selectedSize = size),
              ),
              ConditionSelectionWidget(
                selectedCondition: selectedCondition,
                onConditionSelected: (condition) =>
                    setState(() => selectedCondition = condition),
              ),
              PackagingSelectionWidget(
                selectedPackaging: selectedPackaging,
                onPackagingSelected: (packaging) =>
                    setState(() => selectedPackaging = packaging),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListMultiplePage(shoeModel: widget.shoeModel),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('List More Than One ?'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, color: Colors.black),
          CustomNavigationButton(
            buttonText: 'Continue',
            onPressed: _continuePressed,
            borderRadius: 5,
            height: 45,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
