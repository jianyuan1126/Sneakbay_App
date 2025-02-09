import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentUploadPage extends StatefulWidget {
  const ContentUploadPage({super.key});

  @override
  _ContentUploadPageState createState() => _ContentUploadPageState();
}

class _ContentUploadPageState extends State<ContentUploadPage> {
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final List<String> _selectedImages = [];
  bool _isDeleting = false;

  Future<void> _uploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        String imageUrl;
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('slider_images/${pickedFile.name}');
          final uploadTask = storageRef.putData(bytes);
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('slider_images/${pickedFile.name}');
          await storageRef.putFile(File(pickedFile.path));
          imageUrl = await storageRef.getDownloadURL();
        }

        await _firestore.collection('slider_images').doc('images').set({
          'urls': FieldValue.arrayUnion([imageUrl]),
        }, SetOptions(merge: true));

        setState(() {});
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected.');
    }
  }

  Future<List<String>> _getImages() async {
    try {
      final doc =
          await _firestore.collection('slider_images').doc('images').get();
      return List<String>.from(doc.data()?['urls'] ?? []);
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildImageList() {
    return FutureBuilder<List<String>>(
      future: _getImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
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
          ));
        } else {
          final images = snapshot.data!;
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: Row(
                children: images.map((image) {
                  final isSelected = _selectedImages.contains(image);
                  return GestureDetector(
                    onTap: _isDeleting
                        ? () {
                            setState(() {
                              if (isSelected) {
                                _selectedImages.remove(image);
                              } else {
                                _selectedImages.add(image);
                              }
                            });
                          }
                        : () => _showImageDialog(image),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: CachedNetworkImage(
                              imageUrl: image,
                              placeholder: (context, url) => Container(
                                width: 100,
                                height: 100,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error, size: 100),
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child:
                                Icon(Icons.check_circle, color: Colors.green),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _deleteImages() async {
    for (final imageUrl in _selectedImages) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
        await _firestore.collection('slider_images').doc('images').update({
          'urls': FieldValue.arrayRemove([imageUrl]),
        });
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
    setState(() {
      _selectedImages.clear();
      _isDeleting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Slider Images'),
        actions: [
          if (_isDeleting)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteImages,
            ),
          IconButton(
            icon: Icon(_isDeleting ? Icons.cancel : Icons.edit),
            onPressed: () {
              setState(() {
                _isDeleting = !_isDeleting;
                if (!_isDeleting) {
                  _selectedImages.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Upload Slider Image'),
                    Expanded(child: _buildImageList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _uploadImage,
          ),
        ],
      ),
    );
  }
}
