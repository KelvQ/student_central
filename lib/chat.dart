import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadChatMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // Start from bottom
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildChatMessage(_messages[index]);
                },
              ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              child: Text(message.initials),
            ),
            SizedBox(width: 8.0),
          ],
          Container(
            decoration: BoxDecoration(
              color: message.isMe ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Text(message.message),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      // Save the message to the database
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('chats').add({
            'userId': user.uid,
            'userName': _userName,
            'message': messageText,
            'timestamp': Timestamp.now(),
          });
        }
      } catch (error) {
        print('Error saving chat message: $error');
        return;
      }

      // Add the message to the list
      setState(() {
        _messages.insert(0, ChatMessage(name: _userName, message: messageText, isMe: true, initials: _userInitials));
        _messageController.clear();
      });
    }
  }

  String _userName = '';
  String _userInitials = '';

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _userName = '${userData['firstName']} ${userData['lastName']}';
        _userInitials = '${userData['firstName'][0]}${userData['lastName'][0]}';
      });
    }
  }

  Future<void> _loadChatMessages() async {
    try {
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance.collection('chats').orderBy('timestamp', descending: true).get();
      setState(() {
        _messages.clear();
        _messages.addAll(chatSnapshot.docs.map((doc) => ChatMessage(
          name: doc['userName'],
          message: doc['message'],
          isMe: doc['userId'] == FirebaseAuth.instance.currentUser?.uid,
          initials: _calculateInitials(doc['userName']),
        )));
      });
    } catch (error) {
      print('Error loading chat messages: $error');
    }
  }

  String _calculateInitials(String userName) {
    List<String> names = userName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}';
    } else {
      return userName[0];
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String name;
  final String message;
  final bool isMe;
  final String initials;

  ChatMessage({required this.name, required this.message, this.isMe = false, required this.initials});
}