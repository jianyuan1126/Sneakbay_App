import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/shoe_model.dart';
import 'package:flutter_application_1/models/sneaker_size_quantity.dart';
import 'package:flutter_application_1/mobile_application/src/widget/custom_navigation_button.dart';
import 'package:flutter_application_1/mobile_application/src/widget/earnings_details.dart';
import 'package:flutter_application_1/mobile_application/src/widget/main_app_bar.dart';
import '../main_page.dart';
import 'components/condition_selection_bottom_sheet.dart';
import 'components/box_condition_selection_bottom_sheet.dart';
import 'components/size_selection_bottom_sheet.dart';
import 'package:flutter_application_1/models/common_enums.dart';
import 'package:uuid/uuid.dart';

class ReviewListingPage extends StatefulWidget {
  final ShoeModel selectedShoe;
  final List<SneakerSizeQuantity> selectedSizes;

  const ReviewListingPage({
    super.key,
    required this.selectedShoe,
    required this.selectedSizes,
  });

  @override
  _ReviewListingPageState createState() => _ReviewListingPageState();
}

class _ReviewListingPageState extends State<ReviewListingPage> {
  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _calculateEarnings();
  }

  void _calculateEarnings() {
    for (var size in widget.selectedSizes) {
      if (size.price != null) {
        double commissionFee = size.price! * 0.05;
        double sellerFee = 5.00;
        size.earnings = size.price! - commissionFee - sellerFee;
      }
    }
  }

  void _showBottomSheet(Widget bottomSheetContent) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return bottomSheetContent;
      },
    );
  }

  void _saveDraft() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final userDraftsDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('drafts');

    for (var size in widget.selectedSizes) {
      final draftData = {
        'userId': user.uid,
        'shoeId': widget.selectedShoe.id,
        'shoeName': widget.selectedShoe.name,
        'imgAddress': widget.selectedShoe.imgAddress,
        'size': size.size,
        'condition': size.condition,
        'packaging': size.packaging,
        'quantity': size.quantity,
        'price': size.price,
        'earnings': size.earnings,
        'status': 'draft',
        'timestamp': FieldValue.serverTimestamp(),
        'sku': widget.selectedShoe.sku, 
      };

      // Use the shoeId and size as a composite key to avoid duplicate drafts
      await userDraftsDoc
          .doc('${widget.selectedShoe.id}-${size.size}')
          .set(draftData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved successfully')),
    );

    Navigator.pop(context); // Close the page
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ready to Leave?'),
            content: const Text(
                'You have not finished your listing. A draft will be saved in your not for sale inventory.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Finish Later'),
                onPressed: () {
                  _saveDraft();
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: const Text('Finish Now'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    List<double> sizes = predefinedSizes[widget.selectedShoe.sizeCategory]!;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.selectedSizes.length > 1
            ? "Review Your Listings"
            : "Review Your Listing",
        showBackButton: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'saveDraft') {
                _saveDraft();
              } else if (result == 'deleteListing') {
                // Implement delete logic
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'saveDraft',
                child: Text('Save Draft'),
              ),
              const PopupMenuItem<String>(
                value: 'deleteListing',
                child: Text('Delete Listing'),
              ),
            ],
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          return await _showExitConfirmationDialog();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildShoeDetails(),
              if (widget.selectedSizes.length == 1)
                buildSingleSizeDetail(widget.selectedSizes.first, sizes)
              else
                ...widget.selectedSizes
                    .map((size) => buildMultipleSizeDetail(size, sizes)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(),
      backgroundColor: Colors.white,
    );
  }

  Widget buildShoeDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(widget.selectedShoe.imgAddress, width: 80, height: 90),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.selectedShoe.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                Text(widget.selectedShoe.brand),
                Text('SKU: ${widget.selectedShoe.sku}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSingleSizeDetail(SneakerSizeQuantity size, List<double> sizes) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseSize = 14;
    double scaleFactor = screenWidth / 400;

    return ListTile(
      title: Wrap(
        spacing: 4.0,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              _showBottomSheet(
                SizeSelectionBottomSheet(
                  sizes: sizes.map((size) => size.toString()).toList(),
                  selectedSize: size.size,
                  onSizeSelected: (newSize) {
                    setState(() {
                      size.size = newSize;
                    });
                  },
                ),
              );
            },
            child:
                buildCustomChip(_formatSize(size.size), scaleFactor * baseSize),
          ),
          GestureDetector(
            onTap: () {
              _showBottomSheet(
                ConditionSelectionBottomSheet(
                  conditions: predefinedConditions,
                  selectedCondition: size.condition,
                  onConditionSelected: (newCondition) {
                    setState(() {
                      size.condition = newCondition;
                    });
                  },
                ),
              );
            },
            child: buildCustomChip(size.condition, scaleFactor * baseSize),
          ),
          GestureDetector(
            onTap: () {
              _showBottomSheet(
                PackagingSelectionBottomSheet(
                  packagingOptions: predefinedPackaging,
                  selectedPackaging: size.packaging,
                  onPackagingSelected: (newPackaging) {
                    setState(() {
                      size.packaging = newPackaging;
                    });
                  },
                ),
              );
            },
            child: buildCustomChip(size.packaging, scaleFactor * baseSize),
          ),
          GestureDetector(
            onTap: () {},
            child: buildCustomChip(
                'RM ${size.price?.toStringAsFixed(0)}', scaleFactor * baseSize),
          ),
        ],
      ),
    );
  }

  Widget buildCustomChip(String text, double textSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: textSize, color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget buildMultipleSizeDetail(SneakerSizeQuantity size, List<double> sizes) {
    return ExpansionTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_formatSize(size.size),
              style: const TextStyle(color: Colors.black)),
        ],
      ),
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.spaceEvenly,
          children: [
            Chip(
              backgroundColor: Colors.black,
              label: Text('${size.quantity}',
                  style: const TextStyle(color: Colors.white)),
            ),
            Chip(
              backgroundColor: Colors.black,
              label: Text(size.condition,
                  style: const TextStyle(color: Colors.white)),
            ),
            Chip(
              backgroundColor: Colors.black,
              label: Text(size.packaging,
                  style: const TextStyle(color: Colors.white)),
            ),
            Chip(
              backgroundColor: Colors.black,
              label: Text('RM ${size.price?.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildBottomNavBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(color: Colors.grey),
        EarningsDetails(
          sellChannel: 'Sneakbay',
          sellingPrice: calculateTotalSellingPrice(),
          commission: 0.050,
          sellerFee: 5.0,
          cashOutFeePercent: 0.020,
        ),
        CustomNavigationButton(
          buttonText: 'List Now',
          onPressed: _handleListNowPressed,
        ),
      ],
    );
  }

  double calculateTotalSellingPrice() {
    return widget.selectedSizes.fold(0.0, (total, size) {
      final pricePerPair = size.price ?? 0;
      final totalPriceForSize = pricePerPair * size.quantity;
      return total + totalPriceForSize;
    });
  }

  void _handleListNowPressed() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Redirect to login page or show an error message
      return;
    }

    final shoeDoc = FirebaseFirestore.instance
        .collection('all_listings')
        .doc(widget.selectedShoe.id)
        .collection('listings');

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('listings');

    for (var size in widget.selectedSizes) {
      for (var i = 0; i < size.quantity; i++) {
        final listingId = uuid.v4();
        final listingData = {
          'listingId': listingId,
          'userId': user.uid,
          'shoeId': widget.selectedShoe.id,
          'shoeName': widget.selectedShoe.name,
          'imgAddress': widget.selectedShoe.imgAddress,
          'size': size.size,
          'condition': size.condition,
          'packaging': size.packaging,
          'quantity': 1, // Each document represents one pair
          'price': size.price,
          'earnings': size.earnings, // Store only the earnings
          'status': 'for_sale',
          'timestamp': FieldValue.serverTimestamp(),
          'sku': widget.selectedShoe.sku, // Add SKU field
        };

        // Use the same document ID to create the listing in both collections
        await shoeDoc.doc(listingId).set(listingData);
        await userDoc.doc(listingId).set(listingData);

        // Delete the draft if it exists
        final draftDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('drafts')
            .doc('${widget.selectedShoe.id}-${size.size}');
        final draftSnapshot = await draftDoc.get();
        if (draftSnapshot.exists) {
          await draftDoc.delete();
        }
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'View and manage this listing within your For Sale inventory.',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(
                            initialIndex: 2,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatSize(String size) {
    return size.endsWith('.0') ? size.substring(0, size.length - 2) : size;
  }
}
