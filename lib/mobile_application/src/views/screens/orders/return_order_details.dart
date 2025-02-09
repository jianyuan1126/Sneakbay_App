import 'package:flutter/material.dart';
import '../../../../../models/order_model.dart';
import '../../../widget/main_app_bar.dart';

class ReturnOrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  ReturnOrderDetailsPage({required this.order, Key? key}) : super(key: key);

  @override
  _ReturnOrderDetailsPageState createState() => _ReturnOrderDetailsPageState();
}

class _ReturnOrderDetailsPageState extends State<ReturnOrderDetailsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Return Order Details',
        iconThemeColor: Theme.of(context).primaryColor,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: widget.order.imgAddress.isNotEmpty
                        ? Container(
                            width: 200,
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(widget.order.imgAddress),
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : const Icon(Icons.image_not_supported, size: 200),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      '${widget.order.sku}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.order.shoeName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            Divider(color: Colors.black),
            Row(
              children: [
                _buildInfoColumn(widget.order.size, 'Size (US)'),
                _buildVerticalDivider(),
                _buildInfoColumn(widget.order.condition, 'Item Condition'),
                _buildVerticalDivider(),
                _buildInfoColumn(widget.order.packaging, 'Box Condition'),
              ],
            ),
            Divider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RETURN DETAILS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.black),
                  _buildDetailItem('Return Tracking',
                      widget.order.returnTrackingId ?? 'N/A'),
                  SizedBox(height: 8),
                  _buildDetailItem('Issue Description',
                      widget.order.issueDescription ?? 'N/A'),
                  SizedBox(height: 8),
                  Container(
                    color: Colors.grey[300],
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Why is Your Order Returned?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInstructionItem(1,
                            'We have detected some issues about your shoes.'),
                        _buildInstructionItem(2,
                            'The issue detected was: ${widget.order.issueDescription ?? 'N/A'}.'),
                        _buildInstructionItem(3,
                            'For more information, contact us at SneakBay@gmail.com.'),
                        _buildInstructionItem(
                            4, 'Thank you for your understanding.'),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ORDER DETAILS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  _buildDetailItem('Order Number', widget.order.orderId),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  _buildDetailItem(
                    'Order Date',
                    widget.order.orderCreatedTimestamp.toString().split(' ')[0],
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String description) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 45,
      color: Colors.black,
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 17,
            color: Colors.grey[800],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number.',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
