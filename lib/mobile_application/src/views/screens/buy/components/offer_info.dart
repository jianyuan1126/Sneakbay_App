import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/shoe_model.dart';
import 'package:flutter_application_1/models/user_model.dart';
import '../../../../widget/offer_price_picker.dart';
import '../../main_page.dart';
import 'checkout_page.dart';

class OfferWidget extends StatefulWidget {
  final ShoeModel shoeModel;
  final String selectedSize;

  const OfferWidget({
    Key? key,
    required this.shoeModel,
    required this.selectedSize,
  }) : super(key: key);

  @override
  _OfferWidgetState createState() => _OfferWidgetState();
}

class _OfferWidgetState extends State<OfferWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;
  double? _selectedPrice;
  double _highestOffer = 0.0;
  double _lastSoldPrice = 0.0;
  double _listingPrice = 0.0;
  double? _existingOffer;
  final TextEditingController _priceController = TextEditingController();
  String? _listingId;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _fetchOfferData();
  }

  @override
  void didUpdateWidget(OfferWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSize != oldWidget.selectedSize) {
      _fetchOfferData();
    }
  }

  Future<void> _fetchOfferData() async {
    await _getHighestOffer();
    await _getLastSoldPrice();
    await _getListingPrice();
    await _getExistingOffer();
  }

  void _getUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();

        if (userSnapshot.exists) {
          setState(() {
            _user =
                UserModel.fromMap(userSnapshot.data() as Map<String, dynamic>);
          });
          print('User data fetched: ${_user!.uid}');
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _getHighestOffer() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('all_offers')
          .where('shoeId', isEqualTo: widget.shoeModel.id)
          .where('size', isEqualTo: widget.selectedSize)
          .where('condition', isEqualTo: 'New')
          .where('packaging', isEqualTo: 'Good Box')
          .orderBy('offerPrice', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _highestOffer = snapshot.docs.first['offerPrice'].toDouble();
        });
        print('Highest offer fetched: RM $_highestOffer');
      } else {
        setState(() {
          _highestOffer = 0.0;
        });
        print('No offers found for the specified shoe and size.');
      }
    } catch (e) {
      print('Error fetching highest offer: $e');
    }
  }

  Future<void> _getLastSoldPrice() async {
    try {
      final lastSoldSnapshot = await FirebaseFirestore.instance
          .collection('all_sold')
          .where('shoeName', isEqualTo: widget.shoeModel.name)
          .where('size', isEqualTo: widget.selectedSize)
          .where('condition', isEqualTo: 'New')
          .where('packaging', isEqualTo: 'Good Box')
          .orderBy('orderCreatedTimestamp', descending: true)
          .limit(1)
          .get();

      if (lastSoldSnapshot.docs.isNotEmpty) {
        setState(() {
          _lastSoldPrice = lastSoldSnapshot.docs.first['price'].toDouble();
        });
        print('Last sold price fetched: RM $_lastSoldPrice');
      } else {
        setState(() {
          _lastSoldPrice = 0.0;
        });
        print('No sales found for the specified shoe and size.');
      }
    } catch (e) {
      print('Error fetching last sold price: $e');
    }
  }

  Future<void> _getListingPrice() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('all_listings')
          .doc(widget.shoeModel.id)
          .collection('listings')
          .where('size', isEqualTo: widget.selectedSize)
          .where('condition', isEqualTo: 'New')
          .where('packaging', isEqualTo: 'Good Box')
          .orderBy('price', descending: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _listingPrice = snapshot.docs.first['price'].toDouble();
          _listingId = snapshot.docs.first.id;
        });
        print('Listing price fetched: RM $_listingPrice');
      } else {
        setState(() {
          _listingPrice = 0.0;
        });
        print('No listings found for the specified shoe and size.');
      }
    } catch (e) {
      print('Error fetching listing price: $e');
    }
  }

  Future<void> _getExistingOffer() async {
    try {
      if (_user == null) return;
      final QuerySnapshot existingOfferSnapshot = await _firestore
          .collection('all_offers')
          .where('shoeId', isEqualTo: widget.shoeModel.id)
          .where('size', isEqualTo: widget.selectedSize)
          .where('userId', isEqualTo: _user!.uid)
          .limit(1)
          .get();

      if (existingOfferSnapshot.docs.isNotEmpty) {
        setState(() {
          _existingOffer =
              existingOfferSnapshot.docs.first['offerPrice'].toDouble();
        });
        print('Existing offer fetched: RM $_existingOffer');
      } else {
        setState(() {
          _existingOffer = null;
        });
        print('No existing offer found for the specified shoe and size.');
      }
    } catch (e) {
      print('Error fetching existing offer: $e');
    }
  }

  void _submitOffer(double offerPrice) async {
    if (_user != null) {
      if (offerPrice <= _highestOffer && offerPrice != _listingPrice) {
        setState(() {});
        _showTopSnackbar(context,
            'Offer must be higher than the current highest offer of RM $_highestOffer');
        return;
      }

      if (offerPrice < 25 || offerPrice > 5000) {
        setState(() {});
        _showTopSnackbar(context, 'Offer must be between RM 25 and RM 5000');
        return;
      }

      if (offerPrice == _listingPrice) {
        _showCheckoutBottomSheet();
      } else {
        try {
          if (_existingOffer != null) {
            final QuerySnapshot existingOfferSnapshot = await _firestore
                .collection('all_offers')
                .where('shoeId', isEqualTo: widget.shoeModel.id)
                .where('size', isEqualTo: widget.selectedSize)
                .where('userId', isEqualTo: _user!.uid)
                .limit(1)
                .get();

            String docId = existingOfferSnapshot.docs.first.id;
            await _firestore.collection('all_offers').doc(docId).update({
              'offerPrice': offerPrice,
              'timestamp': FieldValue.serverTimestamp()
            });

            await _firestore
                .collection('users')
                .doc(_user!.uid)
                .collection('offers')
                .doc(docId)
                .update({
              'offerPrice': offerPrice,
              'timestamp': FieldValue.serverTimestamp()
            });

            _showTopSnackbar(context, 'Offer updated!');
          } else {
            final offerData = {
              'offerPrice': offerPrice,
              'shoeId': widget.shoeModel.id,
              'size': widget.selectedSize,
              'userId': _user!.uid,
              'shoeName': widget.shoeModel.name,
              'condition': 'New',
              'packaging': 'Good Box',
              'imgAddress': widget.shoeModel.imgAddress,
              'timestamp': FieldValue.serverTimestamp(),
            };

            DocumentReference newOfferRef =
                _firestore.collection('all_offers').doc();
            await newOfferRef.set(offerData);

            await _firestore
                .collection('users')
                .doc(_user!.uid)
                .collection('offers')
                .doc(newOfferRef.id)
                .set(offerData);

            _showTopSnackbar(context, 'Offer submitted!');
          }

          _fetchOfferData();
        } catch (e) {
          print('Error submitting offer: $e');
          _showTopSnackbar(context, 'Failed to submit offer');
        }
      }
    } else {
      setState(() {});
      _showTopSnackbar(context, 'Please enter a valid offer price');
    }
  }

  void _showCheckoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return CheckoutBottomSheet(
          items: [
            {
              'shoeName': widget.shoeModel.name,
              'userId': _user!.uid,
              'size': widget.selectedSize,
              'sku': widget.shoeModel.sku,
              'condition': 'New',
              'packaging': 'Good Box',
              'price': _listingPrice,
              'imgAddress': widget.shoeModel.imgAddress,
              'listingId': _listingId,
              'shoeId': widget.shoeModel.id,
            },
          ],
          onPaymentSuccess: _handlePaymentSuccess,
        );
      },
    );
  }

  void _showPricePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return PricePicker(
          initialPrice: _existingOffer,
          listingPrice: _listingPrice,
          topOffer: _highestOffer,
          onPriceSelected: (price) {
            setState(() {
              _selectedPrice = price;
              _priceController.text = _selectedPrice.toString();
            });
            _submitOffer(price);
          },
        );
      },
    );
  }

  void _showTopSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewInsets.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'This offer is valid for brand new condition and with original packaging.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Highest Offer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _highestOffer > 0 ? 'RM$_highestOffer' : '-',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last Sold',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _lastSoldPrice > 0 ? 'RM$_lastSoldPrice' : '-',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _showPricePicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(color: Colors.black),
                ),
              ),
              child: const Text(
                'Make an Offer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
