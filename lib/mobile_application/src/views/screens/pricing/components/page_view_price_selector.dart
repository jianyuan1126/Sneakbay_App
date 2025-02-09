import 'package:flutter/material.dart';

class PageViewPriceSelector extends StatelessWidget {
  final int selectedIndex;
  final List<double> priceList;
  final PageController pageController;
  final Function(int) onPageChanged;

  const PageViewPriceSelector({
    super.key,
    required this.selectedIndex,
    required this.priceList,
    required this.pageController,
    required this.onPageChanged,
    required bool enabled,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: PageView.builder(
        itemCount: priceList.length,
        controller: pageController,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) {
          final bool isSelected = index == selectedIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 28 : 20,
            height: isSelected ? 28 : 20,
            margin: EdgeInsets.only(
              top: isSelected ? 0 : 30,
              bottom: isSelected ? 0 : 0,
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.blue : Colors.grey,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 8.0,
                        spreadRadius: 3.0,
                      )
                    ]
                  : [],
            ),
          );
        },
      ),
    );
  }
}
