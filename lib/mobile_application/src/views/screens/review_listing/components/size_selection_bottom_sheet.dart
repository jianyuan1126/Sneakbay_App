import 'package:flutter/material.dart';
import '../../../../widget/custom_navigation_button.dart';

class SizeSelectionBottomSheet extends StatefulWidget {
  final List<String> sizes;
  final String selectedSize;
  final Function(String) onSizeSelected;

  SizeSelectionBottomSheet({
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  _SizeSelectionBottomSheetState createState() =>
      _SizeSelectionBottomSheetState();
}

class _SizeSelectionBottomSheetState extends State<SizeSelectionBottomSheet> {
  late String _selectedSize;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.selectedSize;
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
            const Text(
              'EDIT ITEM SIZE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.sizes.map((size) {
                      // Convert sizes to remove decimal point if it's a whole number
                      final displaySize = size.endsWith('.0')
                          ? size.substring(0, size.length - 2)
                          : size;
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedSize = size;
                              });
                            },
                            child: Container(
                              color: _selectedSize == size
                                  ? Colors.grey[300]
                                  : Colors.white,
                              child: ListTile(
                                title: Center(
                                  child: Text(
                                    displaySize,
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (size != widget.sizes.last)
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
              widget.onSizeSelected(_selectedSize);
              Navigator.pop(context); // Close the bottom sheet
            },
          ),
        ],
      ),
    );
  }
}
