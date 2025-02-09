import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:math';
import '../../../../service/stripe_payment_service.dart';
import '../../orders/components/order_service.dart';

class CheckoutBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function onPaymentSuccess;

  const CheckoutBottomSheet({
    Key? key,
    required this.items,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  _CheckoutBottomSheetState createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  bool _isLoading = false;

  String _generateGdexTrackingCode() {
    final random = Random();
    final trackingNumber = List.generate(8, (_) => random.nextInt(10)).join();
    return 'GDEX$trackingNumber';
  }

  double _calculateEarnings(double price) {
    final commissionFee = price * 0.05;
    final sellerFee = 5.0;
    return price - commissionFee - sellerFee;
  }

  Future<void> _storePurchaseData(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || userDoc.data() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not found')),
      );
      return;
    }

    var userData = userDoc.data() as Map<String, dynamic>;
    var userAddress = userData['address'];

    for (var item in widget.items) {
      String trackingId = _generateGdexTrackingCode();
      double earnings = _calculateEarnings(item['price']);

      Map<String, dynamic> buyerOrderData = {
        'shoeName': item['shoeName'],
        'userId': user.uid,
        'size': item['size'],
        'sku': item['sku'] ?? 'N/A',
        'condition': item['condition'],
        'packaging': item['packaging'],
        'price': item['price'],
        'status': 'Purchased',
        'imgAddress': item['imgAddress'],
        'orderCreatedTimestamp': Timestamp.now(),
        'userName': user.displayName ?? 'Unknown',
        'userEmail': user.email ?? 'Unknown',
        'userAddress': userAddress,
        'orderId': OrderService().generateOrderId(),
        'trackingId': trackingId,
      };

      Map<String, dynamic> sellerOrderData = {
        'shoeName': item['shoeName'],
        'userId': item['userId'],
        'size': item['size'],
        'sku': item['sku'] ?? 'N/A',
        'condition': item['condition'],
        'packaging': item['packaging'],
        'price': item['price'],
        'earnings': earnings,
        'status': 'Pending',
        'imgAddress': item['imgAddress'],
        'orderCreatedTimestamp': Timestamp.now(),
        'userName': item['userName'] ?? 'Unknown',
        'userEmail': item['userEmail'] ?? 'Unknown',
        'userAddress': userAddress,
        'orderId': buyerOrderData['orderId'],
        'trackingId': trackingId,
      };

      // Store buyer's purchased order
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('purchased')
          .doc(buyerOrderData['orderId'])
          .set(buyerOrderData);

      // Store in all_purchased
      await FirebaseFirestore.instance
          .collection('all_purchased')
          .doc(buyerOrderData['orderId'])
          .set(buyerOrderData);

      // Store seller's sold order
      await FirebaseFirestore.instance
          .collection('users')
          .doc(item['userId'])
          .collection('sold')
          .doc(sellerOrderData['orderId'])
          .set(sellerOrderData);

      // Store in all_sold
      await FirebaseFirestore.instance
          .collection('all_sold')
          .doc(sellerOrderData['orderId'])
          .set(sellerOrderData);

      // Remove from cart if applicable
      if (item.containsKey('cartId')) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(item['cartId'])
            .delete();
      }

      // Delete listing from all_listings
      await FirebaseFirestore.instance
          .collection('all_listings')
          .doc(item['shoeId'])
          .collection('listings')
          .doc(item['listingId'])
          .delete();

      // Delete listing from user's listings
      await FirebaseFirestore.instance
          .collection('users')
          .doc(item['userId'])
          .collection('listings')
          .doc(item['listingId'])
          .delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Purchase Successful')),
    );
    widget.onPaymentSuccess();
  }

  Future<void> _initiatePayment(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    double amount = widget.items
            .fold(0.0, (double sum, item) => sum + (item['price'] as double)) *
        100;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists || userDoc['address'] == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No address found for user')),
      );
      return;
    }

    var address = userDoc['address'];
    Map<String, dynamic> shipping = {
      'name': userDoc['name'],
      'address': {
        'line1': address['streetAddress1'],
        'line2': address['streetAddress2'],
        'city': address['city'],
        'state': address['state'],
        'postal_code': address['postalCode'],
        'country': 'MY',
      },
    };

    BillingDetails billingDetails = BillingDetails(
      name: userDoc['name'],
      address: Address(
        line1: address['streetAddress1'],
        line2: address['streetAddress2'],
        city: address['city'],
        state: address['state'],
        postalCode: address['postalCode'].toString(),
        country: 'MY',
      ),
    );

    stripePaymentService.initiatePayment(
      context: context,
      amount: amount,
      shipping: shipping,
      billingDetails: billingDetails,
      onSuccess: () async {
        await _storePurchaseData(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
        setState(() {
          _isLoading = false;
        });
      },
      onFailure: () {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = widget.items
        .fold(0.0, (double sum, item) => sum + (item['price'] as double));
    double shipping = widget.items.length * 15.00;
    double totalPrice = subtotal + shipping;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.items.map((item) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.network(
                      item['imgAddress'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['shoeName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text('Size: ${item['size']}'),
                          Text('Condition: ${item['condition']}'),
                          Text('Box: ${item['packaging']}'),
                          Text('Price: RM ${item['price'].toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('RM ${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping', style: TextStyle(fontSize: 16)),
              Text('RM ${shipping.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('RM ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _initiatePayment(context),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, // Text color
              backgroundColor: Colors.black, // Background color
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // Rounded border
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Pay with Stripe'),
          ),
        ],
      ),
    );
  }
}
