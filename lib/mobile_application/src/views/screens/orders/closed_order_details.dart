import 'package:flutter/material.dart';
import '../../../../../models/order_model.dart';
import '../../../widget/main_app_bar.dart';
import 'components/earnings_details_widget.dart';

class ClosedOrderDetailsPage extends StatefulWidget {
  final OrderModel order;

  ClosedOrderDetailsPage({required this.order, Key? key}) : super(key: key);

  @override
  _ClosedOrderDetailsPageState createState() => _ClosedOrderDetailsPageState();
}

class _ClosedOrderDetailsPageState extends State<ClosedOrderDetailsPage> {
  bool _isEarningsExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Details',
        iconThemeColor: Theme.of(context).primaryColor,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
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
                  Container(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        widget.order.shoeName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
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
                _buildInfoColumn(widget.order.size, 'Size (US M)'),
                _buildVerticalDivider(),
                _buildInfoColumn(widget.order.condition, 'Item Condition'),
                _buildVerticalDivider(),
                _buildInfoColumn(widget.order.packaging, 'Box Condition'),
              ],
            ),
            Divider(color: Colors.black),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildEarningsSection(),
                  Divider(color: Colors.black),
                  SizedBox(height: 20),
                  Text(
                    'SHIPPING DETAILS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.black),
                  _buildDetailItem('Tracking', widget.order.trackingId),
                  Divider(color: Colors.black),
                  SizedBox(height: 16),
                  Text(
                    'ORDER DETAILS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  SizedBox(height: 5),
                  _buildDetailItem('Order Number', widget.order.orderId),
                  SizedBox(height: 5),
                  Divider(color: Colors.black),
                  SizedBox(height: 5),
                  _buildDetailItem(
                      'Order Date',
                      widget.order.orderCreatedTimestamp
                          .add(Duration(days: 1))
                          .toString()
                          .split(' ')[0]),
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: Colors.black),
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
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 17,
                color: Colors.grey[800])),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black)),
      ],
    );
  }

  Widget _buildEarningsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isEarningsExpanded = !_isEarningsExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EARNINGS',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey[800],
                ),
              ),
              Icon(
                _isEarningsExpanded ? Icons.remove : Icons.add,
                size: 24,
              ),
            ],
          ),
        ),
        if (_isEarningsExpanded) EarningsDetailsWidget(order: widget.order),
      ],
    );
  }
}
