import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'custom_navigation_button.dart';
import 'main_app_bar.dart';

class ConditionDialog extends StatefulWidget {
  final String selectedCondition;
  final Function(String) onConditionSelected;

  ConditionDialog({
    required this.selectedCondition,
    required this.onConditionSelected,
  });

  @override
  _ConditionDialogState createState() => _ConditionDialogState();
}

class _ConditionDialogState extends State<ConditionDialog> {
  late Future<Map<String, List<String>>> _futureImages;
  String _expandedTile = '';
  Map<String, int> _currentImageIndices = {
    'New': 0,
    'Used': 0,
    'New with Defects': 0,
  };

  @override
  void initState() {
    super.initState();
    _futureImages = _fetchImages();
  }

  Future<Map<String, List<String>>> _fetchImages() async {
    final firestore = FirebaseFirestore.instance;
    final Map<String, List<String>> images = {
      'New': [],
      'Used': [],
      'New with Defects': [],
    };

    final newDoc = await firestore.collection('conditions').doc('new').get();
    final usedDoc = await firestore.collection('conditions').doc('used').get();
    final newWithDefectsDoc =
        await firestore.collection('conditions').doc('new_with_defects').get();

    images['New'] = List<String>.from(newDoc.data()?['images'] ?? []);
    images['Used'] = List<String>.from(usedDoc.data()?['images'] ?? []);
    images['New with Defects'] =
        List<String>.from(newWithDefectsDoc.data()?['images'] ?? []);

    return images;
  }

  Widget _buildImageSlider(String title, List<String> imageUrls) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: false,
            aspectRatio: 1.5,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndices[title] = index;
              });
            },
          ),
          items: imageUrls
              .map((url) => CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    height: 200,
                    width: double.infinity,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ))
              .toList(),
        ),
        if (imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CarouselIndicator(
              count: imageUrls.length,
              index: _currentImageIndices[title]!,
              color: Colors.black.withOpacity(0.5),
              activeColor: Colors.black,
            ),
          ),
      ],
    );
  }

  void _toggleExpansion(String title) {
    setState(() {
      _expandedTile = _expandedTile == title ? '' : title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Item Condition',
        showBackButton: true,
      ),
      body: FutureBuilder<Map<String, List<String>>>(
        future: _futureImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final images = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Column(
                            children: [
                              _buildSectionTitle(
                                  'New',
                                  'Your item is new and has never been worn.',
                                  images['New']!),
                              Divider(height: 1, color: Colors.black),
                              _buildSectionTitle(
                                  'Used',
                                  'Your item has been worn. Please check the soles, outsoles, insoles and lining for any signs of wear.',
                                  images['Used']!),
                              Divider(height: 1, color: Colors.black),
                              _buildSectionTitle(
                                  'New with Defects',
                                  'Your item is new and has never been worn, but has imperfections from the manufacturer.',
                                  images['New with Defects']!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, color: Colors.black),
          CustomNavigationButton(
            buttonText: 'Done',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, String description, List<String> imageUrls) {
    return ExpansionTile(
      key: Key(title),
      title: Text(
        title,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      onExpansionChanged: (bool expanded) {
        if (expanded) {
          _toggleExpansion(title);
        } else {
          setState(() {
            _expandedTile = '';
          });
        }
      },
      trailing: Icon(
        _expandedTile == title ? Icons.remove : Icons.add,
        color: Colors.black,
      ),
      initiallyExpanded: _expandedTile == title,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            description,
            style: TextStyle(color: Colors.black),
          ),
        ),
        if (imageUrls.isNotEmpty) _buildImageSlider(title, imageUrls),
      ],
    );
  }
}
