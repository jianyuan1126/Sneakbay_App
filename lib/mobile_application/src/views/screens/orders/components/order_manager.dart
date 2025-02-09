import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../models/order_model.dart';
import '../../../../service/user_service.dart';

class OrderManager {
  Timer? _timer;

  OrderManager() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkAndCancelOrders();
    });
  }

  Future<void> _checkAndCancelOrders() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pendingOrders')
        .get();

    for (var orderDoc in ordersSnapshot.docs) {
      var orderData = orderDoc.data() as Map<String, dynamic>;

      var currentTime = DateTime.now();
      var orderCreatedTimestamp =
          (orderData['orderCreatedTimestamp'] as Timestamp).toDate();

      String orderStatus = orderData['status'] ?? '';

      if (orderStatus == OrderStatus.Pending.toString().split('.').last &&
          currentTime.difference(orderCreatedTimestamp).inDays >= 1) {
        await _cancelOrder(orderDoc.reference, user.uid);
      }

      if (orderStatus == OrderStatus.Confirmed.toString().split('.').last &&
          orderData['orderConfirmedTimestamp'] != null) {
        var orderConfirmedTimestamp =
            (orderData['orderConfirmedTimestamp'] as Timestamp).toDate();

        if (currentTime.difference(orderConfirmedTimestamp).inDays >= 3) {
          await _cancelOrder(orderDoc.reference, user.uid);
        }
      }

      if (orderStatus == OrderStatus.DroppedOff.toString().split('.').last &&
          orderData['orderDroppedOffTimestamp'] != null) {
        var orderDroppedOffTimestamp =
            (orderData['orderDroppedOffTimestamp'] as Timestamp).toDate();

        if (currentTime.difference(orderDroppedOffTimestamp).inDays >= 2) {
          await _cancelOrder(orderDoc.reference, user.uid);
        }
      }
    }
  }

  Future<void> _cancelOrder(DocumentReference orderRef, String uid) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Update the status to canceled
    batch.update(
        orderRef, {'status': OrderStatus.Canceled.toString().split('.').last});

    // Remove the order from the appropriate collection
    String collectionPrefix = orderRef.path.contains('pendingOrders')
        ? 'pendingOrders'
        : orderRef.path.contains('confirmedOrders')
            ? 'confirmedOrders'
            : 'droppedOffOrders';

    DocumentReference allOrdersRef = FirebaseFirestore.instance
        .collection('all_$collectionPrefix')
        .doc(orderRef.id);
    batch.delete(allOrdersRef);

    // Remove the order from the user's collection
    batch.delete(orderRef);

    await batch.commit();

    // Deduct points from the user
    await UserService().updateUserPoints(uid, -10);
  }

  Stream<List<OrderModel>> getPendingOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
          code: 'NO_USER', message: 'No user logged in.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pendingOrders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<OrderModel>> getConfirmedOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
          code: 'NO_USER', message: 'No user logged in.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('confirmedOrders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<OrderModel>> getPurchasedOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
          code: 'NO_USER', message: 'No user logged in.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('purchased')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<OrderModel>> getReturnOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
          code: 'NO_USER', message: 'No user logged in.');
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('returnOrders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  void dispose() {
    _timer?.cancel();
  }
}
