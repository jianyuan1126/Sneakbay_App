import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/sneaker_size_quantity.dart';
import 'package:flutter_application_1/mobile_application/src/widget/custom_navigation_button.dart';
import '../../../../../../models/shoe_model.dart';
import '../../../widget/section_title.dart';
import '../../../widget/earnings_details.dart';
import '../main_page.dart';
import '../review_listing/review_listing_page.dart';
import 'components/page_view_price_selector.dart';
import 'components/price_card.dart';
import 'components/pricing_title.dart';
import 'components/editable_price_field.dart';

class PricingPage extends StatefulWidget {
  final ShoeModel? shoeModel;
  final String sku;
  final String size;
  final String condition;
  final String packaging;
  final List<String> selectedSizes;
  final bool isFromMultipleListing;
  final String? documentId;
  final bool isForSalePage;
  final bool isNotForSalePage;
  final double? initialPrice;

  const PricingPage({
    super.key,
    this.shoeModel,
    required this.sku,
    required this.size,
    required this.condition,
    required this.packaging,
    required this.selectedSizes,
    this.isFromMultipleListing = false,
    this.documentId,
    this.isForSalePage = false,
    this.isNotForSalePage = false,
    this.initialPrice,
  });

  @override
  _PricingPageState createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  double _price = 25;
  final double _minPrice = 25;
  final double _maxPrice = 2000;
  final double _step = 1;
  late List<double> priceList;
  PageController? _pageController;
  final TextEditingController _priceController = TextEditingController();
  final FocusNode _priceFocusNode = FocusNode();

  int _selectedIndex = 0;

  double topOffer = -1;
  double globalIndicator = -1;
  double lastSold = -1;
  String pricingMessage = '';

