import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final Function(String) onSaleTap;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onSaleTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use a set to filter out duplicate transactions
    final uniqueTransactionIds = <String>{};
    final uniqueTransactions = transactions.where((data) {
      if (uniqueTransactionIds.contains(data['id'])) {
        return false;
      } else {
        uniqueTransactionIds.add(data['id']);
        return true;
      }
    }).toList();

    return Column(
      children: [
        ...uniqueTransactions.map((data) {
          DateTime dateTime;
          if (data['date'] is Timestamp) {
            dateTime = (data['date'] as Timestamp).toDate();
          } else if (data['date'] is DateTime) {
            dateTime = data['date'] as DateTime;
          } else {
            dateTime = DateTime.now();
          }

          var formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
          var earnings = (data['amount'] as num?)?.toDouble() ?? 0.0;
          var transactionType = data['type'] ?? 'Sale';
          var isCashOut = transactionType == 'Cash Out';

          if (transactionType == 'Pending Credits') {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                    bottom: uniqueTransactions.last == data
                        ? BorderSide(color: Colors.black)
                        : BorderSide.none,
                  ),
                ),
                child: ListTile(
                  title: Text(transactionType),
                  trailing: Text(
                    '+RM ${earnings.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.black),
                    bottom: uniqueTransactions.last == data
                        ? BorderSide(color: Colors.black)
                        : BorderSide.none,
                  ),
                ),
                child: ListTile(
                  title: Text(transactionType),
                  subtitle: Text(formattedDate),
                  trailing: Text(
                    '${isCashOut ? '-' : '+'}RM ${earnings.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isCashOut ? Colors.red : Colors.green,
                      fontSize: 15,
                    ),
                  ),
                  onTap: transactionType == 'Sale'
                      ? () => onSaleTap(data['id'])
                      : null,
                ),
              ),
            );
          }
        }).toList(),
      ],
    );
  }
}
