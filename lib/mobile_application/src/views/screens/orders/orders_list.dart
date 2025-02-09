import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../models/order_model.dart';
import '../../../widget/main_app_bar.dart';
import 'closed_order_details.dart';
import 'components/confirm_drop_off_bottom_sheet.dart';
import 'order_details.dart';
import 'purchased_order_detail_page.dart';
import 'return_order_details.dart';

class OrdersList extends StatelessWidget {
  final List<OrderStatus> orderStatuses;
  final String title;

  const OrdersList({required this.orderStatuses, required this.title, Key? key})
      : super(key: key);

  Stream<List<OrderModel>> getOrders(User user) {
    String collectionName;
    if (orderStatuses.contains(OrderStatus.Closed)) {
      collectionName = 'closedOrders';
    } else if (orderStatuses.contains(OrderStatus.Confirmed) ||
        orderStatuses.contains(OrderStatus.DroppedOff) ||
        orderStatuses.contains(OrderStatus.InTransit) ||
        orderStatuses.contains(OrderStatus.ArrivedandLegitChecking)) {
      collectionName = 'confirmedOrders';
    } else if (orderStatuses.contains(OrderStatus.Pending)) {
      collectionName = 'pendingOrders';
    } else if (orderStatuses.contains(OrderStatus.Purchased)) {
      collectionName = 'purchased';
    } else if (orderStatuses.contains(OrderStatus.IssueDetectedandReturning)) {
      collectionName = 'returnOrders';
    } else {
      collectionName = 'orders';
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .where((order) => orderStatuses.contains(order.status))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: title,
          iconThemeColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
          child: Text('You need to be logged in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        iconThemeColor: Theme.of(context).primaryColor,
        showBackButton: true,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: getOrders(user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          var orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              return GestureDetector(
                onTap: () {
                  if (order.status == OrderStatus.Purchased) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseDetailsPage(order: order),
                      ),
                    );
                  } else if (order.status ==
                      OrderStatus.IssueDetectedandReturning) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReturnOrderDetailsPage(order: order),
                      ),
                    );
                  } else if (order.status == OrderStatus.Closed) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ClosedOrderDetailsPage(order: order),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), // Add black border
                    borderRadius: BorderRadius.circular(4.0), // Optional: Add border radius
                  ),
                  margin: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.status == OrderStatus.Pending ||
                              order.status == OrderStatus.Confirmed)
                            Text(
                              'SHIP BY ${order.orderCreatedTimestamp.add(const Duration(days: 3)).toString().split(' ')[0]}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else
                            Text(
                              order.status.toString().split('.').last,
                              style: TextStyle(
                                color: getStatusColor(order.status),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              order.imgAddress.isNotEmpty
                                  ? Image.network(
                                      order.imgAddress,
                                      width: 100,
                                      height: 50,
                                      fit: BoxFit.contain,
                                    )
                                  : const Icon(
                                      Icons.image_not_supported,
                                      size: 100,
                                    ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '#${order.orderId}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      order.shoeName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      '${order.size} | ${order.condition} | ${order.packaging}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          if (order.status == OrderStatus.Confirmed)
                            ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      child:
                                          ConfirmDropOffBottomSheet(order: order),
                                    );
                                  },
                                );
                              },
                              child: const Text('Dropped Off At SneakBay'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.DroppedOff:
        return Colors.blue;
      case OrderStatus.ArrivedandLegitChecking:
        return Colors.green;
      case OrderStatus.IssueDetectedandReturning:
        return Colors.red;
      case OrderStatus.Closed:
        return Colors.grey;
      case OrderStatus.InTransit:
        return Colors.purple;
      case OrderStatus.Pending:
        return Colors.orange;
      case OrderStatus.Confirmed:
        return Colors.yellow;
      default:
        return Colors.black;
    }
  }
}
