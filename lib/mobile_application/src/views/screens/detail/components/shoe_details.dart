import 'package:flutter/material.dart';
import '../../../../../../models/shoe_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ShoeDetails extends StatelessWidget {
  final ShoeModel model;

  const ShoeDetails({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    List<Widget> details = [
      buildDetailItem('SKU', model.sku),
      buildDetailItem(
          'Retail Price', '\RM ${model.retailPrice.toStringAsFixed(2)}'),
      buildDetailItem('Release Date', model.releaseDate),
      buildDetailItem('Colorway', model.colorway),
      buildDetailItem('Brand', model.brand),
    ];

    return Column(
      children: details
          .expand((widget) =>
              [widget, const Divider(thickness: 1, color: Colors.black)])
          .toList(),
    );
  }

  Widget buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.normal,
                fontSize: 17,
                color: Colors.grey),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 17,
                  color: Colors.black87),
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
