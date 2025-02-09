import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/shoe_model.dart';
import 'components/new_info.dart';
import 'components/offer_info.dart';
import 'components/size_selection_widget.dart';
import 'components/tab_bar_widget.dart';
import 'components/used_info.dart';


class BuyPage extends StatefulWidget {
  final ShoeModel shoeModel;

  const BuyPage({Key? key, required this.shoeModel}) : super(key: key);

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedSize;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSizeSelected(String size) {
    setState(() {
      selectedSize = size;
    });
    print('Size selected in BuyPage: $selectedSize');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildIndicator(),
          SizeSelectionWidget(
            shoeModel: widget.shoeModel,
            onSizeSelected: _onSizeSelected,
          ),
          const Divider(color: Colors.black),
          CustomTabBar(tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                selectedSize != null
                    ? NewInfoWidget(
                        shoeModel: widget.shoeModel,
                        selectedSize: selectedSize!,
                      )
                    : Center(child: Text('Please select a size.')),
                selectedSize != null
                    ? UsedInfoWidget(
                        shoeModel: widget.shoeModel,
                        selectedSize: selectedSize!,
                      )
                    : Center(child: Text('Please select a size.')),
                selectedSize != null
                    ? OfferWidget(
                        shoeModel: widget.shoeModel,
                        selectedSize: selectedSize!,
                      )
                    : Center(child: Text('Please select a size.')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      width: 60.0,
      height: 5.0,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
