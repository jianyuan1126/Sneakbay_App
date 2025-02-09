import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FAQUploadPage extends StatefulWidget {
  const FAQUploadPage({super.key});

  @override
  _FAQUploadPageState createState() => _FAQUploadPageState();
}

class _FAQUploadPageState extends State<FAQUploadPage> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  Future<void> _addFAQ() async {
    if (_questionController.text.isNotEmpty &&
        _answerController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('faqs').add({
        'question': _questionController.text,
        'answer': _answerController.text,
      });

      _questionController.clear();
      _answerController.clear();
    }
  }

  Future<void> _updateFAQ(String id, String question, String answer) async {
    if (question.isNotEmpty && answer.isNotEmpty) {
      await FirebaseFirestore.instance.collection('faqs').doc(id).update({
        'question': question,
        'answer': answer,
      });
    }
  }

  Future<void> _deleteFAQ(String id) async {
    await FirebaseFirestore.instance.collection('faqs').doc(id).delete();
  }

  void _showEditDialog(
      String id, String currentQuestion, String currentAnswer) {
    _questionController.text = currentQuestion;
    _answerController.text = currentAnswer;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit FAQ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateFAQ(
                    id, _questionController.text, _answerController.text);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
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
        title: Text('Upload FAQ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: 'Question'),
            ),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Answer'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addFAQ,
              child: Text('Add FAQ'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('faqs').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final faqs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: faqs.length,
                    itemBuilder: (context, index) {
                      final faq = faqs[index];
                      return ListTile(
                        title: Text(faq['question']),
                        subtitle: Text(faq['answer']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showEditDialog(
                                  faq.id, faq['question'], faq['answer']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteFAQ(faq.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
