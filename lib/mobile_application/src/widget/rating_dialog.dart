import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final void Function(int rating, String? comment) onSubmit;

  const RatingDialog({required this.onSubmit, Key? key}) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  void _submitRating() {
    widget.onSubmit(_selectedRating,
        _commentController.text.isEmpty ? null : _commentController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      title: Center(
        child: Text(
          'Rate your order',
          style: TextStyle(color: Colors.black),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                ),
                color: Colors.amber,
                onPressed: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
              );
            }),
          ),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Leave a comment (optional)',
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        Container(
          width: double.infinity,
          child: TextButton(
            onPressed: _submitRating,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide(color: Colors.black),
              ),
            ),
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
