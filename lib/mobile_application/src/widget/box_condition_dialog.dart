import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'custom_navigation_button.dart';
import 'main_app_bar.dart';

class BoxConditionDialog extends StatefulWidget {
  final String selectedCondition;
  final Function(String) onConditionSelected;

  BoxConditionDialog({
    required this.selectedCondition,
    required this.onConditionSelected,
  });

  @override
  _BoxConditionDialogState createState() => _BoxConditionDialogState();
}

class _BoxConditionDialogState extends State<BoxConditionDialog> {
  late Future<Map<String, List<String>>> _futureImages;
  String _expandedTile = '';
  Map<String, int> _currentImageIndices = {
    'Good Box': 0,
    'Missing Lid': 0,
    'Damaged Box': 0,
    'No Original Box': 0,
  };

  @override
  void initState() {
    super.initState();
    _futureImages = _fetchImages();
  }

  Future<Map<String, List<String>>> _fetchImages() async {
    final firestore = FirebaseFirestore.instance;
    final Map<String, List<String>> images = {
      'Good Box': [],
      'Missing Lid': [],
      'Damaged Box': [],
      'No Original Box': [],
    };

    final goodBoxDoc =
        await firestore.collection('conditions').doc('good_box').get();
    final missingLidDoc =
        await firestore.collection('conditions').doc('missing_lid').get();
    final damagedBoxDoc =
        await firestore.collection('conditions').doc('damaged_box').get();
    final noOriginalBoxDoc =
        await firestore.collection('conditions').doc('no_original_box').get();

    images['Good Box'] = List<String>.from(goodBoxDoc.data()?['images'] ?? []);
    images['Missing Lid'] =
        List<String>.from(missingLidDoc.data()?['images'] ?? []);
    images['Damaged Box'] =
        List<String>.from(damagedBoxDoc.data()?['images'] ?? []);
    images['No Original Box'] =
        List<String>.from(noOriginalBoxDoc.data()?['images'] ?? []);

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
        title: 'Packaging Conditions',
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
                                'Good Box',
                                'You have the item\'s original box and lid and both show only minimal signs of wear.\n\n'
                                    'A box can have slight cosmetic tears, dents or markings and still be considered a \'Good Box\'.\n\n'
                                    'The box\'s label must be accurate and fully legible.\n\n'
                                    'Please review the photos below for examples of a box in good condition.',
                                images['Good Box']!,
                              ),
                              Divider(height: 1, color: Colors.black),
                              _buildSectionTitle(
                                'Missing Lid',
                                'You have the item\'s original box, but the lid is missing.\n\n'
                                    'For boxes that have multiple lid components, if one of the components is missing, you must select '
                                    '\'Missing Lid\' as your packaging condition.',
                                images['Missing Lid']!,
                              ),
                              Divider(height: 1, color: Colors.black),
                              _buildSectionTitle(
                                'Damaged Box',
                                'A box is considered damaged if it has sustained visible and excessive damage. Examples include:\n\n'
                                    '• Structural damage to the point where the box does not fully protect the shoe\n'
                                    '• Severely dented exterior\n'
                                    '• Numerous cuts and holes\n'
                                    '• Excessive tears on the box\'s lid\n'
                                    '• Loose or detached lids\n'
                                    '• Tape or other adhesives\n'
                                    '• Noticeable stains or discoloration',
                                images['Damaged Box']!,
                              ),
                              Divider(height: 1, color: Colors.black),
                              _buildSectionTitle(
                                'No Original Box',
                                'The item is no longer in its original box, the box label is illegible or torn, or the box is so severely damaged it can no longer protect the shoes inside.',
                                images['No Original Box']!,
                              ),
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
