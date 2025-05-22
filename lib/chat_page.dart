import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String? initialMessage; // 💬 Pesan awal dari PredictionPage

  const ChatPage({super.key, this.initialMessage});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        sendMessage(widget.initialMessage!);
      });
    }
  }

  Future<void> sendMessage(String input) async {
    if (input.trim().isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'content': input});
      isLoading = true;
    });

    try {
      final response = await getOpenRouterResponse(input);
      setState(() {
        messages.add({'role': 'assistant', 'content': response});
      });
    } catch (e) {
      setState(() {
        messages
            .add({'role': 'assistant', 'content': '❗ Terjadi kesalahan:\n$e'});
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getOpenRouterResponse(String userInput) async {
    // 🔐 Ganti dengan API key kamu dari OpenRouter
    const String apiKey =
        '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';

    const String url = 'https://openrouter.ai/api/v1/chat/completions';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "mistralai/mistral-7b-instruct:free",
      "messages": [
        {"role": "user", "content": userInput}
      ],
      "temperature": 0.7,
      "max_tokens": 200,
    });

    print('➡️ Mengirim permintaan ke: $url');
    print('📝 Headers: $headers');
    print('📦 Body: $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        if (content == null || content.trim().isEmpty) {
          return '⚠️ Model tidak menghasilkan jawaban.';
        }

        return content;
      } else {
        throw Exception('Server merespons dengan error: ${response.body}');
      }
    } catch (e) {
      throw Exception('❌ Error mengirim permintaan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Konsultasi Mental"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                  child: Text(
                    '${msg['content']}',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => sendMessage(value),
                    decoration: InputDecoration(
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
