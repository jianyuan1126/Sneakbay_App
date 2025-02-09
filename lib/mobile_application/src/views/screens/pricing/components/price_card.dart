// price_card.dart
import 'package:flutter/material.dart';

class PriceCard extends StatelessWidget {
  final String title;
  final String price;

  const PriceCard({
    super.key,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        height: 90,
        width: 95,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 4),
            Text(price,
                style: const TextStyle(color: Colors.black87, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
