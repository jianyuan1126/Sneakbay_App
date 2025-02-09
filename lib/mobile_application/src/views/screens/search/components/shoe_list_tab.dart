import 'package:flutter/material.dart';
import '../../../../../../models/shoe_model.dart';
import 'shoe_list_item.dart';

class ShoeListTab extends StatelessWidget {
  final List<ShoeModel> shoes;
  final String tabName;

  const ShoeListTab({super.key, required this.shoes, required this.tabName});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shoes.length,
      itemBuilder: (context, index) {
        final shoe = shoes[index];
        return ShoeListItem(shoe: shoe);
      },
    );
  }
}
