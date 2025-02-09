import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../models/order_model.dart';
import 'pdf_generator.dart';

class ConfirmSaleBottomSheet extends StatefulWidget {
  final OrderModel order;

  const ConfirmSaleBottomSheet({required this.order, Key? key})
      : super(key: key);

  @override
  _ConfirmSaleBottomSheetState createState() => _ConfirmSaleBottomSheetState();
}

class _ConfirmSaleBottomSheetState extends State<ConfirmSaleBottomSheet> {
  bool isDropOffSelected = false;
  bool isShipNowSelected = false;
  bool isLoading = false;
  final pdfGenerator = PDFGenerator();

  Future<void> _confirmSale(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch user address and name
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.order.userId)
          .get();

      if (userDoc.exists &&
          userDoc['address'] != null &&
          userDoc['name'] != null &&
          userDoc['email'] != null) {
        var userAddress = userDoc['address'];
        var userName = userDoc['name']; // Fetch user name
        var userEmail = userDoc['email']; // Fetch user email

        // Generate tracking ID
        String trackingId = 'GDEX${_generateTrackingNumber()}';

        // Determine the fulfillment method
        String fulfillmentMethod = isDropOffSelected ? 'Drop Off' : 'Shipping';

        // Create update data map
        Map<String, dynamic> updateData = {
          'status': OrderStatus.Confirmed.toString().split('.').last,
          'orderConfirmedTimestamp': Timestamp.now(),
          'trackingId': trackingId,
          'fulfillmentMethod': fulfillmentMethod,
          'userName': userName, // Include user name in update
        };

        // Update the order object with the user name and email
        widget.order.userName = userName;
        widget.order.userEmail = userEmail;

        bool emailSent = false;
        if (isDropOffSelected) {
          emailSent = await pdfGenerator.generateDropOffPdf(
              context, widget.order, userAddress, trackingId);
        } else if (isShipNowSelected) {
          emailSent = await pdfGenerator.generateShippingPdf(
              context, widget.order, userAddress, trackingId);
        }

        if (emailSent) {
          // Add the order to all_confirmedOrders and confirmedOrders collections
          await FirebaseFirestore.instance
              .collection('all_confirmedOrders')
              .doc(widget.order.id)
              .set({
            ...widget.order.toJson(), // Copy existing order data
            ...updateData, // Merge with the update data
            'userAddress': userAddress, // Include user address if needed
            'earnings': widget.order.earnings, // Include earnings
          }, SetOptions(merge: true));

          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.order.userId)
              .collection('confirmedOrders')
              .doc(widget.order.id)
              .set({
            ...widget.order.toJson(), // Copy existing order data
            ...updateData, // Merge with the update data
            'userAddress': userAddress, // Include user address if needed
            'earnings': widget.order.earnings, // Include earnings
          }, SetOptions(merge: true));

          // Remove the order from all_sold and sold collections
          await FirebaseFirestore.instance
              .collection('all_sold')
              .doc(widget.order.id)
              .delete();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.order.userId)
              .collection('sold')
              .doc(widget.order.id)
              .delete();

          Navigator.pop(context);
        } else {
          // Handle the case where email was not sent
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send confirmation email.'),
            ),
          );
        }
      } else {
        // Handle the case where user data is not available
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data is incomplete.'),
          ),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _generateTrackingNumber() {
    final random = Random();
    final trackingNumber = List.generate(8, (_) => random.nextInt(10)).join();
    return trackingNumber;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
                'Confirm Details by ${DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0]}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            widget.order.imgAddress.isNotEmpty
                ? Image.network(widget.order.imgAddress,
                    width: 100, height: 50, fit: BoxFit.contain)
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 16),
            Center(
              child: Text(
                widget.order.shoeName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Text('Size',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(widget.order.size,
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Text('Condition',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(widget.order.condition,
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Text('Box',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(widget.order.packaging,
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Price: RM${widget.order.price.toInt()}'),
            const Divider(),
            const Text('SELECT A FULFILLMENT METHOD:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Drop Off in Person'),
              trailing: Checkbox(
                value: isDropOffSelected,
                onChanged: (bool? value) {
                  setState(() {
                    isDropOffSelected = value ?? false;
                    isShipNowSelected = !isDropOffSelected;
                  });
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Ship Now'),
              trailing: Checkbox(
                value: isShipNowSelected,
                onChanged: (bool? value) {
                  setState(() {
                    isShipNowSelected = value ?? false;
                    isDropOffSelected = !isShipNowSelected;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () => _confirmSale(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Confirm Sale'),
            ),
          ],
        ),
      ),
    );
  }
}
