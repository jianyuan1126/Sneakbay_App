import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'component/order_item.dart';

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPageState createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = false;
  String? checkingInFor;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('scanned_orders')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          final scannedData = doc.data();
          _fetchOrders(scannedData['User ID'], scannedData['Order ID'],
              scannedData['orderData']);
        }
      }
    });
  }

  void _fetchOrders(
      String userId, String orderId, Map<String, dynamic> orderData) {
    setState(() {
      if (orders.isEmpty) {
        checkingInFor = orderData['userName'];
      }

      if (!orders.any((order) => order['orderId'] == orderId)) {
        orders.add(orderData);
      }
    });
  }

  Future<void> _updateOrderStatus(
      String orderId, String userId, String newStatus,
      {String? returnTrackingId, String? issueDescription}) async {
    try {
      setState(() {
        isLoading = true;
      });

      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('confirmedOrders')
          .doc(orderId)
          .get();

      if (!orderSnapshot.exists) {
        throw Exception("Order not found");
      }

      Map<String, dynamic> orderData =
          orderSnapshot.data() as Map<String, dynamic>;
      double orderPrice = (orderData['price'] ?? 0).toDouble();

      // Calculate the earnings
      double commission = orderPrice * 0.05;
      double sellerFee = 5.0;
      double earnings = orderPrice - commission - sellerFee;

      // Update the order status in 'all_confirmedOrders' collection
      await FirebaseFirestore.instance
          .collection('all_confirmedOrders')
          .doc(orderId)
          .update({'status': newStatus});

      // Update the order status in the user's 'confirmedOrders' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('confirmedOrders')
          .doc(orderId)
          .update({'status': newStatus});

      // Update the order status in 'scanned_orders' collection
      await FirebaseFirestore.instance
          .collection('scanned_orders')
          .doc(orderId)
          .update({'orderData.status': newStatus});

      if (newStatus == 'Closed') {
        // Add earnings to the order data
        orderData['earnings'] = earnings;

        // Update the 'all_closedOrders' collection
        await FirebaseFirestore.instance
            .collection('all_closedOrders')
            .doc(orderId)
            .set({
          ...orderData,
          'status': newStatus,
        });

        // Update the user's 'closedOrders' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('closedOrders')
            .doc(orderId)
            .set({
          ...orderData,
          'status': newStatus,
        });

        // Update the user's available currency and lifetime sales
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentReference userDocRef =
              FirebaseFirestore.instance.collection('users').doc(userId);
          DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
          if (!userSnapshot.exists) {
            throw Exception("User not found");
          }

          double currentAvailableCurrency =
              (userSnapshot.data() as Map<String, dynamic>)['availableCurrency']
                      ?.toDouble() ??
                  0.0;
          double updatedAvailableCurrency = currentAvailableCurrency + earnings;

          double currentLifetimeSales =
              (userSnapshot.data() as Map<String, dynamic>)['lifetimeSales']
                      ?.toDouble() ??
                  0.0;
          double updatedLifetimeSales = currentLifetimeSales + orderPrice;

          transaction.update(userDocRef, {
            'availableCurrency': updatedAvailableCurrency,
            'lifetimeSales': updatedLifetimeSales,
          });
        });

        // Delete the order from 'all_confirmedOrders' collection
        await FirebaseFirestore.instance
            .collection('all_confirmedOrders')
            .doc(orderId)
            .delete();

        // Delete the order from 'confirmedOrders' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('confirmedOrders')
            .doc(orderId)
            .delete();

        // Remove the scanned order
        await _deleteScannedOrder(orderId);
      } else if (newStatus == 'IssueDetectedandReturning') {
        // Delete the order from 'all_purchased', user's 'purchased' collections, and 'openOrders'
        await FirebaseFirestore.instance
            .collection('all_purchased')
            .doc(orderId)
            .delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('purchased')
            .doc(orderId)
            .delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('openOrders')
            .doc(orderId)
            .delete();

        // Remove from 'all_confirmedOrders' and user's 'confirmedOrders' collections
        await FirebaseFirestore.instance
            .collection('all_confirmedOrders')
            .doc(orderId)
            .delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('confirmedOrders')
            .doc(orderId)
            .delete();

        // Add the order to 'all_returnOrders' and user's 'returnOrders' collections
        await FirebaseFirestore.instance
            .collection('all_returnOrders')
            .doc(orderId)
            .set({
          ...orderData,
          'status': newStatus,
          'returnTrackingId': returnTrackingId,
          'issueDescription': issueDescription,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('returnOrders')
            .doc(orderId)
            .set({
          ...orderData,
          'status': newStatus,
          'returnTrackingId': returnTrackingId,
          'issueDescription': issueDescription,
        });

        // Remove the scanned order
        await _deleteScannedOrder(orderId);
      } else if (newStatus == 'ArrivedandLegitChecking') {
        // Restore the order to 'all_purchased' and user's 'purchased' collections
        await FirebaseFirestore.instance
            .collection('all_purchased')
            .doc(orderId)
            .set({
          ...orderData,
          'status': 'Purchased', // Ensure the status is updated to Purchased
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('purchased')
            .doc(orderId)
            .set({
          ...orderData,
          'status': 'Purchased', // Ensure the status is updated to Purchased
        });

        // Delete the order from 'all_returnOrders' and user's 'returnOrders' collections
        await FirebaseFirestore.instance
            .collection('all_returnOrders')
            .doc(orderId)
            .delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('returnOrders')
            .doc(orderId)
            .delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $newStatus')),
      );

      setState(() {
        orders = orders.map((order) {
          if (order['orderId'] == orderId) {
            order['status'] = newStatus;
          }
          return order;
        }).toList();

        if (orders.isEmpty) {
          _clearStateAndMoveToNextUser();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order status: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteScannedOrder(String orderId) async {
    await FirebaseFirestore.instance
        .collection('scanned_orders')
        .doc(orderId)
        .delete();
  }

  void _clearStateAndMoveToNextUser() {
    setState(() {
      orders = [];
      checkingInFor = null;
    });
  }

  Widget _buildInitialMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Scan a QR code to get started',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Scan a QR code to load the order details and update the status.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check In Page'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? _buildInitialMessage()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (checkingInFor != null)
                        Text(
                          'Checking In For $checkingInFor',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final orderDetails = orders[index];
                            return OrderItem(
                              orderDetails: orderDetails,
                              onUpdateStatus: _updateOrderStatus,
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _clearStateAndMoveToNextUser,
                        child: Text('Move to Next User'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
