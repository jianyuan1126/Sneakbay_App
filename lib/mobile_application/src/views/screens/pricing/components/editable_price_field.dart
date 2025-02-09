import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditablePriceField extends StatelessWidget {
  final TextEditingController priceController;
  final FocusNode priceFocusNode;
  final Function(String) onPriceChange;

  const EditablePriceField({
    super.key,
    required this.priceController,
    required this.priceFocusNode,
    required this.onPriceChange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 235,
      child: TextField(
        controller: priceController,
        focusNode: priceFocusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [LengthLimitingTextInputFormatter(4)],
        maxLines: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          shadows: [
            Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(0, 0)),
          ],
        ),
        decoration: const InputDecoration(
          prefixText: '\RM',
          prefixStyle: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: [
              Shadow(
                  blurRadius: 10.0, color: Colors.black, offset: Offset(0, 0)),
            ],
          ),
          border: InputBorder.none,
          counterText: "",
        ),
        onChanged: onPriceChange,
      ),
    );
  }
}
