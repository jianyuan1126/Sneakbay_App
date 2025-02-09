import 'package:flutter/material.dart';

class TopSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const TopSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Search: Brand, Name, SKU',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
