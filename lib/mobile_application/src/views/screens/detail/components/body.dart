import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/detail/components/bottom_navigation_bar.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/detail/components/shoe_details.dart';
import 'package:flutter_application_1/mobile_application/src/views/screens/detail/components/top_information.dart';
import 'package:flutter_application_1/models/shoe_model.dart';
import '../../buy/buy_page.dart';
import '../../listing/listing_page.dart';
import '../../sell/sell_page.dart';
import 'detail_app_bar.dart';

class DetailsBody extends StatefulWidget {
  final ShoeModel model;
  final bool isComeFromMoreSection;

  const DetailsBody({
    super.key,
    required this.model,
    required this.isComeFromMoreSection,
  });

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<DetailsBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBuyPage(BuildContext context, ShoeModel shoeModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: BuyPage(shoeModel: shoeModel),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: DetailAppBar(
        shoeId: widget.model.id,
        tabController: _tabController,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'INFO'),
                Tab(text: 'SELL'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(context, width, height),
                SellPage(shoeId: widget.model.id, shoeModel: widget.model),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BuySellPage(
        onBuyPressed: () => _showBuyPage(context, widget.model),
        onSellPressed: (selectedShoeId) async {
          DocumentSnapshot document = await FirebaseFirestore.instance
              .collection('shoes')
              .doc(selectedShoeId)
              .get();

          if (document.exists) {
            ShoeModel shoeModel = ShoeModel.fromFirestore(
                document.data() as Map<String, dynamic>, document.id);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListingPage(
                  shoeModel: shoeModel,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Shoe not found.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        selectedShoeId: widget.model.id, // Pass the selected shoe ID
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context, double width, double height) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopInformation(
            width: width,
            height: height,
            model: widget.model,
            isComeFromMoreSection: widget.isComeFromMoreSection,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: Text("Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShoeDetails(model: widget.model),
                Text(
                  widget.model.description,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}