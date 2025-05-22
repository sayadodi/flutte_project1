import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  Future<void> sendMessage(String input) async {
    setState(() {
      messages.add({'role': 'user', 'content': input});
      isLoading = true;
    });

    try {
      final response = await getQwenResponseFromOpenRouter(input);
      setState(() {
        messages.add({'role': 'assistant', 'content': response});
      });
    } catch (e) {
      String errorMessage = e.toString();
      try {
        final errorData = jsonDecode(e.toString());
        errorMessage = errorData['error']['message'] ?? errorMessage;
      } catch (_) {}

      setState(() {
        messages.add({
          'role': 'assistant',
          'content': '❗ Terjadi kesalahan: $errorMessage'
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getQwenResponseFromOpenRouter(String userInput) async {
    const apiKey =
        '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';
    const url = 'https://openrouter.ai/api/v1/chat/completions ';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "qwen/qwen-turbo",
      "messages": [
        {"role": "user", "content": userInput}
      ]
    });

    // Debug permintaan
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat AI Konsultasi Mental'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman utama
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg['role'] == 'user';
                return Container(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.deepPurple[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(msg['content'] ?? ''),
                );
              },
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final text = _controller.text.trim();
                          if (text.isNotEmpty) {
                            sendMessage(text);
                            _controller.clear();
                          }
                        },
                  child: const Text('Kirim'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
