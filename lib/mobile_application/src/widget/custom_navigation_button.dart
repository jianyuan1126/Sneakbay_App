import 'package:flutter/material.dart';

class CustomNavigationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color backgroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isEnabled;
  final double? height; // Add this property

  const CustomNavigationButton({
    super.key,
    required this.onPressed,
    this.buttonText = '',
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.padding = EdgeInsets.zero, // Change the default padding to zero
    this.borderRadius = 8.0,
    this.isEnabled = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : () {},
          style: ElevatedButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: backgroundColor,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
        ),
      ),
    );
  }
}
