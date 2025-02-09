import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/shoe_model.dart';

import '../../detail/detail_screen.dart';

class ShoeListItem extends StatelessWidget {
  final ShoeModel shoe;

  const ShoeListItem({super.key, required this.shoe});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              shoeId: shoe.id,
              isComeFromMoreSection: true,
            ),
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        height: 120,
        child: Card(
          color: Colors.white, // Set the card background color to white
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Rounded border
            side: const BorderSide(color: Colors.black),
          ),
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.network(
                  shoe.imgAddress,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        shoe.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Set text color to black
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shoe.sku,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black, // Set text color to black
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Colors.black), // Set icon color to black
              ],
            ),
          ),
        ),
      ),
    );
  }
}
