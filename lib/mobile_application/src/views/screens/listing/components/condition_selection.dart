import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/common_enums.dart';
import '../../../../widget/condition_dialog.dart';

class ConditionSelectionWidget extends StatelessWidget {
  final String? selectedCondition;
  final Function(String) onConditionSelected;

  const ConditionSelectionWidget({
    super.key,
    required this.selectedCondition,
    required this.onConditionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final conditions = predefinedConditions;
    final double chipWidth = (MediaQuery.of(context).size.width - 56) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Condition',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.black),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConditionDialog(
                      selectedCondition: selectedCondition ?? '',
                      onConditionSelected: onConditionSelected,
                    );
                  },
                );
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8.0,
          children: conditions.map((condition) {
            bool isSelected = condition == selectedCondition;
            return SizedBox(
              width: chipWidth,
              child: ChoiceChip(
                label: Center(
                  child: Text(
                    condition,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  onConditionSelected(condition);
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
