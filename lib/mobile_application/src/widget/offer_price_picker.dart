import 'package:flutter/material.dart';

class PricePicker extends StatefulWidget {
  final double? initialPrice;
  final double listingPrice;
  final double topOffer;
  final Function(double) onPriceSelected;

  const PricePicker({
    Key? key,
    this.initialPrice,
    required this.listingPrice,
    required this.topOffer,
    required this.onPriceSelected,
  }) : super(key: key);

  @override
  _PricePickerState createState() => _PricePickerState();
}

class _PricePickerState extends State<PricePicker> {
  double? _selectedPrice;

  @override
  void initState() {
    super.initState();
    _selectedPrice = widget.initialPrice ?? widget.topOffer;
  }

  void _showCustomSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewInsets.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<void> _showInputPriceDialog(BuildContext context) async {
    double? enteredPrice;
    double maxOffer = widget.listingPrice > 0 ? widget.listingPrice : 5000;
    await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: Colors.black, width: 1),
              ),
              backgroundColor: Colors.white,
              title: Center(
                child: const Text(
                  'Enter Offer Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  enteredPrice = double.tryParse(value);
                },
                decoration: const InputDecoration(hintText: "Enter price"),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextButton(
                          onPressed: () {
                            if (enteredPrice != null &&
                                enteredPrice! >= 25 &&
                                enteredPrice! <= maxOffer) {
                              setState(() {
                                _selectedPrice = enteredPrice;
                              });
                              Navigator.of(context).pop();
                              widget.onPriceSelected(_selectedPrice!);
                            } else {
                              if (enteredPrice != null && enteredPrice! < 25) {
                                _showCustomSnackbar(
                                    context, 'Cannot offer lower than RM25');
                              } else if (enteredPrice != null &&
                                  enteredPrice! > maxOffer) {
                                _showCustomSnackbar(context,
                                    'The current lowest price is RM${maxOffer.toStringAsFixed(2)}, you can buy now, no need to make an offer.');
                              } else {
                                _showCustomSnackbar(context,
                                    'Please enter a valid price between RM25 and RM5000');
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Set Offer Price',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double minOffer = 25;
    double maxOffer =
        widget.listingPrice > minOffer ? widget.listingPrice : 5000;

    double startPrice = widget.topOffer > minOffer ? widget.topOffer : minOffer;
    int initialItem =
        (_selectedPrice != null ? (_selectedPrice! - startPrice).toInt() : 0);

    FixedExtentScrollController scrollController = FixedExtentScrollController(
      initialItem: initialItem,
    );

    int childCount = (maxOffer - startPrice).toInt() + 1;

    return Container(
      height: 500,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Set Offer Price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ListWheelScrollView.useDelegate(
                  controller: scrollController,
                  itemExtent: 50,
                  diameterRatio: 1.8,
                  physics: FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedPrice = startPrice + index.toDouble();
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      double price = startPrice + index.toDouble();
                      return GestureDetector(
                        onTap: () async {
                          await _showInputPriceDialog(context);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: Text(
                                'RM${price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 22),
                              ),
                            ),
                            if (price == widget.listingPrice)
                              Positioned(
                                right: 20.0,
                                child: Text(
                                  'Buy Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            if (price < widget.topOffer)
                              Positioned(
                                right: 20.0,
                                child: Text(
                                  'Disabled',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: childCount,
                  ),
                ),
                Positioned(
                  left: 16.0,
                  top: 185.0,
                  child: Container(
                    color: Colors.white,
                    child: Text(
                      'Your Offer',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _selectedPrice != null && _selectedPrice! >= 25
                ? () {
                    widget.onPriceSelected(_selectedPrice!);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Container(
              width: 120,
              alignment: Alignment.center,
              child: Text(
                _selectedPrice == widget.listingPrice
                    ? 'Buy Now'
                    : 'Set Offer Price',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
