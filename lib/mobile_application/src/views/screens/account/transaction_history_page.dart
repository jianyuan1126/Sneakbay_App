import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widget/main_app_bar.dart';
import 'component/sale_details.dart';
import 'component/transaction_list_widget.dart';

class TransactionHistoryPage extends StatelessWidget {
  final String userId;

  const TransactionHistoryPage({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> _fetchTransactions(String userId) async {
    double pendingCredits = 0;

    // Fetch all transactions from 'transactions' collection
    final transactionSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    // Fetch all closed orders from 'closedOrders' collection
    final closedOrdersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('closedOrders')
        .orderBy('orderConfirmedTimestamp', descending: true)
        .get();

    // Fetch pending credits from 'sold' collection
    final soldCollection = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('sold')
        .where('status', isEqualTo: 'Pending')
        .get();

    // Sum pending credits from sold collection
    soldCollection.docs.forEach((doc) {
      pendingCredits += (doc['earnings'] as num? ?? 0).toDouble();
    });

    // Sum earnings from confirmed orders
    final confirmedCollection = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('confirmedOrders')
        .get();
    confirmedCollection.docs.forEach((doc) {
      pendingCredits += (doc['earnings'] as num? ?? 0).toDouble();
    });

    // Combine both lists, ensuring no duplicates
    final allDocuments = transactionSnapshot.docs
        .map((doc) => doc.data()..['id'] = doc.id)
        .toList();
    closedOrdersSnapshot.docs.forEach((doc) {
      final data = doc.data()..['id'] = doc.id;
      if (!allDocuments.any((d) => d['id'] == data['id'])) {
        data['date'] =
            data['orderConfirmedTimestamp']; // Ensure correct date field
        data['amount'] = data['earnings']; // Ensure correct amount field
        data['type'] = 'Sale'; // Set type to 'Sale'
        allDocuments.add(data);
      }
    });

    // Add pending credits as a transaction at the beginning
    if (pendingCredits > 0) {
      allDocuments.insert(0, {
        'id': 'pendingCredits',
        'amount': pendingCredits,
        'type': 'Pending Credits',
        'date': DateTime.now(),
      });
    }

    // Sort transactions by date, with pending credits always at the top
    allDocuments.sort((a, b) {
      if (a['id'] == 'pendingCredits') return -1;
      if (b['id'] == 'pendingCredits') return 1;
      return (b['date'] as Timestamp).compareTo(a['date'] as Timestamp);
    });

    print('Transactions fetched: ${allDocuments.length}');
    return allDocuments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Transaction History',
        backgroundColor: Colors.white,
        iconThemeColor: Colors.black,
        showBackButton: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading transactions'));
          }

          final transactionsAvailable =
              snapshot.hasData && snapshot.data!.isNotEmpty;

          if (!transactionsAvailable) {
            return const Center(child: Text('No transactions found'));
          }

          final transactions = snapshot.data!;
          return SingleChildScrollView(
            child: TransactionList(
              transactions: transactions,
              onSaleTap: (orderId) => showSaleDetails(context, userId, orderId),
            ),
          );
        },
      ),
    );
  }
}
