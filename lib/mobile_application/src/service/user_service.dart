import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> userStream(String uid) {
    print('Listening to user stream for uid: $uid');
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      print('Snapshot received: ${snapshot.exists}');
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Future<UserModel> getUser(String uid) async {
    print('Fetching user data for uid: $uid');
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    print('Document fetched: ${doc.exists}');
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserPoints(String uid, int points) async {
    DocumentReference userRef = _firestore.collection('users').doc(uid);

    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      int newPoints =
          (snapshot.data() as Map<String, dynamic>)['points'] + points;

      // Check if points are below or equal to 0
      String newStatus = newPoints <= 0 ? 'banned' : 'active';

      transaction.update(userRef, {
        'points': newPoints,
        'status': newStatus,
      });

      // Automatically log out the user if they are banned
      if (newStatus == 'banned') {
        FirebaseAuth.instance.signOut();
      }
    });
  }

  Future<void> handleOrderCancellation(String uid) async {
    await updateUserPoints(uid, -10);
  }

  Future<void> handleSuccessfulSale(String uid) async {
    await updateUserPoints(uid, 2);
  }

  Future<void> updateUserCurrency(String uid, double currency) async {
    DocumentReference userRef = _firestore.collection('users').doc(uid);
    return _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }
      transaction.update(userRef, {'availableCurrency': currency});
    });
  }

  Future<void> logTransaction(String uid, String type, double amount) async {
    DocumentReference userRef = _firestore.collection('users').doc(uid);
    CollectionReference transactionsRef = userRef.collection('transactions');

    await transactionsRef.add({
      'type': type,
      'amount': amount,
      'date': DateTime.now(),
    });
  }
}
