import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class IssueReportDialog extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  final Function(String, String, String,
      {String? returnTrackingId, String? issueDescription}) onUpdateStatus;

  IssueReportDialog({required this.orderDetails, required this.onUpdateStatus});

  @override
  _IssueReportDialogState createState() => _IssueReportDialogState();
}

class _IssueReportDialogState extends State<IssueReportDialog> {
  final TextEditingController _issueController = TextEditingController();

  String generateReturnTrackingId() {
    final random = Random();
    final randomNumber =
        random.nextInt(90000000) + 10000000; // Generates 8-digit number
    return 'GDEX$randomNumber';
  }

  Future<void> _reportIssue(BuildContext context) async {
    String issueDescription = _issueController.text.trim();

    if (issueDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an issue description')),
      );
      return;
    }

    String orderId = widget.orderDetails['orderId']?.toString() ?? '';
    String userId = widget.orderDetails['userId']?.toString() ?? '';

    // Log the orderDetails for debugging
    print('Order Details: ${widget.orderDetails}');

    try {
      // Generate return tracking ID
      String returnTrackingId = generateReturnTrackingId();

      // Fetch user data
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userAddress =
            userDoc['address'] as Map<String, dynamic>? ?? {};
        String userEmail = userDoc['email']?.toString() ?? '';

        // Log fetched data for debugging
        print('Fetched user data:');
        print('User Address: $userAddress');
        print('User Email: $userEmail');

        // Validate userAddress and userEmail
        if (userAddress.isEmpty) {
          throw 'User address is missing.';
        }
        if (userEmail.isEmpty) {
          throw 'User email is missing.';
        }

        // Ensure non-null values for order details
        widget.orderDetails.forEach((key, value) {
          if (value == null) {
            widget.orderDetails[key] = '';
            print('$key was null, replaced with empty string');
          }
        });

        // Remove the old tracking ID field and set the return tracking ID
        widget.orderDetails.remove('trackingId');
        widget.orderDetails['returnTrackingId'] = returnTrackingId;

        // Log the final order details
        print('Final Order Details: ${widget.orderDetails}');

        // Add the order to the 'all_returnOrders' collection for the admin
        await FirebaseFirestore.instance
            .collection('all_returnOrders')
            .doc(orderId)
            .set({
          ...widget.orderDetails,
          'status': 'IssueDetectedandReturning',
          'returnTrackingId': returnTrackingId,
          'issueDescription': issueDescription,
        });

        // Add the order to the user's 'returnOrders' collection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('returnOrders')
            .doc(orderId)
            .set({
          ...widget.orderDetails,
          'status': 'IssueDetectedandReturning',
          'returnTrackingId': returnTrackingId,
          'issueDescription': issueDescription,
        });

        // Update order status in the original collection
        await widget.onUpdateStatus(
            orderId, userId, 'IssueDetectedandReturning',
            returnTrackingId: returnTrackingId,
            issueDescription: issueDescription);

        Navigator.pop(context);
      } else {
        throw 'User document does not exist.';
      }
    } catch (e) {
      // Log the error
      print('Error reporting issue: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reporting issue: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        width: 400,
        height: 250,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  'Report an Issue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _issueController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Issue Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _reportIssue(context),
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
