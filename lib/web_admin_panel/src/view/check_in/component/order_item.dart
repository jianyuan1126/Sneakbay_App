import 'package:flutter/material.dart';
import 'issue_report_dialog.dart';

class OrderItem extends StatelessWidget {
  final Map<String, dynamic> orderDetails;
  final Function(String, String, String,
      {String? returnTrackingId, String? issueDescription}) onUpdateStatus;

  OrderItem({required this.orderDetails, required this.onUpdateStatus});

  void _showIssueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return IssueReportDialog(
          orderDetails: orderDetails,
          onUpdateStatus: onUpdateStatus,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        title: Text('Order ID: ${orderDetails['orderId']}'),
        subtitle: Text('Status: ${orderDetails['status']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderDetailRow('User ID', orderDetails['userId']),
                _buildOrderDetailRow('User Name', orderDetails['userName']),
                _buildOrderDetailRow('Email', orderDetails['userEmail']),
                _buildOrderDetailRow('Shoe Name', orderDetails['shoeName']),
                _buildOrderDetailRow('SKU', orderDetails['sku']),
                _buildOrderDetailRow('Size', orderDetails['size']),
                _buildOrderDetailRow('Condition', orderDetails['condition']),
                _buildOrderDetailRow('Packaging', orderDetails['packaging']),
                _buildOrderDetailRow('Price', '\$${orderDetails['price']}'),
                _buildOrderDetailRow(
                    'Status', orderDetails['status'].toString()),
                _buildOrderDetailRow(
                    'Tracking ID', orderDetails['trackingId'] ?? 'N/A'),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () => onUpdateStatus(orderDetails['orderId'],
                          orderDetails['userId'], 'ArrivedandLegitChecking'),
                      child: Text('Arrived and Legit Checking'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showIssueDialog(context),
                      child: Text('Issue Detected and Returning'),
                    ),
                    ElevatedButton(
                      onPressed: () => onUpdateStatus(orderDetails['orderId'],
                          orderDetails['userId'], 'Closed'),
                      child: Text('Closed'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value?.toString() ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}
