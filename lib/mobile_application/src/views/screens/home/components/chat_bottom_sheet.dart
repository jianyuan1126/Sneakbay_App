import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../service/open_ai_service.dart';

class ChatBottomSheet extends StatefulWidget {
  const ChatBottomSheet({super.key});

  @override
  _ChatBottomSheetState createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends State<ChatBottomSheet> {
  final TextEditingController _textController = TextEditingController();
  final OpenAIService _openAIService =
      OpenAIService('sk-proj-PkyAYKaFQJBzqLJYrIkUT3BlbkFJ0yvb64mB2XDGD0t5xncA');
  List<Map<String, String>> _chatMessages = [
    {
      'role': 'assistant',
      'content':
          'Hello! You can talk to me using keywords such as "shoes", "sneaker", "shoe", "brand", "model", "price". How can I assist you today?'
    }
  ];
  final List<String> _allowedKeywords = [
    "shoes",
    "sneaker",
    "shoe",
    "brand",
    "model",
    "price",
  ];

  void _sendMessage() async {
    final userMessage = _textController.text;

    // Check if the user's message contains any of the allowed keywords
    if (!_allowedKeywords.any((keyword) =>
        userMessage.toLowerCase().contains(keyword.toLowerCase()))) {
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'content':
              'Please use the keywords "shoes", "sneaker", "shoe", "brand", "model", "price", "size", or "condition" in your message to talk with SneakBot.',
        });
      });
      return;
    }

    setState(() {
      _chatMessages.add({'role': 'user', 'content': userMessage});
      _textController.clear();
    });

    try {
      final response = await _openAIService.sendMessage(userMessage);
      setState(() {
        _chatMessages.add({'role': 'assistant', 'content': response});
      });
    } catch (e) {
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'content': 'Failed to fetch response from OpenAI: $e',
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        left: 10.0,
        right: 16.0,
        top: 10.0,
        bottom: bottomInset,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Text(
                'Sneaker Suggestions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 48), // Placeholder to balance the layout
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final isUserMessage = message['role'] == 'user';
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: isUserMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUserMessage ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['content']!,
                          style: GoogleFonts.urbanist(
                              color:
                                  isUserMessage ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter your message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: 200,
                  // Change this to a specific width if needed
              child: ElevatedButton(
                onPressed: _sendMessage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(color: Colors.black),
                  ),
                ),
                child: Text(
                  'Send',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
