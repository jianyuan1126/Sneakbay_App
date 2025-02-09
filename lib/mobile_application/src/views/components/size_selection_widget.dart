import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/shoe_model.dart';
import '../../../../../../models/common_enums.dart';

class SizeSelectionWidget extends StatefulWidget {
  final ShoeModel shoeModel;
  final ValueChanged<String> onSizeSelected;

  const SizeSelectionWidget({
    Key? key,
    required this.shoeModel,
    required this.onSizeSelected,
  }) : super(key: key);

  @override
  _SizeSelectionWidgetState createState() => _SizeSelectionWidgetState();
}

class _SizeSelectionWidgetState extends State<SizeSelectionWidget> {
  String? selectedSize;
  late PageController _pageController;
  List<String> predefinedSizesStr = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.3, initialPage: 0);
    _fetchShoeData();
  }

  Future<void> _fetchShoeData() async {
    try {
      DocumentSnapshot shoeSnapshot = await FirebaseFirestore.instance
          .collection('shoes')
          .doc(widget.shoeModel.id)
          .get();

      if (shoeSnapshot.exists) {
        ShoeModel shoe = ShoeModel.fromFirestore(
            shoeSnapshot.data() as Map<String, dynamic>, widget.shoeModel.id);
        List<double> predefinedSizesList =
            predefinedSizes[shoe.sizeCategory] ?? [];
        setState(() {
          predefinedSizesStr = predefinedSizesList
              .map((size) => size.toString().replaceAll('.0', ''))
              .toList();
          if (predefinedSizesStr.isNotEmpty) {
            selectedSize = predefinedSizesStr[0];
            widget.onSizeSelected(selectedSize!);
          }
        });
      }
    } catch (e) {
      print('Error fetching shoe data: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (predefinedSizesStr.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 50, 
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        itemCount: predefinedSizesStr.length,
        onPageChanged: (index) {
          setState(() {
            selectedSize = predefinedSizesStr[index];
            widget.onSizeSelected(predefinedSizesStr[index]);
          });
          print('Selected Size: $selectedSize');
        },
        itemBuilder: (context, index) {
          String size = predefinedSizesStr[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedSize == size ? Colors.blue : Colors.black,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('all_listings')
                      .doc(widget.shoeModel.id)
                      .collection('listings')
                      .where('size', isEqualTo: size)
                      .where('condition', isEqualTo: 'New')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('-');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('-');
                    }
                    if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return Text('-');
                    }
                    var listings = snapshot.data!.docs;
                    var lowestPrice = listings
                        .map((doc) => doc['price'] as num)
                        .reduce((a, b) => a < b ? a : b);
                    return Text('US\$${lowestPrice.toString()}');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
