import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/common_enums.dart';
import '../../../../widget/box_condition_dialog.dart';

class PackagingSelectionWidget extends StatelessWidget {
  final String? selectedPackaging;
  final Function(String) onPackagingSelected;

  const PackagingSelectionWidget({
    super.key,
    required this.selectedPackaging,
    required this.onPackagingSelected,
  });

  @override
  Widget build(BuildContext context) {
    final packagingOptions = predefinedPackaging;
    final double chipWidth = (MediaQuery.of(context).size.width - 56) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Packaging',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.black),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BoxConditionDialog(
                      selectedCondition: selectedPackaging ?? '',
                      onConditionSelected: onPackagingSelected,
                    );
                  },
                );
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8.0,
          children: packagingOptions.map((option) {
            bool isSelected = option == selectedPackaging;
            return SizedBox(
              width: chipWidth,
              child: ChoiceChip(
                label: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  onPackagingSelected(option);
                },
                selectedColor: Colors.black,
                backgroundColor: Colors.white,
                side:
                    BorderSide(color: isSelected ? Colors.black : Colors.black),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
