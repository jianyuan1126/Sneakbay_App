import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/common_enums.dart';

class SizeSelectionWidget extends StatelessWidget {
  final ShoeSizeCategory category;
  final String? selectedSize;
  final Function(String) onSizeSelected;

  const SizeSelectionWidget({
    super.key,
    required this.category,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = predefinedSizes[category]
            ?.map((size) => size.toString().replaceAll('.0', ''))
            .toList() ??
        [];
    final double chipWidth = (MediaQuery.of(context).size.width - 72) / 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Size (US)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8.0,
          children: sizes.map((size) {
            bool isSelected = size == selectedSize;
            return SizedBox(
              width: chipWidth,
              child: ChoiceChip(
                label: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      overflow: TextOverflow
                          .ellipsis, // Ensure text fits within the chip
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  onSizeSelected(size);
                },
                selectedColor: Colors.black, // Custom selected color
                backgroundColor: Colors.white,
                side:
                    BorderSide(color: isSelected ? Colors.black : Colors.black),
                showCheckmark: false, // Remove the checkmark when selected
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
