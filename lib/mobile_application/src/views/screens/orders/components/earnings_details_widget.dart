import 'package:flutter/material.dart';
import '../../../../../../models/order_model.dart';

class EarningsDetailsWidget extends StatelessWidget {
  final OrderModel order;

  const EarningsDetailsWidget({required this.order});

  @override
  Widget build(BuildContext context) {
    double sellingPrice = order.price;
    double commission = sellingPrice * 0.05;
    double sellerFee = 5.0;
    double cashOutFeePercent = 0.02;
    double earnings = sellingPrice - commission - sellerFee;
    double cashOutFee = earnings * cashOutFeePercent;
    double finalCashOutAmount = earnings - cashOutFee;

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningsDetailRow('Selling Price', sellingPrice),
          _buildEarningsDetailRow('Commission (5%)', -commission),
          _buildEarningsDetailRow('Seller Fee', -sellerFee),
          Divider(color: Colors.black),
          _buildEarningsDetailRow('Earnings', earnings),
          _buildEarningsDetailRow('Cash Out Fee (2%)', -cashOutFee),
          Divider(color: Colors.black),
          _buildEarningsDetailRow('Final Cash Out Amount', finalCashOutAmount),
        ],
      ),
    );
  }

  Widget _buildEarningsDetailRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
