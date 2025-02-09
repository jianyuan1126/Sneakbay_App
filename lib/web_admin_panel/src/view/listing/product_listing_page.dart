import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/shoe_model.dart';
import 'package:flutter_application_1/models/common_enums.dart';

class ProductListingPage extends StatefulWidget {
  final Function()
      onSave; // Add a callback function to notify parent widget on save

  const ProductListingPage({super.key, required this.onSave});

  @override
  _ProductListingPageState createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _colourWayController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ShoeModel _shoe = ShoeModel(
    id: '',
    name: '',
    retailPrice: 0.0,
    imgAddress: '',
    sku: '',
    releaseDate: '',
    colorway: '',
    brand: '',
    categories: [],
    description: '',
    modelColour: '',
    sizeCategory: ShoeSizeCategory.Mens,
    userId: null, // Set as null for admin purposes
  );
  Uint8List? _imageData;
  Color _currentColor = Colors.blue;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    _brandController.dispose();
    _colourWayController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
    }
  }

  Future<void> _uploadShoe() async {
    if (_imageData == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No image selected')));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields correctly')));
      return;
    }

    _formKey.currentState!.save();

    try {
      String fileExtension = 'jpg';
      SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'description': 'Sneaker image'});

      TaskSnapshot snapshot = await _storage
          .ref('shoes/${_shoe.sku}.$fileExtension')
          .putData(_imageData!, metadata);
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Generate keywords for searching
      List<String> keywords =
          _generateKeywords(_shoe.name, _shoe.brand, _shoe.sku);

      // Use shoe name as the document ID
      String docId = _nameController.text.toLowerCase().replaceAll(' ', '_');

      await _firestore.collection('shoes').doc(docId).set({
        'name': _shoe.name,
        'brand': _shoe.brand,
        'sku': _shoe.sku,
        'nameLowercase': _shoe.name.toLowerCase(),
        'brandLowercase': _shoe.brand.toLowerCase(),
        'skuLowercase': _shoe.sku.toLowerCase(),
        'keywords': keywords,
        'retailPrice': _shoe.retailPrice,
        'imgAddress': imageUrl,
        'releaseDate': _shoe.releaseDate,
        'colorway': _shoe.colorway,
        'categories': _shoe.categories.map((c) => describeEnum(c)).toList(),
        'description': _shoe.description,
        'modelColour': _shoe.modelColour,
        'sizeCategory': describeEnum(_shoe.sizeCategory),
        'timestamp': FieldValue.serverTimestamp(), // Add this line
        'userId': null, // Set as null for admin purposes
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shoe uploaded successfully')));

      widget.onSave(); // Call the callback function to notify parent widget
      Navigator.pop(context); // Close the dialog
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error uploading shoe: $e')));
    }
  }

  List<String> _generateKeywords(String name, String brand, String sku) {
    List<String> keywords = [];

    List<String> nameWords = name.toLowerCase().split(' ');
    List<String> brandWords = brand.toLowerCase().split(' ');

    keywords.addAll(nameWords);
    keywords.addAll(brandWords);
    keywords.add(sku.toLowerCase());

    return keywords.toSet().toList(); // Removing duplicates
  }

  Widget _buildTextField(
      String label, TextEditingController controller, Function(String) onSaved,
      {bool numeric = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
        labelText: label,
        hintText: 'Enter $label',
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white),
      ),
      style: const TextStyle(color: Colors.white),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      onSaved: (String? value) => onSaved(value!),
      validator: validator,
    );
  }

  Widget _buildPreviewPane() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_imageData != null)
          Image.memory(
            _imageData!,
            width: 240,
            height: 240,
            fit: BoxFit.contain,
          ),
        if (_imageData == null)
          const Icon(Icons.camera_alt, size: 240, color: Colors.white),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      Function(String) onSaved, BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select Date',
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _selectDate(context, controller, onSaved);
      },
      validator: _validateNotEmpty,
    );
  }

  Widget _buildCategorySelectors() {
    return DropdownButtonFormField<ShoeCategory>(
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
      ),
      dropdownColor: Colors.black,
      style: const TextStyle(color: Colors.white),
      items: ShoeCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(describeEnum(category),
              style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (ShoeCategory? value) {
        setState(() {
          _shoe.categories = value != null ? [value] : [];
        });
      },
      value: _shoe.categories.isNotEmpty ? _shoe.categories.first : null,
    );
  }

  Widget _buildSizeCategorySelectors() {
    return DropdownButtonFormField<ShoeSizeCategory>(
      decoration: InputDecoration(
        labelText: 'Size Category',
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.0),
        ),
      ),
      dropdownColor: Colors.black,
      style: const TextStyle(color: Colors.white),
      items: ShoeSizeCategory.values.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(describeEnum(category),
              style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (ShoeSizeCategory? value) {
        setState(() {
          _shoe.sizeCategory = value!;
        });
      },
      value: _shoe.sizeCategory,
    );
  }

  String? _validateNotEmpty(String? value) {
    return (value == null || value.isEmpty)
        ? 'This field cannot be empty'
        : null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'This field cannot be empty';
    final price = double.tryParse(value);
    return price != null && price > 0 ? null : 'Please enter a valid price';
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, Function(String) onSaved) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
      onSaved(controller.text);
    }
  }

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: _currentColor,
              onColorChanged: (color) {
                setState(() {
                  _currentColor = color;
                  _shoe.modelColour =
                      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                });
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Sneaker Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    _buildTextField(
                        'Name', _nameController, (value) => _shoe.name = value,
                        validator: _validateNotEmpty),
                    const SizedBox(height: 10),
                    _buildTextField(
                        'SKU', _skuController, (value) => _shoe.sku = value,
                        validator: _validateNotEmpty),
                    const SizedBox(height: 10),
                    _buildTextField(
                        'Retail Price',
                        _priceController,
                        (value) =>
                            _shoe.retailPrice = double.tryParse(value) ?? 0.0,
                        numeric: true,
                        validator: _validatePrice),
                    const SizedBox(height: 10),
                    _buildDateField('Release Date', _dateController,
                        (value) => _shoe.releaseDate = value, context),
                    const SizedBox(height: 10),
                    _buildTextField('Brand', _brandController,
                        (value) => _shoe.brand = value,
                        validator: _validateNotEmpty),
                    const SizedBox(height: 10),
                    _buildTextField('Colorway', _colourWayController,
                        (value) => _shoe.colorway = value,
                        validator: _validateNotEmpty),
                    const SizedBox(height: 10),
                    _buildTextField('Description', _descriptionController,
                        (value) => _shoe.description = value),
                    const SizedBox(height: 10),
                    _buildCategorySelectors(),
                    const SizedBox(height: 20),
                    _buildSizeCategorySelectors(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Model Colour: '),
                        GestureDetector(
                          onTap: () => _pickColor(context),
                          child: Container(
                            width: 24,
                            height: 24,
                            color: _currentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Container(
                  child: _buildPreviewPane(),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Choose File'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadShoe,
        child: const Icon(Icons.save),
      ),
    );
  }
}
