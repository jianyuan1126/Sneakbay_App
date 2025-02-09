import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../models/order_model.dart';
import '../../../service/user_service.dart';
import '../../../widget/main_app_bar.dart';
import 'components/earnings_details_widget.dart';

class OrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  OrderDetailsPage({required this.order, Key? key}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isEarningsExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _confirmDropOff(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order not found')),
        );
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference userOrderRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('confirmedOrders')
          .doc(widget.order.id);
      batch.update(userOrderRef, {
        'status': OrderStatus.DroppedOff.toString().split('.').last,
        'orderDroppedOffTimestamp': Timestamp.now(),
      });

      DocumentReference allOrdersRef = FirebaseFirestore.instance
          .collection('all_confirmedOrders')
          .doc(widget.order.id);
      batch.update(allOrdersRef, {
        'status': OrderStatus.DroppedOff.toString().split('.').last,
        'orderDroppedOffTimestamp': Timestamp.now(),
      });

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order marked as dropped off')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error confirming drop off: $e')),
      );
    }
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order not found')),
        );
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

      // Remove the order from the user's orders collection
      batch.delete(userOrderRef);

      // Remove the order from the global all_orders collection
      batch.delete(allOrdersRef);

      await UserService().updateUserPoints(user.uid, -10);

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order has been canceled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error canceling order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:
            'SHIP BY ${widget.order.orderCreatedTimestamp.add(Duration(days: 3)).toString().split(' ')[0]}',
        iconThemeColor: Theme.of(context).primaryColor,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
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
                  Container(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        widget.order.shoeName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
                _buildInfoColumn(widget.order.size, 'Size (US M)'),
                _buildVerticalDivider(),
                _buildInfoColumn(widget.order.condition, 'Item Condition'),
                _buildVerticalDivider(),
                _buildInfoColumn(widget.order.packaging, 'Box Condition'),
              ],
            ),
            Divider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'SHIPPING DETAILS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.black),
                  _buildDetailItem(
                      'Ship By',
                      widget.order.orderCreatedTimestamp
                          .add(Duration(days: 3))
                          .toString()
                          .split(' ')[0]),
                  Divider(color: Colors.black),
                  _buildDetailItem(
                      'Method', widget.order.fulfillmentMethod ?? 'Unknown'),
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
                          'Shipping Instructions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInstructionItem(1,
                            'Print the shipping label and packing slip sent to your email.'),
                        _buildInstructionItem(2,
                            'Place your item in either a box or bag. Include the packing slip as well as any item accessories, if applicable.'),
                        _buildInstructionItem(3,
                            'Seal the package and attach the shipping label to the outside of the box.'),
                        _buildInstructionItem(
                            4, 'Drop it off at the nearest carrier.'),
                        _buildInstructionItem(5,
                            'Confirm you’ve dropped off your item at the correct carrier by clicking the button below.'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.black),
                  SizedBox(height: 5),
                  _buildEarningsSection(),
                  SizedBox(height: 16),
                  Text(
                    'ORDER DETAILS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  SizedBox(height: 5),
                  _buildDetailItem('Order Number', widget.order.orderId),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  SizedBox(height: 5),
                  _buildDetailItem(
                      'Order Date',
                      widget.order.orderCreatedTimestamp
                          .add(Duration(days: 1))
                          .toString()
                          .split(' ')[0]),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  if (widget.order.status == OrderStatus.Confirmed)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Failure to meet the deadline will result in an auto-cancellation. Multiple cancellations may lead to account penalties.',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[800]),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _cancelOrder(context),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: Colors.black),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
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
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (widget.order.status == OrderStatus.Confirmed)
          ? Container(
              height: 59,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              child: BottomAppBar(
                color: Colors.white,
                child: InkWell(
                  onTap: () => _confirmDropOff(context),
                  child: Center(
                    child: Text(
                      'Dropped Off At SneakBay',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoColumn(String value, String description) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.black),
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
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 17,
                color: Colors.grey[800])),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black)),
      ],
    );
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

  Widget _buildEarningsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isEarningsExpanded = !_isEarningsExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EARNINGS',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[800],
                ),
              ),
              Icon(
                _isEarningsExpanded ? Icons.remove : Icons.add,
                size: 24,
              ),
            ],
          ),
        ),
        if (_isEarningsExpanded) EarningsDetailsWidget(order: widget.order),
      ],
    );
  }
}
