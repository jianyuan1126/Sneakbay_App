import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerPolicyUploadPage extends StatefulWidget {
  const SellerPolicyUploadPage({Key? key}) : super(key: key);

  @override
  _SellerPolicyUploadPageState createState() => _SellerPolicyUploadPageState();
}

class _SellerPolicyUploadPageState extends State<SellerPolicyUploadPage> {
  final TextEditingController _policyController = TextEditingController();
  final CollectionReference _contentCollection =
      FirebaseFirestore.instance.collection('content');

  @override
  void initState() {
    super.initState();
    _loadCurrentPolicy();
  }

  Future<void> _loadCurrentPolicy() async {
    DocumentSnapshot doc = await _contentCollection.doc('sellerPolicy').get();
    if (doc.exists) {
      setState(() {
        _policyController.text = doc['text'];
      });
    }
  }

  Future<void> _savePolicy() async {
    await _contentCollection.doc('sellerPolicy').set({
      'text': _policyController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seller Policy updated successfully.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Seller Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _policyController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Seller Policy',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePolicy,
              child: const Text('Save Seller Policy'),
            ),
          ],
        ),
      ),
    );
  }
}
