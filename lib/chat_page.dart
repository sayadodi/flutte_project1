import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_history_page.dart'; // Pastikan file ini dibuat

class ChatPage extends StatefulWidget {
  final String? initialMessage;

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
    loadChatHistory().then((loadedMessages) {
      setState(() {
        messages = loadedMessages;
      });

      if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
        sendMessage(widget.initialMessage!);
      }
    });
  }

  Future<void> sendMessage(String input) async {
    if (input.trim().isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'content': input});
      isLoading = true;
    });
    await saveChatHistory(messages);

    try {
      final response = await getOpenRouterResponse(input);
      setState(() {
        messages.add({'role': 'assistant', 'content': response});
      });
      await saveChatHistory(messages);
    } catch (e) {
      setState(() {
        messages
            .add({'role': 'assistant', 'content': '❗ Terjadi kesalahan:\n$e'});
      });
      await saveChatHistory(messages);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getOpenRouterResponse(String userInput) async {
    const String apiKey =
        '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'; // Ganti API kamu
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
      "max_tokens": 1000,
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content ?? '⚠️ Model tidak menghasilkan jawaban.';
    } else {
      throw Exception('Server error: ${response.body}');
    }
  }

  Future<void> saveChatHistory(List<Map<String, String>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_history', jsonEncode(messages));
  }

  Future<List<Map<String, String>>> loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('chat_history');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Map<String, String>.from(e)).toList();
    }
    return [];
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChatHistoryPage()),
              );
            },
          ),
        ],
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
                    msg['content'] ?? '',
                    style: const TextStyle(fontSize: 16),
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
