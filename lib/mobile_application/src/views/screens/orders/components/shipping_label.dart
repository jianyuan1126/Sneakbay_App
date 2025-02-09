import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:barcode/barcode.dart';
import '../../../../../../../../models/order_model.dart';
import '../../../../../../../../models/user_model.dart';

class ShippingLabel extends StatelessWidget {
  final OrderModel order;
  final String trackingId;

  ShippingLabel({required this.order, required this.trackingId});

  Future<UserModel> _fetchUser(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return UserModel.fromFirestore(userDoc);
  }

  @override
  Widget build(BuildContext context) {
    final barcode = Barcode.code128();
    final svg = barcode.toSvg(
      trackingId,
      width: 300,
      height: 80,
    );

    return FutureBuilder<UserModel>(
      future: _fetchUser(order.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.hasError) {
          return Center(child: Text('Error fetching user data'));
        }

        UserModel user = snapshot.data!;

        return RepaintBoundary(
          key: GlobalKey(), // Add a global key to capture the widget
          child: Container(
            width: 400, // Adjust the width to desired size
            height: 500, // Adjust the height to desired size
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text('Gdex',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Text('www.Gdex.com'),
                    ],
                  ),
                ),
                Divider(thickness: 2),
                Text('FROM:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(user.name),
                Text(
                    '${user.address!.streetAddress1}, ${user.address?.streetAddress2 ?? ''}'),
                Text(
                    '${user.address?.city}, ${user.address?.state}, ${user.address?.postalCode}'),
                Text('Contact: ${user.phoneNumber}'),
                Divider(thickness: 2),
                Text('TO:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('SneakBay'),
                Text('Nadayu28 residences, Lot Warehouse C,'),
                Text('3, Jalan PJS 11/9, Bandar Sunway,'),
                Text('47500, Selangor, Malaysia'),
                Divider(thickness: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ITEM CATEGORY:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Fashion Footwear'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL WEIGHT:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('1.80 kg'),
                      ],
                    ),
                  ],
                ),
                Divider(thickness: 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ORDER ID:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(order.orderId),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GDEX:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(trackingId),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 80,
                      child: SvgPicture.string(svg),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
