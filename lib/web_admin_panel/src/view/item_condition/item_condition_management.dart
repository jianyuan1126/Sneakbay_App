import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ItemConditionManagement extends StatefulWidget {
  @override
  _ItemConditionManagementState createState() =>
      _ItemConditionManagementState();
}

class _ItemConditionManagementState extends State<ItemConditionManagement> {
  final picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, List<String>> _selectedImages = {
    'new': [],
    'used': [],
    'new_with_defects': [],
  };
  bool _isDeleting = false;
  final ScrollController _newScrollController = ScrollController();
  final ScrollController _usedScrollController = ScrollController();
  final ScrollController _newWithDefectsScrollController = ScrollController();

  Future<void> _uploadImage(String conditionType) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        String imageUrl;
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('$conditionType/${pickedFile.name}');
          final uploadTask = storageRef.putData(bytes);
          final snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        } else {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('$conditionType/${pickedFile.name}');
          await storageRef.putFile(File(pickedFile.path));
          imageUrl = await storageRef.getDownloadURL();
        }

        await _firestore.collection('conditions').doc(conditionType).set({
          'images': FieldValue.arrayUnion([imageUrl]),
        }, SetOptions(merge: true));

        setState(() {});
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      print('No image selected.');
    }
  }

  Future<List<String>> _getImages(String conditionType) async {
    try {
      final doc =
          await _firestore.collection('conditions').doc(conditionType).get();
      return List<String>.from(doc.data()?['images'] ?? []);
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

  Widget _buildImageList(
      String conditionType, ScrollController scrollController) {
    return FutureBuilder<List<String>>(
      future: _getImages(conditionType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No images found'));
        } else {
          final images = snapshot.data!;
          return Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              child: Row(
                children: images.map((image) {
                  final isSelected =
                      _selectedImages[conditionType]!.contains(image);
                  return GestureDetector(
                    onTap: _isDeleting
                        ? () {
                            setState(() {
                              if (isSelected) {
                                _selectedImages[conditionType]!.remove(image);
                              } else {
                                _selectedImages[conditionType]!.add(image);
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

  Future<void> _deleteImages(String conditionType) async {
    final selectedImages = _selectedImages[conditionType]!;
    for (final imageUrl in selectedImages) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
        await _firestore.collection('conditions').doc(conditionType).update({
          'images': FieldValue.arrayRemove([imageUrl]),
        });
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
    setState(() {
      _selectedImages[conditionType] = [];
      _isDeleting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Item and Box Conditions'),
        actions: [
          if (_isDeleting)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteImages('new');
                _deleteImages('used');
                _deleteImages('new_with_defects');
              },
            ),
          IconButton(
            icon: Icon(_isDeleting ? Icons.cancel : Icons.edit),
            onPressed: () {
              setState(() {
                _isDeleting = !_isDeleting;
                if (!_isDeleting) {
                  _selectedImages['new'] = [];
                  _selectedImages['used'] = [];
                  _selectedImages['new_with_defects'] = [];
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
                    _buildSectionTitle('Upload New Condition Image', 'new'),
                    Expanded(
                        child: _buildImageList('new', _newScrollController)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
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
                    _buildSectionTitle('Upload Used Condition Image', 'used'),
                    Expanded(
                        child: _buildImageList('used', _usedScrollController)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
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
                    _buildSectionTitle(
                        'Upload New with Defects Condition Image',
                        'new_with_defects'),
                    Expanded(
                        child: _buildImageList('new_with_defects',
                            _newWithDefectsScrollController)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String conditionType) {
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
            onPressed: () => _uploadImage(conditionType),
          ),
        ],
      ),
    );
  }
}
