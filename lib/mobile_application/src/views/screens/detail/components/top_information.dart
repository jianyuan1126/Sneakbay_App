import 'package:flutter/material.dart';
import '../../../../../../models/shoe_model.dart';

class TopInformation extends StatelessWidget {
  final double width;
  final double height;
  final ShoeModel model;
  final bool isComeFromMoreSection;

  const TopInformation({
    super.key,
    required this.width,
    required this.height,
    required this.model,
    required this.isComeFromMoreSection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        topInformationWidget(width, height, model, isComeFromMoreSection),
      ],
    );
  }

  Widget topInformationWidget(double width, double height, ShoeModel model,
      bool isComeFromMoreSection) {
    final modelColor = isValidHexColor(model.modelColour)
        ? Color(int.parse(model.modelColour.replaceFirst('#', '0xff')))
        : Colors.grey;

    return Container(
      width: width,
      height: height / 2.3,
      child: Stack(
        children: [
          Positioned(
            left: 50,
            bottom: 20,
            child: Container(
              width: 1000,
              height: height / 2.2,
              decoration: BoxDecoration(
                color: modelColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(1500),
                  bottomRight: Radius.circular(100),
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 30,
            child: Hero(
              tag: isComeFromMoreSection ? model.id : model.imgAddress,
              child: RotationTransition(
                turns: const AlwaysStoppedAnimation(-25 / 360),
                child: SizedBox(
                  width: width / 1.3,
                  height: height / 4.3,
                  child: Image.network(model.imgAddress, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isValidHexColor(String hexColor) {
    final validHexColorRegExp = RegExp(r'^#([A-Fa-f0-9]{6})$');
    return validHexColorRegExp.hasMatch(hexColor);
  }
}