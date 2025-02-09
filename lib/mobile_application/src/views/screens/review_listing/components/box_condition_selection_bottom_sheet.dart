import 'package:flutter/material.dart';
import '../../../../widget/box_condition_dialog.dart';
import '../../../../widget/custom_navigation_button.dart';

class PackagingSelectionBottomSheet extends StatefulWidget {
  final List<String> packagingOptions;
  final String selectedPackaging;
  final Function(String) onPackagingSelected;

  PackagingSelectionBottomSheet({
    required this.packagingOptions,
    required this.selectedPackaging,
    required this.onPackagingSelected,
  });

  @override
  _PackagingSelectionBottomSheetState createState() =>
      _PackagingSelectionBottomSheetState();
}

class _PackagingSelectionBottomSheetState
    extends State<PackagingSelectionBottomSheet> {
  late String _selectedPackaging;

  @override
  void initState() {
    super.initState();
    _selectedPackaging = widget.selectedPackaging;
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
                  'EDIT PACKAGING CONDITION',
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
                        return BoxConditionDialog(
                          selectedCondition: '',
                          onConditionSelected: (String condition) {},
                        );
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
                children: widget.packagingOptions.map((packaging) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPackaging = packaging;
                          });
                        },
                        child: Container(
                          color: _selectedPackaging == packaging
                              ? Colors.grey[300]
                              : Colors.white,
                          child: ListTile(
                            title: Center(
                              child: Text(
                                packaging,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (packaging != widget.packagingOptions.last)
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
              widget.onPackagingSelected(_selectedPackaging);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
