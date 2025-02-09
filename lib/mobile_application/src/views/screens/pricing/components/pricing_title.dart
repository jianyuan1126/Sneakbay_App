// pricing_title.dart
import 'package:flutter/material.dart';

class PricingTitle extends StatelessWidget {
  final String sku;
  final String size;
  final String condition;
  final String packaging;

  const PricingTitle({
    super.key,
    required this.sku,
    required this.size,
    required this.condition,
    required this.packaging,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          sku,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        Text(
          '$size | $condition | $packaging',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
