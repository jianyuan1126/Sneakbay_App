import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/models/shoe_model.dart';
import 'package:flutter_application_1/models/common_enums.dart';

class EditListingPage extends StatefulWidget {
  final ShoeModel shoe;

  const EditListingPage({Key? key, required this.shoe}) : super(key: key);

  @override
  _EditListingPageState createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _priceController;
  late TextEditingController _dateController;
  late TextEditingController _brandController;
  late TextEditingController _colourWayController;
  late TextEditingController _descriptionController;
  Uint8List? _imageData;
  Color _currentColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shoe.name);
    _skuController = TextEditingController(text: widget.shoe.sku);
    _priceController =
        TextEditingController(text: widget.shoe.retailPrice.toString());
    _dateController = TextEditingController(text: widget.shoe.releaseDate);
    _brandController = TextEditingController(text: widget.shoe.brand);
    _colourWayController = TextEditingController(text: widget.shoe.colorway);
    _descriptionController =
        TextEditingController(text: widget.shoe.description);

    // Ensure modelColour is correctly parsed, handling the potential presence of '#'
    String colorString = widget.shoe.modelColour.replaceFirst('#', '');
    _currentColor = Color(int.parse('FF$colorString', radix: 16));
  }

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
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
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
                  widget.shoe.modelColour =
                      '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}'; // Remove '#'
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

  Future<void> _saveUpdatedShoe() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields correctly')));
      return;
    }

    _formKey.currentState!.save();

    DocumentReference shoeRef =
        FirebaseFirestore.instance.collection('shoes').doc(widget.shoe.id);

    Map<String, dynamic> updatedData = {
      'name': _nameController.text,
      'sku': _skuController.text,
      'retailPrice': double.parse(_priceController.text),
      'releaseDate': _dateController.text,
      'brand': _brandController.text,
      'colorway': _colourWayController.text,
      'description': _descriptionController.text,
      'categories': widget.shoe.categories.map((c) => describeEnum(c)).toList(),
      'modelColour': widget.shoe.modelColour,
      'sizeCategory': describeEnum(widget.shoe.sizeCategory),
    };

    try {
      if (_imageData != null) {
        String fileExtension = 'jpg';
        SettableMetadata metadata = SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'description': 'Updated sneaker image'});

        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('shoes/${widget.shoe.sku}.$fileExtension')
            .putData(_imageData!, metadata);
        String imageUrl = await snapshot.ref.getDownloadURL();

        updatedData['imgAddress'] = imageUrl;
      }

      await shoeRef.update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shoe details updated successfully')));
      Navigator.pop(context); // This line closes the modal
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating shoe: $e')));
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool numeric = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter $label',
        border: const OutlineInputBorder(),
      ),
      keyboardType: numeric
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Select Date',
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.parse(controller.text),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = pickedDate.toIso8601String().split('T').first;
          });
        }
      },
    );
  }

  Widget _buildCategorySelectors() {
    return DropdownButtonFormField<ShoeCategory>(
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      value: widget.shoe.categories.isNotEmpty
          ? widget.shoe.categories.first
          : null,
      onChanged: (ShoeCategory? newCategory) {
        if (newCategory != null) {
          setState(() {
            widget.shoe.categories = [newCategory];
          });
        }
      },
      items: ShoeCategory.values.map((category) {
        return DropdownMenuItem<ShoeCategory>(
          value: category,
          child: Text(describeEnum(category)),
        );
      }).toList(),
    );
  }

  Widget _buildSizeCategorySelectors() {
    return DropdownButtonFormField<ShoeSizeCategory>(
      decoration: const InputDecoration(
        labelText: 'Size Category',
        border: OutlineInputBorder(),
      ),
      value: widget.shoe.sizeCategory,
      onChanged: (ShoeSizeCategory? newCategory) {
        if (newCategory != null) {
          setState(() {
            widget.shoe.sizeCategory = newCategory;
          });
        }
      },
      items: ShoeSizeCategory.values.map((category) {
        return DropdownMenuItem<ShoeSizeCategory>(
          value: category,
          child: Text(describeEnum(category)),
        );
      }).toList(),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imageData != null)
          Image.memory(_imageData!,
              width: 240, height: 240, fit: BoxFit.contain),
        if (_imageData == null && widget.shoe.imgAddress.isNotEmpty)
          Image.network(widget.shoe.imgAddress,
              width: 240, height: 240, fit: BoxFit.contain),
        if (_imageData == null && widget.shoe.imgAddress.isEmpty)
          const Icon(Icons.camera_alt, size: 240),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sneaker Details'),
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
                    _buildTextField('Name', _nameController),
                    const SizedBox(height: 10),
                    _buildTextField('SKU', _skuController),
                    const SizedBox(height: 10),
                    _buildTextField('Retail Price', _priceController,
                        numeric: true),
                    const SizedBox(height: 10),
                    _buildDateField('Release Date', _dateController),
                    const SizedBox(height: 10),
                    _buildTextField('Brand', _brandController),
                    const SizedBox(height: 10),
                    _buildTextField('Colorway', _colourWayController),
                    const SizedBox(height: 10),
                    _buildTextField('Description', _descriptionController),
                    const SizedBox(height: 10),
                    _buildCategorySelectors(),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Container(
                  child: _buildImagePicker(),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Change Image'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveUpdatedShoe,
        child: const Icon(Icons.save),
      ),
    );
  }
}
