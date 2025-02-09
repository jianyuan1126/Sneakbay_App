import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TermsUploadPage extends StatefulWidget {
  const TermsUploadPage({Key? key}) : super(key: key);

  @override
  _TermsUploadPageState createState() => _TermsUploadPageState();
}

class _TermsUploadPageState extends State<TermsUploadPage> {
  final TextEditingController _termsController = TextEditingController();
  final CollectionReference _contentCollection =
      FirebaseFirestore.instance.collection('content');

  @override
  void initState() {
    super.initState();
    _loadCurrentTerms();
  }

  Future<void> _loadCurrentTerms() async {
    DocumentSnapshot doc = await _contentCollection.doc('terms').get();
    if (doc.exists) {
      setState(() {
        _termsController.text = doc['text'];
      });
    }
  }

  Future<void> _saveTerms() async {
    await _contentCollection.doc('terms').set({
      'text': _termsController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terms of Use updated successfully.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Terms of Use'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _termsController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: 'Terms of Use',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveTerms,
              child: Text('Save Terms of Use'),
            ),
          ],
        ),
      ),
    );
  }
}
