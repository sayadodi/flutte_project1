import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

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
        title: const Text("Riwayat Chat"),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: loadChatHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!;
          if (messages.isEmpty) {
            return const Center(child: Text("Belum ada riwayat chat."));
          }

          return ListView.builder(
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
                  color: isUser ? Colors.blue[100] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  msg['content'] ?? '',
                  style: const TextStyle(fontSize: 15),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
