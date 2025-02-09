import 'package:flutter/material.dart';
import '../../../../../../models/shoe_model.dart';

class SneakerWidget extends StatelessWidget {
  final ShoeModel shoe;

  const SneakerWidget({super.key, required this.shoe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.network(
              shoe.imgAddress,
              width: MediaQuery.of(context).size.width * 0.9,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            shoe.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            shoe.sku,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
