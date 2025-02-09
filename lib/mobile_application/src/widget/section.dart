import 'package:flutter/material.dart';
import 'custom_list_item.dart';  // Ensure this import matches the location of your CustomListItem widget

class Section extends StatelessWidget {
  final List<CustomListItem> children;

  const Section({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          return CustomListItem(
            title: children[index].title,
            value: children[index].value,
            onTap: children[index].onTap,
            isLastItem: index == children.length - 1,  
          );
        }),
      ),
    );
  }
}
