import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to fetch response from OpenAI');
    }
  }
}
