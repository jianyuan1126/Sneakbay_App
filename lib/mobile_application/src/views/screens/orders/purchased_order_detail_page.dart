import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../models/order_model.dart';
import '../../../service/user_service.dart';
import '../../../widget/main_app_bar.dart';
import '../../../widget/rating_dialog.dart';

class PurchaseDetailsPage extends StatefulWidget {
  final OrderModel order;

  PurchaseDetailsPage({required this.order, Key? key}) : super(key: key);

  @override
  _PurchaseDetailsPageState createState() => _PurchaseDetailsPageState();
}

class _PurchaseDetailsPageState extends State<PurchaseDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar('User not logged in');
      return;
    }

    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('confirmedOrders')
          .doc(widget.order.id)
          .get();

      if (!orderSnapshot.exists) {
        _showSnackBar('Order not found');
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference userOrderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('confirmedOrders')
          .doc(widget.order.id);
      batch.update(userOrderRef,
          {'status': OrderStatus.Canceled.toString().split('.').last});

      DocumentReference allOrdersRef = FirebaseFirestore.instance
          .collection('all_confirmedOrders')
          .doc(widget.order.id);
      batch.update(allOrdersRef,
          {'status': OrderStatus.Canceled.toString().split('.').last});

      batch.delete(userOrderRef);

      // Remove the order from the global all_orders collection
      batch.delete(allOrdersRef);

      await UserService().updateUserPoints(user.uid, -10);

      await batch.commit();

      _showSnackBar('Order has been canceled');
    } catch (e) {
      _showSnackBar('Error canceling order: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return RatingDialog(
          onSubmit: (rating, comment) async {
            final User? user = FirebaseAuth.instance.currentUser;

            if (user == null) {
              _showSnackBar('User not logged in');
              return;
            }

            await FirebaseFirestore.instance.collection('ratings').add({
              'userId': user.uid,
              'orderId': widget.order.id,
              'rating': rating,
              'comment': comment,
              'timestamp': FieldValue.serverTimestamp(),
            });

            _showSnackBar('Thank you for your feedback!');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Purchased Details',
        iconThemeColor: Theme.of(context).primaryColor,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: widget.order.imgAddress.isNotEmpty
                        ? Container(
                            width: 200,
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(widget.order.imgAddress),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : const Icon(Icons.image_not_supported, size: 200),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${widget.order.sku}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.order.shoeName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            Divider(color: Colors.black),
            Row(
              children: [
                _buildInfoColumn(widget.order.size, 'Size (US)'),
                _buildVerticalDivider(),
                _buildInfoColumn(widget.order.condition, 'Item Condition'),
                _buildVerticalDivider(),
                _buildInfoColumn(widget.order.packaging, 'Box Condition'),
              ],
            ),
            Divider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHIPPING DETAILS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.black),
                  _buildDetailItem('Tracking', widget.order.trackingId),
                  SizedBox(height: 8),
                  Container(
                    color: Colors.grey[300],
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How To Track Your Orders?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInstructionItem(1,
                            'The seller will ship out the order within 3 days.'),
                        _buildInstructionItem(2,
                            'You will be able to track your order via www.Gdex.com using the tracking code.'),
                        _buildInstructionItem(3,
                            'If you have any questions, contact us at SneakBay@gmail.com.'),
                        _buildInstructionItem(
                            4, 'Thank you for your purchase!'),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ORDER DETAILS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  _buildDetailItem('Order Number', widget.order.orderId),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  _buildDetailItem(
                    'Order Date',
                    widget.order.orderCreatedTimestamp.toString().split(' ')[0],
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  if (widget.order.status == OrderStatus.Confirmed)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Failure to meet the deadline will result in an auto-cancellation. Multiple cancellations may lead to account penalties.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _cancelOrder(context),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: Colors.black),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            elevation: 0,
                          ),
                          child: Text('CANCEL ORDER'),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  SizedBox(height: 16),
                  Text(
                    'Have you received your order?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: _showRatingDialog,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String description) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 45,
      color: Colors.black,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 17,
            color: Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

Widget _buildInstructionItem(int number, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number.',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
