import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';                    // ← This was missing

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Customer Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  final String baseUrl = "http://localhost:8000";   // Windows Desktop

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final String userMessage = _controller.text.trim();
    
    setState(() {
      _messages.add({"role": "user", "content": userMessage});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "message": userMessage,
          "conversation_id": "conv1",
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": data['message'] ?? "No response",
            "ui_type": data['ui_type'] ?? "message_only",
            "data": data['data'],
            "intent": data['intent'],
          });
        });
      } else {
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": "Server error: ${response.statusCode}"
          });
        });
      }
    } 
    on SocketException {
      _showError("❌ Connection Failed\n\nBackend is not running.\nMake sure FastAPI is started on port 8000.");
    } 
    on TimeoutException {
      _showError("⏱️ Request Timeout\nBackend is taking too long.");
    } 
    on HttpException {
      _showError("❌ HTTP Error");
    } 
    catch (e) {
      _showError("❌ Error: $e");
    } 
    finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.add({
        "role": "assistant",
        "content": message
      });
    });
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final bool isUser = msg['role'] == 'user';
    final String uiType = msg['ui_type'] ?? 'message_only';

    if (!isUser && uiType == 'hotel_page' && msg['data'] != null) {
      return HotelWidget(hotels: msg['data']['hotels'] ?? []);
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg['content'] ?? '',
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Customer Support Assistant"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "👋 Hello!\nHow can I help you today?\n\nTry: Show hotels in Dubai",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _buildMessage(_messages[index]),
                  ),
          ),
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Hotel Widget
class HotelWidget extends StatelessWidget {
  final List<dynamic> hotels;

  const HotelWidget({required this.hotels, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text("🏨 Available Hotels", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: hotels.length,
          itemBuilder: (context, index) {
            final hotel = hotels[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://picsum.photos/id/${20 + index}/80/80',
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(hotel['name'] ?? 'Hotel', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${hotel['location'] ?? ''} • ${hotel['price'] ?? ''}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [const Icon(Icons.star, color: Colors.amber, size: 20), Text(" ${hotel['rating'] ?? ''}")],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}