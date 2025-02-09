// navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'menu_item.dart'; // Ensure this import points to your MenuItem file

class SideNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelect;

  const SideNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: const Color.fromARGB(255, 27, 27, 27),
      child: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child:
                Image.asset('assets/icons/SneakBayWhite_Logo.png', width: 180),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('MAIN MENU',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          MenuItem(
            icon: FontAwesomeIcons.users,
            title: 'Users',
            isSelected: selectedIndex == 0,
            onTap: () => onSelect(0),
          ),
          MenuItem(
            icon: FontAwesomeIcons.boxOpen,
            title: 'Product Inventory',
            isSelected: selectedIndex == 1,
            onTap: () => onSelect(1),
          ),
          MenuItem(
            icon: FontAwesomeIcons.boxes,
            title: 'CheckIn',
            isSelected: selectedIndex == 2,
            onTap: () => onSelect(2),
          ),
          MenuItem(
            icon: FontAwesomeIcons.bullhorn,
            title: 'Review Rating',
            isSelected: selectedIndex == 3,
            onTap: () => onSelect(3),
          ),
          const Divider(color: Colors.grey),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('SETTINGS',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          MenuItem(
            icon: FontAwesomeIcons.tag,
            title: 'Item Condition',
            isSelected: selectedIndex == 4,
            onTap: () => onSelect(4),
          ),
          MenuItem(
            icon: FontAwesomeIcons.box,
            title: 'Box Condition',
            isSelected: selectedIndex == 5,
            onTap: () => onSelect(5),
          ),
          MenuItem(
            icon: FontAwesomeIcons.fileUpload,
            title: 'Content Slider',
            isSelected: selectedIndex == 6,
            onTap: () => onSelect(6),
          ),
          MenuItem(
            icon: FontAwesomeIcons.fileWord,
            title: 'FAQ',
            isSelected: selectedIndex == 7,
            onTap: () => onSelect(7),
          ),
          MenuItem(
            icon: FontAwesomeIcons.fileWord,
            title: 'Terms',
            isSelected: selectedIndex == 8,
            onTap: () => onSelect(8),
          ),
          MenuItem(
            icon: FontAwesomeIcons.fileWord,
            title: 'Seller Policy',
            isSelected: selectedIndex == 9,
            onTap: () => onSelect(9),
          ),
        ],
      ),
    );
  }
}
