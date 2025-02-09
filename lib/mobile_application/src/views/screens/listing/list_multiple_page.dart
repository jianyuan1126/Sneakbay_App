import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/common_enums.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../models/shoe_model.dart';
import '../../../../../models/sneaker_size_quantity.dart';
import '../../../widget/custom_navigation_button.dart';
import '../../../widget/main_app_bar.dart';
import '../pricing/pricing_page.dart';
import '../review_listing/review_listing_page.dart';

class ListMultiplePage extends StatefulWidget {
  final ShoeModel shoeModel;

  const ListMultiplePage({super.key, required this.shoeModel});

  @override
  _ListMultiplePageState createState() => _ListMultiplePageState();
}

class _ListMultiplePageState extends State<ListMultiplePage> {
  late List<SneakerSizeQuantity> sizes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeSizes();
  }

  void initializeSizes() {
    sizes = predefinedSizes[widget.shoeModel.sizeCategory]!
        .map((size) => SneakerSizeQuantity(
              size: size.toString().replaceAll('.0', ''),
              quantity: 0,
              price: null,
              condition: 'New',
              packaging: 'Good Box',
            ))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  void reviewListings() {
    List<SneakerSizeQuantity> selectedSizes = sizes
        .where((size) => size.quantity > 0 && size.price != null)
        .map((size) => SneakerSizeQuantity(
              size: size.size,
              quantity: size.quantity,
              price: size.price,
              condition: size.condition,
              packaging: size.packaging,
            ))
        .toList();

    if (selectedSizes.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewListingPage(
            selectedShoe: widget.shoeModel,
            selectedSizes: selectedSizes,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No sizes with set prices to review."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'List Up to 50 Items',
        backgroundColor: Colors.white,
        showBackButton: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Make sure all items are new and unworn. You’ll be able to edit the packaging condition and price per listing in the next step.",
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "US",
                            style: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Center(
                            child: Text(
                              "QTY",
                              style: GoogleFonts.poppins(
                                  color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sizes.length,
                    itemBuilder: (context, index) {
                      return QuantitySelector(
                        size: sizes[index],
                        shoeModel: widget.shoeModel,
                        onUpdate: () => setState(() {}),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.black),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, color: Colors.black),
          CustomNavigationButton(
            buttonText: 'Review Listings',
            onPressed: reviewListings,
            borderRadius: 5,
            height: 45,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}

class QuantitySelector extends StatefulWidget {
  final SneakerSizeQuantity size;
  final ShoeModel shoeModel;
  final VoidCallback onUpdate;

  const QuantitySelector({
    super.key,
    required this.size,
    required this.shoeModel,
    required this.onUpdate,
  });

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.size.size,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 10,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 107,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            if (widget.size.quantity > 0) {
                              widget.size.quantity--;
                            }
                          });
                          widget.onUpdate();
                        },
                      ),
                      Text(
                        '${widget.size.quantity}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            widget.size.quantity++;
                          });
                          widget.onUpdate();
                        },
                      ),
                    ],
                  ),
                ),
                if (widget.size.quantity > 0)
                  Positioned(
                    right: 0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: () async {
                        final updatedPrice = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PricingPage(
                              shoeModel: widget.shoeModel,
                              sku: widget.shoeModel.sku,
                              size: widget.size.size,
                              condition: "New",
                              packaging: "Good Box",
                              isFromMultipleListing: true,
                              selectedSizes: const [],
                            ),
                          ),
                        );
                        if (updatedPrice != null) {
                          setState(() {
                            widget.size.price = updatedPrice;
                          });
                        }
                      },
                      child: Text(
                        widget.size.price != null
                            ? '\$${widget.size.price?.toStringAsFixed(2)}'
                            : 'Set Price',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
