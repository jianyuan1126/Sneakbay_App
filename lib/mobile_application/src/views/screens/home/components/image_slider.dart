import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../donation/donation_page.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentIndex = 0;
  List<String> _imgList = [];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final doc = await firestore.collection('slider_images').doc('images').get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('urls')) {
        setState(() {
          _imgList = List<String>.from(data['urls']);
        });
      }
    }
  }

  void _navigateToDonationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DonationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _imgList.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No images available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
        : Stack(
            alignment: Alignment.bottomRight,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: _imgList
                    .map((item) => Center(
                          child: GestureDetector(
                            onTap: _navigateToDonationPage,
                            child: CachedNetworkImage(
                              imageUrl: item,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              if (_imgList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CarouselIndicator(
                    count: _imgList.length,
                    index: _currentIndex,
                    color: Colors.black.withOpacity(0.5),
                    activeColor: Colors.black,
                  ),
                ),
            ],
          );
  }
}
