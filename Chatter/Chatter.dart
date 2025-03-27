import 'package:flutter/material.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Client-Server Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatScreen(),
    );
  }
}

class Message {
  final String sender; // 'client' or 'server'
  final String text;

  Message({required this.sender, required this.text});
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add(Message(sender: 'client', text: text));
    });

    _controller.clear();

    // Simulate server response after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        messages.add(Message(sender: 'server', text: 'Echo: $text'));
      });
    });
  }

  Widget _buildMessage(Message msg) {
    final isClient = msg.sender == 'client';
    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isClient ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Client-Server Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, index) => _buildMessage(messages[index]),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Type message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _sendMessage(_controller.text),
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
