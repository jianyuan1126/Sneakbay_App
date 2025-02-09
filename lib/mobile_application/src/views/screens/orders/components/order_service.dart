import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateOrderId() {
    final random = Random();
    final orderId = List<int>.generate(8, (_) => random.nextInt(10)).join();
    return orderId;
  }

  Future<void> createOrder(
      Map<String, dynamic> orderData, String userId) async {
    String orderId = generateOrderId();
    orderData['orderId'] = orderId;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    Map<String, dynamic> userAddress = userDoc['address'];
    String userEmail = userDoc['email'];

    orderData['userAddress'] = userAddress;
    orderData['userEmail'] = userEmail;

    String collectionName = 'pendingOrders';
    if (orderData['status'] == 'confirmed') {
      collectionName = 'confirmedOrders';
    } else if (orderData['status'] == 'closed') {
      collectionName = 'closedOrders';
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection(collectionName)
        .doc(orderId)
        .set(orderData);
    await _firestore
        .collection('all_$collectionName')
        .doc(orderId)
        .set(orderData);
  }

  Future<void> moveOrder(
      String userId, String orderId, String fromCollection, String toCollection,
      [Map<String, dynamic>? updateData]) async {
    DocumentReference orderRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(fromCollection)
        .doc(orderId);
    DocumentSnapshot orderSnapshot = await orderRef.get();

    if (orderSnapshot.exists) {
      Map<String, dynamic> orderData =
          orderSnapshot.data() as Map<String, dynamic>;

      // Update the status and merge with additional updateData if provided
      if (toCollection == 'confirmedOrders') {
        orderData['status'] = 'confirmed';
      } else if (toCollection == 'closedOrders') {
        orderData['status'] = 'closed';
      }

      if (updateData != null) {
        orderData.addAll(updateData);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection(toCollection)
          .doc(orderId)
          .set(orderData);
      await _firestore
          .collection('all_$toCollection')
          .doc(orderId)
          .set(orderData);
      await orderRef.delete();
      await _firestore.collection('all_$fromCollection').doc(orderId).delete();
    }
  }

  Future<void> updateOrderStatus(
      String userId, String orderId, OrderStatus newStatus) async {
    String fromCollection = '';
    String toCollection = '';

    if (newStatus == OrderStatus.Pending) {
      fromCollection = 'confirmedOrders';
      toCollection = 'pendingOrders';
    } else if (newStatus == OrderStatus.Confirmed ||
        newStatus == OrderStatus.DroppedOff ||
        newStatus == OrderStatus.IssueDetectedandReturning ||
        newStatus == OrderStatus.InTransit ||
        newStatus == OrderStatus.ArrivedandLegitChecking) {
      fromCollection = 'pendingOrders';
      toCollection = 'confirmedOrders';
    } else if (newStatus == OrderStatus.Closed) {
      fromCollection = 'confirmedOrders';
      toCollection = 'closedOrders';
    }

    await moveOrder(userId, orderId, fromCollection, toCollection);
  }
}
