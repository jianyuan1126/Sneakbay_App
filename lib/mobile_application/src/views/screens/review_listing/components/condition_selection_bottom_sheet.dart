import 'package:flutter/material.dart';
import 'package:flutter_application_1/mobile_application/src/widget/condition_dialog.dart';
import 'package:flutter_application_1/mobile_application/src/widget/custom_navigation_button.dart'; 

class ConditionSelectionBottomSheet extends StatefulWidget {
  final List<String> conditions;
  final String selectedCondition;
  final Function(String) onConditionSelected;

  ConditionSelectionBottomSheet({
    required this.conditions,
    required this.selectedCondition,
    required this.onConditionSelected,
  });

  @override
  _ConditionSelectionBottomSheetState createState() =>
      _ConditionSelectionBottomSheetState();
}

class _ConditionSelectionBottomSheetState
    extends State<ConditionSelectionBottomSheet> {
  late String _selectedCondition;

  @override
  void initState() {
    super.initState();
    _selectedCondition = widget.selectedCondition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EDIT ITEM CONDITION',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.help_outline, color: Colors.black),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ConditionDialog(selectedCondition: '', onConditionSelected: (String ) {  },);
                      },
                    );
                  },
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
              ),
              child: Column(
                children: widget.conditions.map((condition) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCondition = condition;
                          });
                        },
                        child: Container(
                          color: _selectedCondition == condition
                              ? Colors.grey[300]
                              : Colors.white,
                          child: ListTile(
                            title: Center(
                              child: Text(
                                condition,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (condition != widget.conditions.last)
                        const Divider(
                          height: 0,
                          thickness: 1,
                          color: Colors.black,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomNavigationButton(
            buttonText: 'Save',
            onPressed: () {
              widget.onConditionSelected(_selectedCondition);
              Navigator.pop(context); // Close the bottom sheet
            },
          ),
        ],
      ),
    );
  }
}
