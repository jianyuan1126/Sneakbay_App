import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../models/order_model.dart';
import '../../../widget/main_app_bar.dart';
import 'components/confirm_sale_bottom_sheet.dart';
import 'components/order_manager.dart';
import 'orders_list.dart';
import '../../../widget/custom_list_item.dart';
import '../../../widget/section.dart';
import '../../../widget/section_title.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late OrderManager _orderManager;

  @override
  void initState() {
    super.initState();
    _orderManager = OrderManager();
  }

  @override
  void dispose() {
    _orderManager.dispose();
    super.dispose();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      // Simulate a data refresh. Implement your data fetching logic here.
    });
  }

  Stream<List<OrderModel>> getPurchasedOrders(User user) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('purchased')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<OrderModel>> getReturnOrders(User user) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('returnOrders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<OrderModel>> getConfirmedOrders(User user) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('confirmedOrders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .where((order) =>
                order.status != OrderStatus.IssueDetectedandReturning)
            .toList());
  }

  Stream<List<OrderModel>> getClosedOrders(User user) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('closedOrders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .where((order) => order.status == OrderStatus.Closed)
            .toList());
  }

  Stream<List<OrderModel>> getSoldOrders(User user) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sold')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Orders',
          iconThemeColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
            child: Text('You need to be logged in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Orders',
        iconThemeColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                text: 'Orders Status',
              ),
              StreamBuilder<List<OrderModel>>(
                stream: getConfirmedOrders(user),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Open Orders', value: 'Error', onTap: () {}),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Open Orders',
                            value: 'Loading...',
                            onTap: () {}),
                      ],
                    );
                  }

                  int openOrdersCount = snapshot.data
                          ?.where((order) =>
                              order.status == OrderStatus.DroppedOff ||
                              order.status == OrderStatus.InTransit ||
                              order.status == OrderStatus.Confirmed ||
                              order.status ==
                                  OrderStatus.ArrivedandLegitChecking)
                          .length ??
                      0;

                  return StreamBuilder<List<OrderModel>>(
                    stream: getClosedOrders(user),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Section(
                          children: [
                            CustomListItem(
                                title: 'Closed Orders',
                                value: 'Error',
                                onTap: () {}),
                          ],
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Section(
                          children: [
                            CustomListItem(
                                title: 'Closed Orders',
                                value: 'Loading...',
                                onTap: () {}),
                          ],
                        );
                      }

                      int closedOrdersCount = snapshot.data?.length ?? 0;

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            children: [
                              CustomListItem(
                                title: 'Open Orders',
                                value: openOrdersCount.toString(),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrdersList(
                                        orderStatuses: [
                                          OrderStatus.DroppedOff,
                                          OrderStatus.InTransit,
                                          OrderStatus.Confirmed,
                                          OrderStatus.ArrivedandLegitChecking,
                                        ],
                                        title: 'Open Orders',
                                      ),
                                    ),
                                  );
                                },
                                isLastItem: false,
                              ),
                              CustomListItem(
                                title: 'Closed Orders',
                                value: closedOrdersCount.toString(),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrdersList(
                                        orderStatuses: [
                                          OrderStatus.Closed,
                                        ],
                                        title: 'Closed Orders',
                                      ),
                                    ),
                                  );
                                },
                                isLastItem: true,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SectionTitle(
                text: 'Purchased Orders',
              ),
              StreamBuilder<List<OrderModel>>(
                stream: getPurchasedOrders(user),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Purchased Orders',
                            value: 'Error',
                            onTap: () {}),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Purchased Orders',
                            value: 'Loading...',
                            onTap: () {}),
                      ],
                    );
                  }

                  int purchasedOrdersCount = snapshot.data?.length ?? 0;

                  return Section(
                    children: [
                      CustomListItem(
                        title: 'Purchased Orders',
                        value: purchasedOrdersCount.toString(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdersList(
                                orderStatuses: [
                                  OrderStatus.Purchased,
                                ],
                                title: 'Purchased Orders',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SectionTitle(
                text: 'Return Orders',
              ),
              StreamBuilder<List<OrderModel>>(
                stream: getReturnOrders(user),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Return Orders',
                            value: 'Error',
                            onTap: () {}),
                      ],
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Section(
                      children: [
                        CustomListItem(
                            title: 'Return Orders',
                            value: 'Loading...',
                            onTap: () {}),
                      ],
                    );
                  }

                  int returnOrdersCount = snapshot.data?.length ?? 0;

                  return Section(
                    children: [
                      CustomListItem(
                        title: 'Return Orders',
                        value: returnOrdersCount.toString(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdersList(
                                orderStatuses: [
                                  OrderStatus.IssueDetectedandReturning,
                                ],
                                title: 'Return Orders',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              StreamBuilder<List<OrderModel>>(
                stream: getSoldOrders(user),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SectionTitle(
                      text: 'Needs Action',
                    );
                  }

                  var soldOrders = snapshot.data ?? [];
                  if (soldOrders.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(
                        text: 'Needs Action',
                      ),
                      Container(
                        color: Colors.white,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: soldOrders.length,
                          itemBuilder: (context, index) {
                            var order = soldOrders[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Colors.black,
                                    width: 1), // Black border
                              ),
                              color: Colors
                                  .white, // Set the background color of the card
                              margin: const EdgeInsets.all(16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CONFIRM SALE BY ${order.orderCreatedTimestamp.add(const Duration(days: 1)).toString().split(' ')[0]}',
                                      style: const TextStyle(
                                        color: Colors.red,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '#${order.orderId}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                order.shoeName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
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
                                    ElevatedButton(
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) =>
                                              FractionallySizedBox(
                                            heightFactor: 0.65,
                                            child: ConfirmSaleBottomSheet(
                                                order: order),
                                          ),
                                        );
                                      },
                                      child: const Text('Confirm Sale'),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.black,
                                        minimumSize:
                                            const Size(double.infinity, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