  @override
  void initState() {
    super.initState();

    fetchPricingData().then((_) {
      setState(() {
        priceList = List.generate(
          ((_maxPrice - _minPrice) / _step).ceil() + 1,
          (index) => _minPrice + index * _step,
        ).where((price) => price >= topOffer).toList();

        _selectedIndex = priceList.indexOf(_price);
        _pageController =
            PageController(initialPage: _selectedIndex, viewportFraction: 0.15);
        _priceController.text = _price.toStringAsFixed(0);
      });
    });

    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) {
        _validatePriceInput();
      }
    });
  }

  Future<void> fetchPricingData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final offersRef = FirebaseFirestore.instance.collection('all_offers');

    final topOfferSnapshot = await offersRef
        .where('shoeId', isEqualTo: widget.shoeModel!.id)
        .where('size', isEqualTo: widget.size)
        .where('condition', isEqualTo: widget.condition)
        .where('packaging', isEqualTo: widget.packaging)
        .orderBy('offerPrice', descending: true)
        .limit(1)
        .get();

    if (topOfferSnapshot.docs.isNotEmpty) {
      topOffer = topOfferSnapshot.docs.first['offerPrice'].toDouble();
    }

    final listingRef = FirebaseFirestore.instance
        .collection('all_listings')
        .doc(widget.shoeModel!.id)
        .collection('listings');
    final globalIndicatorSnapshot = await listingRef
        .where('size', isEqualTo: widget.size)
        .where('condition', isEqualTo: widget.condition)
        .where('packaging', isEqualTo: widget.packaging)
        .orderBy('price')
        .limit(1)
        .get();

    if (globalIndicatorSnapshot.docs.isNotEmpty) {
      globalIndicator = globalIndicatorSnapshot.docs.first['price'].toDouble();
    }

    final lastSoldSnapshot = await FirebaseFirestore.instance
        .collection('all_sold')
        .where('shoeName', isEqualTo: widget.shoeModel!.name)
        .where('size', isEqualTo: widget.size)
        .where('condition', isEqualTo: widget.condition)
        .where('packaging', isEqualTo: widget.packaging)
        .orderBy('orderCreatedTimestamp', descending: true)
        .limit(1)
        .get();

    if (lastSoldSnapshot.docs.isNotEmpty) {
      lastSold = lastSoldSnapshot.docs.first['price'].toDouble();
    }

    setState(() {
      _price = widget.initialPrice ?? (topOffer != -1 ? topOffer : 25);
    });

    _calculatePricingMessage();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _validatePriceInput() {
    final newPrice = double.tryParse(_priceController.text) ?? _minPrice;
    if (newPrice > _maxPrice) {
      _showMaxPriceAlert();
    } else if (newPrice >= _minPrice && newPrice <= _maxPrice) {
      setState(() {
        _price = newPrice;
        _priceController.text = newPrice.toStringAsFixed(0);
        _selectedIndex = priceList.indexOf(newPrice);
      });
      _pageController?.jumpToPage(_selectedIndex);
      _calculatePricingMessage();
    }
  }

  void _showMaxPriceAlert() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exceeding Maximum Price'),
          content: const Text('The maximum price for listing is 2000.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _calculatePricingMessage() {
    FirebaseFirestore.instance
        .collection('all_listings')
        .doc(widget.shoeModel!.id)
        .collection('listings')
        .where('size', isEqualTo: widget.size)
        .where('condition', isEqualTo: widget.condition)
        .where('packaging', isEqualTo: widget.packaging)
        .get()
        .then((querySnapshot) {
      final listingPrices =
          querySnapshot.docs.map((doc) => doc['price'] as double).toList();
      listingPrices.sort();

      setState(() {
        if (listingPrices.isEmpty) {
          if (_price == topOffer && topOffer != -1) {
            pricingMessage = 'Top Offer';
          } else {
            pricingMessage = 'You are the only listing';
          }
        } else if (_price == topOffer && topOffer != -1) {
          pricingMessage = 'Top Offer';
        } else if (_price == listingPrices.first) {
          pricingMessage = 'You are the lowest price';
        } else {
          int belowCount =
              listingPrices.where((price) => price < _price).length;
          double percentage = (belowCount / listingPrices.length) * 100;

          if (percentage >= 100) {
            pricingMessage = 'You are not the lowest price';
          } else if (_price < globalIndicator) {
            pricingMessage = 'You are the lowest price';
          } else {
            pricingMessage =
                'RM${percentage.toStringAsFixed(0)}% are priced below yours';
          }
        }
      });
    });
  }

  Future<void> _handleAcceptOfferPressed() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    // Fetch buyer's details
    DocumentSnapshot buyerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!buyerDoc.exists || buyerDoc.data() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Buyer data not found')),
      );
      return;
    }

    var buyerData = buyerDoc.data() as Map<String, dynamic>;
    var buyerAddress = buyerData['address'];

    // Fetch seller's details
    DocumentSnapshot sellerDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.shoeModel!.userId)
        .get();

    if (!sellerDoc.exists || sellerDoc.data() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller data not found')),
      );
      return;
    }

    var sellerData = sellerDoc.data() as Map<String, dynamic>;

    String trackingId = _generateGdexTrackingCode();
    double earnings = _calculateEarnings(topOffer);

    Map<String, dynamic> orderData = {
      'shoeName': widget.shoeModel!.name,
      'userId': user.uid,
      'size': widget.size,
      'sku': widget.sku,
      'condition': widget.condition,
      'packaging': widget.packaging,
      'price': topOffer,
      'earnings': earnings,
      'status': 'Pending',
      'imgAddress': widget.shoeModel!.imgAddress,
      'orderCreatedTimestamp': Timestamp.now(),
      'orderId': generateOrderId(),
      'trackingId': trackingId,
      'userName': user.displayName ?? 'Unknown',
      'userEmail': user.email ?? 'Unknown',
      'userAddress': buyerAddress,
    };

    // Create order in seller's sold collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.shoeModel!.userId)
        .collection('sold')
        .doc(orderData['orderId'])
        .set({
      ...orderData,
      'userId': widget.shoeModel!.userId,
      'userName': sellerData['name'] ?? 'Unknown',
      'userEmail': sellerData['email'] ?? 'Unknown',
      'userAddress': sellerData['address'],
    });

    // Create order in all_sold collection
    await FirebaseFirestore.instance
        .collection('all_sold')
        .doc(orderData['orderId'])
        .set({
      ...orderData,
      'userId': widget.shoeModel!.userId,
      'userName': sellerData['name'] ?? 'Unknown',
      'userEmail': sellerData['email'] ?? 'Unknown',
      'userAddress': sellerData['address'],
    });

    // Create order in all_purchased collection
    await FirebaseFirestore.instance
        .collection('all_purchased')
        .doc(orderData['orderId'])
        .set(orderData);

    // Create order in buyer's purchased collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('purchased')
        .doc(orderData['orderId'])
        .set(orderData);

    // Delete the offer from all_offers collection
    await FirebaseFirestore.instance
        .collection('all_offers')
        .doc(widget.documentId)
        .delete();

    // Delete the offer from seller's offers collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.shoeModel!.userId)
        .collection('offers')
        .doc(widget.documentId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Offer accepted successfully')),
    );

    // Navigate to OrdersPage and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => const MainScreen(initialIndex: 3)),
      (Route<dynamic> route) => false,
    );
  }

  String _generateGdexTrackingCode() {
    final random = Random();
    final trackingNumber = List.generate(8, (_) => random.nextInt(10)).join();
    return 'GDEX$trackingNumber';
  }

  String generateOrderId() {
    final random = Random();
    final orderId = List<int>.generate(8, (_) => random.nextInt(10)).join();
    return orderId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: PricingTitle(
          sku: widget.sku,
          size: widget.size,
          condition: widget.condition,
          packaging: widget.packaging,
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: _pageController == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          EditablePriceField(
                            priceController: _priceController,
                            priceFocusNode: _priceFocusNode,
                            onPriceChange: (newPrice) {
                              double parsedPrice =
                                  double.tryParse(newPrice) ?? 0.0;
                              if (parsedPrice > 0) {
                                setState(() {
                                  _price = parsedPrice;
                                });
                                _calculatePricingMessage();
                              }
                            },
                          ),
                          Text(
                            pricingMessage,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const SectionTitle(
                  text: 'Set Your Price',
                ),
                const SizedBox(height: 40),
                PageViewPriceSelector(
                  selectedIndex: _selectedIndex,
                  priceList: priceList,
                  pageController: _pageController!,
                  onPageChanged: (index) {
                    if (priceList[index] >= topOffer) {
                      setState(() {
                        _selectedIndex = index;
                        _price = priceList[index];
                        _priceController.text = _price.toStringAsFixed(0);
                      });
                      _calculatePricingMessage();
                    }
                  },
                  enabled: priceList[_selectedIndex] >= topOffer,
                ),
                const SizedBox(height: 20),
                const Spacer(),
                const SectionTitle(
                  text: 'Pricing Data',
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PriceCard(
                        title: 'Top Offer',
                        price: topOffer != -1
                            ? '\RM${topOffer.toStringAsFixed(0)}'
                            : '-'),
                    PriceCard(
                        title: 'Global Indicator',
                        price: globalIndicator != -1
                            ? '\RM${globalIndicator.toStringAsFixed(0)}'
                            : '-'),
                    PriceCard(
                        title: 'Last Sold',
                        price: lastSold != -1
                            ? '\RM${lastSold.toStringAsFixed(0)}'
                            : '-'),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey),
              ],
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EarningsDetails(
            sellChannel: 'Sneakbay',
            sellingPrice: _price,
            commission: 0.05,
            sellerFee: 5.0,
            cashOutFeePercent: 0.02,
          ),
          CustomNavigationButton(
            buttonText: _price == topOffer ? 'Accept Top Offer' : 'Save Price',
            onPressed: () {
              if (_price > 2000) {
                _showMaxPriceAlert();
                return;
              }
              if (_price == topOffer) {
                _handleAcceptOfferPressed();
              } else {
                if (widget.isForSalePage) {
                  Navigator.pop(context, _price); // Return the updated price
                } else {
                  _handleNextPressed();
                }
              }
            },
            borderRadius: 5,
            height: 45,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _handleNextPressed() {
    if (_price > 0) {
      if (widget.isFromMultipleListing) {
        Navigator.pop(context, _price);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewListingPage(
              selectedShoe: widget.shoeModel!,
              selectedSizes: [
                SneakerSizeQuantity(
                  size: widget.size,
                  quantity: 1,
                  price: _price,
                  condition: widget.condition,
                  packaging: widget.packaging,
                )
              ],
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please set a valid price before proceeding."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateEarnings(double price) {
    final commissionFee = price * 0.05;
    final sellerFee = 5.0;
    return price - commissionFee - sellerFee;
  }
}
